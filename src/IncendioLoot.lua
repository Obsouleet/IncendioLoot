local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon("IncendioLoot",
                                                "AceConsole-3.0", "AceComm-3.0",
                                                "AceSerializer-3.0")
_G[addonName] = IncendioLoot
local AceConsole = LibStub("AceConsole-3.0")
--[[
    Init
]] --
function IncendioLoot:OnEnable() LibStub("AceComm-3.0"):Embed(IncendioLoot) end

--[[
    Global events
]] --
IncendioLoot.EVENTS = {
    EVENT_LOOT_LOOTED = "IL.LC.LootLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_CAST = "IL.LC.LootVoteCast", -- whenever a loot council member votes on an item
    EVENT_LOOT_DISTRIBUTED = "IL.LC.LootDistributed" -- whenever the council distributes an item
}

IncendioLoot.LootUtil = {}
function IncendioLoot.LootUtil.SendLootEvent(self, item, looter, encounter)
    local data = {item = item, looter = looter, encounter = encounter}
    local s = IncendioLoot:Serialize(data)
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED, s,
                                 "GUILD")
end
