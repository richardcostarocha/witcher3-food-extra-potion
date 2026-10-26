event  OnUnequipItem( item : SItemUniqueId, moveToIndex : int )
	{
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
			return false;
		}

        if (extraPotionSlotSelected && item == GetWitcherPlayer().GetExtraPotionSlotItem())
        {
            if (AreManualEquipmentChangesBlocked())
            {
                ShowEquipmentChangeBlockedFeedback();
                return false;
            }
            GetWitcherPlayer().ClearExtraPotionSlotItem();
            if (moveToIndex >= 0)
                SetGridPosition(item, moveToIndex);
            InventoryUpdateItem(item);
            RefreshExtraPotionInventory();
            PlayItemUnequipSound('potion');
            return true;
        }
        if (foodSlotSelected && item == GetWitcherPlayer().GetFoodSlotItem())
        {
            if (AreManualEquipmentChangesBlocked())
            {
                ShowEquipmentChangeBlockedFeedback();
                return false;
            }
            GetWitcherPlayer().ClearFoodSlotItem();
            PaperdollUpdateAll();
            PlayItemUnequipSound('edibles');
            return true;
        }
		return UnequipItem(item, moveToIndex);
	}

function RefreshExtraPotionInventory()
    {
        PopulateTabData(InventoryMenuTab_Potions);
        PaperdollUpdateAll();
        thePlayer.SetUpdateQuickSlotItems(true);
    }
