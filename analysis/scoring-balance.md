# Birthday Olympics scoring balance

Implemented scoring:

| Event | Awards |
| --- | --- |
| Ranked, 4 colors | 7, 4, 2, 0 |
| Ranked, 6 colors | 9, 6, 4, 2, 1, 0 |
| Two sides, any group sizes | 3 per winning color; 0 per losing color |
| Two-side draw / not participating | 0 |

First place is a larger step: +3 over second, compared with +2 from second to third. The two-side award is intentionally smaller than a full ranked win. It is awarded per color team, not multiplied by the number of partner colors.

Reducing all awards proportionally does not change the competition. The gaps between places, the relative value of side events, and event order matter more than whether the largest number is 7 or 12.

## Simulation

100,000 tournaments per scenario, 800,000 total, fixed seed 3011. Four and six colors; independently random, equally likely ranked orders and balanced winning-side membership. No draws or persistent skill differences. Final tied champions count as champions. These synthetic trials compare scoring behavior, not actual guest performance.

Selected scale, with events ordered ranked / sides / ranked / sides / ranked:

| Measure | 4 colors | 6 colors |
| --- | --- | --- |
| First game's winner finishes tied or outright first | 54.97% | 47.36% |
| First game's last-place team finishes tied or outright first | 9.49% | 5.07% |
| Title already clinched after 3 of 5 games | 2.02% | 0.56% |
| Average fraction of teams within the remaining point swing after 3 games | 86.58% | 82.77% |

If the two small side events are left until the end, the title is already clinched after three games in 21.31% / 21.88% of these trials. **Finish with a ranked game** to keep more comeback opportunities open. The point table itself cannot compensate for a very low-value finale.

Exact bounds: one side game changes a pair of opposing teams' gap by at most 3 points. A ranked game can change it by 7 (four colors) or 9 (six colors). With two ranked games remaining, a 14- or 18-point deficit can theoretically be erased against a leader who finishes last both times. Tying that maximum is not the same as overtaking it. No positive-point system can guarantee that a team remains able to come back after repeated losses late in the event.

Full candidate comparisons and reproducible code: scoring-simulation.json and scoring-simulation.py in this folder.
