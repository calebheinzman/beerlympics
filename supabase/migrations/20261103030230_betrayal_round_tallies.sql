alter table public.events drop constraint events_scoring_mode_check;
alter table public.events add constraint events_scoring_mode_check check(scoring_mode in ('ranked','sides','points','betrayal'));
create or replace function public.validate_event() returns trigger language plpgsql security invoker set search_path='' as $$
declare participants uuid[]; r jsonb; k text; v jsonb;
begin
 perform pg_advisory_xact_lock(300030);
 if jsonb_typeof(new.point_rounds) is distinct from 'array' then raise exception 'Rounds must be an array.'; end if;
 if new.scoring_mode in ('points','betrayal') then
  if cardinality(new.placements)>0 or cardinality(new.side_a)>0 or cardinality(new.side_b)>0 or new.winner is not null then raise exception 'Custom points cannot also have placement or side results.'; end if;
  if jsonb_array_length(new.point_rounds)>20 then raise exception 'Maximum 20 rounds.'; end if;
  if new.scoring_mode='betrayal' and jsonb_array_length(new.point_rounds)>6 then raise exception 'Maximum six Betrayal rounds.'; end if;
  for r in select value from jsonb_array_elements(new.point_rounds) loop
   if jsonb_typeof(r) is distinct from 'object' or jsonb_typeof(r->'name') is distinct from 'string' or char_length(trim(r->>'name')) not between 1 and 60 or jsonb_typeof(r->'scores') is distinct from 'object' then raise exception 'Every round needs a name and team points.'; end if;
   if (select count(*) from jsonb_object_keys(r->'scores'))<>(select count(*) from public.teams) or exists(select 1 from public.teams t where not ((r->'scores') ? t.id::text)) then raise exception 'Enter points for every team exactly once.'; end if;
   for k,v in select key,value from jsonb_each(r->'scores') loop
    if jsonb_typeof(v) is distinct from 'number' then raise exception 'Points must be whole numbers from 0 to 999.'; end if;
    if (v::text)::numeric<0 or (v::text)::numeric>999 or trunc((v::text)::numeric)<>(v::text)::numeric then raise exception 'Points must be whole numbers from 0 to 999.'; end if;
    if new.scoring_mode='betrayal' and (v::text)::numeric not in (0,2,5) then raise exception 'Betrayal scores must be 0, 2, or 5.'; end if;
   end loop;
  end loop;
 elsif new.scoring_mode='ranked' then
  if cardinality(new.side_a)>0 or cardinality(new.side_b)>0 or new.winner is not null then
   raise exception 'Ranked games cannot also have side results.';
  end if;
  if cardinality(new.placements)>0 then
   if cardinality(new.placements)<>(select count(*) from public.teams) or
      cardinality(new.placements)<>(select count(distinct x) from unnest(new.placements) x) or
      exists(select 1 from unnest(new.placements) x where x is null or not exists(select 1 from public.teams t where t.id=x)) then
    raise exception 'Rank every team exactly once before saving.';
   end if;
  end if;
 else
  if cardinality(new.placements)>0 then raise exception 'Two-side games cannot also have ranked placements.'; end if;
  participants=new.side_a||new.side_b;
  if cardinality(participants)<>(select count(distinct x) from unnest(participants) x) or
     exists(select 1 from unnest(participants) x where x is null or not exists(select 1 from public.teams t where t.id=x)) then
   raise exception 'Each participating color team must be on exactly one side.';
  end if;
  if new.winner is not null and (cardinality(new.side_a)=0 or cardinality(new.side_b)=0) then
   raise exception 'Put at least one color team on each side before saving a result.';
  end if;
 end if;
 if new.scoring_mode not in ('points','betrayal') and new.point_rounds<>'[]'::jsonb then raise exception 'Only custom-points games may have round points.'; end if;
 new.updated_at=clock_timestamp();
 return new;
end; $$;
update public.events set scoring_mode='betrayal', rules=E'Play — Pair up two color teams each round. Negotiate for up to one minute, then each team secretly writes Cooperate or Betray. Lock both choices before revealing together.\nBoth cooperate — Each team earns 2 game points.\nOne betrays — Betrayer earns 5; cooperator earns 0.\nBoth betray — Both teams earn 0.\nWin — Play six rounds, changing opponents each round. Highest total wins; tied totals share a place.' where name='Betrayal' and cardinality(placements)=0 and winner is null and point_rounds='[]'::jsonb;
