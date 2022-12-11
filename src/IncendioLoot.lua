local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon("IncendioLoot",
                                                "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
_G[addonName] = IncendioLoot
IncendioLoot.Version = GetAddOnMetadata(addonName, 'Version')
IncendioLoot.AddonActive = false
IncendioLoot.IsMasterLooter = false

local ReceivedOutOfDateMessage = false
local AceConsole = LibStub("AceConsole-3.0")
local tonumber = tonumber

--[[
    Global events
    The event names cannot exceed 16 bytes
]] --
IncendioLoot.EVENTS = {
    EVENT_VERSION_CHECK = "IL.VerChk", -- version comparison
    EVENT_LOOT_SESSION_STARTED = "IL.LSessStarted", -- whenever a new "loot session" is started
    EVENT_LOOT_LOOTED = "IL.LLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_CAST = "IL.LVoteCast", -- whenever a loot council member votes on an item
    EVENT_LOOT_DISTRIBUTED = "IL.LDist", -- whenever the council distributes an item
    EVENT_LOOT_VOTE_PLAYER = "IL.LVotedPlayer", -- whenever a player sets a vote on an item
    EVENT_CHAT_SENT = "IL.CSent" -- whenever a chat is
}

local function HandleVersionCheckEvent(_, versionStr, _, sender)
    if (sender == UnitName("player")) then
        return 
    end
    local ver, msg = tonumber(IncendioLoot.Version), tonumber(versionStr)
    if (msg and ver < msg and not ReceivedOutOfDateMessage) then
        AceConsole:Print("IncendioLoot out of date: Version "..versionStr.." is available.")
        ReceivedOutOfDateMessage = true
    end
end

local function HandleGroupRosterUpdate()
    IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_VERSION_CHECK,
                                IncendioLoot.Version, IsInRaid() and "RAID" or "PARTY")
end

--[[
    Loot utils
]] --


--[[
    Init
]] --
function IncendioLoot:OnInitialize()
    LibStub("AceComm-3.0"):Embed(IncendioLoot)
    self.DB = LibStub("AceDB-3.0"):New("IncendioLootDB")
end

--[[
    Enable
]] --
function IncendioLoot:OnEnable()
    IncendioLoot:RegisterComm(IncendioLoot.EVENTS.EVENT_VERSION_CHECK, HandleVersionCheckEvent)
    IncendioLoot:RegisterEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)

    HandleGroupRosterUpdate()
end
