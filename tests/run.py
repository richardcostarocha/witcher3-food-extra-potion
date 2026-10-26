from pathlib import Path
import re,subprocess,uuid
from ws import body,js
ROOT=Path(__file__).resolve().parents[1];SCRIPTS=ROOT/'mods/modSlotComida/content/scripts'
def run_template(code):
    folder=ROOT/'dist'/'test-runs'/uuid.uuid4().hex
    folder.mkdir(parents=True)
    test=folder/'test.cjs';test.write_text(code,encoding='utf-8',newline='\n');subprocess.run(['node',str(test)],check=True)
player=(SCRIPTS/'game/player/playerWitcher.ws').read_text('utf-8-sig')
inputs=(SCRIPTS/'game/player/playerInput.ws').read_text('utf-8-sig')
hud=(SCRIPTS/'game/gui/hud/modules/hudModuleItemInfo.ws').read_text('utf-8-sig')
inventory=(SCRIPTS/'game/gui/menus/inventoryMenu.ws').read_text('utf-8-sig')
names=['IsControllerConsumableExtraSelected','GetControllerConsumableIndex','GetControllerConsumableItemAt','GetControllerConsumableItem','GetNextControllerConsumableItem','CycleControllerConsumable','CanUseControllerConsumable','OpenControllerConsumableSelection','UseControllerExtraConsumable','OnPotionDrinkInput','OnPotionDrinkKeyboardsInput','FlipSelectedPotion']
code='\n'.join(js(player,n) for n in names)+'\n'+'\n'.join(js(inputs,n) for n in ('OnCommDrinkpotionUpperHeld','OnCommDrinkpotionLowerHeld','DrinkPotion'))
start=hud.index('            if (theInput.LastUsedGamepad())');end=hud.index('\n\t\t\telse\n\t\t\t{\n\t\t\t\tswitchAnimation = -1;',start)
run_template((ROOT/'tests/controller.cjs').read_text('utf-8').replace('/* ACTUAL_METHODS */',code).replace('/* ACTUAL_HUD_BRANCH */',hud[start:end]))
assert not re.search(r'\breturn\s*;',body(inventory,'OnSelectionModeTargetChosen')),'Boolean event cannot return void'
code='\n'.join(js(player,n) for n in ('EquipItem','IsNativeExtraPotionDestination','ExtraPotionSlotAccepts','SetExtraPotionSlotItem','ClearExtraPotionSlotItem','GetExtraPotionSlotItem','MoveExtraPotionToNativeSlot'))
code+='\n'+'\n'.join(js(inventory,n) for n in ('FilterExtraPotionFromInventoryGrid','RefreshExtraPotionInventory','OnExtraPotionDragStarted','PopulateTabData','InventoryUpdateItem','InventoryUpdateItems','OnEquipItem','OnUnequipItem','OnSwapItems','OnSelectionModeTargetChosen','UpdateInventoryFilter'))
legacy=(ROOT/'tests/fixtures/selection_before_fix.ws').read_text('utf-8');code+='\n'+js(legacy,'OnSelectionModeTargetChosen').replace('OnSelectionModeTargetChosen','legacySelectionModeTargetChosen',1)
old=(ROOT/'tests/fixtures/old_inventory_refresh.ws').read_text('utf-8')
code+='\n'+js(old,'OnUnequipItem').replace('OnUnequipItem','oldOnUnequipItem',1).replace('RefreshExtraPotionInventory','oldRefreshExtraPotionInventory')
code+='\n'+js(old,'RefreshExtraPotionInventory').replace('RefreshExtraPotionInventory','oldRefreshExtraPotionInventory',1)
ui=ROOT/'ui/src'
slot=(ui/'red/game/witcher3/slots/SlotPaperdoll.as').read_text('utf-8')
common=(ui/'red/game/witcher3/utils/CommonUtils.as').read_text('utf-8')
grid=(ui/'red/game/witcher3/slots/SlotsListGrid.as').read_text('utf-8')
tab=(ui/'red/game/witcher3/menus/inventory_menu/InventoryTabbedListModule.as').read_text('utf-8')
menu=(ui/'red/game/witcher3/menus/inventory_menu/MenuInventory.as').read_text('utf-8')
old_common=(ROOT/'tests/fixtures/common_compatibility_before_fix.as').read_text('utf-8')
code+='\n'+js(common,'checkSlotsCompatibility')+'\n'+js(old_common,'checkSlotsCompatibility').replace('function checkSlotsCompatibility','function oldCompatibility',1)
code+='\n'+js(slot,'CheckSlotsType')+'\n'+js(slot,'canDrag').replace('super.canDrag()','nativeCanDrag()')
code+='\n'+re.sub(r'(?<!\.)\b(dispatchEvent|dispatchItemClickEvent)\(',r'this.\1(',js(grid,'applyDrop'))
code+='\n'+js(tab,'handleItemUpdate')+'\n'+js(menu,'forceSelectTab')
code=re.sub(r'\((?:CR4\w+|CActor|W3\w+)\)','',code)
run_template((ROOT/'tests/inventory.cjs').read_text('utf-8').replace('/* ACTUAL_METHODS */',code)+'\n'+(ROOT/'tests/selection.cjs').read_text('utf-8'))
print('Food/controller tests passed. Engine mocks do not replace compilation/testing in the game.')
