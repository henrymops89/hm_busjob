-- ════════════════════════════════════════════════════════════════════════════════════
-- INVENTORY BRIDGE - ox_inventory Support
-- ════════════════════════════════════════════════════════════════════════════════════

Inventory = {}
Inventory.Type = Config.Inventory

-- ════════════════════════════════════════════════════════════════════════════════════
-- ITEM FUNCTIONS (Server-Side Only)
-- ════════════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() == 1 then
    
    --- Add item to player
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param count number Item count
    --- @param metadata table|nil Item metadata
    --- @return boolean Success
    function Inventory.AddItem(source, item, count, metadata)
        if Inventory.Type == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, count, metadata)
        end
        return false
    end
    
    --- Remove item from player
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param count number Item count
    --- @return boolean Success
    function Inventory.RemoveItem(source, item, count)
        if Inventory.Type == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, count)
        end
        return false
    end
    
    --- Get item count
    --- @param source number Player server ID
    --- @param item string Item name
    --- @return number Count
    function Inventory.GetItemCount(source, item)
        if Inventory.Type == 'ox_inventory' then
            local count = exports.ox_inventory:GetItemCount(source, item)
            return count or 0
        end
        return 0
    end
    
    --- Check if player has item
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param count number Required count
    --- @return boolean Has item
    function Inventory.HasItem(source, item, count)
        count = count or 1
        return Inventory.GetItemCount(source, item) >= count
    end
    
end
