LoadAddOn("LibCompress")

local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncil = IncendioLoot:NewModule("LootCouncil",
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0",
                                                      "AceComm-3.0",
                                                      "AceSerializer-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")

--[[
    Event handling
]] --
function HandleLootLootedEvent(prefix, str, distribution, sender)
    local _, data = LootCouncil:Deserialize(str)
    AceConsole:Print(data.looter)
end

function LootCouncil:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootCouncil)
    LootCouncil:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                             HandleLootLootedEvent)
    IncendioLoot.LootUtil:SendLootEvent("someItem", "somePlayer", "someBoss")
end
