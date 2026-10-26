// Additional engine/GUI mocks for the native inventory confirmation path.
let m_selectionModeItem=0,m_selectionModeActive=false;
function HideSelectionMode(){m_selectionModeActive=false;}
function UpdateGuiSceneEntityItems(){}
function UpdatePlayerStatisticsData(){}
function PaperdollUpdateItem(){PaperdollUpdateAll();}
inv.IsItemMask=()=>false;
_playerInv.isPotionItem=id=>inv.GetItemCategory(id)==='potion';
_playerInv.isPetardItem=()=>false;
_playerInv.isQuickslotItem=()=>false;
_playerInv.isFoodItem=id=>inv.GetItemCategory(id)==='edibles';
player.GetItemEquippedOnSlot=slot=>GetItemEquippedOnSlot(slot);
_playerInv.EquipItem=(id,slot)=>{
  if(!IsNativeExtraPotionDestination(slot)){calls.push(['rejected-native-slot',id,slot]);return false;}
  return EquipItem(id,slot);
};
function choose(id,slot){m_selectionModeItem=id;m_selectionModeActive=true;assert.equal(OnSelectionModeTargetChosen(slot),true);assert(!m_selectionModeActive);}

// Failure reproducer uses the actual original native callback and an engine
// that refuses the virtual enum, instead of accepting arbitrary mock slots.
reset();OnEquipItem(1,32,1);assert(grid.includes(2));m_selectionModeItem=2;m_selectionModeActive=true;
legacySelectionModeTargetChosen(32);
assert(calls.some(c=>c[0]==='rejected-native-slot'&&c[2]===32));
assert.equal(GetExtraPotionSlotItem(),1);assert(!grid.includes(2));assert(inv.IsIdValid(2));
console.log('Original callback reproduces the video: new potion disappears from the grid, old fifth-slot item stays, underlying potion remains owned.');

reset();choose(1,32);assert.equal(GetExtraPotionSlotItem(),1);assert(paper.includes(1));assert(!grid.includes(1));invariant();
choose(2,32);assert.equal(GetExtraPotionSlotItem(),2);assert(paper.includes(2));assert(grid.includes(1));assert(!grid.includes(2));invariant();
choose(2,32);assert.equal(GetExtraPotionSlotItem(),2);invariant();
assert(!calls.some(c=>c[0]==='rejected-native-slot'));
reset();OnEquipItem(1,32,1);items[2].ammo=0;choose(2,32);
assert.equal(GetExtraPotionSlotItem(),2);assert(paper.includes(2));assert(grid.includes(1));assert(!grid.includes(2));
assert.equal(items[2].ammo,0);assert.equal(items[1].ammo,5);
for(const slot of [5,6,19,20]){
  reset();slots[slot]=1;RefreshExtraPotionInventory();choose(1,32);
  assert.equal(GetExtraPotionSlotItem(),1);assert.equal(slots[slot],undefined);invariant();
  choose(1,slot);assert.equal(slots[slot],1);assert.equal(GetExtraPotionSlotItem(),0);invariant();
  reset();OnEquipItem(2,32,1);slots[slot]=1;RefreshExtraPotionInventory();choose(1,32);
  assert.equal(GetExtraPotionSlotItem(),1);assert.equal(slots[slot],2);invariant();
  choose(1,slot);assert.equal(slots[slot],1);assert.equal(GetExtraPotionSlotItem(),2);invariant();
  assert(!calls.some(c=>c[0]==='rejected-native-slot'));
}
for(const why of ['combat','blocked','other-inventory','invalid-type','invalid-id']){
  reset();OnEquipItem(1,32,1);
  if(why==='combat')combat=true;
  if(why==='blocked')blocked=true;
  if(why==='other-inventory')_currentInv={};
  const before=state(),beforeGrid=[...grid],beforePaper=[...paper];
  choose(why==='invalid-type'?99:why==='invalid-id'?0:2,32);
  assert.equal(state(),before,why);assert.deepEqual(grid,beforeGrid,why);assert.deepEqual(paper,beforePaper,why);
}
for(const why of ['fail-unequip','fail-swap-equip','fail-move-equip']){
  reset();OnEquipItem(2,32,1);slots[5]=1;RefreshExtraPotionInventory();
  if(why==='fail-unequip')failUnequip=1;
  if(why==='fail-swap-equip')failEquip=2;
  if(why==='fail-move-equip')failEquip=2;
  const before=state(),beforeGrid=[...grid],beforePaper=[...paper];
  choose(why==='fail-move-equip'?2:1,why==='fail-move-equip'?5:32);
  assert.equal(state(),before,why);assert.deepEqual(grid,beforeGrid,why);assert.deepEqual(paper,beforePaper,why);
}
console.log('Corrected actual callback: extra equip/replace, four native directions, invalid items, combat, blocked state and native failures preserve both items and their doses.');
