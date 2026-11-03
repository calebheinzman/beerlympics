# Birthday Olympics

Public site: https://calebheinzman.github.io/beerlympics/

A phone-friendly birthday event scoreboard hosted on GitHub Pages, with Supabase for shared results and organizer authentication.

## Using it

Guests open the site without signing in. The homepage shows overall standings and the event breakdown. Standings refresh every 5 seconds while the page is visible. Games includes the scoring guide, the current draft house rules and published event results.

The organizer opens **Organizer** and enters their password. No email field, email confirmation, or email link is used for normal sign-in. Initial password creation uses a private, single-use recovery link supplied in the Codex chat; it opens the password form directly. This uses the existing organizer's Supabase Auth identity internally, so database permissions remain tied to the same organizer UUID. Public account creation remains disabled. If a password is forgotten, request a fresh private setup link through this chat; never publish setup tokens in GitHub or the site.

The previous email-link login has been removed. Supabase still stores an email as the internal account identifier, but it is not part of the organizer's sign-in flow.

Choose a game, drag teams or use the up/down buttons, and publish. Corrections replace that event's previous placements, so points are never doubled. Results are written atomically as one complete order. Changes from another device cannot silently overwrite newer results. Use Clear results to remove an event's points.

Six initial teams are editable; teammate counts are intentionally not shown or tracked in the organizer interface. Add/remove teams before scoring begins (2–12 teams recommended); names and colors can change later. Games, rules, and equipment are editable in the score desk. Eight games are available: Beer Pong, Bodies, Boom Cup, Beerio Kart, Shuff & Pool, King's Cup, Betrayal, and Arms Up. Rules are concise, editable house rules. King’s Cup includes a full card key with action games and no personal questions. Shuff & Pool uses editable round awards, as does Beerio Kart. King's Cup is three rounds of low-tally scoring, followed by one ranked event result.

## Scoring

Ranked games use a non-linear scale with a larger first-place bonus and zero for last place:

- Four color teams: **7, 4, 2, 0**.
- Six color teams: **9, 6, 4, 2, 1, 0**.
- Other team counts use the same larger-first-step pattern; the site displays the applicable table.

Two-side events award **3 points to each winning color team and 0 to every losing color team**. A draw/no winner and sitting out award zero. This applies regardless of how many colors are grouped on either side. Assign colors to Side A, Side B, or Not playing, then choose the result. Choose scoring format in Add/Edit game; clear results before changing format.

Custom-points events let the organizer name rounds and enter 0–999 whole leaderboard points per team per round. Suggested awards are 3 for a win and 0 for a loss; tied winners can receive equal awards. All rounds add directly into one event total with no extra placement bonus. Add two rounds for two Beerio Kart tournaments or separate Shuffleboard and Pool rounds. Corrections replace saved rounds atomically. Guests can expand round-by-round points, and equal event totals share a place.

Equal overall totals share rank. Ranked-event ties must be resolved before publishing. Existing placements are recalculated with the current scoring scale. Simulations in `analysis/scoring-simulation.py` compare several scales with a fixed random seed and 100,000 trials per scenario; output is `analysis/scoring-simulation.json`. These equal-skill simulations are balance checks, not forecasts. End with a ranked event if comeback potential matters; any positive-point system can eventually be clinched after a sustained lead.

## Development and hosting

Node 22+. Run `npm ci`, `npm run dev`. Tests: `npm test`. Production: `npm run build`.

Pushing main runs tests and publishes dist using GitHub Actions / GitHub Pages. The build base is `/beerlympics/`; change it in package.json when renaming the repository.

The public Supabase URL and publishable key are in src/config.js. They are intentionally public; the database's row-level security grants writes only to the organizer UUID, not merely to signed-in users. No service-role key is shipped. SQL schema and seed data are in database/schema.sql and deployed through a Supabase migration. Do not rerun the initial schema on an existing database.

Supabase project: nbfvlycfvxzothkkjxiv. The organizer-setup edge function is disabled (410 with JWT verification enabled) after initial account provisioning. No email/password or setup token is stored in this repository.

Supabase free projects may pause when inactive; check the site before the party and restore the project from Supabase if needed. New projects were quoted at $0/month in the selected free organization. GitHub Pages hosts only the static frontend; Supabase stores all shared data.

The two-side event schema extension is in database/changes/two-side-events.sql and is deployed after the original schema. The GitHub repository URL is retained so existing shared links keep working.

The flexible-points extension and King's Cup seed are in supabase/migrations/20261103022647_flexible_event_points.sql, applied after the two-side extension.

Player-facing quick rules and renamed games are tracked in database/changes/quick-game-rules.sql. Apply after the flexible-points migration; this only changes names and rules, preserving results.

Current party house rules and final display names are in database/changes/party-house-rules.sql, applied after quick-game-rules.sql. Public game cards omit equipment/setup sections.

The two additional ranked events are seeded by database/changes/add-betrayal-and-survivor.sql. Betrayal game tallies (2 for mutual cooperation, 5/0 for a one-sided betrayal, 0/0 for mutual betrayal) determine final placement after six rounds; they do not add directly to the birthday leaderboard. Survivor uses one nominee per color and a five-minute cap with a tiebreaker.

Final short display names are applied by database/changes/short-event-names.sql.

Betrayal uses the dedicated `betrayal` scoring format from supabase/migrations/20261103030230_betrayal_round_tallies.sql: save up to six editable 0/2/5 rounds, calculate rank from their sum, then award the normal placement points. Tied totals share rank and award; a zero total earns zero. Round tallies and leaderboard awards appear separately in public results. Idle score desks reload updated drafts when polling; unsaved edits stay protected and saves check updated_at.

Boom Cup’s final display name is applied by database/changes/rename-boom-cup.sql.

Arms Up’s final display name is applied by database/changes/rename-arms-up.sql.
