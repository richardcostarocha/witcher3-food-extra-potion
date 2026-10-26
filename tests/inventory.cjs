const assert = require('node:assert/strict');
const EES_InvalidSlot=-1,EES_Potion1=5,EES_Potion2=6,EES_Potion3=19,EES_Potion4=20;
const InventoryMenuTab_Potions=3,InventoryMenuTab_Weapons=4,InventoryMenuTab_Ingredients=0,
 InventoryMenuTab_QuestItems=1,InventoryMenuTab_Default=2,InventoryMenuTab_Books=5;
const IFT_Weapons=4,IFT_AlchemyItems=3,IFT_Ingredients=0,IFT_QuestItems=1,IFT_Default=2,IFT_Books=5;
let extraPotionSlotItemName='', slots={}, grid=[], paper=[], blocked=false, combat=false;
let extraPotionSlotSelected=false,foodSlotSelected=false, failEquip=0, failUnequip=0, calls=[], refreshes=0;
let visibleTab=3,engineFilter=3,tabCache={},incrementalWrites=[];
const items=Object.fromEntries([1,2,3,4,5,6].map(id=>[id,{name:'item'+id,qty:1,ammo:5,tags:['Potion','SingletonItem'],category:'potion',position:-1}]));
items[6].category='edibles';
items[99]={name:'weapon',qty:1,ammo:5,tags:[],category:'weapon',position:0};
const inv={IsIdValid:id=>!!items[id],GetItemQuantity:id=>items[id]?.qty||0,
 GetItemCategory:id=>items[id]?.category||'',ItemHasTag:(id,t)=>!!items[id]?.tags.includes(t),
 GetItemName:id=>items[id]?.name||'',GetItemsByName:n=>Object.keys(items).map(Number).filter(id=>items[id].name===n)};
const thePlayer={SetUpdateQuickSlotItems(){},IsInCombat:()=>combat};
function GetItemSlot(id){return +Object.keys(slots).find(s=>slots[s]===id)||EES_InvalidSlot;}
function IsItemEquipped(id){return inv.IsIdValid(id)&&Object.values(slots).includes(id);}
function GetItemEquippedOnSlot(slot){return slots[slot]||0;}
function EquipItemInGivenSlot(id,slot){assert([5,6,19,20].includes(slot),'virtual enum reached engine');calls.push(['equip',id,slot]);if(id===failEquip)return false; const prev=GetItemSlot(id);if(prev!==-1)delete slots[prev];slots[slot]=id;return true;}
function ForceSoundAppearanceUpdate(){}
function UnequipItem(id){calls.push(['unequip',id]);if(id===failUnequip)return false;const s=GetItemSlot(id);if(s===-1)return false;delete slots[s];return true;}
function ItemToFlashUInt(id){return id;}
function AreManualEquipmentChangesBlocked(){return blocked;}
function ShowEquipmentChangeBlockedFeedback(){}
function showNotification(){}
function GetLocStringByKeyExt(s){return s;}
function OnPlaySoundEvent(){}
function PlayItemEquipSound(){}
function PlayItemUnequipSound(){}
function SetGridPosition(id,pos){items[id].position=pos;}
function GetGridPosition(id){return items[id].position;}
function getTabFromFilter(filter){return filter;}
class Obj{constructor(){this.v={};}CreateFlashObject(){return new Obj();}GetMemberFlashUInt(k){return this.v[k]||0;}SetMemberFlashInt(k,v){this.v[k]=v;}SetMemberFlashArray(k,v){this.v[k]=v;} }
class Arr{constructor(ids=[]){this.a=ids.map(id=>{const o=new Obj();o.v.id=id;return o;});}GetLength(){return this.a.length;}GetElementFlashObject(i){return this.a[i];}RemoveElement(i){this.a.splice(i,1);}PushBackFlashObject(o){this.a.push(o);} }
const m_flashValueStorage={CreateTempFlashObject:()=>new Obj(),CreateTempFlashArray:()=>new Arr(),
 SetFlashObject(k,o){if(k==='inventory.grid.player.itemUpdate'){incrementalWrites.push({tab:visibleTab,id:o.v.id});handleItemUpdate.call(nativeTabModule,o.v);}},
 SetFlashArray(k,arr){if(k==='inventory.grid.player.itemsUpdate')grid=Array.from(new Set([...grid,...arr.a.map(o=>o.v.id)]));}};
