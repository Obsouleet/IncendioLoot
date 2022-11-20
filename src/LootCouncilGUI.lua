local addonName, addon = ...
local IncendioLoot = _G[addonName]
local LootCouncilGUI = IncendioLoot:NewModule("LootCouncilGUI", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local AceConsole = LibStub("AceConsole-3.0")

local MainFrame, ItemTabFrame, VoteFrame, ChatFrame = nil, nil, nil, nil

local VoteItems = {}
local TabIndex = 1

local function DrawVoteFrame(itemTab)
    local ItemData = VoteItems[itemTab]
    if not ItemData then return end
end

local function OnItemTabSelected(container, event, group)
    container:ReleaseChildren()
    DrawVoteFrame(group)
end

local function CreateItemTab(data)
    local item = Item:CreateFromItemID(data.item)
    local ItemTab = AceGUI:Create("InteractiveLabel")

    AceConsole:Print("HELLAS")
    AceConsole:Print(item)

    ItemTab:SetImageSize(40, 40)
    ItemTab.frame:SetHyperlink(item)

    local CurrentItemTab = "tab"..TabIndex
    VoteItems[CurrentItemTab] = data
    
    ItemTab:SetCallback("OnClick", function(widget)
        LootCouncilGUI:SetActiveItemTab(CurrentItemIndex)
    end)

    TabIndex = TabIndex + 1
    return ItemTab
end

local function CreateItemTabFrame()
    ItemTabFrame = AceGUI:Create("ScrollFrame")
    MainFrame:AddChild(ItemTabFrame)
    CreateItemTab({item = 19019})
end

local function CreateMainFrame()
    MainFrame = AceGUI:Create("Frame")
    MainFrame:SetLayout("List")
    MainFrame:SetTitle("IncendioLoot")

    CreateItemTabFrame()
end

--[[
    Event handling
]] --
local function HandleLootLootedEvent(prefix, str, distribution, sender)
    local _, data = LootCouncilGUI:Deserialize(str)
    local ItemTab = CreateItemTab(data)
    ItemTabFrame:AddChild(ItemTab)
end


function LootCouncilGUI:OnInitialize()
    LibStub("AceComm-3.0"):Embed(LootCouncilGUI)
    
    LootCouncilGUI:RegisterComm(IncendioLoot.EVENTS.EVENT_LOOT_LOOTED, HandleLootLootedEvent)

    --CreateMainFrame()
end