package red.game.witcher3.menus.inventory_menu
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import red.core.events.GameEvent;
   import red.game.witcher3.slots.SlotPaperdoll;
   import red.game.witcher3.utils.CommonUtils;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.ui.InputDetails;
   
   public class ModulePaperdoll extends ModulePaperdollBase
   {
      
      public var mcPaperDollSlot21:SlotPaperdoll;
      
      public var mcPaperDollSlot22:SlotPaperdoll;
      
      private var tfFood:TextField;
      
      public var mcPaperDollSlot1:SlotPaperdoll;
      
      public var mcPaperDollSlot2:SlotPaperdoll;
      
      public var mcPaperDollSlot3:SlotPaperdoll;
      
      public var mcPaperDollSlot4:SlotPaperdoll;
      
      public var mcPaperDollSlot5:SlotPaperdoll;
      
      public var mcPaperDollSlot6:SlotPaperdoll;
      
      public var mcPaperDollSlot19:SlotPaperdoll;
      
      public var mcPaperDollSlot20:SlotPaperdoll;
      
      public var mcPaperDollSlot7:SlotPaperdoll;
      
      public var mcPaperDollSlot13:SlotPaperdoll;
      
      public var mcPaperDollSlot8:SlotPaperdoll;
      
      public var mcPaperDollSlot14:SlotPaperdoll;
      
      public var mcPaperDollSlot9:SlotPaperdoll;
      
      public var mcPaperDollSlot10:SlotPaperdoll;
      
      public var mcPaperDollSlot11:SlotPaperdoll;
      
      public var mcPaperDollSlot12:SlotPaperdoll;
      
      public var mcPaperDollSlot15:SlotPaperdoll;
      
      public var mcPaperDollSlot16:SlotPaperdoll;
      
      public var mcPaperDollSlot17:SlotPaperdoll;
      
      public var mcPaperDollSlot18:SlotPaperdoll;
      
      public var tfCurrentState:TextField;
      
      public var tfPotions:TextField;
      
      public var tfPockets:TextField;
      
      public var tfPetards:TextField;
      
      public var tfMasks:TextField;
      
      public var mcSegmentBorderWeapons:MovieClip;
      
      public var mcSegmentBorderArmor:MovieClip;
      
      public var mcSegmentBorderPotion:MovieClip;
      
      public var mcSegmentBorderBombs:MovieClip;
      
      public var mcSegmentBorderHorse:MovieClip;
      
      public var mcPreviewIcon:MovieClip;
      
      protected var _previewMode:Boolean;
      
      protected var _moduleDisplayName:String = "";
      
      protected var _sectionsData:Array = [];
      
      public function ModulePaperdoll()
      {
         super();
         dataBindingKey = "inventory.paperdoll";
         this.mcPreviewIcon.visible = false;
         var foodClass:Class = getDefinitionByName(getQualifiedClassName(this.mcPaperDollSlot8)) as Class;
         this.mcPaperDollSlot21 = new foodClass() as SlotPaperdoll;
         this.mcPaperDollSlot21.name = "mcPaperDollSlot21";
         this.mcPaperDollSlot21.equipID = 16;
         this.mcPaperDollSlot21.slotTag = "food";
         this.mcPaperDollSlot21.gridSize = 1;
         this.mcPaperDollSlot21.enableInitCallback = false;
         this.addChild(this.mcPaperDollSlot21);
         this.mcPaperDollSlot22 = new foodClass() as SlotPaperdoll;
         this.mcPaperDollSlot22.name = "mcPaperDollSlot22";
         this.mcPaperDollSlot22.equipID = 32;
         this.mcPaperDollSlot22.slotTag = "potion5";
         this.mcPaperDollSlot22.gridSize = 1;
         this.mcPaperDollSlot22.enableInitCallback = false;
         this.addChild(this.mcPaperDollSlot22);
         this.createSection(1,-1,2,-1,3,this.mcSegmentBorderWeapons,[this.mcPaperDollSlot1,this.mcPaperDollSlot2,this.mcPaperDollSlot3,this.mcPaperDollSlot4]);
         this.createSection(2,1,-1,-1,4,this.mcSegmentBorderArmor,[this.mcPaperDollSlot9,this.mcPaperDollSlot10,this.mcPaperDollSlot11,this.mcPaperDollSlot12]);
         this.createSection(3,-1,4,1,5,this.mcSegmentBorderPotion,[this.mcPaperDollSlot5,this.mcPaperDollSlot6,this.mcPaperDollSlot19,this.mcPaperDollSlot20,this.mcPaperDollSlot22,this.mcPaperDollSlot21]);
         this.createSection(4,3,-1,2,5,this.mcSegmentBorderHorse,[this.mcPaperDollSlot15,this.mcPaperDollSlot16,this.mcPaperDollSlot17,this.mcPaperDollSlot18]);
         this.createSection(5,-1,4,3,-1,this.mcSegmentBorderBombs,[this.mcPaperDollSlot7,this.mcPaperDollSlot8,this.mcPaperDollSlot13,this.mcPaperDollSlot14]);
         this.mcPaperDollSlot13.selectable = false;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         var startX:Number = this.mcPaperDollSlot5.x;
         var startY:Number = this.mcPaperDollSlot5.y;
         var oldColumnStep:Number = this.mcPaperDollSlot19.x - startX;
         var rowStep:Number = this.mcPaperDollSlot6.y - startY;
         var slotScaleX:Number = this.mcPaperDollSlot5.scaleX;
         var slotScaleY:Number = this.mcPaperDollSlot5.scaleY;
         var cellWidth:Number = this.mcPaperDollSlot5.getSlotRect().width * slotScaleX;
         var scaleFactor:Number = 0.85;
         var columnStep:Number = (oldColumnStep + cellWidth - cellWidth * scaleFactor) / 2;
         var usable:Array = [this.mcPaperDollSlot5,this.mcPaperDollSlot6,this.mcPaperDollSlot19,this.mcPaperDollSlot20,this.mcPaperDollSlot22,this.mcPaperDollSlot21];
         var n:int = 0;
         while(n < usable.length)
         {
            var cell:SlotPaperdoll = usable[n] as SlotPaperdoll;
            cell.scaleX = slotScaleX * scaleFactor;
            cell.scaleY = slotScaleY * scaleFactor;
            cell.x = startX + n % 3 * columnStep;
            cell.y = startY + int(n / 3) * rowStep;
            n++;
         }
         this.mcPaperDollSlot5.navigationRight = 5;
         this.mcPaperDollSlot5.navigationDown = 19;
         this.mcPaperDollSlot6.navigationLeft = 4;
         this.mcPaperDollSlot6.navigationRight = 18;
         this.mcPaperDollSlot6.navigationDown = 21;
         this.mcPaperDollSlot19.navigationLeft = 5;
         this.mcPaperDollSlot19.navigationRight = -1;
         this.mcPaperDollSlot19.navigationUp = 0;
         this.mcPaperDollSlot19.navigationDown = 20;
         this.mcPaperDollSlot20.navigationLeft = -1;
         this.mcPaperDollSlot20.navigationRight = 21;
         this.mcPaperDollSlot20.navigationUp = 4;
         this.mcPaperDollSlot20.navigationDown = 6;
         this.mcPaperDollSlot22.navigationLeft = 19;
         this.mcPaperDollSlot22.navigationRight = 20;
         this.mcPaperDollSlot22.navigationUp = 5;
         this.mcPaperDollSlot22.navigationDown = 7;
         this.mcPaperDollSlot21.navigationLeft = 21;
         this.mcPaperDollSlot21.navigationRight = -1;
         this.mcPaperDollSlot21.navigationUp = 18;
         this.mcPaperDollSlot21.navigationDown = 7;
         this.mcPaperDollSlot7.navigationUp = 19;
         this.mcPaperDollSlot8.navigationUp = 21;
         this.mcPaperDollSlot8.navigationDown = 13;
         mcPaperdoll.slotsInstanceName = "mcPaperDollSlot";
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll",[handlePaperdollDataSet]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.item.update",[handlePaperdollUpdateItem]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.items.update",[handlePaperdollUpdateItems]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.name",[this.handleModuleNameSet]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.pockets",[this.handlePocketsSlotsNameSet]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.potions",[this.handlePotionsSlotsNameSet]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.petards",[this.handlePetardsSlotsNameSet]));
         dispatchEvent(new GameEvent(GameEvent.REGISTER,"inventory.grid.paperdoll.masks",[this.handleMasksSlotsNameSet]));
         this.updateSectionBorders();
      }
      
      public function get previewMode() : Boolean
      {
         return this._previewMode;
      }
      
      public function set previewMode(value:Boolean) : void
      {
         this._previewMode = value;
         if(this.mcPreviewIcon)
         {
            this.mcPreviewIcon.visible = value;
         }
      }
      
      private function createSection(id:int, nLeft:int, nRight:int, nUp:int, nDown:int, border:MovieClip, list:Array) : void
      {
         var newSection:Object = {};
         newSection.id = id;
         newSection.nLeft = nLeft;
         newSection.nRight = nRight;
         newSection.nUp = nUp;
         newSection.nDown = nDown;
         newSection.list = list;
         newSection.border = border;
         var len:int = int(list.length);
         var i:int = 0;
         while(i < len)
         {
            (list[i] as SlotPaperdoll).sectionId = id;
            i++;
         }
         this._sectionsData.push(newSection);
      }
      
      private function getSectionData(id:int) : Object
      {
         var len:int = 0;
         var i:int = 0;
         var curData:Object = null;
         if(this._sectionsData)
         {
            len = int(this._sectionsData.length);
            i = 0;
            while(i < len)
            {
               curData = this._sectionsData[i];
               if(curData.id == id)
               {
                  return curData;
               }
               i++;
            }
         }
         return null;
      }
      
      override public function handleInput(event:InputEvent) : void
      {
         var selectedSection:int = 0;
         var sectionData:Object = null;
         var nextSection:int = 0;
         var nextSectionData:Object = null;
         super.handleInput(event);
         var details:InputDetails = event.details;
         CommonUtils.fixupKeyCode(details);
         if(event.handled || details.value != InputValue.KEY_DOWN)
         {
            return;
         }
         var selectedSlot:SlotPaperdoll = mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
         if(Boolean(focused) && Boolean(selectedSlot) && selectedSlot.sectionId != -1)
         {
            selectedSection = selectedSlot.sectionId;
            sectionData = this.getSectionData(selectedSlot.sectionId);
            if(!sectionData)
            {
               throw new Error("Cant find section " + selectedSlot.sectionId + " data for paperdol component!");
            }
            nextSection = -1;
            switch(details.navEquivalent)
            {
               case NavigationCode.RIGHT_STICK_LEFT:
                  nextSection = int(sectionData.nLeft);
                  break;
               case NavigationCode.RIGHT_STICK_RIGHT:
                  nextSection = int(sectionData.nRight);
                  break;
               case NavigationCode.RIGHT_STICK_UP:
                  nextSection = int(sectionData.nUp);
                  break;
               case NavigationCode.RIGHT_STICK_DOWN:
                  nextSection = int(sectionData.nDown);
            }
            if(nextSection != -1)
            {
               nextSectionData = this.getSectionData(nextSection);
               if(!(Boolean(nextSectionData) && Boolean(nextSectionData.list) && (nextSectionData.list as Array).length > 0))
               {
                  throw new Error("Cant find section " + selectedSlot.sectionId + " data for paperdol component!");
               }
               mcPaperdoll.selectedIndex = (nextSectionData.list[0] as SlotPaperdoll).index;
               event.handled = true;
            }
         }
      }
      
      override public function startSelectModeWithValidSlots(slotList:Array) : void
      {
         super.startSelectModeWithValidSlots(slotList);
         var GROUP_DISABLED_ALPHA:* = 0.1;
         this.mcSegmentBorderWeapons.alpha = this.mcPaperDollSlot1.selectable || this.mcPaperDollSlot2.selectable || this.mcPaperDollSlot3.selectable || this.mcPaperDollSlot4.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
         this.mcSegmentBorderPotion.alpha = this.tfPotions.alpha = this.mcPaperDollSlot5.selectable || this.mcPaperDollSlot6.selectable || this.mcPaperDollSlot19.selectable || this.mcPaperDollSlot20.selectable || this.mcPaperDollSlot22.selectable || this.mcPaperDollSlot21.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
         this.mcSegmentBorderBombs.alpha = this.tfPetards.alpha = this.mcPaperDollSlot7.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
         this.mcSegmentBorderArmor.alpha = this.mcPaperDollSlot9.selectable || this.mcPaperDollSlot10.selectable || this.mcPaperDollSlot11.selectable || this.mcPaperDollSlot12.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
         this.mcSegmentBorderHorse.alpha = this.mcPaperDollSlot15.selectable || this.mcPaperDollSlot16.selectable || this.mcPaperDollSlot17.selectable || this.mcPaperDollSlot18.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
         this.tfPockets.alpha = this.mcPaperDollSlot8.selectable || this.mcPaperDollSlot14.selectable ? 1 : Number(GROUP_DISABLED_ALPHA);
      }
      
      override public function endSelectionMode() : void
      {
         super.endSelectionMode();
         this.mcSegmentBorderWeapons.alpha = 1;
         this.mcSegmentBorderPotion.alpha = 1;
         this.mcSegmentBorderBombs.alpha = 1;
         this.mcSegmentBorderArmor.alpha = 1;
         this.mcSegmentBorderHorse.alpha = 1;
         this.tfPotions.alpha = 1;
         this.tfPetards.alpha = 1;
         this.tfPockets.alpha = 1;
         this.tfMasks.alpha = 1;
         this.mcPaperDollSlot8.selectable = true;
         this.mcPaperDollSlot14.selectable = true;
         this.mcPaperDollSlot7.selectable = true;
         this.mcPaperDollSlot13.selectable = false;
         this.updateSectionBorders();
      }
      
      override public function set focused(value:Number) : void
      {
         super.focused = value;
         this.updateSectionBorders();
      }
      
      override protected function updateActiveContext(currentSlot:SlotPaperdoll) : void
      {
         super.updateActiveContext(currentSlot);
         this.updateSectionBorders();
      }
      
      protected function updateSectionBorders() : void
      {
         var len:int = 0;
         var i:int = 0;
         var curData:Object = null;
         var targetFrame:uint = 0;
         var selectedSlot:SlotPaperdoll = mcPaperdoll.getSelectedRenderer() as SlotPaperdoll;
         if(this._sectionsData)
         {
            len = int(this._sectionsData.length);
            i = 0;
            while(i < len)
            {
               curData = this._sectionsData[i];
               targetFrame = 1;
               if((curData.list as Array).indexOf(selectedSlot) > -1 && focused > 0)
               {
                  targetFrame = 2;
               }
               else
               {
                  targetFrame = 1;
               }
               curData.border.gotoAndStop(targetFrame);
               i++;
            }
         }
      }
      
      protected function handleModuleNameSet(name:String) : void
      {
         this._moduleDisplayName = name;
         this.tfCurrentState.htmlText = name;
      }
      
      protected function handlePocketsSlotsNameSet(name:String) : void
      {
         if(this.tfPockets)
         {
            this.tfPockets.htmlText = name;
         }
      }
      
      protected function handlePotionsSlotsNameSet(name:String) : void
      {
         if(this.tfPotions)
         {
            this.tfPotions.htmlText = name;
         }
      }
      
      protected function handlePetardsSlotsNameSet(name:String) : void
      {
         if(this.tfPetards)
         {
            this.tfPetards.htmlText = name;
         }
      }
      
      protected function handleMasksSlotsNameSet(name:String) : void
      {
         if(this.tfMasks)
         {
            this.tfMasks.htmlText = name;
         }
      }
      
      override public function toString() : String
      {
         return "[W3 ModulePaperdoll]";
      }
   }
}

