package red.game.witcher3.slots
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import red.core.events.GestureEventEx;
   import red.game.witcher3.constants.InventorySlotType;
   import red.game.witcher3.interfaces.IBaseSlot;
   import red.game.witcher3.interfaces.IPaperdollSlot;
   import red.game.witcher3.menus.common.ItemDataStub;
   
   public class SlotsListPaperdoll extends SlotsListBase
   {
      
      protected var _slotTypeToIndexMap:Vector.<int>;
      
      protected var _equipSlotToIndexMap:Vector.<int>;
      
      public function SlotsListPaperdoll()
      {
         super();
      }
      
      override protected function configUI() : void
      {
         super.configUI();
      }
      
      private function initializeSlots() : void
      {
         var renderer:IPaperdollSlot = null;
         var slotType:int = 0;
         this._slotTypeToIndexMap = new Vector.<int>(InventorySlotType._COUNT + 1,true);
         this._equipSlotToIndexMap = new Vector.<int>(InventorySlotType._COUNT + 1,true);
         this._slotTypeToIndexMap[InventorySlotType.InvalidSlot] = -1;
         var len:uint = _renderers.length;
         var i:uint = 0;
         while(i < len)
         {
            renderer = IPaperdollSlot(_renderers[i]);
            slotType = IPaperdollSlot(renderer).slotType;
            this.setupRenderer(renderer);
            renderer.index = i;
            this._slotTypeToIndexMap[slotType] = i;
            this._equipSlotToIndexMap[renderer.equipID] = i;
            i++;
         }
      }
      
      public function set slotList(value:Vector.<IBaseSlot>) : *
      {
         _renderers = value;
      }
      
      public function set slotsInstanceName(value:String) : void
      {
         var clip:IBaseSlot = null;
         if(value == null || value == "" || parent == null)
         {
            throw new Error("Slot instance name is not defined");
         }
         var i:uint = 0;
         var newSlots:Vector.<IBaseSlot> = new Vector.<IBaseSlot>();
         while(++i)
         {
            clip = parent.getChildByName(value + i) as IBaseSlot;
            if(clip == null)
            {
               if(i != 0)
               {
                  break;
               }
            }
            else
            {
               newSlots.push(clip);
            }
         }
         this.slotList = newSlots;
      }
      
      public function hasItemInSlot(slotType:int) : Boolean
      {
         var renderer:IBaseSlot = null;
         var itemDataStub:ItemDataStub = null;
         var quickslotType:int = 0;
         if(this.IsQuickSlotBySlotType(slotType))
         {
            quickslotType = InventorySlotType.Quickslot1;
            while(quickslotType <= InventorySlotType.Quickslot2)
            {
               renderer = this.getRendererForSlotType(quickslotType);
               itemDataStub = renderer ? renderer.data as ItemDataStub : null;
               if(Boolean(itemDataStub))
               {
                  return true;
               }
               quickslotType++;
            }
            return false;
         }
         renderer = this.getRendererForSlotType(slotType);
         itemDataStub = renderer ? renderer.data as ItemDataStub : null;
         return Boolean(itemDataStub);
      }
      
      public function getRendererForSlotType(slotType:int) : IBaseSlot
      {
         return getRendererAt(this.getIndexForSlotType(slotType)) as IBaseSlot;
      }
      
      public function getIndexForSlotType(slotType:int) : int
      {
         if(this._slotTypeToIndexMap.length > 0)
         {
            if(this._slotTypeToIndexMap[slotType] > -1)
            {
               return this._slotTypeToIndexMap[slotType];
            }
            return -1;
         }
         return -1;
      }
      
      override public function updateItemData(itemData:Object) : void
      {
         var targetRenderer:IBaseSlot = null;
         var tipRenderer:SlotBase = null;
         var targetDataStub:ItemDataStub = itemData as ItemDataStub;
         var taregetIndex:int = this.getDataIndex(targetDataStub);
         trace("GFX updateItemData ",targetDataStub.iconPath,"\t\t<",targetDataStub.slotType,">  ");
         if(!targetDataStub.groupId)
         {
            this.removeItem(targetDataStub.id);
         }
         else
         {
            this.removeGroupItem(targetDataStub.id,targetDataStub.groupId);
         }
         if(taregetIndex > -1)
         {
            targetRenderer = _renderers[taregetIndex];
            targetRenderer.data = targetDataStub;
            tipRenderer = targetRenderer as SlotBase;
            if(tipRenderer)
            {
               tipRenderer.showTooltip();
            }
         }
      }
      
      public function removeGroupItem(itemId:uint, groupId:int) : void
      {
         var targetRenderer:IBaseSlot = null;
         var tipRenderer:SlotBase = null;
         var taregetIndex:int = getIdIndex(itemId,groupId);
         if(taregetIndex > -1)
         {
            targetRenderer = _renderers[taregetIndex];
            targetRenderer.cleanup();
            tipRenderer = targetRenderer as SlotBase;
            if(tipRenderer)
            {
               tipRenderer.showTooltip();
            }
         }
      }
      
      override public function removeItem(itemId:uint, keepSelectionIdx:Boolean = false) : void
      {
         var targetRenderer:IBaseSlot = null;
         var tipRenderer:SlotBase = null;
         var taregetIndex:int = getIdIndex(itemId);
         if(taregetIndex > -1)
         {
            targetRenderer = _renderers[taregetIndex];
            targetRenderer.cleanup();
            tipRenderer = targetRenderer as SlotBase;
            if(tipRenderer)
            {
               tipRenderer.showTooltip();
            }
         }
      }
      
      override protected function populateData() : void
      {
         var renderer:SlotPaperdoll = null;
         var itemDataStub:ItemDataStub = null;
         var index:int = 0;
         super.populateData();
         if(!data)
         {
            return;
         }
         var indexUpdated:Array = new Array();
         var renderersCount:int = int(_renderers.length);
         var i:int = 0;
         while(i < renderersCount)
         {
            _renderers[i].cleanup();
            i++;
         }
         this.initializeSlots();
         _renderersCount = _renderers.length;
         for each(itemDataStub in data)
         {
            index = this.getDataIndex(itemDataStub);
            indexUpdated.push(index);
            renderer = getRendererAt(index) as SlotPaperdoll;
            if(renderer.equipID != itemDataStub.equipped)
            {
               trace("GFX ---------------------- Making a huge matching mistake THERE BUDDY BOY! ---------------------",renderer.equipID,", ",(itemDataStub as ItemDataStub).equipped);
            }
            else if(renderer)
            {
               renderer.data = itemDataStub;
            }
         }
         if(selectedIndex == -1)
         {
            findSelection();
         }
      }
      
      override protected function getDataIndex(targetData:ItemDataStub) : int
      {
         var slotId:int = 0;
         var slotType:int = targetData.slotType;
         if(targetData.equipped)
         {
            return this._equipSlotToIndexMap[targetData.equipped];
         }
         slotId = slotType;
         return this.getIndexForSlotType(slotId);
      }
      
      override protected function setupRenderer(renderer:IBaseSlot) : void
      {
         var pdRenderer:IPaperdollSlot = renderer as IPaperdollSlot;
         if(pdRenderer)
         {
            pdRenderer.owner = this;
            pdRenderer.enabled = enabled;
            (pdRenderer.getHitArea() as MovieClip).addEventListener(MouseEvent.MOUSE_DOWN,this.handleItemClick,false,0,true);
            (pdRenderer.getHitArea() as MovieClip).addEventListener(MouseEvent.MOUSE_UP,handleItemMouseUp,false,0,true);
            (pdRenderer.getHitArea() as MovieClip).addEventListener(GestureEventEx.GESTURE_TAP,handleItemTap,false,0,true);
         }
      }
      
      override protected function cleanUpRenderer(renderer:IBaseSlot) : void
      {
         var pdRenderer:IPaperdollSlot = renderer as IPaperdollSlot;
         if(pdRenderer)
         {
            pdRenderer.owner = null;
            (pdRenderer.getHitArea() as MovieClip).removeEventListener(MouseEvent.MOUSE_DOWN,this.handleItemClick);
            (pdRenderer.getHitArea() as MovieClip).removeEventListener(MouseEvent.MOUSE_UP,handleItemMouseUp);
            (pdRenderer.getHitArea() as MovieClip).removeEventListener(GestureEventEx.GESTURE_TAP,handleItemTap);
         }
      }
      
      override protected function handleItemClick(event:MouseEvent) : void
      {
         super.handleItemClick(event);
      }
      
      protected function CheckIfNeedUpdate(updated:Array, index:int) : *
      {
         var i:int = 0;
         while(i < updated.length)
         {
            if(updated[i] == index)
            {
               updated.splice(i,1);
               return false;
            }
            i++;
         }
         return true;
      }
      
      private function IsQuickSlotBySlotType(slotType:uint) : Boolean
      {
         switch(slotType)
         {
            case InventorySlotType.Quickslot1:
            case InventorySlotType.Quickslot2:
               return true;
            default:
               return false;
         }
      }
      
      private function IsPotionSlotBySlotType(slotType:uint) : Boolean
      {
         switch(slotType)
         {
            case InventorySlotType.Potion1:
            case InventorySlotType.Potion2:
               return true;
            default:
               return false;
         }
      }
      
      private function IsPetardSlotBySlotType(slotType:uint) : Boolean
      {
         switch(slotType)
         {
            case InventorySlotType.Petard1:
            case InventorySlotType.Petard2:
               return true;
            default:
               return false;
         }
      }
      
      override public function toString() : String
      {
         return "[SlotsListPaperdoll " + name + "]";
      }
   }
}

