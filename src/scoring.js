// First place receives a larger step than the remaining ranked places.
export function rankedPoints(count){
 if(count<2)return [0];
 if(count===2)return [4,0];
 if(count===3)return [6,3,0];
 return [count+3,count,count-2,...Array.from({length:count-3},(_,i)=>count-4-i)];
}
export const SIDE_POINTS = {win:3,loss:0,draw:0};
export const ordinal = n => `${n}${n%100>=11&&n%100<=13?'th':({1:'st',2:'nd',3:'rd'}[n%10]||'th')}`;
export const isSideEvent = event => event.scoring_mode==='sides';
export const isPointsEvent = event => event.scoring_mode==='points';
export const pointTotals = event => Object.fromEntries(Object.keys(event.point_rounds?.[0]?.scores||{}).map(id=>[id,event.point_rounds.reduce((sum,r)=>sum+r.scores[id],0)]));
export const hasResult = event => isPointsEvent(event)?!!event.point_rounds?.length:isSideEvent(event)?['a','b','draw'].includes(event.winner):!!event.placements?.length;
export function eventResult(event,teamId){
 if(!hasResult(event))return null;
 if(isPointsEvent(event)){
  const totals=pointTotals(event),points=totals[teamId];
  if(points===undefined)return {label:'Did not play',points:0,played:false,win:false};
  const values=Object.values(totals),rank=1+values.filter(p=>p>points).length,tied=values.filter(p=>p===points).length>1;
  return {label:(tied?'Tied ':'')+ordinal(rank),points,played:true,win:rank===1&&points>0};
 }
 if(isSideEvent(event)){
  const side=(event.side_a||[]).includes(teamId)?'a':(event.side_b||[]).includes(teamId)?'b':null;
  if(!side)return {label:'Did not play',points:0,played:false,win:false};
  const draw=event.winner==='draw',win=event.winner===side;
  return {label:draw?'Draw':win?'Win':'Loss',points:draw?SIDE_POINTS.draw:win?SIDE_POINTS.win:SIDE_POINTS.loss,played:true,win,side};
 }
 const i=event.placements.indexOf(teamId);
 return i<0?{label:'Did not play',points:0,played:false,win:false}:{label:ordinal(i+1),points:rankedPoints(event.placements.length)[i]||0,played:true,win:i===0};
}
export function standings(teams,events){
 const rows=teams.map(t=>{
  const results=events.map(e=>eventResult(e,t.id)).filter(Boolean);
  return {...t,total:results.reduce((sum,r)=>sum+r.points,0),wins:results.filter(r=>r.win).length,played:results.filter(r=>r.played).length};
 }).sort((a,b)=>b.total-a.total||a.sort_order-b.sort_order);
 return rows.map((t,i)=>({...t,rank:i&&t.total===rows[i-1].total?rows.findIndex(x=>x.total===t.total)+1:i+1}));
}
export function validateOrder(order,teams){return order.length===teams.length && new Set(order).size===teams.length && order.every(id=>teams.some(t=>t.id===id));}
export function validateSides(sideA,sideB,winner,teams){
 const ids=[...sideA,...sideB];
 return sideA.length>0&&sideB.length>0&&['a','b','draw'].includes(winner)&&new Set(ids).size===ids.length&&ids.every(id=>teams.some(t=>t.id===id));
}

export function validatePointRounds(rounds,teams){
 return Array.isArray(rounds)&&rounds.length>0&&rounds.length<=20&&rounds.every(r=>
  typeof r.name==='string'&&r.name.trim().length>0&&r.name.length<=60&&r.scores&&
  Object.keys(r.scores).length===teams.length&&teams.every(t=>Number.isInteger(r.scores[t.id])&&r.scores[t.id]>=0&&r.scores[t.id]<=999));
}
