event  OnSelectionModeTargetChosen( targetSlot : int )
	{
		var alreadyEquippedItem : bool;
		var isEquippedItemValid : bool;
		var curItemInSlot, otherMask : SItemUniqueId;
		var filterType : EInventoryFilterType;
		
		alreadyEquippedItem = false;
		
		if( _inv.ItemHasTag( m_selectionModeItem, 'mod_dye' ) )
		{
			ApplyDye( m_selectionModeItem, targetSlot );
			m_dyePreviewMode = false;
		}
		
		
		else
		if (_playerInv.isPotionItem(m_selectionModeItem) || _playerInv.isPetardItem(m_selectionModeItem) || _playerInv.isQuickslotItem(m_selectionModeItem) || _playerInv.isFoodItem(m_selectionModeItem) )
		{
			if (AreManualEquipmentChangesBlocked())
			{
				ShowEquipmentChangeBlockedFeedback();
				HideSelectionMode();
				return false;
			}

			
			if(_inv.IsItemMask(m_selectionModeItem))
			{
				if(targetSlot == EES_Quickslot1)
					GetWitcherPlayer().GetItemEquippedOnSlot(EES_Quickslot2, otherMask);
				else if(targetSlot == EES_Quickslot2)
					GetWitcherPlayer().GetItemEquippedOnSlot(EES_Quickslot1, otherMask);
			}
			
			alreadyEquippedItem = GetWitcherPlayer().GetItemEquippedOnSlot(targetSlot, curItemInSlot);
			
			PlayItemEquipSound( _inv.GetItemCategory(m_selectionModeItem) );
			_playerInv.EquipItem( m_selectionModeItem, targetSlot );
			UpdatePlayerStatisticsData();
			
			if (alreadyEquippedItem && _inv.IsIdValid(curItemInSlot))
			{
				InventoryRemoveItem(m_selectionModeItem, true);
				InventoryUpdateItem(curItemInSlot);
				
				filterType = _playerInv.GetFilterTypeByItem(curItemInSlot);
				_playerInv.SetFilterType( filterType );
				UpdateInventoryFilter(filterType);
			}
			else
			{
				InventoryRemoveItem(m_selectionModeItem);
			}
			
			
			if(_inv.IsItemMask(m_selectionModeItem) && _inv.IsItemMask(otherMask))
			{
				PaperdollRemoveItem(otherMask);
				InventoryUpdateItem(otherMask);
			}
			
			PaperdollUpdateItem(m_selectionModeItem);
		}
		else if (_inv.ItemHasTag(m_selectionModeItem, 'Upgrade'))
		{
			ApplyUpgrade(m_selectionModeItem, targetSlot);
		}
		else if (_inv.ItemHasTag(m_selectionModeItem, 'SteelOil') || _inv.ItemHasTag(m_selectionModeItem, 'SilverOil'))
		{
			ApplyOil(m_selectionModeItem, targetSlot);
		}
		else if (_inv.ItemHasTag(m_selectionModeItem, 'WeaponReapairKit') || _inv.ItemHasTag(m_selectionModeItem, 'ArmorReapairKit'))
		{
			ApplyRepairKit(m_selectionModeItem, targetSlot);
		}

		
		HideSelectionMode();
		UpdateGuiSceneEntityItems();
	}
