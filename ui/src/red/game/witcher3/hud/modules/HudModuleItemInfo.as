package red.game.witcher3.hud.modules
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import red.core.constants.KeyCode;
   import red.core.events.GameEvent;
   import red.game.witcher3.controls.InputFeedbackButton;
   import red.game.witcher3.events.ControllerChangeEvent;
   import red.game.witcher3.hud.modules.iteminfo.HudItemInfo;
   import red.game.witcher3.hud.modules.iteminfo.HudPotionInfo;
   import red.game.witcher3.managers.InputManager;
   import scaleform.clik.constants.InputValue;
   import scaleform.clik.constants.NavigationCode;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.managers.InputDelegate;
   
   [SWF(width="1", height="1", backgroundColor="#ff0000", frameRate="30")]
   [SWF(frameRate="30",backgroundColor="#ff0000",width="1",height="1")]
   [SWF(frameRate="30",backgroundColor="#ff0000",width="1",height="1")]
   public class HudModuleItemInfo extends HudModuleBase
   {
      
      public static const HudItemInfoBinding_item1:uint = 0;
      
      public static const HudItemInfoBinding_potion1:uint = 1;
      
      public static const HudItemInfoBinding_potion2:uint = 2;
      
      public static const HudItemInfoBinding_potion3:uint = 3;
      
      public static const HudItemInfoBinding_potion4:uint = 4;
      
      public static const HudItemInfoBinding_steelsword:uint = 5;
      
      public static const HudItemInfoBinding_silversword:uint = 6;
      
      public var mcKbPotion1:HudItemInfo;
      
      public var mcKbPotion2:HudItemInfo;
      
      public var mcKbPotion3:HudItemInfo;
      
      public var mcKbPotion4:HudItemInfo;
      
      public var mcFoodSlot:HudItemInfo;
      
      public var mcExtraPotionSlot:HudItemInfo;
      
      private var extraPotionKey:int = -1;
      
      private var extraPotionPressed:Boolean = false;
      
      private var extraPotionHeld:Boolean = false;
      
      private var extraPotionHoldTimer:Timer;
      
      public var mcItemSlot:HudItemInfo;
      
      public var mcPotionSlot1:HudPotionInfo;
      
      public var mcPotionSlot2:HudPotionInfo;
      
      private var isAlwaysDisplayed:Boolean = false;
      
      private var _showHint:Boolean = false;
      
      public var btnSwitchHint:InputFeedbackButton;
      
      public var btnSwitchHintBackground:MovieClip;
      
      public var mcKbOilSteel:HudItemInfo;
      
      public var mcKbOilSilver:HudItemInfo;
      
      public var btnSwitchHintDoubleTap:InputFeedbackButton;
      
      public var btnSwitchHintBackgroundDoubleTap:MovieClip;
      
      public var btnSwitchHintOils:InputFeedbackButton;
      
      public var btnSwitchHintBackgroundOils:MovieClip;
      
      public var btnSwitchHintOilsKB:InputFeedbackButton;
      
      public var btnSwitchHintBackgroundOilsKB:MovieClip;
      
      public var cachedY:int;
      
      private var _radialMenuOn:Boolean = false;
      
      private var foodKey:int = -1;
      
      private var foodPressed:Boolean = false;
      
      private var foodHeld:Boolean = false;
      
      private var foodHoldTimer:Timer;
      
      public function HudModuleItemInfo()
      {
         super();
         this.mcItemSlot.defaultIconName = "quick1";
         this.mcKbPotion1.showButtonHint = true;
         this.mcKbPotion2.showButtonHint = true;
         this.mcKbPotion3.showButtonHint = true;
         this.mcKbPotion4.showButtonHint = true;
         this.mcFoodSlot = new PotionKeyboardInfo();
         this.mcFoodSlot.name = "mcFoodSlot";
         this.mcFoodSlot.x = this.mcKbPotion4.x;
         this.mcFoodSlot.y = this.mcKbPotion4.y + (this.mcKbPotion4.y - this.mcKbPotion3.y);
         this.mcFoodSlot.scaleX = this.mcKbPotion4.scaleX;
         this.mcFoodSlot.scaleY = this.mcKbPotion4.scaleY;
         this.mcFoodSlot.showButtonHint = true;
         this.mcFoodSlot.minimalSize = this.mcKbPotion4.minimalSize;
         this.addChild(this.mcFoodSlot);
         this.mcExtraPotionSlot = new PotionKeyboardInfo();
         this.mcExtraPotionSlot.name = "mcExtraPotionSlot";
         this.mcExtraPotionSlot.x = this.mcFoodSlot.x;
         this.mcExtraPotionSlot.y = this.mcFoodSlot.y;
         this.mcExtraPotionSlot.scaleX = this.mcFoodSlot.scaleX;
         this.mcExtraPotionSlot.scaleY = this.mcFoodSlot.scaleY;
         this.mcExtraPotionSlot.showButtonHint = true;
         this.mcExtraPotionSlot.minimalSize = this.mcFoodSlot.minimalSize;
         this.addChild(this.mcExtraPotionSlot);
         this.mcFoodSlot.y += this.mcKbPotion4.y - this.mcKbPotion3.y;
         this.mcItemSlot.y += this.mcKbPotion4.y - this.mcKbPotion3.y;
         this.mcItemSlot.y += this.mcKbPotion4.y - this.mcKbPotion3.y;
         this.mcKbOilSteel.showButtonHint = true;
         this.mcKbOilSilver.showButtonHint = true;
         this.__setProp_mcItemSlot_Scene1_Item_0();
      }
      
      private function cancelFoodInput() : void
      {
         if(this.foodHoldTimer)
         {
            this.foodHoldTimer.stop();
         }
         this.foodPressed = false;
         this.foodHeld = false;
      }
      
      private function handleFoodInput(event:InputEvent) : void
      {
         if(!this._radialMenuOn || InputManager.getInstance().isGamepad() || event.details.code != this.foodKey || this.foodKey < 1)
         {
            return;
         }
         if(event.details.value == InputValue.KEY_DOWN && !this.foodPressed)
         {
            this.foodPressed = true;
            this.foodHeld = false;
            this.foodHoldTimer.reset();
            this.foodHoldTimer.start();
         }
         else if(event.details.value == InputValue.KEY_UP && this.foodPressed)
         {
            this.foodHoldTimer.stop();
            this.foodPressed = false;
            if(!this.foodHeld)
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnFoodSlotRadialTap"));
            }
            this.foodHeld = false;
         }
      }
      
      private function foodHoldComplete(event:TimerEvent) : void
      {
         if(!this._radialMenuOn || !this.foodPressed)
         {
            return;
         }
         this.foodHeld = true;
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnFoodSlotRadialHold"));
      }
      
      private function cancelExtraPotionInput() : void
      {
         if(this.extraPotionHoldTimer)
         {
            this.extraPotionHoldTimer.stop();
         }
         this.extraPotionPressed = false;
         this.extraPotionHeld = false;
      }
      
      private function handleExtraPotionInput(event:InputEvent) : void
      {
         if(!this._radialMenuOn || InputManager.getInstance().isGamepad() || event.details.code != this.extraPotionKey || this.extraPotionKey < 1)
         {
            return;
         }
         event.handled = true;
         if(event.details.value == InputValue.KEY_DOWN && !this.extraPotionPressed)
         {
            this.extraPotionPressed = true;
            this.extraPotionHeld = false;
            this.extraPotionHoldTimer.reset();
            this.extraPotionHoldTimer.start();
         }
         else if(event.details.value == InputValue.KEY_UP && this.extraPotionPressed)
         {
            this.extraPotionHoldTimer.stop();
            this.extraPotionPressed = false;
            if(!this.extraPotionHeld)
            {
               dispatchEvent(new GameEvent(GameEvent.CALL,"OnExtraPotionSlotRadialTap"));
            }
            this.extraPotionHeld = false;
         }
      }
      
      private function extraPotionHoldComplete(event:TimerEvent) : void
      {
         if(!this._radialMenuOn || !this.extraPotionPressed)
         {
            return;
         }
         this.extraPotionHeld = true;
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnExtraPotionSlotRadialHold"));
      }
      
      public function setRadialMenuOn(param1:Boolean) : void
      {
         var _loc2_:Boolean = InputManager.getInstance().isGamepad();
         this._radialMenuOn = param1;
         if(!param1)
         {
            this.cancelFoodInput();
            this.cancelExtraPotionInput();
         }
         this.mcKbOilSteel.visible = this._radialMenuOn && !_loc2_;
         this.mcKbOilSilver.visible = this._radialMenuOn && !_loc2_;
         this.btnSwitchHintOilsKB.visible = !_loc2_ && this._radialMenuOn;
         this.btnSwitchHintBackgroundOilsKB.visible = !_loc2_ && this._radialMenuOn;
         this.btnSwitchHintDoubleTap.visible = _loc2_ && this._radialMenuOn;
         this.btnSwitchHintBackgroundDoubleTap.visible = _loc2_ && this._radialMenuOn;
         this.btnSwitchHintOils.visible = _loc2_ && this._radialMenuOn;
         this.btnSwitchHintBackgroundOils.visible = _loc2_ && this._radialMenuOn;
      }
      
      override public function get moduleName() : String
      {
         return "ItemInfoModule";
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this.extraPotionHoldTimer = new Timer(300,1);
         this.extraPotionHoldTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.extraPotionHoldComplete,false,0,true);
         InputDelegate.getInstance().addEventListener(InputEvent.INPUT,this.handleExtraPotionInput,false,2,true);
         this.foodHoldTimer = new Timer(300,1);
         this.foodHoldTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.foodHoldComplete,false,0,true);
         InputDelegate.getInstance().addEventListener(InputEvent.INPUT,this.handleFoodInput,false,2,true);
         this.btnSwitchHint.label = "[[hud_item_info_switch_potions]]";
         this.btnSwitchHint.setDataFromStage(NavigationCode.DPAD_UP_DOWN,-1,-1,300);
         this.btnSwitchHintOils.label = "[[panel_button_inventory_upgrade]]";
         this.btnSwitchHintOils.setDataFromStage(NavigationCode.GAMEPAD_DPAD_LR,-1,-1,300);
         this.btnSwitchHintOilsKB.label = "[[hud_equip_oils_and_potion]]";
         this.btnSwitchHintOilsKB.setDataFromStage("",KeyCode.SHIFT_LEFT,-1,300,true);
         this.btnSwitchHintDoubleTap.label = "[[hud_equip_potions]]";
         this.btnSwitchHintDoubleTap.setDataFromStage(NavigationCode.DPAD_UP_DOWN,-1,-1,300,false,true);
         this.cachedY = this.btnSwitchHint.y;
         visible = true;
         alpha = 0;
         this.updateHints();
         InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE,this.updateHints,false,0,true);
         dispatchEvent(new GameEvent(GameEvent.CALL,"OnConfigUI"));
      }
      
      protected function updateHints(param1:Event = null) : void
      {
         var _loc2_:Boolean = InputManager.getInstance().isGamepad();
         this.btnSwitchHint.visible = _loc2_ && this._showHint;
         this.btnSwitchHintBackground.visible = _loc2_ && this._showHint;
         this.btnSwitchHintDoubleTap.visible = _loc2_ && this._showHint;
         this.btnSwitchHintBackgroundDoubleTap.visible = _loc2_ && this._showHint;
         this.btnSwitchHintOilsKB.visible = !_loc2_ && this._radialMenuOn;
         this.btnSwitchHintBackgroundOilsKB.visible = !_loc2_ && this._radialMenuOn;
         this.btnSwitchHintOils.visible = _loc2_ && this._radialMenuOn;
         this.btnSwitchHintBackgroundOils.visible = _loc2_ && this._radialMenuOn;
         this.btnSwitchHintOils.y = this.cachedY;
         this.btnSwitchHintBackgroundOils.y = this.cachedY;
         this.btnSwitchHintDoubleTap.y = this.btnSwitchHintOils.y - this.btnSwitchHintOils.height * 0.65;
         this.btnSwitchHintBackgroundDoubleTap.y = this.btnSwitchHintDoubleTap.y;
         this.btnSwitchHint.y = this.btnSwitchHintDoubleTap.y - this.btnSwitchHintOils.height * 0.65;
         this.btnSwitchHintBackground.y = this.btnSwitchHint.y;
         this.mcPotionSlot1.visible = _loc2_;
         this.mcPotionSlot2.visible = _loc2_;
         this.mcKbPotion1.visible = !_loc2_;
         this.mcKbPotion2.visible = !_loc2_;
         this.mcKbPotion3.visible = !_loc2_;
         this.mcKbPotion4.visible = !_loc2_;
         this.mcFoodSlot.visible = !_loc2_;
         this.mcExtraPotionSlot.visible = !_loc2_;
         if(_loc2_)
         {
            this.cancelExtraPotionInput();
         }
         this.mcKbOilSteel.visible = this._radialMenuOn && !_loc2_;
         this.mcKbOilSilver.visible = this._radialMenuOn && !_loc2_;
      }
      
      public function showButtonHints(param1:Boolean) : void
      {
         var _loc2_:Boolean = InputManager.getInstance().isGamepad();
         this._showHint = this._radialMenuOn;
         this.btnSwitchHint.visible = this._showHint && _loc2_;
         this.btnSwitchHintDoubleTap.visible = this._showHint && _loc2_;
         this.mcItemSlot.showButtonHint = param1;
         this.mcPotionSlot1.showButtonHint = param1;
         this.mcPotionSlot2.showButtonHint = param1;
      }
      
      public function HideSlots(param1:Boolean) : void
      {
         var _loc2_:Boolean = InputManager.getInstance().isGamepad();
         if(param1)
         {
            this.updateHints();
         }
         else
         {
            this.mcPotionSlot1.visible = false;
            this.mcPotionSlot2.visible = false;
            this.mcKbPotion1.visible = false;
            this.mcKbPotion2.visible = false;
            this.mcKbPotion3.visible = false;
            this.mcKbPotion4.visible = false;
            this.mcFoodSlot.visible = false;
            this.mcExtraPotionSlot.visible = false;
            this.cancelExtraPotionInput();
            this.mcKbOilSteel.visible = false;
            this.mcKbOilSilver.visible = false;
         }
      }
      
      public function animatePotionSwitch(param1:int) : void
      {
         var _loc2_:HudPotionInfo = null;
         switch(param1)
         {
            case HudItemInfoBinding_potion1:
               _loc2_ = this.mcPotionSlot1;
               break;
            case HudItemInfoBinding_potion2:
               _loc2_ = this.mcPotionSlot2;
         }
         if(_loc2_)
         {
            _loc2_.animateSwitching();
         }
      }
      
      public function setItemInfo(param1:int, param2:String, param3:String, param4:String, param5:String, param6:int, param7:int) : void
      {
         var _loc8_:HudItemInfo = null;
         var _loc9_:HudItemInfo = null;
         var _loc10_:HudPotionInfo = null;
         switch(param1)
         {
            case HudItemInfoBinding_item1:
               _loc9_ = this.mcItemSlot;
               break;
            case HudItemInfoBinding_potion1:
               _loc9_ = this.mcPotionSlot1;
               _loc8_ = this.mcKbPotion1;
               break;
            case HudItemInfoBinding_potion2:
               _loc9_ = this.mcPotionSlot2;
               _loc8_ = this.mcKbPotion2;
               break;
            case HudItemInfoBinding_potion3:
               _loc9_ = null;
               _loc10_ = this.mcPotionSlot1 as HudPotionInfo;
               _loc8_ = this.mcKbPotion3;
               break;
            case HudItemInfoBinding_potion4:
               _loc9_ = null;
               _loc10_ = this.mcPotionSlot2 as HudPotionInfo;
               _loc8_ = this.mcKbPotion4;
               break;
            case HudItemInfoBinding_steelsword:
               _loc9_ = null;
               _loc10_ = null;
               _loc8_ = this.mcKbOilSteel;
               break;
            case HudItemInfoBinding_silversword:
               _loc9_ = null;
               _loc10_ = null;
               _loc8_ = this.mcKbOilSilver;
         }
         if(_loc9_)
         {
            _loc9_.IconName = param2;
            _loc9_.ItemCategory = param3;
            _loc9_.ItemName = param4;
            _loc9_.ItemAmmo = param5;
            _loc9_.setItemButtons(param6,param7);
         }
         if(_loc8_)
         {
            _loc8_.IconName = param2;
            _loc8_.ItemCategory = param3;
            _loc8_.ItemName = param4;
            _loc8_.ItemAmmo = param5;
            _loc8_.setItemButtons(param6,param7);
         }
         if(Boolean(_loc9_) || Boolean(_loc8_))
         {
            dispatchEvent(new GameEvent(GameEvent.UPDATE,this.moduleName));
         }
         if(_loc10_)
         {
            _loc10_.alterIconPath = param2;
         }
         if(this._showHint && Boolean(this.btnSwitchHint) && InputManager.getInstance().isGamepad())
         {
         }
      }
      
      public function setFoodInfo(icon:String, category:String, foodName:String, quantity:String, key:int) : void
      {
         if(this.foodKey != key)
         {
            this.cancelFoodInput();
         }
         this.foodKey = key;
         this.mcFoodSlot.IconName = icon;
         this.mcFoodSlot.ItemCategory = category;
         this.mcFoodSlot.ItemName = foodName;
         this.mcFoodSlot.ItemAmmo = quantity;
         this.mcFoodSlot.setItemButtons(-1,key);
         this.mcFoodSlot.mcButton.visible = true;
         this.mcFoodSlot.mcTextBackground.visible = true;
         this.mcFoodSlot.mcDefaultIcon.visible = false;
         dispatchEvent(new GameEvent(GameEvent.UPDATE,this.moduleName));
      }
      
      public function setExtraPotionInfo(icon:String, category:String, potionName:String, quantity:String, key:int) : void
      {
         if(this.extraPotionKey != key)
         {
            this.cancelExtraPotionInput();
         }
         this.extraPotionKey = key;
         this.mcExtraPotionSlot.IconName = icon;
         this.mcExtraPotionSlot.ItemCategory = category;
         this.mcExtraPotionSlot.ItemName = potionName;
         this.mcExtraPotionSlot.ItemAmmo = quantity;
         this.mcExtraPotionSlot.setItemButtons(-1,key);
         this.mcExtraPotionSlot.mcButton.visible = true;
         this.mcExtraPotionSlot.mcTextBackground.visible = true;
         this.mcExtraPotionSlot.mcDefaultIcon.visible = false;
         dispatchEvent(new GameEvent(GameEvent.UPDATE,this.moduleName));
      }
      
      public function EnableElement(param1:Boolean) : void
      {
      }
      
      override public function SetEnabled(param1:Boolean) : *
      {
         isEnabled = param1;
         if(!isEnabled)
         {
            SetState("Hide");
            this.alpha = 0;
            this.desiredAlpha = 0;
         }
         else if(this.isAlwaysDisplayed)
         {
            SetState("OnUpdate");
            this.setAlwaysDisplayed(this.isAlwaysDisplayed);
         }
      }
      
      public function UpdateElement() : void
      {
         dispatchEvent(new GameEvent(GameEvent.UPDATE,this.moduleName));
      }
      
      public function setAlwaysDisplayed(param1:Boolean) : *
      {
         this.isAlwaysDisplayed = param1;
         if(param1)
         {
            RemoveUpdateTimer();
            dispatchEvent(new GameEvent(GameEvent.UPDATE,this.moduleName));
         }
      }
      
      override public function ShowElement(param1:Boolean, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(param3)
         {
            if(!this.isAlwaysDisplayed)
            {
               ShowElementFromState(param1,param2);
            }
         }
         else
         {
            stateMachine.ShowElement(param1,param2);
         }
      }
      
      override internal function UpdateTimerFinishedCounting(param1:TimerEvent) : void
      {
         if(this.isAlwaysDisplayed)
         {
            RemoveUpdateTimer();
            return;
         }
         super.UpdateTimerFinishedCounting(param1);
      }
      
      internal function __setProp_mcItemSlot_Scene1_Item_0() : *
      {
         try
         {
            this.mcItemSlot["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.mcItemSlot.enabled = true;
         this.mcItemSlot.enableInitCallback = false;
         this.mcItemSlot.minimalSize = 140;
         this.mcItemSlot.visible = true;
         try
         {
            this.mcItemSlot["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