const _playerInv={SetInventoryFlashObjectForItem(id,obj){obj.v.id=id;},GetFilterTypeByItem(id){return items[id]?.category==='weapon'?4:items[id]?.category==='edibles'?2:3;},SetFilterType(filter){engineFilter=filter;},
 GetInventoryFlashArray(arr){arr.a=new Arr(Object.keys(items).map(Number).filter(id=>!IsItemEquipped(id)&&(engineFilter===3?items[id].category==='potion':engineFilter===4?items[id].category==='weapon':engineFilter===2?items[id].category==='edibles':false))).a;}};
const _inv=inv;let _currentInv=_playerInv;
function InventoryRemoveItem(id){grid=grid.filter(x=>x!==id);}
function PaperdollUpdateAll(){paper=[...Object.values(slots)];const extra=GetExtraPotionSlotItem();if(extra)paper.push(extra);refreshes++;}
function PopulateDataForTab(tab,arr){tabCache[tab]=arr.a.map(o=>o.v.id);if(visibleTab===tab)grid=[...tabCache[tab]];}
const mcTabList={get selectedIndex(){return visibleTab;},validateNow(){},getRendererAt(){return null;}};
const INVALIDATE_CONTEXT='context';function invalidate(){}function open(){}
function updateDataSurgicallyInCurrentTab(tab,objects){tabCache[tab]=Array.from(new Set([...(tabCache[tab]||[]),...objects.map(o=>o.id)]));}
const nativeTabModule={mcPlayerGrid:{updateItemData(o){grid=Array.from(new Set([...grid,o.id]));}}};
const nativeMenu={mcPlayerInventory:{onSetTabCalled(tab){visibleTab=tab;grid=[...(tabCache[tab]||[])];}}};
function FlashArgUInt(x){return x;}
const m_fxInventoryUpdateFilter={InvokeSelfOneArg(tab){forceSelectTab.call(nativeMenu,tab);}};
const player={GetExtraPotionSlotItem:(...a)=>GetExtraPotionSlotItem(...a),ExtraPotionSlotAccepts:(...a)=>ExtraPotionSlotAccepts(...a),
 SetExtraPotionSlotItem:(...a)=>SetExtraPotionSlotItem(...a),ClearExtraPotionSlotItem:(...a)=>ClearExtraPotionSlotItem(...a),
 IsNativeExtraPotionDestination:(...a)=>IsNativeExtraPotionDestination(...a),MoveExtraPotionToNativeSlot:(...a)=>MoveExtraPotionToNativeSlot(...a),
 FoodSlotAccepts:()=>false,GetFoodSlotItem:()=>0};
