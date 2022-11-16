local addonName, addon = ...
local IncendioLoot = _G[ addonName ]
local AceConsole = LibStub("AceConsole-3.0")
IncendioLoot.LootCouncil = {}

--[[
    Event handling
]]--

function IncendioLoot.LootCouncil:HandleLootLootedEvent()
    -- TBD
end

function IncendioLoot.LootCouncil:HandleLootVoteCastEvent()
    -- TBD
end

function IncendioLoot.LootCouncil:HandleLootDistributedEvent()
    -- TBD
end

IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED, IncendioLoot.LootCouncil.HandleLootLootedEvent)
IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_CAST, IncendioLoot.LootCouncil.HandleLootVoteCastEvent)
IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_DISTRIBUTED, IncendioLoot.LootCouncil.HandleLootDistributedEvent)