-- Replace removed games and clear their results so old points cannot carry over.
BEGIN;
UPDATE public.events SET name='Bodies Bodies Bodies',
 summary='A birthday mystery. Trust your instincts.',
 rules='DRAFT HOUSE RULES — FORMAT TO BE CONFIRMED
The host will explain the roles, round format, boundaries, and how to call a meeting before play begins.
Agree how individual results translate into color-team placements before the first round. Give each color team equal opportunities to earn its result.
Enter one final color-team order after the event. Final rules and the team-scoring format will be added here before play.',
 equipment='Playing area and role cards or another way to assign roles; final setup to be confirmed',
 duration='To be confirmed',
 icon='✦',
 placements='{}'::uuid[], side_a='{}'::uuid[], side_b='{}'::uuid[], winner=NULL, scoring_mode='ranked'
WHERE id='4f4021ad-50e6-466b-97ed-7be0fb8de008' AND name='Flip Cup Relay';
UPDATE public.events SET name='Shuffleboard & Pool',
 summary='Two tables. One combined event.',
 rules='DRAFT COMBINED EVENT RULES
Play both shuffleboard and pool. Agree the match format and house rules for each before starting, with equal playing opportunities for every color team.
Determine each color team’s placement in shuffleboard and in pool. Add those two placement numbers together; the lowest combined total wins this event.
If combined totals tie, the better single-game placement wins the tie. If still tied, play a short host-run playoff between the tied teams.
Enter one final overall team order here. Birthday Olympics points are awarded once for the combined event, not separately for each game.',
 equipment='Shuffleboard table and pucks; pool table, balls, cues, and chalk',
 duration='45–60 min',
 icon='◆',
 placements='{}'::uuid[], side_a='{}'::uuid[], side_b='{}'::uuid[], winner=NULL, scoring_mode='ranked'
WHERE id='b47e4b7c-461a-4a23-ada2-db275ae1db4b' AND name='Among Us';
COMMIT;