player.IsItemEquipped=(...a)=>IsItemEquipped(...a);
function GetWitcherPlayer(){return player;}
const InventorySlotType={Potion1:5,Potion2:6,Potion3:19,Potion4:20,Quickslot1:7,Quickslot2:14,Petard1:8,Petard2:9};
const CommonUtils={checkSlotsCompatibility:(...a)=>checkSlotsCompatibility(...a)};
const MenuInventory={IMS_Shop:1,IMS_Container:2,IMS_Stash:3};
class GameEvent{static CALL=1;constructor(type,name,args){this.name=name;this.args=args;}}
function int(x){return Math.trunc(x);}function uint(x){return x>>>0;}function nativeCanDrag(){return true;}
let data={cantUnequip:false},_cachedSelection=-1;
/* ACTUAL_METHODS */
function reset(){extraPotionSlotItemName='';slots={};grid=[];paper=[];visibleTab=engineFilter=3;tabCache={4:[99]};incrementalWrites=[];blocked=combat=false;failEquip=failUnequip=0;calls=[];extraPotionSlotSelected=foodSlotSelected=false;_currentInv=_playerInv;for(const i of Object.values(items)){i.ammo=5;i.qty=1;i.position=-1;}RefreshExtraPotionInventory();}
function state(){return JSON.stringify({extra:extraPotionSlotItemName,slots,ammo:Object.values(items).map(i=>i.ammo)});}
function invariant(){const extra=GetExtraPotionSlotItem();assert(!extra||!Object.values(slots).includes(extra));assert(!extra||!grid.includes(extra));assert.deepEqual(Object.values(items).map(i=>i.ammo),Array(Object.keys(items).length).fill(5));}
// Reproduce the actual R2 issue: cached potion tab is correct but the native
// incremental Flash handler also inserts the potion into the visible equipment grid.
reset();OnEquipItem(1,32,1);forceSelectTab.call(nativeMenu,4);extraPotionSlotSelected=true;
oldOnUnequipItem(1,-1);assert.equal(visibleTab,4);assert(grid.includes(1));assert(!tabCache[4].includes(1));
forceSelectTab.call(nativeMenu,3);assert(grid.includes(1));forceSelectTab.call(nativeMenu,4);assert(!grid.includes(1));
for(const tab of [0,1,2,3,4,5]){
 reset();OnEquipItem(1,32,1);forceSelectTab.call(nativeMenu,tab);extraPotionSlotSelected=true;const writes=incrementalWrites.length;
 assert(OnUnequipItem(1,-1));assert.equal(visibleTab,3);assert.equal(engineFilter,3);assert(grid.includes(1));assert(!tabCache[4].includes(1));assert.equal(incrementalWrites.length,writes);invariant();
 forceSelectTab.call(nativeMenu,4);assert(!grid.includes(1));forceSelectTab.call(nativeMenu,3);assert(grid.includes(1));
}
// Bag -> extra -> bag updates the actual filtered tab and incremental paths.
reset();assert(grid.includes(1));assert.equal(OnEquipItem(1,32,1),true);assert.equal(GetExtraPotionSlotItem(),1);assert(!grid.includes(1));assert(paper.includes(1));
InventoryUpdateItem(1);InventoryUpdateItems([1,2]);assert(!grid.includes(1));assert(grid.includes(2));
PopulateTabData(3);assert(!grid.includes(1));OnExtraPotionDragStarted(1);assert(extraPotionSlotSelected);assert.equal(OnUnequipItem(1,7),true);assert(grid.includes(1));assert.equal(GetExtraPotionSlotItem(),0);assert.equal(items[1].position,7);
// Replacing from the bag returns the former selection, never consumes doses.
reset();OnEquipItem(1,32,1);OnEquipItem(2,32,1);assert(grid.includes(1));assert(!grid.includes(2));invariant();
// Native compiled UI routes an extra drag over an occupied bag cell to OnSwapItems.
reset();OnEquipItem(1,32,1);items[2].position=7;OnExtraPotionDragStarted(1);
const source={owner:{},data:{id:1,slotType:32,equipped:32,quantity:1},getDragData(){return this.data;}};
const list={_dropMode:0,_currentDropRenderer:{index:7,data:{id:2,slotType:5,gridPosition:7},isEmpty:()=>false},
 removeUselessRows(){},dispatchItemClickEvent(){},dispatchEvent(e){assert.equal(e.name,'OnSwapItems');OnSwapItems(...e.args);}};
