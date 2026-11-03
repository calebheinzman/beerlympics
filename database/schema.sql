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
('Beer Pong','A little aim. A lot of team pride.',E'Setup — Two players per team; six cups in a triangle. Fill target cups with water.\nPlay — Two shots per turn. Remove every cup you hit. No bounce bonuses.\nWin — Clear the other team’s cups first. Play each team; most match wins takes the event.\nTie — Head-to-head, then cup difference, then a three-shot shootout.','Cups, ping-pong balls, table, water','25–35 min','◉',0),
('Bodies','A birthday mystery. Trust your instincts.',E'Setup — Sit in a circle. Secretly choose one killer; everyone else is a survivor. Set the playing boundaries.\nPlay — Spread out with the lights low. The killer eliminates someone with a light shoulder tap. Eliminated players sit down and stay quiet.\nBody! — Find someone eliminated? Call “Bodies!” Everyone stops, gathers, discusses, and votes one player out. Tied vote? Vote again.\nWin — Survivors win by voting out the killer. The killer wins if only two players remain.','Playing area and role cards or another way to assign roles; final setup to be confirmed','To be confirmed','✦',1),
('Rage Cage','Keep your cool. Keep the ball moving.',E'Setup — Team heats: same number of players per team. Stand in a circle; start two cups and balls opposite each other.\nPlay — Bounce your ball into your cup, then pass both clockwise. Make the first bounce? Pass to any teammate without a cup.\nStack — Finish while the next player is still bouncing? Stack your cup on theirs and count one stack. Reset to one cup and keep going.\nWin — Most stacks in three minutes wins. Ties get a 60-second extra heat.','Two ping-pong balls, stackable cups, table, timer','15–20 min','◎',2),
('Mario Kart','Your thirties have nothing on a blue shell.',E'Setup — Same speed, items, assists, and tracks for everyone.\nPlay — Rotate drivers between races. Each color gets the same number of races.\nWin — Most in-game race points wins the tournament. We may play two separate tournaments; each has its own winners.','Nintendo Switch, Mario Kart, TV, controllers','25–35 min','⚑',3),
('Shuff and Pool','Two tables. One combined event.',E'Two games — Play both shuffleboard and pool. Each game has its own winners.\nShuff — Alternate sliding four pucks per side. Only the side with the furthest puck scores: count its pucks beyond the opponent’s best. A puck must fully cross a line to earn that zone. First to 15 wins.\nPool — Play 8-ball. Pocket a solid or stripe after the break to claim that group. Keep shooting after a legal pot. Clear your group, then call and sink the 8-ball.\nPool fouls — Scratch or miss every ball? Opponent gets ball in hand. Sink the 8 early, in the wrong pocket, or while scratching? You lose.','Shuffleboard table and pucks; pool table, balls, cues, and chalk','45–60 min','◆',4);
-- Explicitly narrow Supabase's default table grants as well as enforcing RLS.
revoke insert,update,delete,truncate,references,trigger on public.teams,public.events from anon;
revoke truncate,references,trigger on public.teams,public.events from authenticated;
