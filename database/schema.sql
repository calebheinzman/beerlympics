-- Dedicated Beerlympics project. Public reads; only this organizer may write.
create table public.teams (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(trim(name)) between 1 and 40),
 color text not null check (color ~ '^#[0-9a-fA-F]{6}$'),
 size integer not null default 6 check (size between 1 and 20),
 sort_order integer not null default 0
);
create table public.events (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(trim(name)) between 1 and 80),
 summary text not null default '' check(char_length(summary)<=500),
 rules text not null default '' check(char_length(rules)<=10000),
 equipment text not null default '' check(char_length(equipment)<=1000),
 duration text not null default '15–20 min' check(char_length(duration)<=40),
 icon text not null default '★' check(char_length(icon)<=12),
 sort_order integer not null default 0,
 placements uuid[] not null default '{}',
 updated_at timestamptz not null default now()
);
alter table public.teams enable row level security;
alter table public.events enable row level security;
grant select on public.teams,public.events to anon,authenticated;
grant insert,update,delete on public.teams,public.events to authenticated;
create policy "Public teams" on public.teams for select to anon,authenticated using(true);
create policy "Public events" on public.events for select to anon,authenticated using(true);
create policy "Organizer teams" on public.teams for all to authenticated using((select auth.uid())='d644c5f2-6a2a-47f5-8cb6-d0b58f08c928'::uuid) with check((select auth.uid())='d644c5f2-6a2a-47f5-8cb6-d0b58f08c928'::uuid);
create policy "Organizer events" on public.events for all to authenticated using((select auth.uid())='d644c5f2-6a2a-47f5-8cb6-d0b58f08c928'::uuid) with check((select auth.uid())='d644c5f2-6a2a-47f5-8cb6-d0b58f08c928'::uuid);
create function public.validate_event() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 perform pg_advisory_xact_lock(300030);
 if cardinality(new.placements)>0 then
  if cardinality(new.placements)<>(select count(*) from public.teams) or
     cardinality(new.placements)<>(select count(distinct x) from unnest(new.placements) x) or
     exists(select 1 from unnest(new.placements) x where x is null or not exists(select 1 from public.teams t where t.id=x)) then
   raise exception 'Rank every team exactly once before saving.';
  end if;
 end if;
 new.updated_at=clock_timestamp();
 return new;
end; $$;
create trigger validate_event before insert or update on public.events for each row execute function public.validate_event();
create function public.protect_team_list() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 perform pg_advisory_xact_lock(300030);
 if exists(select 1 from public.events where cardinality(placements)>0) then
  raise exception 'Clear saved event results before adding or removing teams.';
 end if;
 if tg_op='INSERT' and (select count(*) from public.teams)>=12 then raise exception 'Maximum 12 teams.'; end if;
 if tg_op='DELETE' then return old; end if;
 return new;
end; $$;
create trigger protect_team_list before insert or delete on public.teams for each row execute function public.protect_team_list();
revoke execute on function public.validate_event() from public,anon,authenticated;
revoke execute on function public.protect_team_list() from public,anon,authenticated;
insert into public.teams(name,color,size,sort_order) values
 ('Red Team','#dc4e48',6,0),('Blue Team','#3979b9',6,1),('Yellow Team','#d6a82f',6,2),('Green Team','#488967',6,3),('Purple Team','#8c6ab0',6,4),('Orange Team','#df7839',6,5);
insert into public.events(name,summary,rules,equipment,duration,icon,sort_order) values
('Beer Pong','A little aim. A lot of team pride.', E'DRAFT HOUSE RULES\nChoose two players per matchup and rotate teammates between rounds. Use a six-cup triangle with water in the target cups; keep personal drinks separate.\nEach pair takes two shots per turn. A made cup is removed. No bounce bonuses or extra house rules unless agreed before the first match.\nPlay a round robin. Rank teams by match wins, then head-to-head for a two-team tie, then cup differential. Still tied? Three-shot shootout; repeat until separated.\nThe organizer enters the final team order after the event.','Cups, ping-pong balls, table, water','25–35 min','◉',0),
('Bodies Bodies Bodies','A birthday mystery. Trust your instincts.',E'DRAFT HOUSE RULES — FORMAT TO BE CONFIRMED\nThe host will explain the roles, round format, boundaries, and how to call a meeting before play begins.\nAgree how individual results translate into color-team placements before the first round. Give each color team equal opportunities to earn its result.\nEnter one final color-team order after the event. Final rules and the team-scoring format will be added here before play.','Playing area and role cards or another way to assign roles; final setup to be confirmed','To be confirmed','✦',1),
('Rage Cage','Keep your cool. Keep the ball moving.', E'DRAFT TEAM ADAPTATION\nRun timed team heats rather than the usual individual elimination circle. Every team fields the same number of players and uses the same setup.\nPlayers stand in a circle. Start two cups and two balls at opposite sides. Bounce a ball into your cup, then pass both one player clockwise. A successful first bounce may be passed to any teammate without a cup.\nWhen a player with a completed bounce catches the next player still bouncing, stack the cups and count one stack. Continue for three minutes. Reset the stack to one cup after each catch.\nMost stacks wins. Ties use a 60-second extra heat. Rotate players so everyone can take part.','Two ping-pong balls, stackable cups, table, timer','15–20 min','◎',2),
('Mario Kart','Your thirties have nothing on a blue shell.', E'DRAFT HOUSE RULES\nUse the same Mario Kart title, speed class, items, and assists for everyone. Choose the tracks before racing.\nRun balanced heats with one representative per color team where controller capacity allows. Otherwise rotate through an equal number of races with comparable opponents. Rotate drivers between races.\nRecord each team’s in-game race points across its scheduled races. Rank by total race points; ties use a one-race runoff between tied teams.\nEnter that final team order here. The site then awards the same Beerlympics points used by every other event.','Nintendo Switch, Mario Kart, TV, controllers','25–35 min','⚑',3),
('Shuffleboard & Pool','Two tables. One combined event.',E'DRAFT COMBINED EVENT RULES\nPlay both shuffleboard and pool. Agree the match format and house rules for each before starting, with equal playing opportunities for every color team.\nDetermine each color team’s placement in shuffleboard and in pool. Add those two placement numbers together; the lowest combined total wins this event.\nIf combined totals tie, the better single-game placement wins the tie. If still tied, play a short host-run playoff between the tied teams.\nEnter one final overall team order here. Birthday Olympics points are awarded once for the combined event, not separately for each game.','Shuffleboard table and pucks; pool table, balls, cues, and chalk','45–60 min','◆',4);
-- Explicitly narrow Supabase's default table grants as well as enforcing RLS.
revoke insert,update,delete,truncate,references,trigger on public.teams,public.events from anon;
revoke truncate,references,trigger on public.teams,public.events from authenticated;