applyDrop.call(list,source);assert.equal(GetExtraPotionSlotItem(),2);assert(grid.includes(1));assert.equal(items[1].position,7);invariant();
assert.equal(canDrag.call({_slotTag:'potion5'}),true);assert.equal(canDrag.call({_slotTag:'food'}),false);data.cantUnequip=true;assert.equal(canDrag.call({_slotTag:'potion5'}),false);data.cantUnequip=false;
for(let s=0;s<=32;s++){const expected=[5,6,19,20,32].includes(s);assert.equal(checkSlotsCompatibility(32,s),expected);assert.equal(checkSlotsCompatibility(s,32),expected);}
for(let a=0;a<32;a++)for(let b=0;b<32;b++)assert.equal(checkSlotsCompatibility(a,b),oldCompatibility(a,b));
const fifth={_slotTag:'potion5',slotTag:'potion5',slotTagToType:()=>32};const native={_slotTag:'potion1',slotTag:'potion1',slotTagToType:()=>5};
assert(CheckSlotsType.call(native,32));assert(!CheckSlotsType.call({...native,slotTagToType:()=>3},32));assert(CheckSlotsType.call(fifth,5));
for(const s of [5,6,19,20]){
 reset();slots[s]=1;assert(OnEquipItem(1,32,1));assert.equal(slots[s],undefined);assert.equal(GetExtraPotionSlotItem(),1);invariant();
 assert(OnEquipItem(1,s,1));assert.equal(slots[s],1);assert.equal(GetExtraPotionSlotItem(),0);invariant();
 reset();OnEquipItem(2,32,1);slots[s]=1;assert(OnEquipItem(1,32,1));assert.equal(slots[s],2);assert.equal(GetExtraPotionSlotItem(),1);invariant();
 assert(OnEquipItem(1,s,1));assert.equal(slots[s],1);assert.equal(GetExtraPotionSlotItem(),2);invariant();
 // Tab picker calls the same player setter and respects unique native slots.
 reset();SetExtraPotionSlotItem(2);slots[s]=1;assert(SetExtraPotionSlotItem(1));RefreshExtraPotionInventory();assert.equal(slots[s],2);assert.equal(GetExtraPotionSlotItem(),1);invariant();
}
// Old duplicated associations and native assignments via other native menus.
reset();extraPotionSlotItemName='item1';slots[5]=1;assert.equal(GetExtraPotionSlotItem(),0);assert.equal(extraPotionSlotItemName,'');assert.equal(slots[5],1);
reset();SetExtraPotionSlotItem(1);const saved=extraPotionSlotItemName;extraPotionSlotItemName='';extraPotionSlotItemName=saved;RefreshExtraPotionInventory();assert(!grid.includes(1));assert.equal(GetExtraPotionSlotItem(),1);
reset();SetExtraPotionSlotItem(1);items[1].ammo=0;assert.equal(GetExtraPotionSlotItem(),1);items[1].ammo=5;assert.equal(GetExtraPotionSlotItem(),1);
// Existing native selectors also move/swap with the extra slot via EquipItem.
reset();SetExtraPotionSlotItem(1);slots[5]=2;assert(EquipItem(1,5));assert.equal(slots[5],1);assert.equal(GetExtraPotionSlotItem(),2);RefreshExtraPotionInventory();invariant();
// Failed/rejected operations leave the selection and native equipment intact.
for(const why of ['combat','blocked','other-inventory']){reset();SetExtraPotionSlotItem(1);RefreshExtraPotionInventory();if(why==='combat')combat=true;if(why==='blocked')blocked=true;if(why==='other-inventory')_currentInv={};const before=state();assert.equal(OnEquipItem(2,32,1),false);assert.equal(OnEquipItem(1,5,1),false);assert.equal(state(),before);}
reset();const before=state();assert.equal(SetExtraPotionSlotItem(6),false);assert.equal(MoveExtraPotionToNativeSlot(1,32),false);assert.equal(state(),before);
reset();SetExtraPotionSlotItem(2);slots[5]=1;failUnequip=1;const failA=state();assert.equal(SetExtraPotionSlotItem(1),false);assert.equal(state(),failA);
reset();SetExtraPotionSlotItem(2);slots[5]=1;failEquip=2;const failB=state();assert.equal(SetExtraPotionSlotItem(1),false);assert.equal(state(),failB);
reset();SetExtraPotionSlotItem(1);slots[5]=2;failEquip=1;const failC=state();assert.equal(MoveExtraPotionToNativeSlot(1,5),false);assert.equal(state(),failC);
console.log('Actual WS methods passed: grid equip/remove/replace/refresh, four native slot move/swap directions, Tab setter, saved selection, exhausted ammo, duplicate repair, restrictions and native failure rollback.');
