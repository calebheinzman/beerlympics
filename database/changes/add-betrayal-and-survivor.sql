-- New ranked events. Internal game tallies determine the final placement only.
BEGIN;
INSERT INTO public.events(name,summary,rules,equipment,duration,icon,sort_order,scoring_mode)
SELECT 'Prisoner''s Dilemma: The Betrayal Game','Make a deal. Decide whether to keep it.',
E'Play — Pair up two color teams each round. Negotiate for up to one minute, then each team secretly writes Cooperate or Betray. Lock both choices before revealing together.\nBoth cooperate — Each team earns 3 game points.\nOne betrays — Betrayer earns 5; cooperator earns 0.\nBoth betray — Each team earns 1.\nWin — Play six rounds, changing opponents each round. Add your game points; highest total wins. Tied teams play one extra head-to-head round; still tied? Rock-paper-scissors.',
'Phones or paper and pens','20–30 min','⚖',coalesce(max(sort_order),-1)+1,'ranked'
FROM public.events HAVING NOT EXISTS(SELECT 1 FROM public.events WHERE name='Prisoner''s Dilemma: The Betrayal Game');
INSERT INTO public.events(name,summary,rules,equipment,duration,icon,sort_order,scoring_mode)
SELECT 'Survivor: Last One Standing','Steady hands. Stubborn shoulders.',
E'Play — Each team nominates one player. Hold both arms straight out at shoulder height, balancing two stacked empty cups on each open palm. No gripping cups or resting your arms.\nEach minute — The host adds a restriction: feet stay planted at minute 1, no cup adjustments at minute 2, no talking at minute 3, look straight ahead at minute 4. Earlier restrictions stay in effect.\nOut — Drop a cup, lower an arm, or break a restriction and you’re out. You can step out anytime.\nWin — Last player standing wins for their color team. Teams place by how long their player lasts.\nTime cap — Stop at five minutes. Remaining players use rock-paper-scissors to settle the remaining places. Simultaneous eliminations use the same tiebreaker.',
'Four empty plastic cups per player and a timer','5–10 min','♜',coalesce(max(sort_order),-1)+1,'ranked'
FROM public.events HAVING NOT EXISTS(SELECT 1 FROM public.events WHERE name='Survivor: Last One Standing');
COMMIT;
