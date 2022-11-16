local addonName, addon = ...
local IncendioLoot = _G[addonName]
local AceConsole = LibStub("AceConsole-3.0")
IncendioLoot.LootCouncil = {}

--[[
    Event handling
]] --

function HandleLootLootedEvent()
    -- TBD
end

function HandleLootVoteCastEvent()
    -- TBD
end

function HandleLootDistributedEvent()
    -- TBD
end

IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                             HandleLootLootedEvent)
IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_VOTE_CAST,
                             HandleLootVoteCastEvent)
IncendioLoot:RegisterMessage(IncendioLoot.EVENTS.EVENT_LOOT_DISTRIBUTED,
                             HandleLootDistributedEvent)
