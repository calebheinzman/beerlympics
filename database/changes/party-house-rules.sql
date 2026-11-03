-- Party house rules and display names; results remain unchanged.
BEGIN;
UPDATE public.events SET name='Beer Pong', rules='Play — Two shots per team per turn. Clear the other team’s cups to win.
Balls back — Both partners make their shots? Get both balls back.
Bounce — A made bounce removes two cups. You may swat after the bounce.
Trick shot — Recover a missed ball before it hits the floor and take an extra trick shot.
Heating up — Make two in a row and call “heating up.” Make your third and remove an extra cup. A miss resets the streak.
Same cup — Both partners sink the same cup? Remove an extra cup.
Rim shot — Hit one cup’s rim and land in another? Remove both cups.
Redemption — After the last cup, the other team gets one final turn to clear its remaining cups. Succeed and play three-cup overtime.' WHERE id='7d862973-b5c0-40f8-9748-f3210317e2af';
UPDATE public.events SET name='Bodies', rules='Play — One killer per color team keeps their eyes open; everyone else closes their eyes. Killers move around and eliminate opposing players with a light tap. Eliminated players sit down and stay quiet.
Body! — Find a body? Yell “Body!” Everyone freezes and opens their eyes.
Vote — Discuss who the killers are. Each team casts one vote; the player with the most votes is eliminated. Tied vote? Vote again.
Continue — Close your eyes again unless you’re a killer. Repeat until one team remains.
Team out — Your team loses if its killer is voted out or all its non-killer players are eliminated. Last team standing wins.' WHERE id='4f4021ad-50e6-466b-97ed-7be0fb8de008';
UPDATE public.events SET name='Rage Cage', rules='Play — Bounce your ball into your cup, then pass both clockwise. Make the first bounce? Pass to any teammate without a cup.
Stack — Finish while the next player is still bouncing? Stack your cup on theirs and count one stack. Reset to one cup and keep going.
Win — Most stacks in three minutes wins. Ties get a 60-second extra heat.' WHERE id='fc67a972-2770-49ce-b41b-7b870c64bc17';
UPDATE public.events SET name='Beerio Kart', rules='Race — Play a full tournament with a new driver for each race.
Beer — Finish your beer by the end of the race.
Controller down — Set your controller down before drinking. You cannot touch the controller while you drink.' WHERE id='2b7aa002-a893-43ff-9f6c-b4bb0d732e4d';
UPDATE public.events SET name='Shuff & Pool', rules='Two games — Play both shuffleboard and pool. Each game has its own winners.
Shuff — Alternate sliding four pucks per side. Only the side with the furthest puck scores: count its pucks beyond the opponent’s best. A puck must fully cross a line to earn that zone. First to 15 wins.
Pool — Play 8-ball. Pocket a solid or stripe after the break to claim that group. Keep shooting after a legal pot. Clear your group, then call and sink the 8-ball.' WHERE id='b47e4b7c-461a-4a23-ada2-db275ae1db4b';
UPDATE public.events SET name='King''s Cup', rules='Play — Sit in a circle; draw one card per turn. Penalties below add +1 to your tally. Drinking is optional.
A · Clap race — Everyone claps once. Last person: +1.
2 · Duel — Pick an opponent. Rock-paper-scissors; loser: +1. Replay ties.
3 · Me — Drawer: +1.
4 · Floor — Touch the floor. Last person: +1.
5 · Guys — All guys: +1.
6 · Chicks — All girls: +1.
7 · Heaven — Point up. Last person: +1.
8 · Mate — Pick a buddy. Whenever either of you gets a penalty, the other gets +1 too.
9 · Rhyme — Drawer picks a word; go around rhyming. Repeat, miss, or pause three seconds: +1.
10 · Categories — Pick a category (like pizza toppings). Go around naming items. Repeat, miss, or pause three seconds: +1.
J · Thumbs — Put a thumb on the table. Last person: +1.
Q · Question Master — You’re the Question Master until the next Q. Anyone who answers your questions gets +1.
K · Make a rule — Create one silly action rule, like speaking in a robot voice. Break it: +1. The next King replaces it.
Win — Play three rounds through the deck. Add each color team’s player tallies; lowest total wins. Tied teams play rock-paper-scissors to break the tie.' WHERE id='0782123e-bf5e-4a7c-af77-aa9a4a57ef8a';
COMMIT;
