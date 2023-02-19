local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootVoting = IncendioLoot:NewModule("LootVoting", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local LootVotingGUI = LibStub("AceGUI-3.0")
local L = addon.L
IncendioLootLootVoting = {}

local FrameOpen
local ChildCount = 0

local lootTypes = { "BIS", "UPGRADE", "SECOND", "OTHER", "TRANSMOG", "PASS" }
local rollStates = {}
local lootTypeColor = {
    ["BIS"] = IncendioLoot.COLORS.GREEN,
    ["UPGRADE"] = IncendioLoot.COLORS.ORANGE,
    ["SECOND"] = IncendioLoot.COLORS.BLUE,
    ["OTHER"] = IncendioLoot.COLORS.YELLOW,
    ["TRANSMOG"] = IncendioLoot.COLORS.PURPLE,
    ["PASS"] = IncendioLoot.COLORS.GREY
}

for _, type in ipairs(lootTypes) do
    table.insert(rollStates, {type = type, name = WrapTextInColorCode(L["VOTE_STATE_"..type], lootTypeColor[type])})
end


function IncendioLootLootVoting.CloseGUI()
    print("Dont Forget this!") -- TODO
end

local function BuildVoteWindow()
    local mainFrame = CreateFrame("Frame", "LootVoteMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(200, 200)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnMouseDown", function(self, button)
        self:StartMoving()
    end)
    mainFrame:SetScript("OnMouseUp", function(self, button)
        self:StopMovingOrSizing()
    end)
    mainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.5)
    mainFrame:SetBackdropBorderColor(1, 1, 1, 1)
    mainFrame:Hide()

    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -6, -6)

    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -10)
    title:SetText("Loot Voting") -- TODO

    local scrollFrame = CreateFrame("ScrollFrame", "LootVoteScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -30, 10)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(scrollFrame:GetWidth(), #IncendioLootDataHandler.GetLootTable() * 30)
    scrollFrame:SetScrollChild(scrollChild)

    -- Funktion zum Hinzufügen eines Items
    local function AddItem(itemName, itemLink)
        local numItems = #items + 1

        local itemFrame = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
        itemFrame:SetSize(scrollFrame:GetWidth() - 20, 30)
        itemFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -(numItems - 1) * 30)
        itemFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        itemFrame:SetBackdropColor(0, 0, 0, 0.5)
        itemFrame:SetBackdropBorderColor(1, 1, 1, 1)

        local itemNameText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemNameText:SetPoint("LEFT", itemFrame, "LEFT", 10, 0)
        itemNameText:SetText(itemName)

        local itemLinkText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemLinkText:SetPoint("LEFT", itemNameText, "RIGHT", 10, 0)
        itemLinkText:SetText(itemLink)

        local voteButtons = {}
        for i = 1, #rollStates do
            local voteButton = CreateFrame("Button", nil, itemFrame, "UIPanelButtonTemplate")
            voteButton:SetSize(25, 20)
            voteButton:SetPoint("RIGHT", itemFrame, "RIGHT", -((#rollStates - i) * 30 + 10), 0)
            voteButton:SetText(rollStates[i])
            voteButton:SetScript("OnClick", function()
                for j = 1, #voteButtons do
                    voteButtons[j]:Disable()
                end
                print("Vote button clicked for item " .. itemName)
            end)
            voteButtons[i] = voteButton
        end

        local commentBox = CreateFrame("EditBox", nil, itemFrame, "InputBoxTemplate")
        commentBox:SetSize(100, 20)
        commentBox:SetPoint("RIGHT", itemFrame, "RIGHT", -(#rollStates * 30 + 10), 0)
        commentBox:SetMaxLetters(30)
        commentBox:SetAutoFocus(false)
        commentBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        --[[ items[numItems] = {
            frame = itemFrame,
            itemName = itemName,
            itemLink = itemLink,
            voteButtons = voteButtons,
            commentBox = commentBox,
        } ]]
    end
end;

local function HandleLootLootedEvent(prefix, str, distribution, sender)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    
    local SetData = (not UnitIsGroupLeader("player") or 
        not IncendioLootFunctions.CheckIfMasterLooter()) and
        not IncendioLootDataHandler.GetSessionActive()

    if SetData then
        local _, LootTable = LootVoting:Deserialize(str)
        IncendioLootDataHandler.WipeData()
        IncendioLootDataHandler.SetLootTable(LootTable)
        IncendioLootDataHandler.SetSessionActiveInactive(true)
        if IncendioLoot.ILOptions.profile.options.general.debug then 
            print("Data Set for Voting")
        end
    end
    
    HandleLooted()
end

LootVoting:RegisterEvent("START_LOOT_ROLL", function (eventname, rollID)
    if not IncendioLoot.ILOptions.profile.options.general.active then 
        return
    end
    IncendioLootDataHandler.WipeViableLootData()

    local DoAutopass = (IncendioLoot.ILOptions.profile.options.general.autopass and
        not UnitIsGroupLeader("player"))

    local ViableLootRolls = {}
    local pendingLootRolls = GetActiveLootRollIDs()
    for i=1, #pendingLootRolls do
        if (pendingLootRolls ~= nil) then
            local _, ItemName, _, _, _, CanNeed = GetLootRollItemInfo(pendingLootRolls[i])
            if DoAutopass then
                C_Timer.After(0.3, function() RollOnLoot(pendingLootRolls[i], 0) end)
            end
            if CanNeed then
                ViableLootRolls[ItemName] = CanNeed
            end
        end
    end
    if not rawequal(next(ViableLootRolls), nil) then
        IncendioLootDataHandler.SetViableLoot(ViableLootRolls)
    end
end )

function LootVoting:OnEnable()
    LibStub("AceComm-3.0"):Embed(LootVoting)
    LootVoting:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED,
                            HandleLootLootedEvent)

    IncendioLoot:RegisterSubCommand("show", function ()
        if not IncendioLootDataHandler.GetSessionActive() or FrameOpen then
            return
        end
        for key, Item in pairs(IncendioLootDataHandler.GetLootTable()) do
            Item.Rolled = false
        end
        HandleLooted()
    end, L["COMMAND_SHOW"])
end