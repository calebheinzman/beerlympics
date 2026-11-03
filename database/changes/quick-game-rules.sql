-- Short player-facing house rules. Scoring controls remain in the organizer desk.
BEGIN;
UPDATE public.events SET name='Beer Pong', rules='Setup — Two players per team; six cups in a triangle. Fill target cups with water.
Play — Two shots per turn. Remove every cup you hit. No bounce bonuses.
Win — Clear the other team’s cups first. Play each team; most match wins takes the event.
Tie — Head-to-head, then cup difference, then a three-shot shootout.' WHERE id='7d862973-b5c0-40f8-9748-f3210317e2af';
UPDATE public.events SET name='Bodies', rules='Setup — Sit in a circle. Secretly choose one killer; everyone else is a survivor. Set the playing boundaries.
Play — Spread out with the lights low. The killer eliminates someone with a light shoulder tap. Eliminated players sit down and stay quiet.
Body! — Find someone eliminated? Call “Bodies!” Everyone stops, gathers, discusses, and votes one player out. Tied vote? Vote again.
Win — Survivors win by voting out the killer. The killer wins if only two players remain.' WHERE id='4f4021ad-50e6-466b-97ed-7be0fb8de008';
UPDATE public.events SET name='Rage Cage', rules='Setup — Team heats: same number of players per team. Stand in a circle; start two cups and balls opposite each other.
Play — Bounce your ball into your cup, then pass both clockwise. Make the first bounce? Pass to any teammate without a cup.
Stack — Finish while the next player is still bouncing? Stack your cup on theirs and count one stack. Reset to one cup and keep going.
Win — Most stacks in three minutes wins. Ties get a 60-second extra heat.' WHERE id='fc67a972-2770-49ce-b41b-7b870c64bc17';
UPDATE public.events SET name='Mario Kart', rules='Setup — Same speed, items, assists, and tracks for everyone.
Play — Rotate drivers between races. Each color gets the same number of races.
Win — Most in-game race points wins the tournament. We may play two separate tournaments; each has its own winners.' WHERE id='2b7aa002-a893-43ff-9f6c-b4bb0d732e4d';
UPDATE public.events SET name='Shuff and Pool', rules='Two games — Play both shuffleboard and pool. Each game has its own winners.
Shuff — Alternate sliding four pucks per side. Only the side with the furthest puck scores: count its pucks beyond the opponent’s best. A puck must fully cross a line to earn that zone. First to 15 wins.
Pool — Play 8-ball. Pocket a solid or stripe after the break to claim that group. Keep shooting after a legal pot. Clear your group, then call and sink the 8-ball.
Pool fouls — Scratch or miss every ball? Opponent gets ball in hand. Sink the 8 early, in the wrong pocket, or while scratching? You lose.' WHERE id='b47e4b7c-461a-4a23-ada2-db275ae1db4b';
UPDATE public.events SET name='King''s Cup', rules='Play — Sit in a circle; draw one card per turn. Penalties below add +1 to your tally. Drinking is optional.
A · Clap race — Everyone claps once. Last person: +1.
2 · Duel — Pick an opponent. Rock-paper-scissors; loser: +1. Replay ties.
3 · Me — Drawer: +1.
4 · Floor — Touch the floor. Last person: +1.
5 · Freeze — Freeze for five seconds. First to move or laugh: +1.
6 · Buzz — Count clockwise from 1; say “buzz” for multiples of 3. First mistake or three-second pause: +1.
7 · Heaven — Point up. Last person: +1.
8 · Mate — Pick a buddy. Until the next 8, either person’s card penalty gives the other +1 too. No chain reactions.
9 · Rhyme — Drawer picks a word; go around rhyming. Repeat, miss, or pause three seconds: +1.
10 · Categories — Pick a category (like pizza toppings). Go around naming items. Repeat, miss, or pause three seconds: +1.
J · Thumbs — Put a thumb on the table. Last person: +1.
Q · Reverse — Reverse the direction of play, then draw again.
K · Make a rule — Create one silly action rule, like speaking in a robot voice. Break it: +1. The next King replaces it.
Win — Play three rounds through the deck. Add each color team’s player tallies; lowest total wins. Tied teams play rock-paper-scissors to break the tie.' WHERE id='0782123e-bf5e-4a7c-af77-aa9a4a57ef8a';
COMMIT;
