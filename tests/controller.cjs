const assert=require('node:assert/strict');
const EES_Potion1=1,EES_Potion2=2,EES_Potion3=3,EES_Potion4=4,EIAB_QuickSlots=7;
const EISPM_RadialMenuSlot1='slot1',EISPM_RadialMenuSlot2='slot2',EISPM_RadialMenuSlot3='slot3',EISPM_RadialMenuSlot4='slot4';
const MPTT_PotionUsePrimary=0,MPTS_Trigger=0,MPTS_Done=0,MPTT_PotionUseSecondary=0;
let selectedPotionSlotUpper,selectedPotionSlotLower,controllerUpperExtraSelected,controllerLowerFoodSelected;
let radialPopupShown,potionModeHold,potionUpperHeld,potionLowerHeld,radialPotionUpperTimer,radialPotionLowerTimer;
let state,stock,nativeSlots,extraId,foodId,events,scheduled,doubleTapRunning;
const theInput={LastUsedGamepad:()=>state.pad};
const thePlayer={IsCiri:()=>state.ciri,GetInventory:()=>inv};
const theGame={IsBlackscreenOrFading:()=>state.fade,IsDialogOrCutscenePlaying:()=>state.dialog,
 GetGuiManager:()=>({IsAnyMenu:()=>state.menu}),GetHud:()=>({GetHudModule:()=>({ForceShowElement:()=>events.push('hud')})}),
 GetTutorialSystem:()=>({switchTutorialManager:{inMotionPatternTutorial:false}})};
const inv={IsIdValid:id=>stock.has(id)};
function CheckRadialMenu(){return state.radial;}
function IsAlive(){return state.alive;}
function GetBIsInputAllowed(){return state.allowed;}
function GetInputHandler(){return {IsActionAllowed:()=>state.quick};}
function GetItemEquippedOnSlot(slot){return nativeSlots[slot]||0;}
function IsAnyItemEquippedOnSlot(slot){return inv.IsIdValid(GetItemEquippedOnSlot(slot));}
function GetExtraPotionSlotItem(){return inv.IsIdValid(extraId)?extraId:0;}
function GetFoodSlotItem(){return inv.IsIdValid(foodId)?foodId:0;}
function ConsumeExtraPotionSlot(){events.push('extra-attempt');if(state.toxic||!stock.get(extraId)?.ammo)return false;stock.get(extraId).ammo--;events.push('extra');return true;}
function ConsumeFoodSlot(){events.push('food');const item=stock.get(foodId);if(item&&!item.infinite){item.qty--;if(item.qty<=0){stock.delete(foodId);foodId=state.replacementFood||0;}}return true;}
function DrinkPotionFromSlot(slot){events.push('native-'+slot);}
function ExtraPotionSelectionPopup(){events.push('pick-extra');radialPopupShown=true;}
function FoodSelectionPopup(){events.push('pick-food');radialPopupShown=true;}
function PotionSelectionPopup(mode){events.push('pick-'+mode);radialPopupShown=true;}
function IsPressed(action){return action.kind==='down';}
function IsReleased(action){return action.kind==='up';}
function AddTimer(name){scheduled.add(name);}
function RemoveTimer(name){scheduled.delete(name);}
function GetSelectedPotionSlotUpper(){return selectedPotionSlotUpper;}
function GetSelectedPotionSlotLower(){return selectedPotionSlotLower;}
/* ACTUAL_METHODS */
const player={GetSelectedPotionSlotUpper,GetSelectedPotionSlotLower,OnPotionDrinkInput,FlipSelectedPotion,
 CycleControllerConsumable,GetControllerConsumableItem,GetNextControllerConsumableItem,
 OpenControllerConsumableSelection,GetRadialPopupShown:()=>radialPopupShown,AddTimer,RemoveTimer,
 IsPotionDoubleTapRunning:()=>doubleTapRunning,SetPotionDoubleTapRunning:b=>{doubleTapRunning=b;b?scheduled.add('double'):scheduled.delete('double');}};
