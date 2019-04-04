--[[----------------------------------------------------------------------------

UniteGalleryInitPlugin.lua
Init the plugin

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrPrefs = import 'LrPrefs'

--============================================================================--

local prefs = LrPrefs.prefsForPlugin() 

-- Setting up defaults
if prefs.logging_method == nil then
   prefs.logging_method = "off"
end
if prefs.logging_level == nil then
   prefs.logging_level = "info"
end
