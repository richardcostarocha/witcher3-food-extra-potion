package red.game.witcher3.menus.inventory_menu
{
   import com.gskinner.motion.GTween;
   import com.gskinner.motion.GTweener;
   import com.gskinner.motion.easing.Sine;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.getDefinitionByName;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.game.witcher3.constants.CommonConstants;
   import red.game.witcher3.controls.AdvancedTabListItem;
   import red.game.witcher3.interfaces.IAbstractItemContainerModule;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.menus.common.ItemDataStub;
   import red.game.witcher3.modules.CollapsableTabbedListModule;
   import red.game.witcher3.slots.SlotBase;
   import red.game.witcher3.slots.SlotInventoryGrid;
   import red.game.witcher3.slots.SlotsListBase;
   import red.game.witcher3.slots.SlotsListGrid;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.events.ListEvent;
   
   public class InventoryTabbedListModule extends CollapsableTabbedListModule implements IAbstractItemContainerModule
   {
      
      private const SECTION_BORDER_REF:String = "GridSegmentationRef";
      
      private const SECTION_BORDER_SIDE_PADDING:Number = 3;
      
      private const SECTION_BORDER_TOP_PADDING:Number = 9;
      
      internal var maskClip:MovieClip;
      
      protected var _gridRenderHeight:int = 520;
      
      public var mcSectionTitlesAnchor:MovieClip;
      
      public var mcPlayerGrid:SlotsListGrid;
      
      protected var _sectionTitlesContainer:MovieClip;
      
      protected var _sectionTitlesList:Vector.<TextField> = new Vector.<TextField>();
      
      protected var _sectionBordersList:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      protected var _itemSectionsList:GridTabSections;
      
      private var isHorse:Boolean = false;
      
      public var gridMaskOffset:Number = 0;
      
      protected var maskTweener:GTween;
      
      public function InventoryTabbedListModule()
      {
         super();
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         _initialSelectedIndex = 4;
         this.maskClip = getChildByName("mcGridMask") as MovieClip;
         if(this.maskClip)
         {
            trace("GFX - updating list height from mask to: ",this.maskClip.height);
            this._gridRenderHeight = this.maskClip.height - this.gridMaskOffset;
         }
         dataBindingKey = "inventory.grid.player";
         addToListContainer(this.mcPlayerGrid);
         stage.addEventListener(SlotBase.NEW_FLAG_CLEARED,this.onNewFlagCleared,true,0,true);
         enableSelectTabWithTap(true);
         dispatchEvent(new GameEvent(GameEvent.REGISTER,dataBindingKey + ".itemUpdate",[this.handleItemUpdate]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,dataBindingKey + ".itemsUpdate",[this.handleItemsUpdate]));
         if(this.mcPlayerGrid)
         {
            this.mcPlayerGrid.enableTouch(true);
            this.mcPlayerGrid.enableScrollWithPan(true);
            this.mcPlayerGrid.addEventListener(SlotsListBase.EVENT_SELECTED_TAPPED,this.onSlotItemTappedTwice,false,0,true);
            this.mcPlayerGrid.addEventListener(SlotsListBase.EVENT_SELECTED_DOUBLE_TAPPED,this.onSlotItemTappedTwice,false,0,true);
            this.mcPlayerGrid.gridMaskOffset = this.gridMaskOffset;
            this.mcPlayerGrid.focusable = false;
            this.mcPlayerGrid.handleScrollBar = true;
            this.mcPlayerGrid.ignoreGridPosition = false;
            _inputHandlers.push(this.mcPlayerGrid);
            this.mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE,this.handleSlotChanged,false,0,true);
         }
         bToCloseEnabled = true;
      }
      
      private function onSlotItemTappedTwice(event:Event) : void
      {
         var gridSelected:SlotInventoryGrid = this.mcPlayerGrid.getSelectedRenderer() as SlotInventoryGrid;
         var selected:SlotInventoryGrid = event.target.getSelectedRenderer() as SlotInventoryGrid;
         trace("InventoryTabbedListModule::onSlotItemTappedTwice : ",gridSelected,selected,event);
         if(isOpen && hasFocus && Boolean(selected))
         {
            selected.tryExecuteAssignedAction();
         }
      }
      
      public function setItemSections(sectionsList:GridTabSections) : void
      {
         this._itemSectionsList = sectionsList;
      }
      
      override protected function onTabListItemSelected(event:ListEvent) : void
      {
         var curSectionsList:Array = null;
         var curBorder:MovieClip = null;
         var borderRef:Class = null;
         var len:int = 0;
         var curPosition:Number = NaN;
         var gridPos:Point = null;
         var i:int = 0;
         var curSectionData:ItemSectionData = null;
         var curBlockWidth:Number = NaN;
         var curBlockMiddle:Number = NaN;
         var newTextField:TextField = null;
         var newBorder:MovieClip = null;
         var columnSize:Number = this.mcPlayerGrid.gridSquareSize;
         var sectionPadding:Number = SlotsListGrid.SECTION_PADDING;
         trace("GFX --------------- onTabListItemSelected, new index ",event.index,"; old index ",currentlySelectedTabIndex);
         trace("GFX update columns...");
         if(event.index != currentlySelectedTabIndex)
         {
            curSectionsList = this._itemSectionsList.getTabSections(event.index);
            if(curSectionsList)
            {
               this.mcPlayerGrid.setItemSections(curSectionsList);
            }
         }
         super.onTabListItemSelected(event);
         var gridWidth:Number = 0;
         if(Boolean(curSectionsList) && Boolean(curSectionsList.length))
         {
            gridWidth = this.mcPlayerGrid.columns * columnSize + (curSectionsList.length - 1) * SlotsListGrid.SECTION_PADDING;
            this.mcPlayerGrid.x = -gridWidth / 2;
         }
         else
         {
            gridWidth = this.mcPlayerGrid.actualWidth;
         }
         if(Boolean(curSectionsList) && Boolean(this.mcSectionTitlesAnchor))
         {
            if(this._sectionTitlesContainer)
            {
               while(this._sectionTitlesList.length)
               {
                  this._sectionTitlesContainer.removeChild(this._sectionTitlesList.pop());
               }
               while(this._sectionBordersList.length)
               {
                  curBorder = this._sectionBordersList.pop();
                  GTweener.removeTweens(curBorder);
                  this._sectionTitlesContainer.removeChild(curBorder);
               }
               removeChild(this._sectionTitlesContainer);
               this._sectionTitlesContainer = null;
            }
            if(curSectionsList.length)
            {
               borderRef = getDefinitionByName(this.SECTION_BORDER_REF) as Class;
               len = int(curSectionsList.length);
               curPosition = 0;
               gridPos = mcListContainer.localToGlobal(new Point(this.mcPlayerGrid.x,this.mcPlayerGrid.y));
               this._sectionTitlesContainer = new MovieClip();
               this._sectionTitlesContainer.y = this.mcSectionTitlesAnchor.y;
               this._sectionTitlesContainer.x = this.mcSectionTitlesAnchor.x - gridWidth / 2;
               addChild(this._sectionTitlesContainer);
               this._sectionTitlesContainer.mouseChildren = this._sectionTitlesContainer.mouseEnabled = false;
               for(i = 0; i < len; i++)
               {
                  curSectionData = curSectionsList[i] as ItemSectionData;
                  if(curSectionData)
                  {
                     curBlockWidth = (curSectionData.end - curSectionData.start + 1) * columnSize;
                     if(curBlockWidth < 0)
                     {
                        throw new Error("Invalid grid sections structure. Check MenuInventory.as or InventoryTabbedListModule.as ;-)");
                     }
                     curBlockMiddle = curBlockWidth / 2;
                     newTextField = CommonUtils.spawnTextField(21);
                     newTextField.text = curSectionData.label;
                     CommonUtils.toSmallCaps(newTextField);
                     newTextField.width = newTextField.textWidth + CommonConstants.SAFE_TEXT_PADDING;
                     newTextField.x = curPosition + curBlockMiddle - newTextField.width / 2;
                     this._sectionTitlesContainer.addChild(newTextField);
                     newBorder = new borderRef() as MovieClip;
                     newBorder.x = curPosition - this.SECTION_BORDER_SIDE_PADDING;
                     newBorder.y = -this.SECTION_BORDER_TOP_PADDING;
                     newBorder.width = curBlockWidth + this.SECTION_BORDER_SIDE_PADDING * 2;
                     this._sectionTitlesContainer.addChild(newBorder);
                     curSectionData.border = newBorder;
                     newBorder.alpha = CommonConstants.BORDER_ALPHA_UNSELECTED;
                     this.mcPlayerGrid.lastSelectedSection = -1;
                     curPosition += sectionPadding + curBlockWidth;
                  }
               }
            }
         }
      }
      
      override protected function handleMouseMove(event:MouseEvent) : void
      {
         if(!_lastMoveWasMouse)
         {
            _lastMoveWasMouse = true;
         }
         open();
      }
      
      override protected function requestTabdata(index:int) : void
      {
         dispatchEvent(new GameEvent(GameEvent.CALL,tabDataEventName,[index,this.isHorse]));
      }
      
      override protected function setAllowSelectionHighlight(allowed:Boolean) : void
      {
         var currentSlotItem:SlotBase = null;
         var i:int = 0;
         super.setAllowSelectionHighlight(allowed);
         if(this.mcPlayerGrid)
         {
            this.mcPlayerGrid.activeSelectionVisible = allowed;
         }
      }
      
      override protected function state_Open_begin() : void
      {
         super.state_Open_begin();
         invalidate(INVALIDATE_CONTEXT);
         if(this.mcPlayerGrid.selectedIndex == -1)
         {
            this.mcPlayerGrid.findSelection();
         }
         this.mcPlayerGrid.applySelectionContext();
         this.checkTabNewFlag(this.mcPlayerGrid.getSelectedRenderer() as SlotBase);
      }
      
      protected function handleSlotChanged(event:ListEvent) : void
      {
         invalidate(INVALIDATE_CONTEXT);
         this.checkTabNewFlag(this.mcPlayerGrid.getSelectedRenderer() as SlotBase);
      }
      
      protected function onNewFlagCleared(event:Event) : void
      {
         if(event.target is SlotBase)
         {
            this.checkTabNewFlag(event.target as SlotBase);
         }
      }
      
      protected function checkTabNewFlag(targetSlot:SlotBase) : void
      {
         if(Boolean(targetSlot) && targetSlot._unprocessedNewFlagRemoval)
         {
            targetSlot._unprocessedNewFlagRemoval = false;
            this.validateTabNewFlag(mcTabList.selectedIndex);
         }
      }
      
      protected function validateTabNewFlag(tabIndex:int) : void
      {
         var currentData:Array = null;
         var i:int = 0;
         var hasNew:Boolean = false;
         var selectedTab:AdvancedTabListItem = mcTabList.getRendererAt(tabIndex) as AdvancedTabListItem;
         if(Boolean(selectedTab) && selectedTab.hasNewFlag())
         {
            currentData = subDataDictionary[tabIndex];
            if(currentData)
            {
               i = 0;
               hasNew = false;
               for(i = 0; i < currentData.length; i++)
               {
                  if(currentData[i].isNew)
                  {
                     hasNew = true;
                     break;
                  }
               }
               if(!hasNew)
               {
                  selectedTab.setNewFlag(false);
               }
            }
         }
      }
      
      protected function handleItemUpdate(itemData:Object) : void
      {
         var selectedTab:AdvancedTabListItem = null;
         var tstDataObj:ItemDataStub = itemData as ItemDataStub;
         var targetIndex:int = mcTabList.selectedIndex;
         if(tstDataObj.tabIndex != -1)
         {
            targetIndex = tstDataObj.tabIndex;
         }
         mcTabList.validateNow();
         var dataArray:Array = new Array();
         dataArray.push(tstDataObj);
         updateDataSurgicallyInCurrentTab(targetIndex,dataArray);
         this.mcPlayerGrid.updateItemData(itemData);
         invalidate(INVALIDATE_CONTEXT);
         open();
         if(tstDataObj.isNew)
         {
            selectedTab = mcTabList.getRendererAt(tstDataObj.tabIndex) as AdvancedTabListItem;
            if(selectedTab)
            {
               selectedTab.setNewFlag(true);
            }
         }
      }
      
      protected function handleItemsUpdate(items:Array) : void
      {
         var i:* = undefined;
         var len:int = 0;
         var itemData:Object = null;
         var tstDataObj:ItemDataStub = null;
         var selectedTab:AdvancedTabListItem = null;
         var dataArray:Array = new Array();
         var targetIndex:int = mcTabList.selectedIndex;
         var isNew:Boolean = false;
         if(items)
         {
            len = int(items.length);
            for(i = 0; i < len; i++)
            {
               itemData = items[i];
               tstDataObj = itemData as ItemDataStub;
               if(tstDataObj.tabIndex != -1)
               {
                  targetIndex = tstDataObj.tabIndex;
               }
               if(tstDataObj.isNew)
               {
                  isNew = true;
               }
               dataArray.push(tstDataObj);
            }
            this.mcPlayerGrid.updateItems(dataArray);
            updateDataSurgicallyInCurrentTab(targetIndex,dataArray);
            mcTabList.validateNow();
            invalidate(INVALIDATE_CONTEXT);
            open();
            if(isNew)
            {
               selectedTab = mcTabList.getRendererAt(targetIndex) as AdvancedTabListItem;
               if(selectedTab)
               {
                  selectedTab.setNewFlag(true);
               }
            }
         }
      }
      
      override protected function draw() : void
      {
         super.draw();
         if(isInvalid(INVALIDATE_CONTEXT))
         {
            this.updateActiveContext();
         }
      }
      
      protected function updateActiveContext() : void
      {
         var slotData:ItemDataStub = null;
         var targetX:Number = NaN;
         var targetY:Number = NaN;
         var slotType:uint = 0;
         var targetId:uint = 0;
         var targetPoint:Point = new Point();
         var currentSlot:SlotBase = this.mcPlayerGrid.getSelectedRenderer() as SlotBase;
         if(focused == 0)
         {
            return;
         }
         if(Boolean(currentSlot) && this.mcPlayerGrid.enabled)
         {
            slotData = currentSlot.data as ItemDataStub;
            if(slotData)
            {
               targetId = slotData.id;
               slotType = uint(slotData.slotType);
            }
            targetX = currentSlot.x + currentSlot.getSlotRect().width;
            targetY = currentSlot.y + currentSlot.getSlotRect().height;
            targetPoint = currentSlot.parent.localToGlobal(new Point(targetX,targetY));
         }
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnSelectInventoryItem",[targetId,slotType,targetPoint.x,targetPoint.y]));
      }
      
      public function forceSelectItem(itemPosition:int) : void
      {
         if(this.mcPlayerGrid)
         {
            this.mcPlayerGrid.selectedIndex = itemPosition;
         }
      }
      
      override public function set focused(value:Number) : void
      {
         if(value > 0 && value != _focused)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnSetCurrentPlayerGrid",[dataBindingKey]));
         }
         super.focused = value;
         invalidate(INVALIDATE_CONTEXT);
         if(isOpen)
         {
            this.mcPlayerGrid.applySelectionContext();
            this.checkTabNewFlag(this.mcPlayerGrid.getSelectedRenderer() as SlotBase);
         }
      }
      
      public function SetOverburdened(value:Boolean) : void
      {
         var i:int = 0;
         var curRenderer:SlotInventoryGrid = null;
         for(i = 0; i < this.mcPlayerGrid.getRenderersLength(); i += 1)
         {
            curRenderer = this.mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;
            if(curRenderer)
            {
               curRenderer.setOverburdened(value);
            }
         }
      }
      
      override public function getDataShowerForTab(index:int) : UIComponent
      {
         return this.mcPlayerGrid;
      }
      
      public function get CurrentItemDataStub() : ItemDataStub
      {
         return null;
      }
      
      override protected function setSubData(index:int, data:Array) : void
      {
         super.setSubData(index,data);
      }
      
      public function inventoryRemoveItem(itemId:int, keepSelectionIdx:Boolean = false) : void
      {
         mcTabList.validateNow();
         this.mcPlayerGrid.removeItem(itemId,keepSelectionIdx);
         var dataArray:Array = new Array();
         dataArray.push(itemId);
         removeDataSurgicallyInCurrentTab(mcTabList.selectedIndex,dataArray);
      }
      
      public function getSlotByID(slotID:int) : SlotInventoryGrid
      {
         return this.mcPlayerGrid.getSlotByID(slotID) as SlotInventoryGrid;
      }
      
      protected function handleMaskTweenComplete(curTween:GTween) : void
      {
         this.maskTweener = null;
      }
      
      override protected function ApplyCloseAnimationToMask() : *
      {
         this.maskClip = getChildByName("mcGridMask") as MovieClip;
         if(this.maskClip)
         {
            if(this.maskTweener)
            {
               this.maskTweener.paused = true;
               GTweener.removeTweens(this.maskClip);
            }
            this.maskTweener = GTweener.to(this.maskClip,0.2,{"height":ClosedListScale * this._gridRenderHeight},{
               "onComplete":this.handleMaskTweenComplete,
               "ease":Sine.easeOut
            });
         }
      }
      
      override protected function ApplyOpenAnimationToMask() : *
      {
         this.maskClip = getChildByName("mcGridMask") as MovieClip;
         if(this.maskClip)
         {
            if(this.maskTweener)
            {
               this.maskTweener.paused = true;
               GTweener.removeTweens(this.maskClip);
            }
            this.maskTweener = GTweener.to(this.maskClip,0.2,{"height":this._gridRenderHeight},{
               "onComplete":this.handleMaskTweenComplete,
               "ease":Sine.easeOut
            });
         }
      }
      
      override public function handleInput(event:InputEvent) : void
      {
         if(InputManager.getInstance().isMouse() && (event.details.code == KeyCode.ESCAPE || event.details.navEquivalent == NavigationCode.GAMEPAD_B))
         {
            return;
         }
         super.handleInput(event);
      }
   }
}

