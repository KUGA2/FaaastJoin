-----------------------------------------------------------------------------------------------
-- Client Lua Script for FaaastJoin
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- FaaastJoin Module Definition
-----------------------------------------------------------------------------------------------
FaaastJoin = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function FaaastJoin:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function FaaastJoin:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- FaaastJoin OnLoad
-----------------------------------------------------------------------------------------------
function FaaastJoin:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("FaaastJoin.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayer", 			"OnContextMenu", self) -- 2 args + 2 optional
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayerDetailed", 	"OnContextMenu", self) -- 3 args + 1 optional
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuFriend", 			"OnFriendContextMenu", self) -- 2 args
	
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
    FaaastJoin.log = GeminiLogging:GetLogger({
        level = GeminiLogging.DEBUG,
        pattern = "%d %n %c %l - %m",
        appender = "GeminiConsole"
    })
end

-----------------------------------------------------------------------------------------------
-- FaaastJoin OnDocLoaded
-----------------------------------------------------------------------------------------------
function FaaastJoin:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "FaaastJoinForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
	    self.wndMain:Show(false, true)
	
		self.wndButton = Apollo.LoadForm(self.xmlDoc, "FaaastJoinButtonWindow", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		self.wndButton:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("fjdebug", "OnFaaastJoinOn", self)

		-- Do additional Addon initialization here	
		
		-- Find ContextMenuPlayer addon
		self.addon = Apollo.GetAddon("ContextMenuPlayer")
		if self.addon == nil then
			self.log:fatal("addon = nil")
		end
		
		-- Remove Events to call the original registered methods manually
		Apollo.RemoveEventHandler("GenericEvent_NewContextMenuPlayer", self.addon)
		Apollo.RemoveEventHandler("GenericEvent_NewContextMenuPlayerDetailed", self.addon)	
		Apollo.RemoveEventHandler("GenericEvent_NewContextMenuFriend", self.addon)
		
		--Hook OnMainWindowClosedPreHook
		Apollo.RegisterEventHandler("OnMainWindowClosedPreHook", "OnMainWindowClosedPreHook", self) -- 2 args
		self.addon.org = self.addon.OnMainWindowClosed
	
		self.addon.OnMainWindowClosed = function(...)
			Event_FireGenericEvent("OnMainWindowClosedPreHook")
			self.addon:org (...)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- FaaastJoin Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/fjdebug"
function FaaastJoin:OnFaaastJoinOn()
	FaaastJoin.log:debug("OnFaaastJoinOn")
end

-- on Hook OnMainWindowClosedPreHook
function FaaastJoin:OnMainWindowClosedPreHook()
	FaaastJoin.log:debug("OnMainWindowClosedPreHook")
	self.wndButton:Close()
end

-- on Context Menu
function FaaastJoin:OnContextMenu(wndParent, strTarget, unitTarget, tOptionalCharacterData)
	self.log:debug("OnContextMenu")
	self.addon:Initialize(wndParent, strTarget, unitTarget, tOptionalCharacterData)
	self:DrawButton(strTarget)
end

-- on Friend Context Menu
function FaaastJoin:OnFriendContextMenu(wndParent, nFriendId)
	self.log:debug("OnFriendContextMenu")
	self.addon:InitializeFriend(wndParent, nFriendId)
	local tFriend = FriendshipLib.GetById(nFriendId)
	local tAccountFriend = FriendshipLib.GetAccountById(nFriendId)
	if tFriend ~= nil then
		self:DrawButton(tFriend.strCharacterName)
	elseif tAccountFriend ~= nil then
		-- maybe loop over elements for all chars?
		if tAccountFriend.arCharacters and tAccountFriend.arCharacters[1] ~= nil then
			self:DrawButton(tAccountFriend.arCharacters[1].strCharacterName)
		end		
	end
end

-- DrawButton
function FaaastJoin:DrawButton(nameString)
	self.log:debug("DrawButton")
	self.str = nameString
	if self.str == nil then
		self.log:fatal("self.str = nil")
	end
	if self.addon.wndMain == nil then
		self.log:fatal("self.addon.wndMain = nil")
	else
		self.addon.left, self.addon.top, self.addon.right, self.addon.bottom = self.addon.wndMain:GetAnchorOffsets()
		self.wndButton:SetAnchorOffsets(self.addon.left+20, self.addon.top-50, self.addon.right, self.addon.top+30)
		self.log:debug(self.addon.left .. " " .. self.addon.top .. " " .. self.addon.right .. " " .. self.addon.bottom)
		self.wndButton:Invoke() -- show the window
		--self.wndMain:Invoke() -- show the window
	end
end

-----------------------------------------------------------------------------------------------
-- FaaastJoinForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function FaaastJoin:OnOK()
	self.log:debug("OnOK: /join " .. self.str)
	ChatSystemLib.Command("/join " .. self.str)
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function FaaastJoin:OnCancel()
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- FaaastJoinButtonWindow Functions
-----------------------------------------------------------------------------------------------
-- when the button is clicked
function FaaastJoin:OnJoinButton()
	self.log:debug("OnJoinButton: /join " .. self.str)
	ChatSystemLib.Command("/join " .. self.str)
	self.wndButton:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- FaaastJoin Instance
-----------------------------------------------------------------------------------------------
local FaaastJoinInst = FaaastJoin:new()
FaaastJoinInst:Init()
