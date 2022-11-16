local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon( "IncendioLoot", "AceConsole-3.0", "AceEvent-3.0" )
_G[ addonName ] = IncendioLoot


--[[
    Global events
]]--
IncendioLoot.EVENTS = {
    EVENT_LOOT_LOOTED = "IL.LC.LootLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_CAST = "IL.LC.LootVoteCast", -- whenever a loot council member votes on an item
    EVENT_LOOT_DISTRIBUTED = "IL.LC.LootDistributed" -- whenever the council distributes an item
}