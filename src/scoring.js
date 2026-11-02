export const POINTS = [15,12,10,9,8,7,6,5,4,3,2,1];
export const ordinal = n => `${n}${n%100>=11&&n%100<=13?'th':({1:'st',2:'nd',3:'rd'}[n%10]||'th')}`;
export function standings(teams,events){
 const completed=events.filter(e=>e.placements?.length);
 const rows=teams.map(t=>({...t,total:completed.reduce((sum,e)=>{const i=e.placements.indexOf(t.id);return sum+(i<0?0:POINTS[i]||0)},0),wins:completed.filter(e=>e.placements[0]===t.id).length,played:completed.filter(e=>e.placements.includes(t.id)).length})).sort((a,b)=>b.total-a.total||a.sort_order-b.sort_order);
 return rows.map((t,i)=>({...t,rank:i&&t.total===rows[i-1].total?rows.findIndex(x=>x.total===t.total)+1:i+1}));
}
export function validateOrder(order,teams){return order.length===teams.length && new Set(order).size===teams.length && order.every(id=>teams.some(t=>t.id===id));}
