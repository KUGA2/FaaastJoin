-----------------------------------------------------------------------------------------------
-- Client Lua Script for FaaastJoin
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- FaaastJoin Module Definition
-----------------------------------------------------------------------------------------------
local FaaastJoin = {} 
 
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
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuFriend", 			"OnContextMenu", self) -- 2 args
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

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("fjdebug", "OnFaaastJoinOn", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- FaaastJoin Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/fjdebug"
function FaaastJoin:OnFaaastJoinOn()
	self.wndMain:Invoke() -- show the window
end

-- on SlashCommand "/fjdebug"
function FaaastJoin:OnContextMenu(wndParent, strTarget, unitTarget, tOptionalCharacterData)
	Print("OnContextMenu")
	self.str = strTarget
	self.wndMain:Invoke() -- show the window
end

-----------------------------------------------------------------------------------------------
-- FaaastJoinForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function FaaastJoin:OnOK()
	ChatSystemLib.Command("/join " .. self.str)
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function FaaastJoin:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- FaaastJoin Instance
-----------------------------------------------------------------------------------------------
local FaaastJoinInst = FaaastJoin:new()
FaaastJoinInst:Init()
