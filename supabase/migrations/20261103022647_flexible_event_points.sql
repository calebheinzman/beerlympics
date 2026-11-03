alter table public.events add column point_rounds jsonb not null default '[]'::jsonb;
alter table public.events drop constraint events_scoring_mode_check;
alter table public.events add constraint events_scoring_mode_check check(scoring_mode in ('ranked','sides','points'));
create or replace function public.validate_event() returns trigger language plpgsql security invoker set search_path='' as $$
declare participants uuid[]; r jsonb; k text; v jsonb;
begin
 perform pg_advisory_xact_lock(300030);
 if jsonb_typeof(new.point_rounds) is distinct from 'array' then raise exception 'Rounds must be an array.'; end if;
 if new.scoring_mode='points' then
  if cardinality(new.placements)>0 or cardinality(new.side_a)>0 or cardinality(new.side_b)>0 or new.winner is not null then raise exception 'Custom points cannot also have placement or side results.'; end if;
  if jsonb_array_length(new.point_rounds)>20 then raise exception 'Maximum 20 rounds.'; end if;
  for r in select value from jsonb_array_elements(new.point_rounds) loop
   if jsonb_typeof(r) is distinct from 'object' or jsonb_typeof(r->'name') is distinct from 'string' or char_length(trim(r->>'name')) not between 1 and 60 or jsonb_typeof(r->'scores') is distinct from 'object' then raise exception 'Every round needs a name and team points.'; end if;
   if (select count(*) from jsonb_object_keys(r->'scores'))<>(select count(*) from public.teams) or exists(select 1 from public.teams t where not ((r->'scores') ? t.id::text)) then raise exception 'Enter points for every team exactly once.'; end if;
   for k,v in select key,value from jsonb_each(r->'scores') loop
    if jsonb_typeof(v) is distinct from 'number' then raise exception 'Points must be whole numbers from 0 to 999.'; end if;
    if (v::text)::numeric<0 or (v::text)::numeric>999 or trunc((v::text)::numeric)<>(v::text)::numeric then raise exception 'Points must be whole numbers from 0 to 999.'; end if;
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
 if new.scoring_mode<>'points' and new.point_rounds<>'[]'::jsonb then raise exception 'Only custom-points games may have round points.'; end if;
 new.updated_at=clock_timestamp();
 return new;
end; $$;
create or replace function public.protect_team_list() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 perform pg_advisory_xact_lock(300030);
 if exists(select 1 from public.events where jsonb_array_length(point_rounds)>0 or cardinality(placements)>0 or winner is not null or cardinality(side_a)>0 or cardinality(side_b)>0) then
  raise exception 'Clear saved event results and side assignments before adding or removing teams.';
 end if;
 if tg_op='INSERT' and (select count(*) from public.teams)>=12 then raise exception 'Maximum 12 teams.'; end if;
 if tg_op='DELETE' then return old; end if;
 return new;
end; $$;
-- Existing saved results are preserved. Only unscored games change format.
update public.events set scoring_mode='points', rules=E'DRAFT COMBINED EVENT RULES\nPlay shuffleboard and pool as two rounds of one event. Agree each game’s match format before starting.\nSuggested award per game: 3 leaderboard points for a win and 0 for a loss. Tied winners can each receive 3. The organizer can edit awards for every color team.\nRecord Shuffleboard and Pool as separate rounds in this event. Round points add together; equal event totals share a place. No extra placement points are added.' where name='Shuffleboard & Pool' and cardinality(placements)=0 and winner is null;
update public.events set scoring_mode='points', rules=E'DRAFT TOURNAMENT RULES\nAgree the Mario Kart title, speed class, tracks, items, and assists before racing. Rotate drivers and give each color team equal racing opportunities.\nYou can play two tournaments. Record each tournament as its own round in this event. Suggested award: 3 leaderboard points for each tournament winner and 0 for a loss. Multiple or tied winners can receive the same points.\nThe organizer can edit each color team’s award in every round. The round awards add into one event total; equal totals share a place. In-game race scores do not go directly onto the birthday leaderboard.' where name='Mario Kart' and cardinality(placements)=0 and winner is null;
insert into public.events(name,summary,rules,equipment,duration,icon,sort_order) select 'King''s Cup','Draw a card. Keep your tally low.',E'DRAFT BIRTHDAY HOUSE RULES\nEveryone sits in a circle and takes turns drawing a card. Agree the card meanings before the first round.\nWhenever a card rule would normally require you to drink, add 1 to your game tally instead. This is a tally trigger; drinking is optional and does not affect scoring.\nPlan to play three rounds. Keep each player’s tally across all three rounds, then add player tallies within each color team. Confirm the participating players before starting so every team has equal scoring opportunities.\nLowest combined tally wins. If teams tie, play a short host-run tiebreaker before entering the final team order. These tallies determine placement only; the site awards the normal ranked-event leaderboard points.','Deck of playing cards and a way to record tallies','3 rounds','♠',coalesce(max(sort_order),-1)+1 from public.events where not exists(select 1 from public.events where name='King''s Cup') having not exists(select 1 from public.events where name='King''s Cup');
