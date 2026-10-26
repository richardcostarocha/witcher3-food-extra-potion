function checkSlotsCompatibility(slot1:int, slot2:int) : Boolean
      {
         if((slot1 == InventorySlotType.Quickslot1 || slot1 == InventorySlotType.Quickslot2) && (slot2 == InventorySlotType.Quickslot1 || slot2 == InventorySlotType.Quickslot2))
         {
            return true;
         }
         if((slot1 == InventorySlotType.Potion1 || slot1 == InventorySlotType.Potion2) && (slot2 == InventorySlotType.Potion1 || slot2 == InventorySlotType.Potion2))
         {
            return true;
         }
         if((slot1 == InventorySlotType.Petard1 || slot1 == InventorySlotType.Petard2) && (slot2 == InventorySlotType.Petard1 || slot2 == InventorySlotType.Petard2))
         {
            return true;
         }
         return slot1 == slot2;
      }
