--[[----------------------------------------------------------------------------

UniteGalleryServiceProvider.lua
An export service provider that creates a Unite Gallery.

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- UniteGallery plug-in
require 'UniteGalleryExportDialogSections'
require 'UniteGalleryExportTask'


--============================================================================--

return {
   
   hideSections = { 'exportLocation' },

   allowFileFormats = nil, -- nil equates to all available formats
   canExportVideo = true,
   
   allowColorSpaces = nil, -- nil equates to all color spaces
   hidePrintResolution = true,

   exportPresetFields = {
      { key = 'path', default = 'photos' },
      { key = 'title', default = LOC "$$$/UniteGallery/Default/Title=Unite Gallery" },
      { key = 'creator_enabled', default = false },
      { key = 'creator_title', default = LOC "$$$/UniteGallery/Default/CreatorTitle=Me" },
      { key = 'creator_url', default = LOC "$$$/UniteGallery/Default/CreatorURL=mailto:me@example.com" },
      { key = 'other_link_enabled', default = false },
      { key = 'other_link_title', default = LOC "$$$/UniteGallery/Default/OtherLinkTitle=Homepage" },
      { key = 'other_link_url', default = LOC "$$$/UniteGallery/Default/OtherLinkURL=https://example.com/" },
      { key = 'original_res_link_enabled', default = false },
      { key = 'original_res_link_title', default = LOC "$$$/UniteGallery/Default/OriginalLinkTitle=Link to full resolution image." },
   },

   startDialog = UniteGalleryExportDialogSections.startDialog,
   sectionsForTopOfDialog = UniteGalleryExportDialogSections.sectionsForTopOfDialog,
   
   processRenderedPhotos = UniteGalleryExportTask.processRenderedPhotos,
}
