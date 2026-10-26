package red.game.witcher3.menus.inventory_menu
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import red.core.CoreMenu;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.game.witcher3.constants.EInputDeviceType;
   import red.game.witcher3.controls.InputFeedbackButton;
   import red.game.witcher3.events.ControllerChangeEvent;
   import red.game.witcher3.managers.ContextInfoManager;
   import red.game.witcher3.managers.InputFeedbackManager;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.menus.character_menu.CharacterModeBackground;
   import red.game.witcher3.menus.common.CheckboxListMode;
   import red.game.witcher3.menus.common.PlayerStatsModule;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotInventoryGrid;
   import red.game.witcher3.slots.SlotPaperdoll;
   import red.game.witcher3.slots.SlotsListGrid;
   import red.game.witcher3.slots.SlotsTransferManager;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.data.DataProvider;
   import scaleform.clik.events.ButtonEvent;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.ui.InputDetails;
   
   [SWF(width="1920", height="1080", backgroundColor="#cccccc", frameRate="22")]
   public class MenuInventory extends CoreMenu
   {
      
      public static const STATE_CHARACTER:String = "CharacterInventory";
      
      public static const STATE_HORSE:String = "HorseInventory";
      
      public static const IMS_Invalid:int = -1;
      
      public static const IMS_Player:int = 0;
      
      public static const IMS_Shop:int = 1;
      
      public static const IMS_Container:int = 2;
      
      public static const IMS_HorseInventory:int = 3;
      
      public static const IMS_Stash:int = 4;
      
      public static const INV_SORT_MODE_INVALID:int = -1;
      
      public static const INV_SORT_MODE_TYPE:int = 0;
      
      public static const INV_SORT_MODE_PRICE:int = 1;
      
      public static const INV_SORT_MODE_WEIGHT:int = 2;
      
      public static const INV_SORT_MODE_DURABILTIY:int = 3;
      
      public static const INV_SORT_MODE_RARITY:int = 4;
      
      protected static const HORSE_GRID_X:Number = 1293;
      
      protected static const CONTAINER_GRID_X:Number = 758;
      
      private var mcContainerGridModule:ModuleContainer;
      
      public var mcPlayerInventory:InventoryTabbedListModule;
      
      private var mcPaperDollModule:ModulePaperdoll;
      
      public var mcHorsePaperdollModule:ModuleHorsePaperdoll;
      
      public var mcPlayerStatistics:PlayerStatsModule;
      
      public var mcSortingMode:CheckboxListMode;
      
      public var pinnedCraftingModule:PinnedCraftingInfoModule;
      
      public var currentSortingMode:int;
      
      public var mcSelectionMode:CharacterModeBackground;
      
      public var moduleMerchantInfo:ModuleMerchantInfo;
      
      public var containerGrid:Sprite;
      
      public var mcOverburdened:MovieClip;
      
      public var tooltipLeftAnchor:DisplayObject;
      
      public var tooltipRightAnchor:DisplayObject;
      
      public var mcShopPaperdollAnchor:DisplayObject;
      
      public var mcHorseModelAnchor:MovieClip;
      
      public var mcCharacterModelAnchor:MovieClip;
      
      public var mcCharacterRenderer:MovieClip;
      
      public var mcShopBackground:MovieClip;
      
      public var mcStashBackground:MovieClip;
      
      public var mcContainerAnchor:MovieClip;
      
      public var mcPaperdollAnchor:MovieClip;
      
      public var btnSort:InputFeedbackButton;
      
      public var btnSortChange:InputFeedbackButton;
      
      public var dropSlot:InventoryDropArea;
      
      public var mcSelectionModeBackground:MovieClip;
      
      public var tooltipPaperdollAnchor:MovieClip;
      
      protected var _filteringMode:Boolean;
      
      protected var _sellJunkEnable:Boolean;
      
      private var _btn_stats_id:int = -1;
      
      private var _btn_sort_id:int = -1;
      
      private var _btn_switch_sections:int = -1;
      
      private var _defaultTabIdx:int = -1;
      
      private var _inventoryMode:int = -1;
      
      public var mcVitalityStat:PlayerStatInfo;
      
      public var mcToxicityStat:PlayerStatInfo;
      
      public var mcPanelDetailedStats:PlayerDetailedStatsPanel;
      
      public var mcPanelGeneralStats:PlayerGeneralStatsPanel;
      
      private var _rendererController:CharacterRendererController;
      
      public var playerGridInitX:Number;
      
      public var playerGridXOffset:Number = 155;
      
      private const TICK_DELAY:int = 100;
      
      private var _timer:Timer;
      
      private var _inputSymbolIDA:int = -1;
      
      private var tickTimeDelta:int = 0;
      
      private var junkHoldTimeRequired:Number = 0.5;
      
      private var junkHold:Boolean = false;
      
      private var junkTimerStart:Number;
      
      private var dontReactOnNextGPA:Boolean = false;
      
      protected var _isTooltipHidden:Boolean = false;
      
      public function MenuInventory()
      {
         SlotBase.AUTO_SHOW_COLLAPSED_ICON = true;
         SlotBase.OPT_MODE = false;
         super();
         this.playerGridInitX = this.mcPlayerInventory.x;
         this._rendererController = new CharacterRendererController(this.mcCharacterRenderer,this);
         this._rendererController.setCenterAnchor(450,50);
         this._rendererController.setDefaultAnchor(this.mcCharacterModelAnchor.x,50);
         this._rendererController.addFadeOutComponent(this.mcPlayerInventory);
         this._rendererController.addFadeOutComponent(this.mcVitalityStat);
         this._rendererController.addFadeOutComponent(this.mcToxicityStat);
         this._rendererController.addFadeOutComponent(this.btnSort);
         this._rendererController.addFadeOutComponent(this.btnSortChange);
         this._rendererController.leftInfoPanel = this.mcPanelGeneralStats;
         this._rendererController.rightInfoPanel = this.mcPanelDetailedStats;
         this.mcVitalityStat.label = "[[vitality]]";
         this.mcVitalityStat.isPositive = true;
         this.mcVitalityStat.type = PlayerStatInfo.TYPE_VITALITY;
         this.mcVitalityStat.visible = false;
         this.mcVitalityStat.dangerLimit = 0.3;
         this.mcToxicityStat.label = "[[attribute_name_toxicity]]";
         this.mcToxicityStat.isPositive = false;
         this.mcToxicityStat.type = PlayerStatInfo.TYPE_TOXICITY;
         this.mcToxicityStat.visible = false;
         this.mcToxicityStat.dangerLimit = 0.7;
         this.mcToxicityStat.isPercentage = true;
         this.mcCharacterRenderer.addEventListener(Event.ACTIVATE,this.handleCharStatsShown,false,0,true);
         this.mcCharacterRenderer.addEventListener(Event.DEACTIVATE,this.handleCharStatHidden,false,0,true);
         this.mcPlayerInventory.tabsAutoAlign = true;
         this.mcPlayerInventory.gridMaskOffset = 0;
         this.mcPlayerInventory.noDelay = false;
         this.dropSlot.disabled = true;
         this.mcCharacterRenderer.mouseChildren = this.mcCharacterRenderer.mouseEnabled = false;
         this.mcSelectionModeBackground.mouseChildren = this.mcSelectionModeBackground.mouseEnabled = false;
         this.mcSelectionMode.mcBackground = this.mcSelectionModeBackground;
         this.mcSelectionModeBackground.alpha = 0;
         addEventListener(Event.ADDED_TO_STAGE,this.__setPerspectiveProjection_);
         this.__setProp_mcPlayerInventory_Scene1_Inventory_Grid_0();
      }
      
      public function __setPerspectiveProjection_(evt:Event) : void
      {
         root.transform.perspectiveProjection.fieldOfView = 122.353662;
         root.transform.perspectiveProjection.projectionCenter = new Point(960,540);
      }
      
      override public function setCurrentModule(value:int) : void
      {
         super.setCurrentModule(value);
         if(value == 0)
         {
            this.mcPlayerInventory.focused = 1;
            this.mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
            this.mcPlayerInventory.mcPlayerGrid.selectedIndex = -1;
            this.mcPlayerInventory.mcPlayerGrid.validateNow();
         }
      }
      
      public function SetSellJunkEnable(newEnable:Boolean) : *
      {
         if(this._sellJunkEnable == newEnable)
         {
            return;
         }
         this._sellJunkEnable = newEnable;
         if(newEnable)
         {
            this._inputSymbolIDA = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_A,KeyCode.SPACE,"panel_inventory_sellJunk",true,0.5);
         }
         else
         {
            InputFeedbackManager.removeButton(this,this._inputSymbolIDA);
         }
         InputFeedbackManager.updateButtons(this);
      }
      
      private function handleCharStatsShown(event:Event) : void
      {
         if(_contextMgr)
         {
            _contextMgr.enableInputFeedbackShowing(false,true);
            _contextMgr.blockTooltips(true);
            _contextMgr.blockModeSwitching = true;
         }
         this.dropSlot.disabled = true;
         if(this._btn_sort_id != -1)
         {
            InputFeedbackManager.removeButton(this,this._btn_sort_id);
            this._btn_sort_id = -1;
         }
         if(this._btn_switch_sections != -1)
         {
            InputFeedbackManager.removeButton(this,this._btn_switch_sections);
            this._btn_switch_sections = -1;
         }
         this.mcPlayerInventory.enabled = false;
         this.mcPlayerInventory.refreshButtons();
      }
      
      private function handleCharStatHidden(event:Event) : void
      {
         if(_contextMgr)
         {
            _contextMgr.enableInputFeedbackShowing(true,true);
            _contextMgr.blockTooltips(false);
            _contextMgr.blockModeSwitching = false;
         }
         this.dropSlot.disabled = false;
         if(this._btn_sort_id == -1)
         {
            this._btn_sort_id = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_RSTICK_HOLD,-1,"panel_button_common_sort_items");
         }
         if(this._btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
         {
            this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
         }
         this.mcPlayerInventory.enabled = true;
         this.mcPlayerInventory.refreshButtons();
      }
      
      private function CreateItemSectionData(id:uint, start:uint, end:uint, label:String, border:MovieClip = null) : ItemSectionData
      {
         var itemSectionData:ItemSectionData = new ItemSectionData();
         itemSectionData.setData(id,start,end,label,border);
         return itemSectionData;
      }
      
      override protected function get menuName() : String
      {
         return "InventoryMenu";
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         var gridSectionsList:Array = [];
         var sectionsData:GridTabSections = new GridTabSections();
         sectionsData.push(4,this.CreateItemSectionData(0,0,3,"[[panel_inventory_tab_weapons]]"));
         sectionsData.push(4,this.CreateItemSectionData(1,4,8,"[[panel_inventory_tab_armors]]"));
         sectionsData.push(3,this.CreateItemSectionData(0,0,2,"[[panel_alchemy_tab_oils]]"));
         sectionsData.push(3,this.CreateItemSectionData(1,3,5,"[[panel_alchemy_tab_potions]]"));
         sectionsData.push(3,this.CreateItemSectionData(2,6,8,"[[panel_alchemy_tab_bombs]]"));
         sectionsData.push(2,this.CreateItemSectionData(0,0,5,"[[item_category_edibles]]"));
         sectionsData.push(2,this.CreateItemSectionData(1,6,8,"[[panel_inventory_tab_horse]]"));
         sectionsData.push(1,this.CreateItemSectionData(0,0,3,"[[item_category_quest_items]]"));
         sectionsData.push(1,this.CreateItemSectionData(1,4,8,"[[item_category_misc]]"));
         sectionsData.push(0,this.CreateItemSectionData(0,0,4,"[[panel_inventory_tab_crafting]]"));
         sectionsData.push(0,this.CreateItemSectionData(1,5,8,"[[panel_inventory_tab_alchemy]]"));
         this.mcPlayerInventory.setItemSections(sectionsData);
         SlotsTransferManager.getInstance().enableDragWithPan(true);
         this.initDataBindings();
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnConfigUI"));
         this.initTooltips();
         this.mcSelectionMode.visible = false;
         this.mcSelectionMode.addEventListener(CharacterModeBackground.ACCEPT,this.handleSelectionModeAcceptClick,false,0,true);
         this.mcSelectionMode.addEventListener(CharacterModeBackground.CANCEL,this.handleSelectionModeCancelClick,false,0,true);
         var inputMgr:InputManager = InputManager.getInstance();
         inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE,this.handleControllerChanged,false,0,true);
         if(this.mcSortingMode)
         {
            this.mcSortingMode.hideCB = this.sortingModeClosed;
            this.mcSortingMode.closeCB = this.sortingModeApply;
            this.mcSortingMode.mcTitle.text = "[[gui_panel_sort_by]]";
            this.mcSortingMode.disallowCloseOnNoCheck = true;
            this.mcSortingMode.allowUnchecking = false;
            this.mcSortingMode.exclusiveCheckList = true;
            this.mcSortingMode.extraCloseMode = true;
         }
         this.btnSort.label = "[[panel_button_common_quick_sort_items]]";
         this.btnSort.setDataFromStage("",KeyCode.Q);
         this.btnSort.addEventListener(ButtonEvent.CLICK,this.handleSortClick,false,0,true);
         this.btnSort.clickable = true;
         this.btnSort.validateNow();
         this.btnSortChange.label = "[[panel_button_common_sort_items]]";
         this.btnSortChange.setDataFromStage("",KeyCode.F);
         this.btnSortChange.addEventListener(ButtonEvent.CLICK,this.showSortingModeChange,false,0,true);
         this.btnSortChange.clickable = true;
         this.btnSortChange.x = this.btnSort.x + this.btnSort.actualWidth;
         this._btn_sort_id = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_RSTICK_HOLD,-1,"panel_button_common_sort_items");
         this._timer = new Timer(this.TICK_DELAY);
         this._timer.addEventListener(TimerEvent.TIMER,this.handleTickEvent,false,0,true);
         this._timer.start();
         this.tickTimeDelta = getTimer();
         if(this._btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
         {
            this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
         }
      }
      
      override protected function handleControllerChanged(event:ControllerChangeEvent) : void
      {
         super.handleControllerChanged(event);
         this._rendererController.handleControllerChanged(event);
         if(this._btn_stats_id != -1)
         {
            InputFeedbackManager.removeButton(this,this._btn_stats_id);
            this._btn_stats_id = InputFeedbackManager.appendButton(this,this.getShowAdvancedStatsGpadNavCode(),KeyCode.C,"panel_common_show_advanced_statistics");
         }
         if(this.mcPlayerInventory.enabled)
         {
            if(this._btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
            {
               this._btn_switch_sections = InputFeedbackManager.appendButton(this,NavigationCode.GAMEPAD_R3,-1,"panel_button_common_jump_sections");
            }
            else if(this._btn_switch_sections != -1)
            {
               InputFeedbackManager.removeButton(this,this._btn_switch_sections);
               this._btn_switch_sections = -1;
            }
         }
         InputFeedbackManager.updateButtons(this);
      }
      
      private function handleTickEvent(event:TimerEvent) : void
      {
         var res:int = getTimer();
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnTickEvent",[int(res - this.tickTimeDelta)]));
         this.tickTimeDelta = res;
      }
      
      public function setPaperdollPreviewIcon(slotType:int, show:Boolean) : void
      {
         if(!this.mcPaperDollModule)
         {
            return;
         }
         var targetSlot:SlotPaperdoll = this.mcPaperDollModule.mcPaperdoll.getRendererForSlotType(slotType) as SlotPaperdoll;
         if(Boolean(targetSlot) && Boolean(targetSlot.mcPreviewIcon))
         {
            targetSlot.mcPreviewIcon.visible = show;
         }
      }
      
      override public function setMenuState(value:String) : void
      {
         super.setMenuState(value);
      }
      
      public function setSortingMode(value:int, firstSortString:String, secondSortString:String, thirdSortString:String, forthSortString:String, fifthSortString:String) : void
      {
         var defaultData:Array = null;
         this.currentSortingMode = value;
         defaultData = [{
            "key":"TypeSort",
            "label":firstSortString,
            "isChecked":value == INV_SORT_MODE_TYPE
         },{
            "key":"PriceSort",
            "label":secondSortString,
            "isChecked":value == INV_SORT_MODE_PRICE
         },{
            "key":"WeightSort",
            "label":thirdSortString,
            "isChecked":value == INV_SORT_MODE_WEIGHT
         },{
            "key":"DurabilitySort",
            "label":forthSortString,
            "isChecked":value == INV_SORT_MODE_DURABILTIY
         },{
            "key":"RaritySort",
            "label":fifthSortString,
            "isChecked":value == INV_SORT_MODE_RARITY
         }];
         this.mcPlayerInventory.mcPlayerGrid.setCurrentSort(this.currentSortingMode);
         this.mcSortingMode.setData(defaultData);
         this.mcSortingMode.validateNow();
      }
      
      protected function initTooltips() : void
      {
         _contextMgr.addGridEventsTooltipHolder(stage,false);
         _contextMgr.defaultAnchor = this.tooltipLeftAnchor;
         _contextMgr.overridedMouseDataSource = "OnGetItemDataForMouse";
         _contextMgr.enableInputFeedbackShowing(true);
         _contextMgr.saveScaleValue = true;
      }
      
      protected function initDataBindings() : void
      {
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.item.active",[this.setActiveItem]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.capacity.overburdened.text",[this.setIsOverburdenedText]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.capacity.overburdened.value",[this.setIsOverburdened]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.selection.mode.show",[this.showSelectionMode]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.merchant.info",[this.setMerchantInfo]));
      }
      
      private function handleSortClick(event:ButtonEvent = null) : void
      {
         this.mcPlayerInventory.mcPlayerGrid.ignoreNextGridPosition = true;
         this.mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSortingRequested"));
      }
      
      public function setNewFlagsForTabs(tab1:Boolean, tab2:Boolean, tab3:Boolean, tab4:Boolean, tab5:Boolean, tab6:Boolean) : void
      {
         var flagArray:Array = new Array(tab1,tab2,tab3,tab4,tab5,tab6);
         this.mcPlayerInventory.setNewFlagsForTabs(flagArray);
      }
      
      override protected function onLastMoveStatusChanged() : *
      {
         if(this.mcSortingMode)
         {
            this.mcSortingMode.lastMoveWasMouse = _lastMoveWasMouse;
         }
      }
      
      public function setPreviewMode(value:Boolean) : void
      {
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.previewMode = value;
         }
      }
      
      public function setVitality(value:Number, minValue:Number, maxValue:Number) : void
      {
         this.mcVitalityStat.setData(value,minValue,maxValue);
      }
      
      public function setToxicity(value:Number, minValue:Number, maxValue:Number) : void
      {
         this.mcToxicityStat.setData(value,minValue,maxValue);
      }
      
      public function setFilteringMode(value:Boolean) : void
      {
         trace("GFX setFilteringMode ",value);
         this._filteringMode = value;
         if(this._filteringMode)
         {
            if(this.mcPaperDollModule)
            {
               this.mcPaperDollModule.visible = false;
               this.mcPaperDollModule.enabled = false;
            }
         }
         else if(Boolean(this.mcPaperDollModule) && this.mcPaperDollModule.active)
         {
            this.mcPaperDollModule.visible = true;
            this.mcPaperDollModule.enabled = true;
         }
      }
      
      public function paperdollRemoveItem(itemId:uint) : void
      {
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.paperdollRemoveItem(itemId);
         }
      }
      
      public function handlePaperdollUpdateItem(itemData:Object) : void
      {
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.handlePaperdollUpdateItem(itemData);
         }
      }
      
      public function forceSelectTab(tabIndex:int) : void
      {
         this.mcPlayerInventory.onSetTabCalled(tabIndex);
      }
      
      public function forceSelectItem(itemPosition:int) : void
      {
         this.mcPlayerInventory.forceSelectItem(itemPosition);
      }
      
      public function forceSelectPaperdollSlot(slotType:int) : void
      {
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.forceSelectPaperdollSlot(slotType);
         }
      }
      
      public function inventoryRemoveItem(itemId:int, keepSelectionIdx:Boolean = false) : void
      {
         this.mcPlayerInventory.inventoryRemoveItem(itemId,keepSelectionIdx);
      }
      
      public function shopRemoveItem(itemID:int) : void
      {
         if(this.mcContainerGridModule)
         {
            this.mcContainerGridModule.handleItemRemoved(itemID);
         }
      }
      
      public function CloseMenu() : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnCloseMenu"));
      }
      
      private function showSortingModeChange(event:ButtonEvent = null) : void
      {
         this.mcSortingMode.show();
         this.mcPlayerInventory.enabled = false;
         this.mcPlayerInventory._inputEnabled = false;
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.enabled = false;
         }
         _contextMgr.blockTooltips(true);
         _contextMgr.blockModeSwitching = true;
         currentModuleIdx = 0;
         this.mcPlayerInventory.refreshButtons();
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSortingIndexChoosingStart"));
      }
      
      private function sortingModeClosed() : void
      {
         this.mcPlayerInventory.enabled = true;
         this.mcPlayerInventory._inputEnabled = true;
         if(this.mcPaperDollModule)
         {
            this.mcPaperDollModule.enabled = true;
         }
         _contextMgr.blockTooltips(false);
         _contextMgr.blockModeSwitching = false;
         currentModuleIdx = 0;
         this.mcPlayerInventory.refreshButtons();
      }
      
      private function sortingModeApply(valuesChanged:Boolean) : void
      {
         var newSortIndex:int = 0;
         if(this.mcSortingMode.isBoxChecked("TypeSort"))
         {
            newSortIndex = 0;
         }
         else if(this.mcSortingMode.isBoxChecked("PriceSort"))
         {
            newSortIndex = 1;
         }
         else if(this.mcSortingMode.isBoxChecked("WeightSort"))
         {
            newSortIndex = 2;
         }
         else if(this.mcSortingMode.isBoxChecked("DurabilitySort"))
         {
            newSortIndex = 3;
         }
         else if(this.mcSortingMode.isBoxChecked("RaritySort"))
         {
            newSortIndex = 4;
         }
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSortingIndexChosen",[newSortIndex]));
         this.mcPlayerInventory.mcPlayerGrid.ignoreNextGridPosition = true;
         this.mcPlayerInventory.mcPlayerGrid.scrollPosition = 0;
         this.mcPlayerInventory.mcPlayerGrid.setCurrentSort(newSortIndex);
         this.mcPlayerInventory.mcPlayerGrid.selectedIndex = -1;
         this.mcPlayerInventory.mcPlayerGrid.validateNow();
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSortingRequested"));
      }
      
      public function setDefaultTab(value:int) : void
      {
         trace("GFX [WitcherScript] setDefaultTab",value);
         this._defaultTabIdx = value;
      }
      
      private function createPaperdollModule(active:Boolean) : Boolean
      {
         var containerGridClass:Class = null;
         if(!this.mcPaperDollModule)
         {
            containerGridClass = getDefinitionByName("PaperdollRef") as Class;
            this.mcPaperDollModule = new containerGridClass() as ModulePaperdoll;
            if(!this.mcPaperDollModule)
            {
               return false;
            }
            addChild(this.mcPaperDollModule);
            swapChildren(this.mcPaperdollAnchor,this.mcPaperDollModule);
            this.mcPaperDollModule.validateNow();
         }
         this.mcPaperDollModule.active = active;
         this._rendererController.addFadeOutComponent(this.mcPaperDollModule);
         this.mcPaperDollModule.addEventListener(CharacterModeBackground.ACCEPT,this.handleSelectionModeAcceptClick,false,0,true);
         this.mcPaperDollModule.x = 856;
         this.mcPaperDollModule.y = 107;
         initModuleDynamically(this.mcPaperDollModule);
         return true;
      }
      
      private function createContainerGridModule(value:int) : Boolean
      {
         var containerGridClass:Class = null;
         if(!this.mcContainerGridModule)
         {
            containerGridClass = getDefinitionByName("ContainerGrid") as Class;
            this.mcContainerGridModule = new containerGridClass() as ModuleContainer;
            this.mcContainerGridModule.mcPlayerGrid.ignoreValidationOpt = true;
            addChild(this.mcContainerGridModule);
            this.mcContainerGridModule.validateNow();
            swapChildren(this.mcContainerAnchor,this.mcContainerGridModule);
         }
         this.mcContainerGridModule.active = true;
         this.mcContainerGridModule.x = 1046;
         this.mcContainerGridModule.y = 217;
         this.mcContainerGridModule.dropMode = value;
         this.mcContainerGridModule.dropEnabled = true;
         initModuleDynamically(this.mcContainerGridModule);
         return true;
      }
      
      private function getShowAdvancedStatsGpadNavCode() : String
      {
         return InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2;
      }
      
      public function setInventoryMode(value:int) : void
      {
         trace("GFX --------------------------------------");
         trace("GFX [WitcherScript] setInventoryMode",value);
         this._inventoryMode = value;
         this.mcPlayerInventory.mcPlayerGrid.dropMode = value;
         if(this._btn_stats_id != -1)
         {
            InputFeedbackManager.removeButton(this,this._btn_stats_id);
            this._btn_stats_id = -1;
         }
         this.SetSellJunkEnable(value == IMS_Shop);
         switch(value)
         {
            case IMS_Player:
               if(this._btn_stats_id == -1)
               {
                  this._btn_stats_id = InputFeedbackManager.appendButton(this,this.getShowAdvancedStatsGpadNavCode(),KeyCode.C,"panel_common_show_advanced_statistics");
               }
               this.mcSortingMode.x = 0;
               this.btnSort.x = 314.75;
               this.btnSortChange.x = 500.65;
               this.mcPlayerInventory.x = this.playerGridInitX;
               this.mcShopBackground.visible = false;
               this.mcStashBackground.visible = false;
               this.createPaperdollModule(!this._filteringMode);
               this.mcCharacterRenderer.x = this.mcCharacterModelAnchor.x;
               this.mcCharacterRenderer.y = this.mcCharacterModelAnchor.y;
               this._rendererController.enabled = true;
               registerRenderTarget("test_nopack",1024,1024);
               this.dropSlot.disabled = false;
               this.mcVitalityStat.visible = true;
               this.mcToxicityStat.visible = true;
               this.mcPlayerInventory.setTabData(new DataProvider([{
                  "icon":"INGREDIENTS",
                  "locKey":"[[panel_inventory_filter_type_ingredients]]"
               },{
                  "icon":"QUEST_ITEMS",
                  "locKey":"[[panel_inventory_filter_type_quest_items]]"
               },{
                  "icon":"DEFAULT",
                  "locKey":"[[panel_inventory_filter_type_default]]"
               },{
                  "icon":"POTIONS",
                  "locKey":"[[panel_inventory_filter_type_alchemy_items]]"
               },{
                  "icon":"WEAPONS",
                  "locKey":"[[item_category_equipement]]"
               }]));
               this.mcPlayerInventory.onSetTabCalled(4);
               break;
            case IMS_Stash:
               this.mcSortingMode.x = 170;
               this.mcPlayerInventory.x = this.playerGridInitX + this.playerGridXOffset;
               if(this.mcPlayerInventory.mcSlotList as SlotsListGrid)
               {
                  (this.mcPlayerInventory.mcSlotList as SlotsListGrid).updateRendererBounds();
               }
               this.btnSort.x = 422;
               this.btnSortChange.x = 608;
               this.mcShopBackground.visible = false;
               this.mcStashBackground.visible = true;
               this.createContainerGridModule(value);
               this.mcContainerGridModule.mcPlayerGrid.ignoreGridPosition = true;
               this.mcCharacterRenderer.visible = false;
               this._rendererController.enabled = false;
               this.dropSlot.disabled = true;
               this.mcVitalityStat.visible = false;
               this.mcToxicityStat.visible = false;
               this.mcPlayerInventory.setTabData(new DataProvider([{
                  "icon":"INGREDIENTS",
                  "locKey":"[[panel_inventory_filter_type_ingredients]]"
               },{
                  "icon":"QUEST_ITEMS",
                  "locKey":"[[panel_inventory_filter_type_quest_items]]"
               },{
                  "icon":"DEFAULT",
                  "locKey":"[[panel_inventory_filter_type_default]]"
               },{
                  "icon":"POTIONS",
                  "locKey":"[[panel_inventory_filter_type_alchemy_items]]"
               },{
                  "icon":"WEAPONS",
                  "locKey":"[[item_category_equipement]]"
               }]));
               if(this._defaultTabIdx != -1)
               {
                  this.mcPlayerInventory.onSetTabCalled(this._defaultTabIdx);
               }
               break;
            case IMS_Shop:
            case IMS_Container:
               this.mcSortingMode.x = 170;
               this.mcPlayerInventory.x = this.playerGridInitX + this.playerGridXOffset;
               if(this.mcPlayerInventory.mcSlotList as SlotsListGrid)
               {
                  (this.mcPlayerInventory.mcSlotList as SlotsListGrid).updateRendererBounds();
               }
               this.btnSort.x = 422;
               this.btnSortChange.x = 608;
               this.mcShopBackground.visible = true;
               this.mcStashBackground.visible = false;
               this.createContainerGridModule(value);
               this.mcContainerGridModule.mcPlayerGrid.ignoreGridPosition = true;
               this.mcCharacterRenderer.visible = false;
               this._rendererController.enabled = false;
               this.dropSlot.disabled = true;
               this.mcVitalityStat.visible = false;
               this.mcToxicityStat.visible = false;
               this.mcPlayerInventory.setTabData(new DataProvider([{
                  "icon":"INGREDIENTS",
                  "locKey":"[[panel_inventory_filter_type_ingredients]]"
               },{
                  "icon":"QUEST_ITEMS",
                  "locKey":"[[panel_inventory_filter_type_quest_items]]"
               },{
                  "icon":"DEFAULT",
                  "locKey":"[[panel_inventory_filter_type_default]]"
               },{
                  "icon":"POTIONS",
                  "locKey":"[[panel_inventory_filter_type_alchemy_items]]"
               },{
                  "icon":"WEAPONS",
                  "locKey":"[[item_category_equipement]]"
               }]));
               if(this._defaultTabIdx != -1)
               {
                  this.mcPlayerInventory.onSetTabCalled(this._defaultTabIdx);
               }
               break;
            case IMS_HorseInventory:
               this.mcSortingMode.x = 170;
               this.mcShopBackground.visible = false;
               this.mcStashBackground.visible = false;
               this.createContainerGridModule(value);
               this.mcCharacterRenderer.x = this.mcHorseModelAnchor.x;
               this.mcCharacterRenderer.y = this.mcHorseModelAnchor.y;
               this._rendererController.enabled = false;
               this.dropSlot.disabled = true;
               this.mcVitalityStat.visible = false;
               this.mcToxicityStat.visible = false;
         }
         stage.dispatchEvent(new Event(CoreMenu.CURRENT_MODULE_INVALIDATE));
      }
      
      protected function setIsOverburdenedText(value:String) : void
      {
         var textField:TextField = null;
         if(this.mcOverburdened)
         {
            textField = (this.mcOverburdened.getChildByName("txtOverburdened") as MovieClip).getChildByName("txtOverburdened") as TextField;
            if(textField)
            {
               textField.text = value;
            }
         }
      }
      
      protected function setIsOverburdened(value:Boolean) : void
      {
         this.mcOverburdened.visible = value;
         this.mcPlayerInventory.SetOverburdened(value);
      }
      
      protected function setMerchantInfo(value:Object) : void
      {
         this.moduleMerchantInfo.data = value;
      }
      
      public function setActiveItem(value:String) : void
      {
         trace("GFX [Witcher Script] setActiveItem",value);
      }
      
      override protected function handleInputNavigate(event:InputEvent) : void
      {
         var details:InputDetails = event.details;
         var keyUp:* = details.value == InputValue.KEY_UP;
         var keyDown:* = details.value == InputValue.KEY_DOWN;
         var keyHold:* = details.value == InputValue.KEY_HOLD;
         var inputEnabledUp:Boolean = Boolean(keyUp) && !event.handled;
         var inputEnabledDown:Boolean = (Boolean(keyDown) || Boolean(keyHold)) && !event.handled;
         if(inputEnabledDown)
         {
            if((details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.E) && this._sellJunkEnable)
            {
               if(keyDown)
               {
                  this.junkHold = true;
                  this.junkTimerStart = new Date().time;
               }
               if(Boolean(keyHold) && this.junkHold)
               {
                  if(new Date().time - this.junkTimerStart > this.junkHoldTimeRequired * 1000)
                  {
                     this.junkHold = false;
                     this.handleSellAllJunk();
                     this.dontReactOnNextGPA = true;
                     this.dispatchSetBlockSell(true);
                     InputFeedbackManager.updateButtons(this);
                  }
               }
            }
         }
         else if(inputEnabledUp)
         {
            switch(details.navEquivalent)
            {
               case NavigationCode.GAMEPAD_R2:
                  event.handled = true;
                  break;
               case NavigationCode.GAMEPAD_B:
                  if(this.mcSelectionMode.isActive())
                  {
                     event.handled = true;
                     event.stopImmediatePropagation();
                     this.CancelSelectionMode();
                  }
                  break;
               case NavigationCode.GAMEPAD_A:
                  if(!this.dontReactOnNextGPA)
                  {
                     if(this.mcSelectionMode.isActive())
                     {
                        if(this.FinishSelectionMode())
                        {
                           event.handled = true;
                           event.stopImmediatePropagation();
                        }
                     }
                  }
                  else
                  {
                     this.dontReactOnNextGPA = false;
                     setTimeout(this.dispatchSetBlockSell,1,false);
                  }
            }
            if(details.code == KeyCode.C)
            {
               event.handled = true;
            }
            else if(details.code == KeyCode.Q)
            {
               if(!this.mcSelectionMode.isActive() && !this._rendererController.isActive())
               {
                  event.handled = true;
                  this.handleSortClick();
               }
            }
            else if(details.code == KeyCode.F || details.navEquivalent == NavigationCode.GAMEPAD_R3)
            {
               if(!this.mcSelectionMode.isActive() && !this._rendererController.isActive())
               {
                  if(!this.mcSortingMode.visible)
                  {
                     this.showSortingModeChange();
                  }
                  else
                  {
                     this.mcSortingMode.close();
                  }
               }
            }
            if(details.code == KeyCode.E)
            {
               if(!this.dontReactOnNextGPA)
               {
                  if(this.mcSelectionMode.isActive())
                  {
                     if(this.FinishSelectionMode())
                     {
                        event.handled = true;
                        event.stopImmediatePropagation();
                     }
                  }
               }
               else
               {
                  setTimeout(this.dispatchSetBlockSell,1,false);
                  this.dontReactOnNextGPA = false;
               }
            }
         }
         super.handleInputNavigate(event);
      }
      
      private function dispatchSetBlockSell(value:Boolean) : *
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSetBlockSell",[value]));
      }
      
      private function handleSellAllJunk() : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSellAllJunk"));
      }
      
      private function handleSelectionModeAcceptClick(event:Event) : void
      {
         trace("GFX handleSelectionModeAcceptClick");
         this.FinishSelectionMode();
      }
      
      private function handleSelectionModeCancelClick(event:Event) : void
      {
         trace("GFX handleSelectionModeCancelClick");
         this.CancelSelectionMode();
      }
      
      private function FinishSelectionMode() : Boolean
      {
         if(!this.mcPaperDollModule)
         {
            return false;
         }
         var currentPaperdollSlot:SlotPaperdoll = this.mcPaperDollModule.mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
         trace("GFX FinishSelectionMode ",currentPaperdollSlot);
         if(currentPaperdollSlot)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnSelectionModeTargetChosen",[currentPaperdollSlot.equipID]));
            return true;
         }
         throw new Error("GFX - failed to activate selected slot, selected index: " + this.mcPaperDollModule.mcPaperdoll.selectedIndex);
      }
      
      private function CancelSelectionMode() : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSelectionModeCancelRequested"));
      }
      
      protected function showSelectionMode(infoObject:Object) : void
      {
         if(!this.mcPaperDollModule)
         {
            return;
         }
         var id:int = int(infoObject.sourceItem);
         var slotList:Array = infoObject.validSlots;
         var targetSlot:SlotInventoryGrid = this.mcPlayerInventory.getSlotByID(id);
         trace("GFX - starting selection mode by id: " + id + ", with valid slot list: " + slotList);
         if(!targetSlot)
         {
            this.mcPlayerInventory.mcPlayerGrid.traceGrid();
            throw new Error("GFX - was unable to find inventory slot with id: " + id);
         }
         trace("GFX - successfully found target slot: " + targetSlot);
         this.mcSelectionMode.activate(targetSlot);
         this.mcPaperDollModule.startSelectModeWithValidSlots(slotList);
         this.mcPlayerInventory.enabled = false;
         this.mcPlayerInventory._inputEnabled = false;
         currentModuleIdx = 0;
         this._rendererController.inputDisabled = true;
         SlotsTransferManager.getInstance().disabled = true;
         this._isTooltipHidden = ContextInfoManager.getInstanse().isHidden();
         if(!this._isTooltipHidden && Boolean(infoObject.isDyeApplyingMode))
         {
            ContextInfoManager.getInstanse().setHiddenState(true);
         }
      }
      
      public function hideSelectionMode() : void
      {
         if(!this.mcPaperDollModule)
         {
            return;
         }
         this.mcSelectionMode.deactivate();
         this.mcPaperDollModule.endSelectionMode();
         this.mcPlayerInventory.enabled = true;
         this.mcPlayerInventory._inputEnabled = true;
         currentModuleIdx = 0;
         this._rendererController.inputDisabled = false;
         SlotsTransferManager.getInstance().disabled = false;
         if(!this._isTooltipHidden)
         {
            ContextInfoManager.getInstanse().setHiddenState(false);
         }
      }
      
      internal function __setProp_mcPlayerInventory_Scene1_Inventory_Grid_0() : *
      {
         try
         {
            this.mcPlayerInventory["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.mcPlayerInventory.enabled = true;
         this.mcPlayerInventory.enableInitCallback = false;
         this.mcPlayerInventory.subDataProvider = "player.inventory.menu.tabs.data";
         this.mcPlayerInventory.tabDataEventName = "OnTabDataRequested";
         this.mcPlayerInventory.visible = true;
         try
         {
            this.mcPlayerInventory["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

