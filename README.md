# Thirty & Thirsty · Beerlympics

Public site: https://calebheinzman.github.io/beerlympics/

A phone-friendly birthday event scoreboard hosted on GitHub Pages, with Supabase for shared results and organizer authentication.

## Using it

Guests open the site without signing in. The homepage shows overall standings and the event breakdown. Standings refresh every 10 seconds while the page is visible. Games includes the scoring guide, the current draft house rules and published event results.

The organizer opens **Organizer** and enters their password. No email field, email confirmation, or email link is used for normal sign-in. Initial password creation uses a private, single-use recovery link supplied in the Codex chat; it opens the password form directly. This uses the existing organizer's Supabase Auth identity internally, so database permissions remain tied to the same organizer UUID. Public account creation remains disabled. If a password is forgotten, request a fresh private setup link through this chat; never publish setup tokens in GitHub or the site.

The previous email-link login has been removed. Supabase still stores an email as the internal account identifier, but it is not part of the organizer's sign-in flow.

Choose a game, drag teams or use the up/down buttons, and publish. Corrections replace that event's previous placements, so points are never doubled. Results are written atomically as one complete order. Changes from another device cannot silently overwrite newer results. Use Clear results to remove an event's points.

Six initial teams are editable; teammate counts are intentionally not shown or tracked in the organizer interface. Add/remove teams before scoring begins (2–12 teams recommended); names and colors can change later. Games, rules, and equipment are editable in the score desk. Five indoor games are seeded, with draft house rules. Among Us was confirmed in the planning chat; the other four are starter options because early chat content wasn't exposed by the retrieval tool.

## Scoring

1st–12th: **15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1** points. All games carry equal weight. Equal overall totals share rank. Individual event ties must be resolved before publishing a complete order. Unplayed events award no points.

## Development and hosting

Node 22+. Run `npm ci`, `npm run dev`. Tests: `npm test`. Production: `npm run build`.

Pushing main runs tests and publishes dist using GitHub Actions / GitHub Pages. The build base is `/beerlympics/`; change it in package.json when renaming the repository.

The public Supabase URL and publishable key are in src/config.js. They are intentionally public; the database's row-level security grants writes only to the organizer UUID, not merely to signed-in users. No service-role key is shipped. SQL schema and seed data are in database/schema.sql and deployed through a Supabase migration. Do not rerun the initial schema on an existing database.

Supabase project: nbfvlycfvxzothkkjxiv. The organizer-setup edge function is disabled (410 with JWT verification enabled) after initial account provisioning. No email/password or setup token is stored in this repository.

Supabase free projects may pause when inactive; check the site before the party and restore the project from Supabase if needed. New projects were quoted at $0/month in the selected free organization. GitHub Pages hosts only the static frontend; Supabase stores all shared data.
