package red.game.witcher3.slots
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.GestureEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.game.witcher3.constants.CommonConstants;
   import red.game.witcher3.constants.InventorySlotType;
   import red.game.witcher3.constants.ItemQuality;
   import red.game.witcher3.events.GridEvent;
   import red.game.witcher3.interfaces.IDragTarget;
   import red.game.witcher3.interfaces.IDropTarget;
   import red.game.witcher3.interfaces.IPaperdollSlot;
   import red.game.witcher3.managers.InputManager;
   import red.game.witcher3.menus.character_menu.CharacterModeBackground;
   import red.game.witcher3.menus.common.ItemDataStub;
   import scaleform.clik.events.InputEvent;
   import scaleform.gfx.MouseEventEx;
   
   public class SlotPaperdoll extends SlotInventoryGrid implements IPaperdollSlot, IDropTarget
   {
      
      public var tfSlotName:TextField;
      
      public var defaultIcon:MovieClip;
      
      public var iconLock:MovieClip;
      
      public var mcPreviewIcon:MovieClip;
      
      public var mcTransmogIcon:MovieClip;
      
      public var sectionId:int = -1;
      
      protected var _slotTag:String;
      
      protected var _slotTagOverride:String = "";
      
      protected var _slotTypeID:int;
      
      protected var _equipID:int;
      
      protected var _selectionMode:Boolean;
      
      protected var _darkUnselectable:Boolean = true;
      
      private var _dropEnabled:Boolean = true;
      
      private var _currentDropAction:int = 1;
      
      protected var _lockedDataProvider:String = "INVALID_STRING_PARAM!";
      
      protected var _isLocked:Boolean = false;
      
      public function SlotPaperdoll()
      {
         super();
         _defaultTooltipAnchor = "tooltipPaperdollAnchor";
         AUTO_SHOW_COLLAPSED_ICON = true;
      }
      
      public function get selectionMode() : Boolean
      {
         return this._selectionMode;
      }
      
      public function set selectionMode(value:Boolean) : void
      {
         this._selectionMode = value;
      }
      
      public function get darkUnselectable() : Boolean
      {
         return this._darkUnselectable;
      }
      
      public function set darkUnselectable(value:Boolean) : void
      {
         this._darkUnselectable = value;
      }
      
      public function get dropEnabled() : Boolean
      {
         return this._dropEnabled;
      }
      
      public function set dropEnabled(value:Boolean) : void
      {
         this._dropEnabled = value;
      }
      
      override public function set dragSelection(value:Boolean) : void
      {
         super.dragSelection = value;
         if(value && !isEmpty() && Boolean(data))
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnDragItemStarted",[data.id]));
            if(this._slotTag == "potion5")
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnExtraPotionDragStarted",[data.id]));
            }
         }
      }
      
      public function applyDrop(source:IDragTarget) : void
      {
         var itemData:ItemDataStub = source.getDragData() as ItemDataStub;
         switch(this._currentDropAction)
         {
            case SlotDragAvatar.ACTION_ENHANCE:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnApplyUpgrade",[itemData.id,this.slotTagToType(this.slotTag)]));
               break;
            case SlotDragAvatar.ACTION_OIL:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnApplyOil",[itemData.id,this.slotTagToType(this.slotTag)]));
               break;
            case SlotDragAvatar.ACTION_REPAIR:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnApplyRepairKit",[itemData.id,this.slotTagToType(this.slotTag)]));
               break;
            case SlotDragAvatar.ACTION_SHARPEN:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnApplySharpstone",[itemData.id,this.slotTagToType(this.slotTag)]));
               break;
            case SlotDragAvatar.ACTION_DIY:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnApplyDye",[itemData.id,this.slotTagToType(this.slotTag)]));
               break;
            default:
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnDropOnPaperdoll",[itemData.id,this.slotTagToType(this.slotTag),itemData.quantity]));
         }
         var ownerList:SlotsListPaperdoll = owner as SlotsListPaperdoll;
         if(ownerList)
         {
            ownerList.dispatchItemClickEvent(this);
         }
      }
      
      override public function canDrag() : Boolean
      {
         if(this._slotTag == "food")
         {
            return false;
         }
         if(Boolean(data) && Boolean(data.cantUnequip))
         {
            return false;
         }
         return super.canDrag();
      }
      
      public function canDrop(dragData:IDragTarget) : Boolean
      {
         var isSteelSword:Boolean = false;
         var isSilverSword:Boolean = false;
         var isArmor:Boolean = false;
         var canBeUpgraded:Boolean = false;
         var itemData:ItemDataStub = dragData.getDragData() as ItemDataStub;
         var slotData:ItemDataStub = _data as ItemDataStub;
         if(Boolean(itemData) && !this.isLocked)
         {
            if(Boolean(slotData) && slotData.id == itemData.id)
            {
               this._currentDropAction = SlotDragAvatar.ACTION_NONE;
               return false;
            }
            if(!this.CheckSlotsType(itemData.slotType))
            {
               if(!isEmpty() && Boolean(slotData))
               {
                  isSteelSword = slotData.slotType == InventorySlotType.SteelSword;
                  isSilverSword = slotData.slotType == InventorySlotType.SilverSword;
                  isArmor = slotData.slotType == InventorySlotType.Armor || slotData.slotType == InventorySlotType.Boots || slotData.slotType == InventorySlotType.Gloves || slotData.slotType == InventorySlotType.Pants || slotData.slotType == InventorySlotType.Quickslot2;
                  canBeUpgraded = slotData.socketsCount > slotData.socketsUsedCount && !slotData.enchanted;
                  if(itemData.isDye && isArmor && (slotData.isDyeable || slotData.quality == ItemQuality.SET && slotData.canBeDyed))
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_DIY;
                     return true;
                  }
                  if(itemData.isSteelOil && isSteelSword)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_OIL;
                     return true;
                  }
                  if(itemData.isSilverOil && isSilverSword)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_OIL;
                     return true;
                  }
                  if(itemData.isArmorUpgrade && isArmor && canBeUpgraded)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_ENHANCE;
                     return true;
                  }
                  if(itemData.isWeaponUpgrade && (isSteelSword || isSilverSword) && canBeUpgraded)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_ENHANCE;
                     return true;
                  }
                  if(itemData.isWeaponRepairKit && (isSteelSword || isSilverSword) && slotData.durability < 100)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_REPAIR;
                     return true;
                  }
                  if(itemData.isArmorRepairKit && isArmor && slotData.durability < 100)
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_REPAIR;
                     return true;
                  }
                  if(itemData.isSharpener && (isSteelSword || isSilverSword))
                  {
                     this._currentDropAction = SlotDragAvatar.ACTION_SHARPEN;
                     return true;
                  }
               }
               this._currentDropAction = SlotDragAvatar.ACTION_ERROR;
               return false;
            }
            if(isEmpty())
            {
               this._currentDropAction = SlotDragAvatar.ACTION_DROP;
            }
            else
            {
               this._currentDropAction = SlotDragAvatar.ACTION_SWAP;
            }
            return true;
         }
         this._currentDropAction = SlotDragAvatar.ACTION_ERROR;
         return false;
      }
      
      public function processOver(avatar:SlotDragAvatar) : int
      {
         if(avatar)
         {
            highlight = true;
         }
         else
         {
            highlight = false;
         }
         return this._currentDropAction;
      }
      
      public function get dropSelection() : Boolean
      {
         return _dropSelection;
      }
      
      public function set dropSelection(value:Boolean) : void
      {
         _dropSelection = value;
         invalidateState();
      }
      
      override public function set selectable(value:Boolean) : void
      {
         if(value)
         {
            alpha = 1;
         }
         else if(this._darkUnselectable)
         {
            alpha = 0.1;
         }
         super.selectable = value;
      }
      
      override public function get selectable() : Boolean
      {
         return _selectable;
      }
      
      override public function executeAction(keyCode:Number, event:InputEvent) : Boolean
      {
         if(useContextMgr && isEmpty() && (keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE))
         {
            dispatchEvent(new GameEvent(GameEvent.CALL,"OnEmptySlotActivate",[this.equipID]));
            if(event)
            {
               event.handled = true;
            }
            trace("GFX ------------------- /handled/ B1");
            return true;
         }
         return super.executeAction(keyCode,event);
      }
      
      override protected function defaultSlotEquipAction(itemData:Object) : void
      {
         if(useContextMgr)
         {
            if(!isEmpty())
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnUnequipItem",[itemData.id,-1]));
            }
         }
      }
      
      override protected function handleMouseDoubleClick(event:MouseEvent) : void
      {
         var superMouseEvent:MouseEventEx = event as MouseEventEx;
         if(Boolean(superMouseEvent) && superMouseEvent.buttonIdx != MouseEventEx.LEFT_BUTTON)
         {
            return;
         }
         if(useContextMgr)
         {
            if(this.selectionMode)
            {
               dispatchEvent(new Event(CharacterModeBackground.ACCEPT,true));
            }
            else if(!isEmpty())
            {
               callContextFunction();
            }
            else
            {
               this.executeAction(KeyCode.PAD_A_CROSS,null);
            }
         }
         else
         {
            executeDefaultAction(KeyCode.PAD_A_CROSS,null);
         }
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this.initDropTarget();
         if(this.iconLock)
         {
            this.iconLock.visible = false;
         }
         if(this._lockedDataProvider != CommonConstants.INVALID_STRING_PARAM)
         {
            dispatchEvent(new GameEvent(GameEvent.REGISTER,this._lockedDataProvider,[this.setIsLocked]));
         }
         if(this.tfSlotName)
         {
            this.tfSlotName.mouseEnabled = false;
         }
         if(this.mcPreviewIcon)
         {
            this.mcPreviewIcon.visible = false;
         }
         if(this.mcTransmogIcon)
         {
            this.mcTransmogIcon.visible = false;
         }
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"slot.paperdoll.override.tag",[this.setOverrideTag]));
      }
      
      protected function initDropTarget() : void
      {
         SlotsTransferManager.getInstance().addDropTarget(this);
      }
      
      public function get lockedDataProvider() : String
      {
         return this._lockedDataProvider;
      }
      
      public function set lockedDataProvider(value:String) : void
      {
         this._lockedDataProvider = value;
      }
      
      public function get isLocked() : Boolean
      {
         return this._isLocked;
      }
      
      protected function setIsLocked(value:Boolean) : void
      {
         this._isLocked = value;
         if(value)
         {
            this.iconLock.visible = true;
         }
         else
         {
            this.iconLock.visible = false;
         }
      }
      
      override protected function updateSize() : *
      {
      }
      
      public function get tooltipAlignment() : String
      {
         return _tooltipAlignment;
      }
      
      public function set tooltipAlignment(value:String) : void
      {
         _tooltipAlignment = value;
      }
      
      public function get slotTypeID() : int
      {
         return this._slotTypeID;
      }
      
      public function set slotTypeID(value:int) : void
      {
         this._slotTypeID = value;
      }
      
      public function get equipID() : int
      {
         return this._equipID;
      }
      
      public function set equipID(value:int) : void
      {
         this._equipID = value;
      }
      
      public function get slotTag() : String
      {
         return this._slotTag;
      }
      
      public function set slotTag(value:String) : void
      {
         this._slotTag = value;
         this.setSlotNameText();
         if(this._slotTag)
         {
            this.defaultIcon.gotoAndStop(this._slotTag == "food" || this._slotTag == "potion5" ? "potion1" : this._slotTag);
            this.defaultIcon.visible = true;
         }
         else
         {
            this.defaultIcon.visible = false;
         }
      }
      
      private function setSlotNameText() : void
      {
         if(this.tfSlotName)
         {
            if(!this._slotTag)
            {
               this.tfSlotName.htmlText = "";
            }
            if(this._slotTagOverride.length > 0)
            {
               this.tfSlotName.htmlText = this._slotTagOverride;
            }
            else if(this._slotTag == "food" || this._slotTag == "potion5")
            {
               this.tfSlotName.htmlText = "";
            }
            else if(this._slotTag.indexOf("quick") != -1)
            {
               this.tfSlotName.htmlText = "";
            }
            else if(this._slotTag.indexOf("potion") != -1)
            {
               this.tfSlotName.htmlText = "";
            }
            else if(this._slotTag.indexOf("petard") != -1)
            {
               this.tfSlotName.htmlText = "";
            }
            else
            {
               this.tfSlotName.htmlText = "[[panel_inventory_paperdoll_slotname_" + this._slotTag + "]]";
            }
         }
      }
      
      public function setOverrideTag(arr:Array) : *
      {
         var i:int = 0;
         var obj:Object = null;
         var currentTag:String = null;
         var overrideTag:String = null;
         while(i < arr.length)
         {
            obj = arr[i];
            currentTag = obj.currentTag;
            overrideTag = obj.overrideTag;
            if(this._slotTag == currentTag)
            {
               this._slotTagOverride = overrideTag;
               this.setSlotNameText();
            }
            i++;
         }
      }
      
      public function get slotType() : int
      {
         return this.slotTagToType(this._slotTag);
      }
      
      override protected function updateData() : *
      {
         super.updateData();
         if(Boolean(_data) && Boolean(this.defaultIcon))
         {
            this.defaultIcon.visible = false;
         }
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         if(this._slotTag)
         {
            this.defaultIcon.visible = true;
            if(this._slotTag == "quick2")
            {
               this.loadIcon("icons\\inventory\\slots\\mask2.png");
            }
         }
         if(_selected && !InputManager.getInstance().isMouse())
         {
            this.fireTooltipShowEvent();
         }
      }
      
      override protected function loadIcon(iconPath:String) : void
      {
         super.loadIcon(iconPath);
         if(this.mcPreviewIcon)
         {
            addChild(this.mcPreviewIcon);
         }
      }
      
      override protected function wipeIndicators() : void
      {
      }
      
      private function slotTagToType(slotTag:String) : int
      {
         var slotType:int = InventorySlotType.InvalidSlot;
         switch(slotTag)
         {
            case "potion5":
               return 32;
            case "food":
               return 16;
            case "steel":
               slotType = InventorySlotType.SteelSword;
               break;
            case "silver":
               slotType = InventorySlotType.SilverSword;
               break;
            case "armor":
               slotType = InventorySlotType.Armor;
               break;
            case "gloves":
               slotType = InventorySlotType.Gloves;
               break;
            case "trousers":
               slotType = InventorySlotType.Pants;
               break;
            case "boots":
               slotType = InventorySlotType.Boots;
               break;
            case "trophy":
               slotType = InventorySlotType.Trophy;
               break;
            case "quick1":
               slotType = InventorySlotType.Quickslot1;
               break;
            case "quick2":
               slotType = InventorySlotType.Quickslot2;
               break;
            case "rangeweapon":
               slotType = InventorySlotType.RangedWeapon;
               break;
            case "petard1":
               slotType = InventorySlotType.Petard1;
               break;
            case "petard2":
               slotType = InventorySlotType.Petard1;
               break;
            case "potion1":
               slotType = InventorySlotType.Potion1;
               break;
            case "potion2":
               slotType = InventorySlotType.Potion2;
               break;
            case "potion3":
               slotType = InventorySlotType.Potion3;
               break;
            case "potion4":
               slotType = InventorySlotType.Potion4;
               break;
            case "mutagen1":
               slotType = InventorySlotType.Mutagen1;
               break;
            case "mutagen2":
               slotType = InventorySlotType.Mutagen2;
               break;
            case "mutagen3":
               slotType = InventorySlotType.Mutagen3;
               break;
            case "mutagen4":
               slotType = InventorySlotType.Mutagen4;
               break;
            case "bolt":
               slotType = InventorySlotType.Bolt;
               break;
            case "horseBag":
               slotType = InventorySlotType.HorseBag;
               break;
            case "horseBlinders":
               slotType = InventorySlotType.HorseBlinders;
               break;
            case "horseSaddle":
               slotType = InventorySlotType.HorseSaddle;
               break;
            case "horseTrophy":
               slotType = InventorySlotType.HorseTrophy;
         }
         return slotType;
      }
      
      override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false) : void
      {
         var displayEvent:GridEvent = null;
         if(!(activeSelectionEnabled || InputManager.getInstance().isMouse()) && isParentEnabled())
         {
            return;
         }
         if(_data)
         {
            if(_data.prepItemType == 3)
            {
               displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP,true,false,index,-1,-1,null,null);
               if(!_data.showExtendedTooltip)
               {
                  displayEvent.tooltipContentRef = "ItemDescriptionTooltipRef";
               }
               else
               {
                  displayEvent.tooltipContentRef = "ItemTooltipRef";
               }
               displayEvent.tooltipDataSource = "OnGetAppliedOilTooltip";
               displayEvent.tooltipForceSetDataSource = true;
               displayEvent.tooltipCustomArgs = [this.equipID];
               displayEvent.isMouseTooltip = isMouseTooltip;
               displayEvent.anchorRect = getGlobalSlotRect();
               displayEvent.tooltipAlignment = _tooltipAlignment;
               dispatchEvent(displayEvent);
            }
            else
            {
               super.fireTooltipShowEvent(isMouseTooltip);
            }
         }
         else
         {
            displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP,true,false,index,-1,-1,null,null);
            displayEvent.tooltipMouseContentRef = "TooltipEmptySlotRef";
            displayEvent.tooltipContentRef = "TooltipEmptySlotRef";
            displayEvent.tooltipDataSource = "OnGetEmptyPaperdollTooltip";
            displayEvent.tooltipForceSetDataSource = true;
            displayEvent.tooltipCustomArgs = [this.equipID,this.isLocked];
            displayEvent.isMouseTooltip = isMouseTooltip;
            displayEvent.anchorRect = getGlobalSlotRect();
            displayEvent.tooltipAlignment = _tooltipAlignment;
            dispatchEvent(displayEvent);
            _tooltipRequested = true;
         }
      }
      
      public function CheckSlotsType(checkSlotType:int) : Boolean
      {
         var curSlotTag:int = this.slotTagToType(this.slotTag);
         if(checkSlotType == 32)
         {
            return curSlotTag == 32 || curSlotTag == InventorySlotType.Potion1 || curSlotTag == InventorySlotType.Potion2 || curSlotTag == InventorySlotType.Potion3 || curSlotTag == InventorySlotType.Potion4;
         }
         if(this._slotTag == "food" || this._slotTag == "potion5")
         {
            return checkSlotType == InventorySlotType.Potion1 || checkSlotType == InventorySlotType.Potion2 || checkSlotType == InventorySlotType.Potion3 || checkSlotType == InventorySlotType.Potion4;
         }
         if(checkSlotType == InventorySlotType.Petard1)
         {
            if(curSlotTag == InventorySlotType.Petard2)
            {
            }
         }
         else
         {
            if(checkSlotType == InventorySlotType.Petard2)
            {
               return false;
            }
            if((checkSlotType == InventorySlotType.Potion1 || checkSlotType == InventorySlotType.Potion2 || checkSlotType == InventorySlotType.Potion3 || checkSlotType == InventorySlotType.Potion4) && (curSlotTag == InventorySlotType.Potion1 || curSlotTag == InventorySlotType.Potion2 || curSlotTag == InventorySlotType.Potion3 || curSlotTag == InventorySlotType.Potion4))
            {
               return true;
            }
            if(checkSlotType == InventorySlotType.Potion1)
            {
               if(curSlotTag == InventorySlotType.Potion2)
               {
                  return true;
               }
            }
            else if(checkSlotType == InventorySlotType.Potion2)
            {
               if(curSlotTag == InventorySlotType.Potion1)
               {
                  return true;
               }
            }
         }
         return checkSlotType == curSlotTag;
      }
      
      override public function toString() : String
      {
         return "SlotPaperdoll [" + this.name + "] ";
      }
      
      override protected function handleGesturePress(event:GestureEvent) : void
      {
      }
   }
}

