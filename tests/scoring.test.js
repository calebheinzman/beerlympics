import test from 'node:test';import assert from 'node:assert/strict';import {standings,validateOrder,ordinal} from '../src/scoring.js';
const teams=['red','blue','green'].map((id,i)=>({id,sort_order:i}));
test('placements award points and edits replace previous results',()=>{let events=[{placements:['blue','red','green']}];assert.equal(standings(teams,events)[0].total,6);events[0].placements=['red','green','blue'];assert.equal(standings(teams,events)[0].id,'red');assert.equal(standings(teams,events).find(t=>t.id==='blue').total,0);});
test('unplayed events award no points; equal totals share rank',()=>{const rows=standings(teams,[{placements:[]}]);assert.deepEqual(rows.map(t=>t.rank),[1,1,1]);assert.equal(rows[0].played,0);const tied=standings(teams,[{placements:['red','blue','green']},{placements:['blue','red','green']}]);assert.deepEqual(tied.map(t=>t.rank),[1,1,3]);});
test('reject missing, duplicate and unknown teams',()=>{assert.ok(validateOrder(['red','blue','green'],teams));for(let order of [['red','blue'],['red','red','green'],['red','blue','pink']])assert.equal(validateOrder(order,teams),false)});
test('ordinal suffixes',()=>assert.deepEqual([1,2,3,4,11,12,13,21].map(ordinal),['1st','2nd','3rd','4th','11th','12th','13th','21st']));

test('two-side games give each winning color 3 and every losing color zero',async()=>{
 const {eventResult}=await import('../src/scoring.js');
 const all=['red','blue','green','yellow','purple','orange'].map((id,sort_order)=>({id,sort_order}));
 const event={scoring_mode:'sides',side_a:['red','blue','green'],side_b:['yellow','purple','orange'],winner:'a',placements:[]};
 const rows=standings(all,[event]);
 assert.deepEqual(rows.map(t=>t.total),[3,3,3,0,0,0]);
 assert.equal(rows.find(t=>t.id==='red').wins,1);
 assert.equal(eventResult(event,'yellow').label,'Loss');
 assert.equal(rows[0].total-rows.at(-1).total,3);
});
test('side-only participants, draws, corrections and mixed event totals',async()=>{
 const {eventResult}=await import('../src/scoring.js');
 const e={scoring_mode:'sides',side_a:['red'],side_b:['blue'],winner:'draw'};
 assert.deepEqual(standings(teams,[e]).map(t=>t.total),[0,0,0]);
 assert.equal(eventResult(e,'green').played,false);
 assert.equal(standings(teams,[e]).find(t=>t.id==='red').wins,0);
 e.winner='b';
 assert.equal(standings(teams,[e]).find(t=>t.id==='blue').total,3);
 assert.equal(standings(teams,[e,{placements:['red','blue','green']}]).find(t=>t.id==='red').total,6);
 e.winner=null;
 assert.equal(standings(teams,[e]).find(t=>t.id==='red').total,0);
});
test('side membership rejects overlap, empty sides and unknown teams',async()=>{
 const {validateSides}=await import('../src/scoring.js');
 assert.ok(validateSides(['red'],['blue'],'a',teams));
 assert.equal(validateSides(['red'],['red'],'a',teams),false);
 assert.equal(validateSides(['red'],[],'a',teams),false);
 assert.equal(validateSides(['red'],['pink'],'b',teams),false);
 assert.equal(validateSides(['red'],['blue'],'',teams),false);
});

 test('four- and six-team scales reward first place disproportionately and finish at zero',async()=>{const {rankedPoints}=await import('../src/scoring.js');assert.deepEqual(rankedPoints(4),[7,4,2,0]);assert.deepEqual(rankedPoints(6),[9,6,4,2,1,0]);for(let n=2;n<=12;n++){const p=rankedPoints(n);assert.equal(p.length,n);assert.equal(p.at(-1),0);assert.ok(p.every((v,i)=>i===0||p[i-1]>v));if(n>=4)assert.ok(p[0]-p[1]>p[1]-p[2]);}});

test('four color teams grouped as two sides still give losers zero',async()=>{const {eventResult}=await import('../src/scoring.js');const e={scoring_mode:'sides',side_a:['red','blue'],side_b:['green','yellow'],winner:'a'};for(const id of e.side_a)assert.equal(eventResult(e,id).points,3);for(const id of e.side_b)assert.equal(eventResult(e,id).points,0);e.winner='b';for(const id of e.side_a)assert.equal(eventResult(e,id).points,0);for(const id of e.side_b)assert.equal(eventResult(e,id).points,3);});

test('custom rounds add once, allow tied winners, and replace corrected awards',async()=>{
 const {eventResult,hasResult}=await import('../src/scoring.js');
 const e={scoring_mode:'points',point_rounds:[{name:'Pool',scores:{red:3,blue:3,green:0}},{name:'Shuffleboard',scores:{red:0,blue:0,green:3}}]};
 assert.ok(hasResult(e));
 assert.deepEqual(standings(teams,[e]).map(t=>[t.total,t.rank]),[[3,1],[3,1],[3,1]]);
 assert.equal(eventResult(e,'red').label,'Tied 1st');
 e.point_rounds[1].scores.red=3;
 assert.equal(standings(teams,[e])[0].total,6);
 assert.equal(eventResult(e,'red').label,'1st');
 assert.equal(standings(teams,[e,{placements:['green','red','blue']}]).find(t=>t.id==='red').total,9);
 e.point_rounds=[];
 assert.equal(hasResult(e),false);
 assert.deepEqual(standings(teams,[e]).map(t=>t.total),[0,0,0]);
});
test('two tournaments may have distinct winners and the same total, with zero for losses',async()=>{
 const {eventResult}=await import('../src/scoring.js');
 const e={scoring_mode:'points',point_rounds:[{name:'Tournament 1',scores:{red:3,blue:0,green:0}},{name:'Tournament 2',scores:{red:0,blue:3,green:0}}]};
 assert.equal(eventResult(e,'red').points,3);assert.equal(eventResult(e,'blue').points,3);
 assert.equal(eventResult(e,'green').points,0);assert.equal(eventResult(e,'green').win,false);
 assert.equal(eventResult(e,'blue').label,'Tied 1st');
});
test('round validation rejects missing teams, fractions, negatives and unnamed rounds',async()=>{
 const {validatePointRounds}=await import('../src/scoring.js');
 const valid={name:'Round 1',scores:{red:3,blue:3,green:0}};
 assert.ok(validatePointRounds([valid],teams));
 for(const rounds of [[],[{...valid,name:''}],[{...valid,scores:{red:3,blue:0}}],[{...valid,scores:{red:-1,blue:0,green:0}}],[{...valid,scores:{red:0.5,blue:0,green:0}}],[{...valid,scores:{red:NaN,blue:0,green:0}}]])assert.equal(validatePointRounds(rounds,teams),false);
});
