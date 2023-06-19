local addonName, addon = ...
IncendioLoot = LibStub("AceAddon-3.0"):NewAddon("IncendioLoot",
                                                "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
_G[addonName] = IncendioLoot
IncendioLoot.Version = GetAddOnMetadata(addonName, 'Version')
IncendioLoot.AddonActive = false
IncendioLootFunctions = {}
IncendioLoot.L = addon.L

local AceConsole = LibStub("AceConsole-3.0")
local L = addon.L

--[[
    ["subcommand"] = {
        ["callback"] = function(args),
        ["description"] = string
]]
local CommandCallbacks = {}

--[[
    Global events
    The event names cannot exceed 16 bytes
]] --
IncendioLoot.EVENTS = {
    EVENT_VERSION_COMPARE = "IL.VerComp", -- version comparison
    EVENT_VERSION_REQUEST = "IL.VerReq", -- version request
    EVENT_LOOT_LOOTED = "IL.LLooted", -- whenever a member loots an item
    EVENT_LOOT_VOTE_PLAYER = "IL.LVotedPlayer", -- whenever a player sets a vote on an item
    EVENT_LOOT_ANNOUNCE_COUNCIL = "IL.Council", -- announces the council as raidlead
    EVENT_SET_VOTING_INACTIVE = "IL.VoteInA", -- announces voting is set inactive
    EVENT_LOOT_LOOTDATA_BUILDED = "IL.LootBuild", -- Lootdata has been builded and structured
    EVENT_LOOT_ANNOUNCE_MLS = "IL.AnnounceMLs", -- Announces Masterlooters to all addonusers
    EVENT_LOOT_VOTE_COUNCIL = "IL.AnnounceVote", -- Announces the own vote to Council
    EVENT_LOOT_ASSIGN_ITEM_COUNCIL = "IL.AssignItem", --Announces the assigned item to the council
    EVENT_DATA_RECEIVED = "IL.DataReceived", --Council confirms when data is received
    EVENT_DATA_AUTODECISION = "IL.AutoDecision", --ML sends AutoDecision to Council
    EVENT_CHAT_SENT = "IL.ChatSent", --ChatEvent triggers when the chat is used
    EVENT_GET_DB_SYNC = "IL.DBSync", --Triggers if a DB-Sync starts
}

--[[
    local Dialogs
]]
StaticPopupDialogs["IL_DOAUTOPASS"] = {
    text = L["DO_AUTOPASS"],
    button1 = L["YES"],
    button2 = L["NO"],
    OnAccept = function(self)
        IncendioLoot.ILOptions.profile.options.general.autopass = true
    end,
    OnCancel = function (self)
        IncendioLoot.ILOptions.profile.options.general.autopass = false
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

--[[
    UwU pretty colors
]]
IncendioLoot.COLORS = {
    LIGHTBLUE = 'FF00CCFF',
    GREEN = 'FF03E83D',
    ORANGE = 'FFED8505',
    BLUE = 'FF046DFF',
    YELLOW = 'FFE1F40D',
    PURPLE = 'FFA301F9',
    GREY = 'FF898989'
}

local C = IncendioLoot.COLORS

function IncendioLootFunctions.CheckIfMasterLooter()
    if UnitIsGroupLeader("player") then 
        return(true)
    end
    
    local MasterLooter = IncendioLootDataHandler.GetExternalMasterLooter()
    
    for i, MasterLooter in pairs(MasterLooter) do
        if (UnitName("player") == MasterLooter) then
            return(true)
        end
    end
end

local function HandleGroupRosterUpdate()
    local LfgDungeonID = select(10, GetInstanceInfo())
	if LfgDungeonID == nil then 
        IncendioLoot:SendCommMessage(IncendioLoot.EVENTS.EVENT_VERSION_COMPARE,
                                    IncendioLoot.Version, IsInRaid() and "RAID" or "PARTY")
	end
end

function IncendioLoot:RegisterSubCommand(subcommand, callback, description)
    if not CommandCallbacks[subcommand] then
        CommandCallbacks[subcommand] = {
            callback = callback,
            description = description
        }
    else
        AceConsole:Print(string.format(L["ERROR_COMMAND_ALREADY_REGISTERED"], subommand, debugstack()))
    end
end

--[[
    Returns an iterator function that sorts a table alphabetically by its keys
]]--
local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

local function PrintChatCommands()
    AceConsole:Print(WrapTextInColorCode("/il", C.LIGHTBLUE).." - IncendioLoot [v"..WrapTextInColorCode(IncendioLoot.Version, C.LIGHTBLUE).."]")
    for command, tbl in pairsByKeys(CommandCallbacks) do
        AceConsole:Print("  "..WrapTextInColorCode(command, C.LIGHTBLUE).." - "..tbl.description)
    end 
end



local function CreateScrollCol(ColName, Width, sort, SortNext)
    if sort and (SortNext == 0) then
        return {
            ["name"] = ColName,
            ["width"] = Width,
            ["align"] = "LEFT",
            ["colorargs"] = nil,
            ["defaultsort"] = "dcs",
            ["DoCellUpdate"] = nil,
        }
    end
    if sort and (SortNext > 0) then
        return {
            ["name"] = ColName,
            ["width"] = Width,
            ["align"] = "LEFT",
            ["colorargs"] = nil,
            ["defaultsort"] = "acs",
            ["sortnext"]= SortNext,
            ["DoCellUpdate"] = nil,
        }
    end
    return {
        ["name"] = ColName,
        ["width"] = Width,
        ["align"] = "LEFT",
        ["colorargs"] = nil,
        ["defaultsort"] = "dsc",
        ["comparesort"] = function (cella, cellb, column)
            --function?
        end,
        ["DoCellUpdate"] = nil,
    }
end

local function BuildBasicData()
    local ScrollCols = {}
    table.insert(ScrollCols, CreateScrollCol("Name", 80, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Zone", 80, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Online", 50, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Answer", 80, true, 8))
    table.insert(ScrollCols, CreateScrollCol("Itemlevel", 50, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Slot 1", 50, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Slot 2", 50, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Roll", 50, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Votes", 70, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Gewichtung %", 70, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Notiz", 80, false, 0))

    return(ScrollCols)
end

local function BuildBasicHistoryData()
    local ScrollCols = {}
    table.insert(ScrollCols, CreateScrollCol("Name", 80, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Klasse", 100, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Antwort", 80, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Roll", 50, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Item", 120, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Instanz", 100, false, 0))
    table.insert(ScrollCols, CreateScrollCol("Datum", 100, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Uhrzeit", 100, true, 0))
    table.insert(ScrollCols, CreateScrollCol("Index", 0, false, 0))

    return(ScrollCols)
end

local function SetSessionInactive()
    IncendioLootDataHandler.SetSessionActiveInactive(false)
    IncendioLootLootVoting.CloseGUI()
    IncendioLootLootCouncilGUI.CloseGUI()
    IncendioLootDataHandler.WipeData()
    IncendioLootChatFrames.WipdeData()
    DEFAULT_CHAT_FRAME:AddMessage("The Session has been closed", 1, 1, 0)
end

local function trim(str)
    return str ~= nil and string.gsub(str, "^%s*(.-)%s*$", "%1") or nil
end

local function is_str_empty(str)
    return str == nil or trim(str) == ""
end

local function SetUpCommandHandler()
    IncendioLoot:RegisterChatCommand("il", function(msg)
        local args = {}
        if not is_str_empty(msg) then
            -- just select 3 args for now, should cover 99% of cases
            args = { AceConsole:GetArgs(msg, 1), AceConsole:GetArgs(msg, 2), AceConsole:GetArgs(msg, 3) }
        end

        local subCommand = #args > 0 and args[1] or nil
        if subCommand == nil or not CommandCallbacks[subCommand] then
            PrintChatCommands()
        else
            -- skip first arg (which is the subcommand)
            local cb_args = {}
            for i = 2, #args do
                cb_args[i-1] = args[i]
            end

            CommandCallbacks[subCommand].callback(cb_args)
        end
    end)

    IncendioLoot:RegisterSubCommand("help", PrintChatCommands, L["COMMAND_HELP"])
end

local function EnterRaidInstanceTimerStart()		
    if not IncendioLoot.ILOptions.profile.options.general.active or not IncendioLoot.ILOptions.profile.options.general.askForAutopass then 
        return
    end
    C_Timer.After(3, function() IL_EnterRaidInstance() end)		-- in some strange situations GetInstanceInfo() can be empty immediatly after entering - so we wait a little  
end


function IL_EnterRaidInstance()
	
    local _, InstanceType = GetInstanceInfo()
	
    if InstanceType ~= "raid" then
        return
    end

    StaticPopup_Show("IL_DOAUTOPASS")
end

local function RegisterCommsAndEvents()
    IncendioLoot:RegisterComm(IncendioLoot.EVENTS.EVENT_SET_VOTING_INACTIVE, SetSessionInactive)
    IncendioLoot:RegisterEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
    IncendioLoot:RegisterEvent("PLAYER_ENTERING_WORLD", EnterRaidInstanceTimerStart)	
    IncendioLoot:RegisterSubCommand("options", function() Settings.OpenToCategory('IncendioLoot') end, L["COMMAND_OPTIONS"])
end

local function BuildBasics()
    IncendioLootDataHandler.BuildAndSetMLTable()
    IncendioLootDataHandler.InitScrollFrameCols(BuildBasicData())
    IncendioLootDataHandler.InitHistoryScrollFrameCols(BuildBasicHistoryData())
    SetUpCommandHandler()
end

local function CheckOtherLootAddons()
    local _,_,_,Enabled = GetAddOnInfo("RCLootCouncil")
    if Enabled then 
        print(WrapTextInColorCode(L["DOUBLE_USE_WARNING"], "FFFF0000"))
    end
end

function IncendioLoot:OnInitialize()
    local DefaultOptions = {
        profile = {
            options = {
                general = {
                    active = false,
                    debug = false,
                    autopass = false,
                    askForAutopass = true,
                    allowDBSync = false
                },
                masterlooters = {
                    ml1 = "",
                    ml2 = "",
                    ml3 = "",
                    ml4 = "",
                    ml5 = ""
                }
            }
        }
    }
    local DefaultDBOptions = {
        profile = {
            history = {
            }
        },
        factionrealm = {
            history = {
                
            }
        }
    }
    LibStub("AceComm-3.0"):Embed(IncendioLoot)
    self.ILOptions = LibStub("AceDB-3.0"):New("IncendioLootOptionsDB", DefaultOptions, true)
    self.ILHistory = LibStub("AceDB-3.0"):New("IncendioLootHistoryDB", DefaultDBOptions, true)
end

function IncendioLoot:OnEnable()
    RegisterCommsAndEvents()
    BuildBasics()
    CheckOtherLootAddons()
end
