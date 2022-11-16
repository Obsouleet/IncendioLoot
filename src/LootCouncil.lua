local addonName, addon = ...
local IncendioLoot = _G[ addonName ]
local AceConsole = LibStub("AceConsole-3.0")
IncendioLoot.LootCouncil = {}

--[[
    Event handling
]]--
IncendioLoot.LootCouncil.EVENTS = {
    EVENT_LOOT_LOOTED = "IL.LC.LootLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_CAST = "IL.LC.LootVoteCast", -- whenever a loot council member votes on an item
    EVENT_LOOT_DISTRIBUTED = "IL.LC.LootDistributed" -- whenever the council distributes an item
}

function IncendioLoot.LootCouncil:HandleLootLootedEvent()
    -- TBD
end

function IncendioLoot.LootCouncil:HandleLootVoteCastEvent()
    -- TBD
end

function IncendioLoot.LootCouncil:HandleLootDistributedEvent()
    -- TBD
end

IncendioLoot:RegisterMessage(IncendioLoot.LootCouncil.EVENTS.EVENT_LOOT_LOOTED, IncendioLoot.LootCouncil.HandleLootLootedEvent)
IncendioLoot:RegisterMessage(IncendioLoot.LootCouncil.EVENTS.EVENT_LOOT_VOTE_CAST, IncendioLoot.LootCouncil.HandleLootVoteCastEvent)
IncendioLoot:RegisterMessage(IncendioLoot.LootCouncil.EVENTS.EVENT_LOOT_DISTRIBUTED, IncendioLoot.LootCouncil.HandleLootDistributedEvent)