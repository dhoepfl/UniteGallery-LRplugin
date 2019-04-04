--[[----------------------------------------------------------------------------

UniteGalleryExportDialogSections.lua
Export dialog customization for Unite Gallery exporter

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrView = import 'LrView'
local LrFileUtils = import 'LrFileUtils'

--============================================================================--

UniteGalleryExportDialogSections = {}

-------------------------------------------------------------------------------

local function updateExportStatus( propertyTable )
   
   local message = nil
   
   repeat
      -- Use a repeat loop to allow easy way to "break" out.
      -- (It only goes through once.)
      
      if propertyTable.path == nil or propertyTable.path == "" then
         message = LOC "$$$/UniteGallery/ExportDialog/Messages/SelectPath=Enter a destination path."
         break
      end

      if propertyTable.creator_enabled and ( propertyTable.creator_title == "" or propertyTable.creator_title == nil ) then
         message = LOC "$$$/UniteGallery/ExportDialog/Messages/Creator=Enter a creator name"
         break
      end
      
      if propertyTable.other_link_enabled and ( propertyTable.other_link_title == "" or propertyTable.other_link_title == nil or propertyTable.other_link_url == "" or propertyTable.other_link_url == nil) then
         message = LOC "$$$/UniteGallery/ExportDialog/Messages/OtherLink=Enter homepage title and URL."
         break
      end

      if propertyTable.original_res_link_enabled and ( propertyTable.original_res_link_title == "" or propertyTable.original_res_link_title == nil) then
         message = LOC "$$$/UniteGallery/ExportDialog/Messages/OriginalLink=Enter original image link title."
         break
      end
   until true
   
   if message then
      propertyTable.hasError = true
      propertyTable.hasNoError = false
      propertyTable.LR_cantExportBecause = message
   else
      propertyTable.hasError = false
      propertyTable.hasNoError = true
      propertyTable.LR_cantExportBecause = nil
   end
   
end

-------------------------------------------------------------------------------

function UniteGalleryExportDialogSections.startDialog( propertyTable )
   
   propertyTable:addObserver( 'path', updateExportStatus )
   propertyTable:addObserver( 'creator_enabled', updateExportStatus )
   propertyTable:addObserver( 'creator_title', updateExportStatus )
   propertyTable:addObserver( 'creator_url', updateExportStatus )
   propertyTable:addObserver( 'other_link_enabled', updateExportStatus )
   propertyTable:addObserver( 'other_link_title', updateExportStatus )
   propertyTable:addObserver( 'other_link_url', updateExportStatus )
   propertyTable:addObserver( 'original_res_link_enabled', updateExportStatus )
   propertyTable:addObserver( 'original_res_link_title', updateExportStatus )
   
   updateExportStatus( propertyTable )
   
end

-------------------------------------------------------------------------------

function UniteGalleryExportDialogSections.sectionsForTopOfDialog( viewFactory, propertyTable )

   local f = viewFactory
   local bind = LrView.bind
   local share = LrView.share

   local result = {
   
      {
         title = LOC "$$$/UniteGallery/ExportDialog/UniteGallerySettings=Unite Gallery",
         
         synopsis = bind { key = 'title', object = propertyTable },
         
         -- Basic info
         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/Title=Title:",
               alignment = 'right',
               width = share 'labelWidth'
            },
   
            f:edit_field {
               value = bind 'title',
               truncation = 'middle',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/Title/Tooltip=Enter the title of the gallery.",
               fill_horizontal = 1,
            },
         },

         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/Destination=Destination:",
               alignment = 'right',
               width = share 'labelWidth'
            },
   
            f:edit_field {
               value = bind 'path',
               truncation = 'middle',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/Destination/Tooltip=Enter the path you want the gallery to be saved at.",
               fill_horizontal = 1,
            },
         },

         
         -- creator info
         f:row {
            f:checkbox {
               title = LOC "$$$/UniteGallery/ExportDialog/IncludeCreator=Include creator",
               value = bind 'creator_enabled',
               tooltip = LOC "$$$/UniteGallery/ExportDialog/IncludeCreator/Tooltip=Check to include creator information in the gallery.",
            },
         },

         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/Creator=Creator:",
               alignment = 'right',
               enabled = bind 'creator_enabled',
               width = share 'labelWidth'
            },

            f:edit_field {
               value = bind 'creator_title',
               enabled = bind 'creator_enabled',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/Creator/Tooltip=The creator info shown in the gallery.",
               fill_horizontal = 1,
            },
         },
         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/URL=URL:",
               alignment = 'right',
               enabled = bind 'creator_enabled',
               width = share 'labelWidth'
            },
            f:edit_field {
               value = bind 'creator_url',
               enabled = bind 'creator_enabled',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/CreatorURL/Tooltip=The URL the creator info links to (optional).",
               fill_horizontal = 1,
            },
         },
         
         
         -- Homepage link
         f:row {
            f:checkbox {
               title = LOC "$$$/UniteGallery/ExportDialog/IncludeOtherLink=Include homepage link",
               value = bind 'other_link_enabled',
               tooltip = LOC "$$$/UniteGallery/ExportDialog/IncludeOtherLink/Tooltip=Check to include an additional link in the gallery.",
            },
         },

         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/OtherLink=Homepage:",
               alignment = 'right',
               enabled = bind 'other_link_enabled',
               width = share 'labelWidth'
            },

            f:edit_field {
               value = bind 'other_link_title',
               enabled = bind 'other_link_enabled',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/OtherLink/Tooltip=The title of the additional link.",
               fill_horizontal = 1,
            },
         },
         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/URL=URL:",
               alignment = 'right',
               enabled = bind 'other_link_enabled',
               width = share 'labelWidth'
            },
            f:edit_field {
               value = bind 'other_link_url',
               enabled = bind 'other_link_enabled',
               tooltip = LOC "$$$/UniteGallery/ExportDialog/OtherLinkURL/Tooltip=The URL the additional link points to.",
               immediate = true,
               fill_horizontal = 1,
            },
         },


         -- Link to original res image
         f:row {
            f:checkbox {
               title = LOC "$$$/UniteGallery/ExportDialog/IncludeOriginalLink=Include link to original res image",
               value = bind 'original_res_link_enabled',
               tooltip = LOC "$$$/UniteGallery/ExportDialog/IncludeOriginalLink/Tooltip=Check to include original resolution versions of the images in the gallery.",
            },
         },

         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/ExportDialog/OriginalLinkTitle=Original Resolution Link Title:",
               alignment = 'right',
               enabled = bind 'original_res_link_enabled',
               width = share 'labelWidth'
            },

            f:edit_field {
               value = bind 'original_res_link_title',
               enabled = bind 'original_res_link_enabled',
               immediate = true,
               tooltip = LOC "$$$/UniteGallery/ExportDialog/OriginalLink/Tooltip=The title of the original resolution image link.",
               fill_horizontal = 1,
            },
         },
      },
   }
   
   return result
end
