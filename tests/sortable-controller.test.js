import test from 'node:test';
import assert from 'node:assert/strict';
import {createSortableController} from '../src/sortable-controller.js';

test('repeated list renders destroy each drag instance exactly once',()=>{
  const instances=[];
  const controller=createSortableController(()=>{
    let destroyed=false;
    const instance={destroy(){assert.equal(destroyed,false,'an instance must not be destroyed twice');destroyed=true},option(){},get destroyed(){return destroyed}};
    instances.push(instance);
    return instance;
  });
  for(let i=0;i<10;i++){
    controller.clear();
    controller.clear();
    controller.mount({},{});
  }
  assert.equal(instances.length,10);
  assert.ok(instances.slice(0,-1).every(i=>i.destroyed));
  assert.equal(instances.at(-1).destroyed,false);
  controller.clear();
  controller.clear();
  assert.ok(instances.every(i=>i.destroyed));
});

test('mounting a replacement disposes the previous list and supports save locking',()=>{
  const calls=[];
  const controller=createSortableController(el=>({destroy:()=>calls.push(['destroy',el]),option:(...args)=>calls.push(['option',el,...args])}));
  controller.mount('old',{});
  controller.mount('new',{});
  controller.setDisabled(true);
  controller.clear();
  controller.setDisabled(false);
  assert.deepEqual(calls,[['destroy','old'],['option','new','disabled',true],['destroy','new']]);
});
