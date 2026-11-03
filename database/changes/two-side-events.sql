alter table public.events add column scoring_mode text not null default 'ranked' check(scoring_mode in ('ranked','sides'));
alter table public.events add column side_a uuid[] not null default '{}';
alter table public.events add column side_b uuid[] not null default '{}';
alter table public.events add column winner text check(winner in ('a','b','draw'));
create or replace function public.validate_event() returns trigger language plpgsql security invoker set search_path='' as $$
declare participants uuid[];
begin
 perform pg_advisory_xact_lock(300030);
 if new.scoring_mode='ranked' then
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
 new.updated_at=clock_timestamp();
 return new;
end; $$;
create or replace function public.protect_team_list() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 perform pg_advisory_xact_lock(300030);
 if exists(select 1 from public.events where cardinality(placements)>0 or winner is not null or cardinality(side_a)>0 or cardinality(side_b)>0) then
  raise exception 'Clear saved event results and side assignments before adding or removing teams.';
 end if;
 if tg_op='INSERT' and (select count(*) from public.teams)>=12 then raise exception 'Maximum 12 teams.'; end if;
 if tg_op='DELETE' then return old; end if;
 return new;
end; $$;
update public.events set rules=replace(rules,'Beerlympics','Birthday Olympics');
