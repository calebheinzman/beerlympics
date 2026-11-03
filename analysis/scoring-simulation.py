"""Reproducible balance checks. Synthetic tournament results, not party predictions."""
import json, random, statistics
from pathlib import Path
TRIALS=100_000

def simulate(points, side_win, seed=3011, small_finale=False):
 n=len(points); rng=random.Random(seed); schedule=['ranked']*3+['sides']*2 if small_finale else ['ranked','sides','ranked','sides','ranked']
 first_leader_champion=first_last_champion=clinched_after_three=0
 viable=[]
 for _ in range(TRIALS):
  order=list(range(n));rng.shuffle(order)
  scores=[0]*n
  for i,t in enumerate(order):scores[t]=points[i]
  first_leader=order[0];first_last=order[-1]
  for game in range(1,5):
   if schedule[game]=='ranked':
    rng.shuffle(order)
    for i,t in enumerate(order):scores[t]+=points[i]
   else:
    rng.shuffle(order)
    for t in order[:n//2]:scores[t]+=side_win
   if game==2:
    remaining=sum(max(points)-min(points) if k=='ranked' else side_win for k in schedule[game+1:])
    lead=max(scores);viable.append(sum(lead-s<=remaining for s in scores)/n)
    sorted_scores=sorted(scores,reverse=True)
    clinched_after_three+=sorted_scores[0]-sorted_scores[1]>remaining
  best=max(scores)
  first_leader_champion+=scores[first_leader]==best
  first_last_champion+=scores[first_last]==best
 return {'ranked_points':points,'side_win_loss':[side_win,0],'trials':TRIALS,
 'schedule':','.join(schedule)+'; independent equally likely results',
 'first_game_winner_finishes_tied_or_outright_first_pct':round(first_leader_champion/TRIALS*100,2),
 'first_game_last_finishes_tied_or_outright_first_pct':round(first_last_champion/TRIALS*100,2),
 'average_teams_still_within_remaining_point_swing_after_3_pct':round(statistics.mean(viable)*100,2),
 'title_clinched_after_3_of_5_pct':round(clinched_after_three/TRIALS*100,2)}

results={}
for n,chosen,linear in [(4,[7,4,2,0],[6,4,2,0]),(6,[9,6,4,2,1,0],[10,8,6,4,2,0])]:
 candidates={'large_winner':([12,8,4,0] if n==4 else [15,12,10,9,8,7],6),'even_steps':(linear,3),'chosen':(chosen,3)}
 results[str(n)]={name:simulate(pts,side) for name,(pts,side) in candidates.items()}
 results[str(n)]['chosen_with_two_small_games_last']=simulate(chosen,3,small_finale=True)
# Exact worst-case bounds for an early event (no randomness needed).
results['bounds']={'four_teams':{'ranked_max_swing':7,'two_side_max_swing':3,'max_recoverable_deficit_with_two_ranked_games_left':14},'six_teams':{'ranked_max_swing':9,'two_side_max_swing':3,'max_recoverable_deficit_with_two_ranked_games_left':18},'limits':'No fixed positive point system guarantees a comeback late in an event. Repeated wins can clinch a title. Results above assume independent equal-skill outcomes; tied champions count for both percentages.'}
path=Path(__file__).with_name('scoring-simulation.json');path.write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