function GetWitcherPlayer(){return player;}
function reset(){
 state={pad:true,radial:false,ciri:false,fade:false,dialog:false,menu:false,alive:true,allowed:true,quick:true,toxic:false};
 stock=new Map([[101,{ammo:3}],[102,{ammo:3}],[103,{ammo:3}],[104,{ammo:3}],[105,{ammo:3}],[106,{qty:2}]]);
 nativeSlots={1:101,2:102,3:103,4:104};extraId=105;foodId=106;
 selectedPotionSlotUpper=1;selectedPotionSlotLower=2;controllerUpperExtraSelected=false;controllerLowerFoodSelected=false;
 radialPopupShown=false;potionModeHold=true;potionUpperHeld=false;potionLowerHeld=false;radialPotionUpperTimer=false;radialPotionLowerTimer=false;
 events=[];scheduled=new Set();doubleTapRunning=false;
}
function down(upper){DrinkPotion({kind:'down',patternName:'test'},upper);}
function up(upper){DrinkPotion({kind:'up',patternName:'test'},upper);}
function hold(upper){(upper?OnCommDrinkpotionUpperHeld:OnCommDrinkpotionLowerHeld)({kind:'duration',patternName:'test'});}
function hud(prev1=0,prev2=0){
 let witcherPlayer=player,radialMenuOn=state.radial,m_currentItemOnSlot1=prev1,m_currentItemOnSlot2=prev2;
 let item1=0,item2=0,alterItem1=0,alterItem2=0,playerInv,switchAnimation;
 /* ACTUAL_HUD_BRANCH */
 return {item1,item2,alterItem1,alterItem2,switchAnimation};
}
reset();
assert.equal(GetControllerConsumableItem(true),101);assert.equal(GetControllerConsumableItem(false),102);
for(const [upper,expected] of [[true,[103,105,101]],[false,[104,106,102]]]){
 for(const id of expected){assert.equal(CycleControllerConsumable(upper),true);assert.equal(GetControllerConsumableItem(upper),id);}
}
assert.deepEqual(nativeSlots,{1:101,2:102,3:103,4:104});
console.log('Three-item cycles: upper 1/3/extra and lower 2/4/food; native equipment unchanged.');

reset();down(true);hold(true);hold(true);up(true);
assert.equal(GetControllerConsumableItem(true),103);assert.equal(events.filter(e=>e.startsWith('native')||e==='extra'||e==='food').length,0);
down(true);hold(true);up(true);assert.equal(GetControllerConsumableItem(true),105);
down(true);up(true);assert.equal(stock.get(105).ammo,2);assert.equal(events.filter(e=>e==='extra').length,1);
assert(!events.includes('native-3'));
down(true);hold(true);up(true);assert.equal(GetControllerConsumableItem(true),101);
down(true);up(true);assert(events.includes('native-1'));
down(false);hold(false);up(false);down(false);hold(false);up(false);
assert.equal(GetControllerConsumableItem(false),106);down(false);up(false);assert.equal(stock.get(106).qty,1);
assert.equal(events.filter(e=>e==='food').length,1);
console.log('Actual input handlers: hold advances once and never consumes; tap routes one dose to the selected native/extra/food item.');

reset();CycleControllerConsumable(true);CycleControllerConsumable(true);
state.toxic=true;OnPotionDrinkInput(true);assert.equal(stock.get(105).ammo,3);assert(!events.includes('extra'));
state.toxic=false;stock.get(105).ammo=0;OnPotionDrinkInput(true);assert.equal(GetControllerConsumableItem(true),105);
assert(!events.includes('native-3'));stock.get(105).ammo=3;OnPotionDrinkInput(true);assert.equal(stock.get(105).ammo,2);
for(const [key,value] of [['pad',false],['ciri',true],['fade',true],['dialog',true],['menu',true],['alive',false],['allowed',false],['quick',false]]){
 const old=state[key];state[key]=value;events=[];OnPotionDrinkInput(true);assert.equal(events.length,0,key);assert.equal(CycleControllerConsumable(true),false,key);state[key]=old;
}
radialPopupShown=true;events=[];OnPotionDrinkInput(true);assert.equal(events.length,0);radialPopupShown=false;
console.log('Virtual use blocks unsafe contexts, retains an exhausted singleton for meditation, and never falls back to a native dose.');

