--[[----------------------------------------------------------------------------

Info.lua
Unite Gallery export target.

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.


------------------------------------------------------------------------------]]

return {

   LrSdkVersion = 6.0,
   LrSdkMinimumVersion = 5.0, -- minimum SDK version required by this plug-in

   LrToolkitIdentifier = 'de.hoepfl.lightroom.export.unite.gallery',

   LrPluginName = LOC "$$$/UniteGallery/PluginName=Unite Gallery",
   LrPluginInfoUrl = "mailto:unite@hoepfl.de",
   
   LrExportServiceProvider = {
      title = "Unite Gallery",
      file = 'UniteGalleryServiceProvider.lua',
   },
   -- LrExportMenuItems = {
   --    title = "Unite Gallery",
   --    enabledWhen = "anythingSelected",
   --    file = 'UniteGalleryServiceProvider.lua',
   -- },

   VERSION = { major=1, minor=0, revision=0, build=0, },

}
