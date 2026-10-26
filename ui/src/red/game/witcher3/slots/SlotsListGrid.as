package red.game.witcher3.slots
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TransformGestureEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import red.core.events.GameEvent;
   import red.game.witcher3.constants.CommonConstants;
   import red.game.witcher3.constants.InventorySlotType;
   import red.game.witcher3.interfaces.IBaseSlot;
   import red.game.witcher3.interfaces.IDragTarget;
   import red.game.witcher3.interfaces.IDropTarget;
   import red.game.witcher3.interfaces.IInventorySlot;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.menus.common.ItemDataStub;
   import red.game.witcher3.menus.inventory_menu.ItemSectionData;
   import red.game.witcher3.menus.inventory_menu.MenuInventory;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.InvalidationType;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.controls.ScrollIndicator;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.events.ListEvent;
   import scaleform.clik.interfaces.IListItemRenderer;
   import scaleform.clik.interfaces.IScrollBar;
   import scaleform.clik.ui.InputDetails;
   
   public class SlotsListGrid extends SlotsListBase implements IDropTarget
   {
      
      public static const SECTION_PADDING:Number = 15;
      
      protected static const HIGHLIGHT_REF:String = "SlotHighlightRef";
      
      protected static const HIGHLIGHT_LABEL_ACCEPT:String = "accept";
      
      protected static const HIGHLIGHT_LABEL_DENIDED:String = "denided";
      
      protected static const HIGHLIGHT_LABEL_NONE:String = "none";
      
      protected static const ITEM_PADDING:Number = 4;
      
      public var handleScrollBar:Boolean = false;
      
      protected var _gridRenderHeight:int = 520;
      
      protected var _discardedRendererPool:Vector.<IInventorySlot> = new Vector.<IInventorySlot>();
      
      protected var _specialCachedSelection:int = -1;
      
      protected var _lastSetSort:int = -1;
      
      protected var _maxOffset:Number = 0;
      
      protected var _scrollBarValue:Object;
      
      protected var _offset:uint;
      
      protected var _scrollBar:IScrollBar;
      
      protected var _gridSquareSize:Number;
      
      protected var _elementGridSquareOffset:Number;
      
      protected var _rows:uint;
      
      protected var _columns:uint;
      
      protected var _totalRenderers:int;
      
      public var handlesRightJoystick:Boolean = false;
      
      public var ignoreValidationOpt:Boolean = false;
      
      protected var _numRowsVisible:uint = 1;
      
      protected var _dropSelection:Boolean;
      
      protected var _highlightCanvas:Sprite;
      
      protected var _highlightIndicator:MovieClip;
      
      protected var _cachedItemPositions:Object;
      
      protected var _initFindSelection:Boolean = true;
      
      protected var _ignoreGridPosition:Boolean = false;
      
      public var ignoreNextGridPosition:Boolean = false;
      
      protected var _itemSectionsList:Array;
      
      protected var _paddingsMap:Object;
      
      protected var highestRowNeeded:uint = 0;
      
      public var gridMaskOffset:Number = 0;
      
      public var mcStateDropTarget:MovieClip;
      
      protected var _gridMask:MovieClip = null;
      
      protected var _dropMode:int;
      
      protected var _useContextMgr:Boolean = true;
      
      private var _dropEnabled:Boolean = true;
      
      protected var _currentDropRenderer:IInventorySlot;
      
      public var lastSelectedSection:int = -1;
      
      internal const DEBUG_REC_LIMIT:* = 100;
      
      protected var _renderBounds:Rectangle = null;
      
      public function SlotsListGrid()
      {
         super();
         if(this.mcStateDropTarget)
         {
            this.mcStateDropTarget.visible = false;
         }
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this._totalRenderers = this._rows * this._columns;
         this.createInitRenderers();
         _canvas.addEventListener(MouseEvent.MOUSE_WHEEL,this.onScroll,false,0,true);
         this._highlightCanvas = new Sprite();
         this._highlightCanvas.mouseChildren = false;
         this._highlightCanvas.mouseEnabled = false;
         addChild(this._highlightCanvas);
         if(this.gridMask)
         {
            this._gridRenderHeight = this.gridMask.height - this.gridMaskOffset;
            this._numRowsVisible = Math.floor((this.gridMask.height - this.gridMaskOffset) / CommonConstants.INVENTORY_GRID_SIZE);
         }
         addEventListener(ListEvent.INDEX_CHANGE,this.handleSlotChanged,false,0,true);
      }
      
      protected function get gridMask() : MovieClip
      {
         if(this._gridMask == null)
         {
            this._gridMask = parent.getChildByName("mcGridMask") as MovieClip;
         }
         return this._gridMask;
      }
      
      public function setItemSections(sectionsList:Array) : void
      {
         this._itemSectionsList = sectionsList;
         this.updateColumnsPaddingMap();
         clearRenderers();
      }
      
      private function updateColumnsPaddingMap() : void
      {
         var len:int = 0;
         var k:int = 0;
         var i:int = 0;
         if(this._itemSectionsList)
         {
            this._paddingsMap = {};
            len = int(this._itemSectionsList.length);
            for(k = 0; k < this.numColumns; k++)
            {
               this._paddingsMap[k] = 0;
               for(i = 0; i < len; i++)
               {
                  if(k >= this._itemSectionsList[i].start && k <= this._itemSectionsList[i].end)
                  {
                     this._paddingsMap[k] = this._itemSectionsList[i].id;
                     break;
                  }
               }
            }
         }
      }
      
      public function get dropMode() : int
      {
         return this._dropMode;
      }
      
      public function set dropMode(value:int) : void
      {
         this._dropMode = value;
      }
      
      public function get useContextMgr() : Boolean
      {
         return this._useContextMgr;
      }
      
      public function set useContextMgr(value:Boolean) : void
      {
         this._useContextMgr = value;
      }
      
      public function get initFindSelection() : *
      {
         return this._initFindSelection;
      }
      
      public function set initFindSelection(value:Boolean) : void
      {
         this._initFindSelection = value;
      }
      
      public function get ignoreGridPosition() : *
      {
         return this._ignoreGridPosition;
      }
      
      public function set ignoreGridPosition(value:Boolean) : void
      {
         this._ignoreGridPosition = value;
      }
      
      override public function set visible(value:Boolean) : void
      {
         super.visible = value;
         this.updateScrollBar();
      }
      
      override public function set focused(value:Number) : void
      {
         if(value > 0 && value != focused)
         {
            if(selectedIndex < 0 && this.initFindSelection)
            {
               findSelection();
            }
         }
         super.focused = value;
      }
      
      override public function get numColumns() : uint
      {
         return this._columns;
      }
      
      public function get dropEnabled() : Boolean
      {
         return this._dropEnabled;
      }
      
      public function set dropEnabled(value:Boolean) : void
      {
         this._dropEnabled = value;
      }
      
      public function applyDrop(dragData:IDragTarget) : void
      {
         var targetIdx:int = 0;
         var itemData:ItemDataStub = dragData.getDragData() as ItemDataStub;
         var sourceRenderer:IInventorySlot = dragData as IInventorySlot;
         var isInternal:Boolean = sourceRenderer.owner == this;
         if(!this._currentDropRenderer)
         {
            if(!isInternal)
            {
               if(this._dropMode == MenuInventory.IMS_Shop)
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnBuyItem",[itemData.id,itemData.quantity,-1]));
               }
               else if(this._dropMode == MenuInventory.IMS_Container)
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnTransferItem",[itemData.id,itemData.quantity,-1]));
               }
               else if(this._dropMode == MenuInventory.IMS_Stash)
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnTakeFromStash",[itemData.id]));
               }
               else
               {
                  dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipItem",[itemData.id,-1]));
               }
            }
            return;
         }
         if(this._currentDropRenderer.isEmpty())
         {
            targetIdx = this.getDropIndex(dragData.x,dragData.y,itemData.gridSize);
         }
         else
         {
            targetIdx = int(this._currentDropRenderer.data.gridPosition);
         }
         if(isInternal)
         {
            if(this._currentDropRenderer.isEmpty())
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnMoveItem",[itemData.id,targetIdx]));
            }
            else if(this._currentDropRenderer.data.id != itemData.id)
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnMoveItems",[itemData.id,targetIdx,this._currentDropRenderer.data.id,sourceRenderer.data.gridPosition]));
            }
         }
         else if(this._dropMode == MenuInventory.IMS_Shop)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnBuyItem",[itemData.id,itemData.quantity,targetIdx]));
         }
         else if(this._dropMode == MenuInventory.IMS_Container)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnTransferItem",[itemData.id,itemData.quantity,targetIdx]));
         }
         else if(this._dropMode == MenuInventory.IMS_Stash)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnTakeFromStash",[itemData.id]));
         }
         else if(this._currentDropRenderer.isEmpty())
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipItem",[uint(itemData.id),int(targetIdx)]));
         }
         else if(CommonUtils.checkSlotsCompatibility(this._currentDropRenderer.data.slotType,sourceRenderer.data.slotType))
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnSwapItems",[this._currentDropRenderer.data.id,itemData.id,sourceRenderer.data.slotType]));
         }
         _cachedSelection = this._currentDropRenderer.index;
         this.removeUselessRows();
         if(this._currentDropRenderer)
         {
            dispatchItemClickEvent(this._currentDropRenderer);
         }
      }
      
      public function canDrop(dragData:IDragTarget) : Boolean
      {
         return true;
      }
      
      public function get dropSelection() : Boolean
      {
         return this._dropSelection;
      }
      
      public function set dropSelection(value:Boolean) : void
      {
         this._dropSelection = value;
      }
      
      public function processOver(avatar:SlotDragAvatar) : int
      {
         var sourceRenderer:IInventorySlot = null;
         var isInternal:Boolean = false;
         var gridSize:int = 0;
         var dropIdx:int = 0;
         var targetRenderer:IInventorySlot = null;
         var IndicatorClassRef:Class = null;
         var highlightRenderer:IInventorySlot = null;
         var cantUseCurrentPosition:Boolean = false;
         var highlightLabel:String = null;
         var isTargetEmpty:Boolean = false;
         var linkIdx:int = 0;
         var linkedRenderer:IInventorySlot = null;
         var freeIndx:int = 0;
         var currentDragIcon:int = int(SlotDragAvatar.ACTION_NONE);
         var showGridHighlighting:Boolean = false;
         if(avatar)
         {
            sourceRenderer = avatar.getSourceContainer() as IInventorySlot;
            isInternal = sourceRenderer.owner == this;
            if(!this._highlightIndicator)
            {
               IndicatorClassRef = getDefinitionByName(HIGHLIGHT_REF) as Class;
               this._highlightIndicator = new IndicatorClassRef() as MovieClip;
               this._highlightCanvas.addChild(this._highlightIndicator);
            }
            gridSize = int(avatar.data.gridSize);
            dropIdx = this.getDropIndex(avatar.x,avatar.y,gridSize);
            if(dropIdx < 0 || dropIdx > _renderers.length)
            {
               this._currentDropRenderer = null;
               return SlotDragAvatar.ACTION_NONE;
            }
            targetRenderer = _renderers[dropIdx] as IInventorySlot;
            this._currentDropRenderer = targetRenderer;
            if(targetRenderer)
            {
               if(!this.isSectionCorrect(targetRenderer.index,sourceRenderer.data))
               {
                  this._currentDropRenderer = null;
                  cantUseCurrentPosition = false;
                  highlightLabel = HIGHLIGHT_LABEL_DENIDED;
                  currentDragIcon = int(SlotDragAvatar.ACTION_ERROR);
               }
               else
               {
                  cantUseCurrentPosition = false;
                  highlightLabel = HIGHLIGHT_LABEL_ACCEPT;
                  isTargetEmpty = Boolean(targetRenderer.isEmpty());
                  currentDragIcon = int(SlotDragAvatar.ACTION_GRID_DROP);
                  if(Boolean(targetRenderer.uplink) && targetRenderer.uplink.data.id != sourceRenderer.data.id)
                  {
                     this._currentDropRenderer = null;
                     if(isInternal)
                     {
                        highlightLabel = HIGHLIGHT_LABEL_DENIDED;
                        currentDragIcon = int(SlotDragAvatar.ACTION_ERROR);
                     }
                     else
                     {
                        highlightLabel = HIGHLIGHT_LABEL_ACCEPT;
                        cantUseCurrentPosition = true;
                        currentDragIcon = int(SlotDragAvatar.ACTION_GRID_DROP);
                     }
                  }
                  else if(!isTargetEmpty)
                  {
                     currentDragIcon = int(SlotDragAvatar.ACTION_GRID_SWAP);
                     if(this.dropMode == MenuInventory.IMS_Shop && !isInternal)
                     {
                        cantUseCurrentPosition = false;
                        currentDragIcon = int(SlotDragAvatar.ACTION_GRID_DROP);
                     }
                     else if(Boolean(sourceRenderer) && (sourceRenderer.owner != this || targetRenderer.data.gridSize != sourceRenderer.data.gridSize))
                     {
                        if(!CommonUtils.checkSlotsCompatibility(targetRenderer.data.slotType,sourceRenderer.data.slotType))
                        {
                           this._currentDropRenderer = null;
                           if(isInternal)
                           {
                              highlightLabel = HIGHLIGHT_LABEL_DENIDED;
                              currentDragIcon = int(SlotDragAvatar.ACTION_ERROR);
                           }
                           else
                           {
                              highlightLabel = HIGHLIGHT_LABEL_ACCEPT;
                              cantUseCurrentPosition = true;
                              currentDragIcon = int(SlotDragAvatar.ACTION_GRID_DROP);
                           }
                        }
                     }
                  }
               }
               if(this._currentDropRenderer != null && gridSize > 1)
               {
                  for(linkIdx = dropIdx + this._columns; linkIdx > _renderers.length; )
                  {
                     this.addRow();
                  }
                  linkedRenderer = _renderers[linkIdx] as IInventorySlot;
                  if(!linkedRenderer.isEmpty() && linkedRenderer.data.id != sourceRenderer.data.id)
                  {
                     this._currentDropRenderer = null;
                     if(isInternal)
                     {
                        highlightLabel = HIGHLIGHT_LABEL_DENIDED;
                        currentDragIcon = int(SlotDragAvatar.ACTION_ERROR);
                     }
                     else
                     {
                        highlightLabel = HIGHLIGHT_LABEL_NONE;
                        currentDragIcon = int(SlotDragAvatar.ACTION_GRID_DROP);
                     }
                  }
               }
               highlightRenderer = targetRenderer;
               if(cantUseCurrentPosition)
               {
                  freeIndx = this.findItemPlace(sourceRenderer.data);
                  highlightRenderer = _renderers[freeIndx] as IInventorySlot;
               }
               if(this.mcStateDropTarget)
               {
                  this.mcStateDropTarget.visible = true;
               }
               this._highlightIndicator.x = highlightRenderer.x;
               this._highlightIndicator.y = highlightRenderer.y;
               this._highlightIndicator.width = this.gridSquareSize;
               this._highlightIndicator.height = this.gridSquareSize * gridSize;
               this._highlightIndicator.gotoAndStop(highlightLabel);
               this._highlightIndicator.visible = true;
            }
         }
         else if(this._highlightIndicator)
         {
            this._highlightCanvas.removeChild(this._highlightIndicator);
            this._highlightIndicator = null;
            if(this.mcStateDropTarget)
            {
               this.mcStateDropTarget.visible = false;
            }
         }
         return currentDragIcon;
      }
      
      protected function isSectionCorrect(targetIdx:int, itemData:ItemDataStub) : Boolean
      {
         var targetSection:ItemSectionData = null;
         var curColumn:int = 0;
         if(itemData.sectionId < 0)
         {
            return true;
         }
         targetSection = this.getItemSection(itemData.sectionId);
         if(targetSection)
         {
            curColumn = this.getColumn(targetIdx);
            if(curColumn < targetSection.start || curColumn > targetSection.end)
            {
               return false;
            }
            return true;
         }
         return false;
      }
      
      protected function handleSlotChanged(event:ListEvent) : void
      {
         var curScrollValue:Number = NaN;
         var itemY:int = 0;
         var itemHeight:int = 0;
         if(!this.handleScrollBar)
         {
            return;
         }
         var currentSlot:SlotBase = event.itemRenderer as SlotBase;
         if(currentSlot)
         {
            curScrollValue = Number(this.scrollBar.position);
            itemY = currentSlot.y;
            itemHeight = currentSlot.gridSize * this._gridSquareSize;
            if(itemY + itemHeight > this._gridRenderHeight + curScrollValue)
            {
               this.scrollBar.position = itemY + itemHeight - this._gridRenderHeight;
            }
            else if(itemY < curScrollValue)
            {
               this.scrollBar.position = itemY;
            }
         }
         var inventorySlot:SlotInventoryGrid = event.itemRenderer as SlotInventoryGrid;
         if(inventorySlot)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnInventoryItemSelected",[inventorySlot.data.id]));
         }
         this.updateScrollBar();
      }
      
      protected function currentDropIsPossible(dropData:ItemDataStub) : Boolean
      {
         return true;
      }
      
      protected function getDropRenderer() : IInventorySlot
      {
         return this._currentDropRenderer;
      }
      
      private function getDropIndex(stageX:Number, stageY:Number, gridSize:int = 1) : int
      {
         var targetRenderer:IBaseSlot = null;
         var localPoint:Point = globalToLocal(new Point(stageX,stageY));
         var targetCol:int = Math.min(this._columns - 1,Math.ceil(localPoint.x / this.gridSquareSize) - 1);
         var yOffset:int = gridSize == 2 ? int(this.gridSquareSize / 2) : 0;
         var targetRow:int = Math.ceil((localPoint.y - yOffset + this._offset) / this.gridSquareSize) - 1;
         var targetIdx:int = targetCol + targetRow * this._columns;
         if(targetIdx > -1 && targetIdx < _renderers.length)
         {
            targetRenderer = _renderers[targetIdx] as IBaseSlot;
            if(targetRenderer)
            {
               return targetRenderer.index;
            }
         }
         return -1;
      }
      
      public function get scrollBar() : Object
      {
         return this._scrollBar;
      }
      
      public function set scrollBar(value:Object) : void
      {
         this._scrollBarValue = value;
         invalidate(InvalidationType.SCROLL_BAR);
      }
      
      public function get scrollPosition() : uint
      {
         return this.offset;
      }
      
      public function set scrollPosition(value:uint) : void
      {
         this.offset = value;
      }
      
      public function get gridSquareSize() : Number
      {
         return this._gridSquareSize;
      }
      
      public function set gridSquareSize(value:Number) : void
      {
         this._gridSquareSize = value;
      }
      
      public function get elementGridSquareOffset() : Number
      {
         return this._elementGridSquareOffset;
      }
      
      public function set elementGridSquareOffset(value:Number) : void
      {
         this._elementGridSquareOffset = value;
      }
      
      public function get rows() : uint
      {
         return this._rows;
      }
      
      public function set rows(value:uint) : void
      {
         this._rows = value;
      }
      
      public function get columns() : uint
      {
         return this._columns;
      }
      
      public function set columns(value:uint) : void
      {
         this._columns = value;
      }
      
      public function get offset() : uint
      {
         return this._offset;
      }
      
      public function set offset(value:uint) : void
      {
         if(value > -1)
         {
            this._offset = value;
         }
         _canvas.y = -this._offset;
         this.validateRenderersSpecial();
         this._highlightCanvas.y = _canvas.y;
         this.updateScrollBar();
      }
      
      public function getRendererNoUplink(index:uint) : IListItemRenderer
      {
         if(index < 0 || index >= _renderers.length)
         {
            return null;
         }
         return _renderers[index] as IListItemRenderer;
      }
      
      override public function getRendererAt(index:uint, offset:int = 0) : IListItemRenderer
      {
         if(index < 0 || index >= _renderers.length)
         {
            return null;
         }
         var renderer:IInventorySlot = _renderers[index] as IInventorySlot;
         while(Boolean(renderer) && Boolean(renderer.uplink))
         {
            renderer = renderer.uplink;
         }
         return renderer as IBaseSlot;
      }
      
      protected function saveItemPosition(targetItem:ItemDataStub) : void
      {
         if(!this._ignoreGridPosition)
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnSaveItemGridPosition",[targetItem.id,targetItem.gridPosition]));
         }
      }
      
      override protected function draw() : void
      {
         super.draw();
         if(isInvalid(InvalidationType.SCROLL_BAR))
         {
            this.createScrollBar();
            this.updateScrollBar();
         }
         if(isInvalid(InvalidationType.DATA))
         {
            this.updateScrollBar();
         }
      }
      
      public function calculateColumnsAndRows(numItems:uint) : void
      {
         if(this.gridSquareSize > 0)
         {
            this.columns = Math.floor(this.actualWidth / this.gridSquareSize);
            if(this.columns < 1)
            {
               this.columns = 1;
            }
         }
         this.rows = Math.ceil(numItems / this.columns);
      }
      
      public function getSlotByID(slotID:int) : SlotBase
      {
         var i:int = 0;
         for(i = 0; i < _renderers.length; i++)
         {
            if(Boolean(_renderers[i].data) && _renderers[i].data.id == slotID)
            {
               return _renderers[i] as SlotBase;
            }
         }
         return null;
      }
      
      override public function updateItems(itemsList:Array) : void
      {
         var curDataStub:* = undefined;
         var moreDataStub:* = undefined;
         var curRenderer:IBaseSlot = null;
         this._specialCachedSelection = _cachedSelection ? _cachedSelection : selectedIndex;
         selectedIndex = -1;
         this.lastSelectedSection = -1;
         for each(curDataStub in itemsList)
         {
            for each(curRenderer in _renderers)
            {
               if(!curRenderer.isEmpty() && curRenderer.data.id == curDataStub.id && curRenderer.data.gridPosition != curDataStub.gridPosition)
               {
                  curRenderer.cleanup();
                  break;
               }
            }
         }
         for each(moreDataStub in itemsList)
         {
            this.appendItemData(moreDataStub,!InputManager.getInstance().isMouse());
         }
         if(this._specialCachedSelection != -1)
         {
            ReselectIndexIfInvalid(this._specialCachedSelection);
            this._specialCachedSelection = -1;
         }
         validateNow();
         this.updateScrollBar();
      }
      
      override public function updateItemData(itemData:Object) : void
      {
         this._specialCachedSelection = _cachedSelection ? _cachedSelection : selectedIndex;
         selectedIndex = -1;
         this.appendItemData(itemData);
         if(this._specialCachedSelection != -1)
         {
            ReselectIndexIfInvalid(this._specialCachedSelection);
            this._specialCachedSelection = -1;
         }
         validateNow();
         this.updateScrollBar();
      }
      
      override public function removeItem(itemId:uint, keepSelectionIdx:Boolean = false) : void
      {
         var removedIdx:int = this.removeItemData(itemId);
         if(!keepSelectionIdx)
         {
            this._specialCachedSelection = selectedIndex;
            if(selectedIndex == removedIdx)
            {
               ReselectIndexIfInvalid(removedIdx);
            }
         }
         validateNow();
         this.updateScrollBar();
      }
      
      protected function appendItemData(itemData:Object, ignoreCollisions:Boolean = false) : void
      {
         var dataStub:ItemDataStub = itemData as ItemDataStub;
         if(dataStub)
         {
            this.removeItemData(dataStub.id);
            this.populateItemData(dataStub,InputManager.getInstance().isMouse(),ignoreCollisions);
            this.removeUselessRows();
         }
      }
      
      protected function removeItemData(itemId:uint) : int
      {
         var targetRenderer:IInventorySlot = null;
         var targetIndex:* = getIdIndex(itemId);
         if(targetIndex > -1)
         {
            targetRenderer = _renderers[targetIndex] as IInventorySlot;
            this.removeUplinks(targetRenderer);
            targetRenderer.cleanup();
            targetRenderer.data = null;
            --_renderersCount;
         }
         this.removeUselessRows();
         return targetIndex;
      }
      
      public function removeAllItemData() : void
      {
         var targetRenderer:IInventorySlot = null;
         for(var targetIndex:* = int(_renderers.length - 1); targetIndex >= 0; targetIndex--)
         {
            targetRenderer = _renderers[targetIndex] as IInventorySlot;
            this.removeUplinks(targetRenderer);
            targetRenderer.cleanup();
            targetRenderer.data = null;
            --_renderersCount;
         }
         this.removeUselessRows();
         _renderersCount = 0;
      }
      
      protected function removeUplinks(targetRenderer:IInventorySlot) : void
      {
         var curItem:IInventorySlot = null;
         var len:int = int(_renderers.length);
         for(var i:int = 0; i < len; i++)
         {
            curItem = _renderers[i] as IInventorySlot;
            if(curItem.uplink == targetRenderer)
            {
               curItem.uplink = null;
            }
         }
      }
      
      override protected function populateData() : void
      {
         var isMouse:Boolean = false;
         var gridPositionsMatter:Boolean = false;
         var oldSelection:* = undefined;
         var neededCellCount:int = 0;
         var curDataStub:ItemDataStub = null;
         var minRenderersNeeded:int = 0;
         var i:* = undefined;
         var k:int = 0;
         var createdRawsCount:int = 0;
         var columnsMap:Object = null;
         var columnsMap_plain:Array = null;
         var sectionsCount:int = 0;
         var targetDataStub:ItemDataStub = null;
         var curSectionData:ItemSectionData = null;
         var sectionColsCount:int = 0;
         var columnData:Array = null;
         var sectionData:ItemSectionData = null;
         var targetList:Array = null;
         var len:int = 0;
         var minColumnIdx:int = 0;
         var minColumnSize:int = 0;
         var sectionStartIdx:int = 0;
         var targetIdx:int = 0;
         var rendererInstance:IInventorySlot = null;
         var curSize:int = 0;
         var linkIdx:int = 0;
         var linkedRenderer:IInventorySlot = null;
         var nonPositionedItems:Array = null;
         super.populateData();
         if(_data)
         {
            this.updateColumnsPaddingMap();
            isMouse = InputManager.getInstance().isMouse();
            gridPositionsMatter = isMouse && !this.ignoreNextGridPosition;
            oldSelection = selectedIndex;
            if(gridPositionsMatter)
            {
               data.sortOn("gridPosition",Array.NUMERIC | Array.DESCENDING);
            }
            else
            {
               this.ignoreNextGridPosition = false;
               this.sortList(data);
            }
            this.cleanUpRenderers();
            neededCellCount = 0;
            for each(curDataStub in _data)
            {
               neededCellCount += curDataStub.gridSize;
            }
            minRenderersNeeded = Math.ceil(neededCellCount / this._columns) * this._columns;
            while(minRenderersNeeded > _renderers.length)
            {
               _renderers.push(this.spawnRenderer(_renderers.length));
            }
            if(!isMouse)
            {
               createdRawsCount = 0;
               columnsMap = {};
               sectionsCount = this._itemSectionsList ? int(this._itemSectionsList.length) : -1;
               if(sectionsCount > 0)
               {
                  for(i = 0; i < sectionsCount; i++)
                  {
                     curSectionData = this._itemSectionsList[i];
                     sectionColsCount = curSectionData.end - curSectionData.start + 1;
                     columnData = [];
                     for(k = 0; k < sectionColsCount; k++)
                     {
                        columnData[k] = 0;
                     }
                     columnsMap[i] = columnData;
                  }
               }
               else
               {
                  columnsMap_plain = [];
                  for(k = 0; k < this.columns; k++)
                  {
                     columnsMap_plain.push(0);
                  }
               }
               for each(targetDataStub in _data)
               {
                  sectionData = this.getItemSection(targetDataStub.sectionId);
                  if(sectionsCount > 0)
                  {
                     targetList = columnsMap[targetDataStub.sectionId];
                  }
                  else
                  {
                     targetList = columnsMap_plain;
                  }
                  if(targetList)
                  {
                     len = int(targetList.length);
                     minColumnIdx = 0;
                     minColumnSize = int(targetList[0]);
                     for(i = 1; i < len; i++)
                     {
                        curSize = int(targetList[i]);
                        if(minColumnSize > curSize)
                        {
                           minColumnSize = curSize;
                           minColumnIdx = i;
                        }
                     }
                     targetList[minColumnIdx] += 1;
                     sectionStartIdx = sectionData ? int(sectionData.start) : 0;
                     targetIdx = sectionStartIdx + minColumnIdx + minColumnSize * this.numColumns;
                     rendererInstance = this.getRendererNoUplink(targetIdx) as IInventorySlot;
                     while(!rendererInstance)
                     {
                        this.addRow();
                        rendererInstance = this.getRendererNoUplink(targetIdx) as IInventorySlot;
                     }
                     targetDataStub.gridPosition = targetIdx;
                     rendererInstance.data = targetDataStub;
                     ++_renderersCount;
                     if(targetDataStub.gridSize > 1)
                     {
                        targetList[minColumnIdx] += 1;
                        linkIdx = targetIdx + this._columns;
                        while(linkIdx >= _renderers.length)
                        {
                           this.addRow();
                        }
                        linkedRenderer = _renderers[linkIdx] as IInventorySlot;
                        linkedRenderer.uplink = rendererInstance;
                     }
                  }
                  else
                  {
                     trace("GFX [SlotsListGrid] {WARNING} CAN\'T POPULATE DATA --------------- ");
                  }
               }
            }
            else
            {
               nonPositionedItems = new Array();
               for each(curDataStub in _data)
               {
                  if(gridPositionsMatter && curDataStub.gridPosition < 0)
                  {
                     nonPositionedItems.push(curDataStub);
                  }
                  else
                  {
                     this.populateItemData(curDataStub,gridPositionsMatter);
                  }
               }
               if(nonPositionedItems.length > 0)
               {
                  this.sortList(nonPositionedItems);
                  for each(curDataStub in nonPositionedItems)
                  {
                     this.populateItemData(curDataStub,false);
                  }
               }
            }
         }
         if(this._initFindSelection || oldSelection == -1)
         {
            findSelection();
         }
         else
         {
            ReselectIndexIfInvalid(oldSelection);
         }
         invalidate(InvalidationType.SCROLL_BAR);
         this.removeUselessRows();
         this.validateRenderersSpecial();
      }
      
      public function setCurrentSort(sortIndex:int) : void
      {
         if(this._lastSetSort != sortIndex)
         {
            this._lastSetSort = sortIndex;
         }
      }
      
      protected function sortList(list:Array) : void
      {
         if(!list)
         {
            return;
         }
         switch(this._lastSetSort)
         {
            case MenuInventory.INV_SORT_MODE_INVALID:
            case MenuInventory.INV_SORT_MODE_TYPE:
               trace("GFX ------------ Applying Type sort ---------------------");
               list.sort(this.inventorySorter_Type);
               break;
            case MenuInventory.INV_SORT_MODE_PRICE:
               trace("GFX ------------ Applying Price sort ---------------------");
               list.sort(this.inventorySorter_Price);
               break;
            case MenuInventory.INV_SORT_MODE_WEIGHT:
               trace("GFX ------------ Applying Weight sort ---------------------");
               list.sort(this.inventorySorter_Weight);
               break;
            case MenuInventory.INV_SORT_MODE_DURABILTIY:
               trace("GFX ------------ Applying Durability sort ---------------------");
               list.sort(this.inventorySorter_Durability);
               break;
            case MenuInventory.INV_SORT_MODE_RARITY:
               trace("GFX ------------ Applying Rarity sort ---------------------");
               list.sort(this.inventorySorter_Rarity);
         }
      }
      
      protected function inventorySorter_Type(element1:ItemDataStub, element2:ItemDataStub) : Number
      {
         if(element1.isNew && !element2.isNew)
         {
            return -1;
         }
         if(!element1.isNew && element2.isNew)
         {
            return 1;
         }
         if(element1.sortGroup != element2.sortGroup)
         {
            return element1.sortGroup > element2.sortGroup ? 1 : -1;
         }
         if(element1.disableAction && !element2.disableAction)
         {
            return 1;
         }
         if(!element1.disableAction && element2.disableAction)
         {
            return -1;
         }
         if(element1.category == "edibles" && element2.category != "edibles")
         {
            return 1;
         }
         if(element1.category != "edibles" && element2.category == "edibles")
         {
            return -1;
         }
         if(element1.isEquipped && !element2.isEquipped)
         {
            return -1;
         }
         if(!element1.isEquipped && element2.isEquipped)
         {
            return 1;
         }
         if(element1.slotType != element2.slotType)
         {
            if(element1.slotType == InventorySlotType.InvalidSlot)
            {
               return 1;
            }
            if(element2.slotType == InventorySlotType.InvalidSlot)
            {
               return -1;
            }
            return InventorySlotType.getSortingWeight(element1.slotType) - InventorySlotType.getSortingWeight(element2.slotType);
         }
         if(element1.category != element2.category)
         {
            return element1.category > element2.category ? -1 : 1;
         }
         if(element1.quality != element2.quality)
         {
            return element2.quality - element1.quality;
         }
         return element1.id - element2.id;
      }
      
      protected function inventorySorter_Price(element1:ItemDataStub, element2:ItemDataStub) : Number
      {
         if(element1.isNew && !element2.isNew)
         {
            return -1;
         }
         if(!element1.isNew && element2.isNew)
         {
            return 1;
         }
         if(element1.price != element2.price)
         {
            return element2.price - element1.price;
         }
         return this.inventorySorter_Type(element1,element2);
      }
      
      protected function inventorySorter_Weight(element1:ItemDataStub, element2:ItemDataStub) : Number
      {
         if(element1.isNew && !element2.isNew)
         {
            return -1;
         }
         if(!element1.isNew && element2.isNew)
         {
            return 1;
         }
         if(element1.weight != element2.weight)
         {
            return element2.weight - element1.weight;
         }
         return this.inventorySorter_Type(element1,element2);
      }
      
      protected function inventorySorter_Durability(element1:ItemDataStub, element2:ItemDataStub) : Number
      {
         if(element1.isNew && !element2.isNew)
         {
            return -1;
         }
         if(!element1.isNew && element2.isNew)
         {
            return 1;
         }
         if(element1.durability != element2.durability)
         {
            return element1.durability - element2.durability;
         }
         return this.inventorySorter_Type(element1,element2);
      }
      
      protected function inventorySorter_Rarity(element1:ItemDataStub, element2:ItemDataStub) : Number
      {
         if(element1.isNew && !element2.isNew)
         {
            return -1;
         }
         if(!element1.isNew && element2.isNew)
         {
            return 1;
         }
         if(element1.quality != element2.quality)
         {
            return element2.quality - element1.quality;
         }
         return this.inventorySorter_Type(element1,element2);
      }
      
      protected function tryRestoreItemPosition(targetDataStub:ItemDataStub) : int
      {
         var cachedPosition:int = 0;
         var curSlot:IBaseSlot = null;
         if(this._cachedItemPositions)
         {
            cachedPosition = int(this._cachedItemPositions[targetDataStub.id]);
            if(cachedPosition)
            {
               curSlot = this.getRendererAt(cachedPosition) as IBaseSlot;
               if(Boolean(curSlot) && curSlot.isEmpty())
               {
                  return cachedPosition;
               }
            }
         }
         return -1;
      }
      
      protected function populateItemData(targetDataStub:ItemDataStub, gridPositionMatters:Boolean, ignoreCollisions:Boolean = false) : IInventorySlot
      {
         var linkIdx:int = 0;
         var linkedRenderer:IInventorySlot = null;
         if(targetDataStub.invisible)
         {
            return null;
         }
         var startingPosition:int = targetDataStub.gridPosition;
         if(targetDataStub.gridPosition < 0 || !gridPositionMatters || !this.isItemPlaceValid(targetDataStub.gridPosition,targetDataStub.gridSize,targetDataStub.sectionId))
         {
            targetDataStub.gridPosition = this.findItemPlace(targetDataStub);
         }
         var rendererIdx:int = targetDataStub.gridPosition;
         var rendererInstance:IInventorySlot = this.getRendererAt(rendererIdx) as IInventorySlot;
         while(!rendererInstance)
         {
            this.addRow();
            rendererInstance = this.getRendererAt(rendererIdx) as IInventorySlot;
         }
         if(!rendererInstance.isEmpty() && rendererInstance.data.id != targetDataStub.id && !ignoreCollisions)
         {
            targetDataStub.gridPosition = this.findItemPlace(targetDataStub);
            rendererInstance = this.getRendererAt(rendererIdx) as IInventorySlot;
         }
         if(targetDataStub.gridPosition != startingPosition)
         {
            this.saveItemPosition(targetDataStub);
         }
         rendererInstance.data = targetDataStub;
         ++_renderersCount;
         if(targetDataStub.gridSize > 1)
         {
            linkIdx = rendererIdx + this._columns;
            while(linkIdx >= _renderers.length)
            {
               this.addRow();
            }
            linkedRenderer = _renderers[linkIdx] as IInventorySlot;
            linkedRenderer.uplink = rendererInstance;
         }
         return rendererInstance;
      }
      
      protected function isItemPlaceValid(rendererIdx:int, size:int, sectionId:int = -1) : Boolean
      {
         var targetSection:ItemSectionData = null;
         var curColumn:int = 0;
         var downIndex:* = undefined;
         if(sectionId != -1)
         {
            targetSection = this.getItemSection(sectionId);
            if(targetSection)
            {
               curColumn = this.getColumn(rendererIdx);
               if(curColumn < targetSection.start || curColumn > targetSection.end)
               {
                  return false;
               }
            }
         }
         if(rendererIdx >= _renderers.length)
         {
            return true;
         }
         var renderer:SlotBase = _renderers[rendererIdx] as SlotBase;
         if(renderer.isEmpty() && (renderer as IInventorySlot).uplink == null)
         {
            if(size <= 1)
            {
               return true;
            }
            downIndex = rendererIdx + this._columns;
            if(downIndex >= _renderers.length || _renderers[downIndex].isEmpty())
            {
               return true;
            }
         }
         return false;
      }
      
      protected function getSectionRenderers(sectionId:int) : Vector.<IBaseSlot>
      {
         var curRenderer:IBaseSlot = null;
         var count:int = int(_renderers.length);
         var resultList:Vector.<IBaseSlot> = new Vector.<IBaseSlot>();
         for(var i:int = 0; i < count; i++)
         {
            curRenderer = _renderers[i];
            if(!curRenderer.isEmpty() && curRenderer.data.sectionId == sectionId)
            {
               resultList.push(curRenderer);
            }
         }
         return resultList;
      }
      
      protected function getSectionByRendererIdx(rendererIdx:int) : ItemSectionData
      {
         var len:int = 0;
         var itemCol:int = 0;
         var i:* = undefined;
         var curSectionData:ItemSectionData = null;
         if(this._itemSectionsList)
         {
            len = int(this._itemSectionsList.length);
            itemCol = this.getColumn(rendererIdx);
            for(i = 0; i < len; i++)
            {
               curSectionData = this._itemSectionsList[i] as ItemSectionData;
               if(Boolean(curSectionData) && Boolean(itemCol >= curSectionData.start) && itemCol <= curSectionData.end)
               {
                  return curSectionData;
               }
            }
         }
         return null;
      }
      
      protected function getItemSection(sectionId:int) : ItemSectionData
      {
         var len:int = 0;
         var i:* = undefined;
         var curSectionData:ItemSectionData = null;
         if(this._itemSectionsList)
         {
            len = int(this._itemSectionsList.length);
            for(i = 0; i < len; i++)
            {
               curSectionData = this._itemSectionsList[i] as ItemSectionData;
               if(Boolean(curSectionData) && curSectionData.id == sectionId)
               {
                  return curSectionData;
               }
            }
         }
         return null;
      }
      
      override public function applySelectionContext() : void
      {
         var curSectionData:ItemSectionData = null;
         var targetFrame:Number = NaN;
         super.applySelectionContext();
         if(!this._itemSectionsList)
         {
            return;
         }
         var targetSection:ItemSectionData = this.getSectionByRendererIdx(_selectedIndex);
         var targetSectionId:int = -1;
         if(targetSection)
         {
            targetSectionId = int(targetSection.id);
         }
         this.lastSelectedSection = targetSectionId;
         var len:int = int(this._itemSectionsList.length);
         for(var i:* = 0; i < len; i++)
         {
            curSectionData = this._itemSectionsList[i] as ItemSectionData;
            if(Boolean(curSectionData) && Boolean(curSectionData.border))
            {
               targetFrame = 1;
               if(_activeSelectionVisible)
               {
                  targetFrame = curSectionData.id == this.lastSelectedSection ? 2 : 1;
               }
               else
               {
                  targetFrame = 1;
               }
               curSectionData.border.gotoAndStop(targetFrame);
            }
         }
      }
      
      protected function findItemPlace(targetDataStub:ItemDataStub, depth:uint = 0) : int
      {
         var placeIdx:int = this.getFreeRendererIdx(targetDataStub);
         if(placeIdx > -1)
         {
            return placeIdx;
         }
         if(depth > this.DEBUG_REC_LIMIT)
         {
            throw new Error("Can\'t find place for item in the grid. Something is realy wrong!");
         }
         this.addRow();
         return this.findItemPlace(targetDataStub,depth + 1);
      }
      
      protected function getFreeRendererIdx(targetDataStub:ItemDataStub) : int
      {
         var len:uint = _renderers.length;
         var reqSize:uint = uint(targetDataStub.gridSize);
         for(var i:int = 0; i < len; i++)
         {
            if(this.isItemPlaceValid(i,targetDataStub.gridSize,targetDataStub.sectionId))
            {
               return i;
            }
         }
         return -1;
      }
      
      protected function isUplink(idx:int) : Boolean
      {
         var targetRenderer:IInventorySlot = _renderers[idx] as IInventorySlot;
         if(targetRenderer)
         {
            return targetRenderer.uplink != null;
         }
         return false;
      }
      
      protected function addRow() : void
      {
         var idx:int = int(_renderers.length);
         for(var count:int = idx + this._columns; idx < count; )
         {
            _renderers.push(this.spawnRenderer(_renderers.length));
            idx++;
         }
         invalidate(InvalidationType.SCROLL_BAR);
      }
      
      protected function removeUselessRows() : void
      {
         var curRenderer:IBaseSlot = null;
         var curRendererData:ItemDataStub = null;
         var curRdr:IInventorySlot = null;
         var minNumRows:uint = this._numRowsVisible;
         this.highestRowNeeded = 0;
         var rdrCount:int = int(_renderers.length);
         for(var i:int = 0; i < rdrCount; i++)
         {
            curRenderer = _renderers[i];
            if(Boolean(curRenderer) && !curRenderer.isEmpty())
            {
               curRendererData = curRenderer.data as ItemDataStub;
               this.highestRowNeeded = curRendererData.gridPosition / this._columns + curRendererData.gridSize;
               if(this.highestRowNeeded > minNumRows)
               {
                  minNumRows = this.highestRowNeeded;
               }
            }
         }
         this.highestRowNeeded = minNumRows;
         var targetRendererCount:* = minNumRows * this._columns;
         while(targetRendererCount > _renderers.length)
         {
            this.addRow();
         }
         while(targetRendererCount < _renderers.length)
         {
            curRdr = _renderers.pop() as IInventorySlot;
            this._discardedRendererPool.push(curRdr);
            if(curRdr)
            {
               curRdr.cleanup();
               _canvas.removeChild(curRdr as DisplayObject);
            }
         }
         invalidate(InvalidationType.SCROLL_BAR);
      }
      
      private function createInitRenderers() : void
      {
         var renderer:IInventorySlot = null;
         this._totalRenderers = this.rows * this.columns;
         _renderers = new Vector.<IBaseSlot>(this._totalRenderers);
         for(var index:* = int(this._totalRenderers - 1); index >= 0; index--)
         {
            renderer = this.spawnRenderer(index);
            _renderers[index] = renderer;
         }
      }
      
      public function updateRendererBounds() : void
      {
         if(this.gridMask)
         {
            this._renderBounds = this.gridMask.getBounds(stage);
            invalidateData();
         }
      }
      
      protected function get renderBounds() : Rectangle
      {
         if(!this.ignoreValidationOpt && this._renderBounds == null && Boolean(this.gridMask))
         {
            this._renderBounds = this.gridMask.getBounds(stage);
         }
         return this._renderBounds;
      }
      
      private function spawnRenderer(index:uint) : IInventorySlot
      {
         var newRenderer:IInventorySlot = null;
         if(this._discardedRendererPool.length > 0)
         {
            newRenderer = this._discardedRendererPool.pop();
         }
         else
         {
            newRenderer = new _slotRendererRef() as IInventorySlot;
         }
         newRenderer.index = index;
         if(newRenderer is SlotBase)
         {
            (newRenderer as SlotBase).name = "Instance: " + String(index);
            (newRenderer as SlotBase).validationBounds = this.renderBounds;
         }
         newRenderer.useContextMgr = this._useContextMgr;
         _canvas.addChild(newRenderer as DisplayObject);
         this.repositionRenderer(index,newRenderer);
         setupRenderer(newRenderer);
         return newRenderer;
      }
      
      private function repositionRenderer(index:int, renderer:IInventorySlot) : *
      {
         var rendererColumn:int = this.getColumn(index);
         var rendererRow:int = this.getRow(index);
         var sectionPadding:uint = 0;
         if(this._paddingsMap)
         {
            sectionPadding = this._paddingsMap[rendererColumn] * SECTION_PADDING;
         }
         renderer.x = rendererColumn * this._gridSquareSize + this._elementGridSquareOffset * rendererColumn + sectionPadding;
         renderer.y = rendererRow * this._gridSquareSize + this._elementGridSquareOffset * rendererRow;
      }
      
      private function cleanUpRenderers() : void
      {
         var renderer:IInventorySlot = null;
         for each(renderer in _renderers)
         {
            if(renderer)
            {
               renderer.cleanup();
            }
         }
         _renderersCount = 0;
      }
      
      protected function validateRenderersSpecial() : void
      {
         var currentRenderer:SlotBase = null;
         var minRowsValidAtStart:int = this._numRowsVisible * this._columns;
         for(var i:* = 0; i < _renderers.length; i++)
         {
            currentRenderer = _renderers[i] as SlotBase;
            if(Boolean(currentRenderer) && currentRenderer.awaitingCompleteValidation)
            {
               currentRenderer.validateNow();
               if(Boolean(i <= minRowsValidAtStart) && Boolean(currentRenderer) && currentRenderer.awaitingCompleteValidation)
               {
                  currentRenderer.forceValidateNow();
               }
            }
         }
      }
      
      protected function scrollList(delta:int) : void
      {
         this.scrollPosition -= delta;
      }
      
      protected function handleScroll(event:Event) : void
      {
         this.scrollPosition = this._scrollBar.position;
      }
      
      protected function onScroll(event:MouseEvent) : void
      {
         if(this._maxOffset > 0)
         {
            if(event.delta > 0)
            {
               this._scrollBar.position -= CommonConstants.INVENTORY_GRID_SIZE;
            }
            else
            {
               this._scrollBar.position += CommonConstants.INVENTORY_GRID_SIZE;
            }
         }
      }
      
      public function enableScrollWithPan(enable:Boolean) : void
      {
         if(enable)
         {
            addEventListener(TransformGestureEvent.GESTURE_PAN,this.onGesturePan,false,0,true);
         }
         else
         {
            removeEventListener(TransformGestureEvent.GESTURE_PAN,this.onGesturePan);
         }
      }
      
      protected function onGesturePan(event:TransformGestureEvent) : void
      {
         var dragInProgress:Boolean = SlotsTransferManager.getInstance().isDragging();
         if(!dragInProgress && this._maxOffset > 0)
         {
            this._scrollBar.position -= event.offsetY;
         }
      }
      
      override protected function handleRightJoystick(yValue:Number) : *
      {
         if(this.handlesRightJoystick)
         {
            if(this._maxOffset > 0)
            {
               this._scrollBar.position -= yValue * 40;
            }
         }
      }
      
      protected function createScrollBar() : void
      {
         if(!this._scrollBar && Boolean(this._scrollBarValue))
         {
            this._scrollBar = parent.getChildByName(this._scrollBarValue.toString()) as IScrollBar;
            this._scrollBar.addEventListener(Event.SCROLL,this.handleScroll,false,0,true);
            this._scrollBar.addEventListener(Event.CHANGE,this.handleScroll,false,0,true);
            this._scrollBar.focusTarget = this;
            this._scrollBar.tabEnabled = false;
         }
      }
      
      protected function updateScrollBar() : void
      {
         var scrollIndicator:ScrollIndicator = null;
         var pageSize:Number = NaN;
         if(this._scrollBar != null)
         {
            scrollIndicator = this._scrollBar as ScrollIndicator;
            pageSize = this._rows * this._gridSquareSize;
            this._maxOffset = (this.highestRowNeeded - this._rows) * this._gridSquareSize;
            this._maxOffset = Math.max(0,this._maxOffset);
            if(!this._maxOffset || !visible)
            {
               scrollIndicator.visible = false;
               scrollIndicator.setScrollProperties(0,0,0);
            }
            else
            {
               scrollIndicator.visible = true;
               scrollIndicator.setScrollProperties(pageSize,0,this._maxOffset);
            }
            this._scrollBar.position = this.scrollPosition;
            this._scrollBar.validateNow();
         }
      }
      
      private function dbgDumpUplinks() : void
      {
         var curItem:IInventorySlot = null;
         trace("SlotsListGrid::dbgDumpUplinks ----------------------------------------------------------- ");
         var len:int = int(_renderers.length);
         for(var i:int = 0; i < len; i++)
         {
            curItem = _renderers[i] as IInventorySlot;
            if(curItem.uplink)
            {
               trace("SlotsListGrid::dbgDumpUplinks : ",curItem);
            }
         }
         trace("SlotsListGrid::dbgDumpUplinks ----------------------------------------------------------- ");
      }
      
      override public function handleInputNavSimple(event:InputEvent) : void
      {
         var selectedRenderer:IBaseSlot = null;
         var selectionContainer:Sprite = null;
         var currentSectionData:ItemSectionData = null;
         var targetSectionId:* = 0;
         var renderersList:Vector.<IBaseSlot> = null;
         var len:int = 0;
         var i:int = 0;
         var inflateBorder:* = new Namespace("");
         var slotBase:SlotBase = null;
         var slotRenderBounds:Rectangle = null;
         if(event.handled)
         {
            return;
         }
         var details:InputDetails = event.details as InputDetails;
         var result:Boolean = false;
         var isRStick:Boolean = details.navEquivalent == NavigationCode.RIGHT_STICK_LEFT || details.navEquivalent == NavigationCode.RIGHT_STICK_RIGHT;
         if(Boolean(this._itemSectionsList && this._itemSectionsList.length > 0) && Boolean(isRStick) && event.details.value != InputValue.KEY_UP)
         {
            selectedRenderer = getSelectedRenderer() as IBaseSlot;
            if(selectedRenderer)
            {
               selectionContainer = (selectedRenderer as Sprite).parent as Sprite;
               if(selectionContainer)
               {
                  currentSectionData = this.getSectionByRendererIdx(selectedIndex);
                  targetSectionId = int(currentSectionData.id);
                  while(!result && targetSectionId < this._itemSectionsList.length && targetSectionId >= 0)
                  {
                     switch(details.navEquivalent)
                     {
                        case NavigationCode.RIGHT_STICK_LEFT:
                           targetSectionId--;
                           break;
                        case NavigationCode.RIGHT_STICK_RIGHT:
                           targetSectionId++;
                     }
                     if(targetSectionId < this._itemSectionsList.length && targetSectionId >= 0)
                     {
                        renderersList = this.getSectionRenderers(targetSectionId);
                        len = int(renderersList.length);
                        i = 0;
                        while(i < len)
                        {
                           inflateBorder = -10;
                           slotBase = renderersList[i] as SlotBase;
                           slotRenderBounds = slotBase.getGlobalSlotRect();
                           slotRenderBounds.inflate(inflateBorder,inflateBorder);
                           if(Boolean(slotBase) && this.renderBounds.intersects(slotRenderBounds))
                           {
                              selectedIndex = slotBase.index;
                              result = true;
                              break;
                           }
                           i++;
                        }
                     }
                  }
               }
            }
         }
         if(result)
         {
            event.handled = true;
         }
         super.handleInputNavSimple(event);
      }
      
      override public function getColumn(index:int) : int
      {
         if(index < 0)
         {
            return -1;
         }
         return index % this._columns;
      }
      
      override public function getRow(index:int) : int
      {
         if(index < 0)
         {
            return -1;
         }
         return index / this.columns;
      }
      
      override public function toString() : String
      {
         return "[SlotsListGrid " + name + "]";
      }
      
      override public function GetDropdownListHeight() : Number
      {
         return this._rows * this.gridSquareSize + ITEM_PADDING;
      }
   }
}