reset();state.pad=false;controllerUpperExtraSelected=true;controllerLowerFoodSelected=true;
OnPotionDrinkKeyboardsInput(EES_Potion1);OnPotionDrinkKeyboardsInput(EES_Potion4);
assert.deepEqual(events,['native-1','native-4']);
FlipSelectedPotion(true);assert.equal(selectedPotionSlotUpper,3);assert(controllerUpperExtraSelected);
console.log('Keyboard potion keys still target their native slots; controller selection survives an input-device switch.');

reset();stock.delete(103);assert.equal(CycleControllerConsumable(true),true);assert.equal(GetControllerConsumableItem(true),105);
stock.delete(105);extraId=0;assert.equal(hud().item1,101);assert.equal(controllerUpperExtraSelected,false);
nativeSlots={};stock.clear();controllerUpperExtraSelected=false;assert.equal(CycleControllerConsumable(true),false);
state.radial=true;assert(CycleControllerConsumable(true));assert(CycleControllerConsumable(true));assert(controllerUpperExtraSelected);
OpenControllerConsumableSelection(true);assert.equal(events.at(-1),'pick-extra');
console.log('Empty slots skipped outside radial; empty virtual slot remains reachable in radial for its picker.');

reset();state.radial=true;CycleControllerConsumable(true);CycleControllerConsumable(true);
down(true);assert(scheduled.has('DrinkRadialPotionUpper'));down(true);
assert(events.includes('pick-extra'));assert.equal(stock.get(105).ammo,3);assert(!scheduled.has('DrinkRadialPotionUpper'));
reset();state.radial=true;CycleControllerConsumable(false);CycleControllerConsumable(false);down(false);down(false);
assert(events.includes('pick-food'));assert.equal(stock.get(106).qty,2);
reset();state.radial=true;down(true);down(true);assert(events.includes('pick-slot1'));
console.log('Actual radial double-tap path opens the selected native, extra-potion or food picker without consuming.');

reset();potionModeHold=false;CycleControllerConsumable(true);CycleControllerConsumable(true);
down(true);assert(doubleTapRunning);down(true);assert(!doubleTapRunning);assert.equal(GetControllerConsumableItem(true),101);assert.equal(stock.get(105).ammo,3);
down(true);assert(doubleTapRunning);OnPotionDrinkInput(true);assert(events.includes('native-1'));
console.log('Existing double-tap switching preference also cycles all three items.');
reset();potionModeHold=false;state.radial=true;down(true);hold(true);up(true);down(true);hold(true);up(true);
assert.equal(GetControllerConsumableItem(true),105);assert.equal(stock.get(105).ammo,3);
down(true);down(true);assert(events.includes('pick-extra'));assert.equal(stock.get(105).ammo,3);
console.log('Radial hold cycles three choices even with outside double-tap mode; double-tap opens the picker.');

reset();CycleControllerConsumable(true);CycleControllerConsumable(true);CycleControllerConsumable(false);CycleControllerConsumable(false);
assert.deepEqual(hud(103,104),{item1:105,item2:106,alterItem1:101,alterItem2:102,switchAnimation:-1});
const saved={selectedPotionSlotUpper,selectedPotionSlotLower,controllerUpperExtraSelected,controllerLowerFoodSelected};
reset();Object.assign(globalThis,{});selectedPotionSlotUpper=saved.selectedPotionSlotUpper;selectedPotionSlotLower=saved.selectedPotionSlotLower;
controllerUpperExtraSelected=saved.controllerUpperExtraSelected;controllerLowerFoodSelected=saved.controllerLowerFoodSelected;
assert.equal(hud().item1,105);assert.equal(hud().item2,106);
stock.get(106).infinite=true;OnPotionDrinkInput(false);assert.equal(stock.get(106).qty,2);
stock.get(106).infinite=false;stock.get(106).qty=1;state.replacementFood=107;stock.set(107,{qty:4});OnPotionDrinkInput(false);
assert.equal(hud().item2,107);assert(controllerLowerFoodSelected);
console.log('Actual HUD branch shows selected virtual item and next preview; saved selection, infinite food and automatic replacement retained.');
reset();stock.delete(extraId);extraId=0;CycleControllerConsumable(true);
assert.equal(hud(101,102).switchAnimation,1);
console.log('Native two-icon swapping animation retained for true swaps, without showing a wrong previous icon in three-item cycles.');
