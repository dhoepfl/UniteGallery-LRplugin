--[[----------------------------------------------------------------------------

UniteGalleryExportTask.lua
Generate a Unite Gallery

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- Lightroom API
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrErrors = import 'LrErrors'
local LrDialogs = import 'LrDialogs'
local LrExportSession = import 'LrExportSession'
local LrTasks = import 'LrTasks'
local template = require('template')

--============================================================================--

UniteGalleryExportTask = {}

--------------------------------------------------------------------------------

function UniteGalleryExportTask.processRenderedPhotos( functionContext, exportContext )

   -- Make a local reference to the export parameters.
   
   local exportSession = exportContext.exportSession
   local exportParams = exportContext.propertyTable
   local failures = {}
   
   -- Set progress title.

   exportParams.LR_collisionHandling = "overwrite"
   local nPhotos = exportSession:countRenditions()

   local progressScope = exportContext:configureProgress {
                  title = nPhotos > 1
                        and LOC( "$$$/UniteGallery/Export/Progress=Exporting ^1 photos into Unite Gallery", nPhotos )
                        or LOC "$$$/UniteGallery/Export/Progress/One=Exporting one photo into Unite Gallery",
               }
   
   -- Ensure target directory exists.
   
   local imagesDir = LrPathUtils.child( exportParams.path, "images" )
   local largeImagesDir = LrPathUtils.child( imagesDir, "large" )
   local previewImagesDir = LrPathUtils.child( imagesDir, "preview" )
   local originalImagesDir = LrPathUtils.child( imagesDir, "original" )
   
   LrFileUtils.createAllDirectories( exportParams.path )
   LrFileUtils.createAllDirectories( imagesDir )
   LrFileUtils.createAllDirectories( largeImagesDir )
   LrFileUtils.createAllDirectories( previewImagesDir )
   if exportParams.original_res_link_enabled then
      LrFileUtils.createAllDirectories( originalImagesDir )
   end

   -- Clear target folder
   for filePath in LrFileUtils.recursiveFiles( imagesDir ) do
      LrFileUtils.delete( filePath )
   end
   
   -- Iterate through photo renditions.

   local createdFiles = {}
   for _, rendition in exportContext:renditions{ stopIfCanceled = true } do
   
      -- Wait for next photo to render.
      local success, pathOrMessage = rendition:waitForRender()

      -- Check for cancellation again after photo has been rendered.
      if progressScope:isCanceled() then break end
      
      if success then

         local filename = LrPathUtils.leafName( pathOrMessage )
         local targetFilename = LrFileUtils.chooseUniqueFileName( LrPathUtils.child( largeImagesDir, filename ) )
         filename = LrPathUtils.leafName( targetFilename )

         local success = LrFileUtils.copy( pathOrMessage, targetFilename )
         if not success then
            table.insert( failures, filename )
         else
            if rendition.photo:getRawMetadata("isVideo") then
               local videoPreviewDone = false
               local videoPreview = nil
               local videoPreviewBig = nil

               local requestTask = nil
               LrTasks.startAsyncTask(function()
                     requestTask = rendition.photo:requestJpegThumbnail( 350, 350, function(jpeg, reason)
                        videoPreview = jpeg

                        requestTask = rendition.photo:requestJpegThumbnail( 2000, 2000, function(jpeg, reason)

                            videoPreviewBig = jpeg
                            videoPreviewDone = true
                            requestTask = nil
                         end)
                     end)
                  end)

               while not videoPreviewDone do
                  if LrTasks.canYield() then
                     LrTasks.yield()
                  else
                     LrTasks.sleep( .1 )
                  end
               end

               if not videoPreview or not videoPreviewBig then
                  table.insert( failures, filename )
               else
                  local targetPreview = LrPathUtils.replaceExtension( LrPathUtils.child( previewImagesDir, filename ), "jpg" )
                  local preview_file = io.open(targetPreview, "w")
                  if preview_file and
                     preview_file:write(videoPreview) and
                     preview_file:close() then

                     local targetPreviewBig = LrPathUtils.child( previewImagesDir, filename ) .. ".jpg"
                     local video_image_file = io.open(targetPreviewBig, "w")
                     if video_image_file and
                        video_image_file:write(videoPreviewBig) and
                        video_image_file:close() then

                        createdFiles[ #createdFiles + 1 ] = { filename, rendition.photo }
                     else
                        table.insert( failures, filename )
                     end
                  else
                     table.insert( failures, filename )
                  end
               end
            else
               local previewExportSessionSettings = {
                  LR_export_destinationType = "specificFolder",
                  LR_export_destinationPathPrefix = exportParams.path,
                  LR_export_useSubfolder = false,
                  LR_reimportExportedPhoto = false,
                  LR_collisionHandling = "rename",
                  
                  LR_extensionCase = exportParams.LR_extensionCase,
                  LR_initialSequenceNumber = exportParams.LR_initialSequenceNumber,
                  LR_renamingTokensOn = exportParams.LR_renamingTokensOn,
                  LR_tokenCustomString = exportParams.LR_tokenCustomString,
                  LR_tokens = exportParams.LR_tokens,
                  
                  LR_format = "JPEG",
                  LR_export_colorSpace = "sRGB",
                  LR_jpeg_quality = 0.7,
                  LR_jpeg_useLimitSize = false,
                  
                  LR_size_doConstrain = true,
                  LR_size_doNotEnlarge = true,
                  LR_size_maxHeight = 350,
                  LR_size_maxWidth = 350,
                  LR_size_resizeType = "longEdge",
                  LR_size_resolution = 72,
                  LR_size_resolutionUnits = "inch",
                  LR_size_units = "pixels",
                  
                  LR_outputSharpeningOn = true,
                  LR_outputSharpeningMedia = "screen",
                  LR_outputSharpeningLevel = 3,
                  
                  LR_minimizeEmbeddedMetadata = true,
                  LR_removeLocationMetadata = false,
                  LR_embeddedMetadataOption = "copyrightOnly",
                  
                  LR_includeVideoFiles = false,    -- Videos are handles separately
                  
                  LR_useWatermark = false,
                  
                  LR_exportFiltersFromThisPlugin = {},
                  
                  LR_cantExportBecause = nil,
               }
               local previewExportSession = LrExportSession( { photosToExport = { rendition.photo },
                                                               exportSettings = previewExportSessionSettings } )
               previewExportSession.doExportOnNewTask()
               for _, previewRendition in previewExportSession:renditions{ stopIfCanceled = true } do
                  local success, pathOrMessage = previewRendition:waitForRender()
                  
                  -- Check for cancellation again after photo has been rendered.
                  if progressScope:isCanceled() then break end

                  if success then
                     local previewFilename = LrPathUtils.child( previewImagesDir, filename )
                     if pathOrMessage ~= previewFilename then
                        LrFileUtils.delete( previewFilename )
                        success = LrFileUtils.move( pathOrMessage, previewFilename )
                     end
                     if success then
                        if exportParams.original_res_link_enabled then
                           local originalExportSessionSettings = {
                              LR_export_destinationType = "specificFolder",
                              LR_export_destinationPathPrefix = exportParams.path,
                              LR_export_useSubfolder = false,
                              LR_reimportExportedPhoto = false,
                              LR_collisionHandling = "rename",
                              
                              LR_extensionCase = exportParams.LR_extensionCase,
                              LR_initialSequenceNumber = exportParams.LR_initialSequenceNumber,
                              LR_renamingTokensOn = exportParams.LR_renamingTokensOn,
                              LR_tokenCustomString = exportParams.LR_tokenCustomString,
                              LR_tokens = exportParams.LR_tokens,
                              
                              LR_format = "JPEG",
                              LR_export_colorSpace = "sRGB",
                              LR_jpeg_quality = 0.7,
                              LR_jpeg_useLimitSize = false,
                              
                              LR_size_doConstrain = false,
                              LR_size_doNotEnlarge = true,
                              LR_size_resizeType = "longEdge",
                              LR_size_resolution = 72,
                              LR_size_resolutionUnits = "inch",
                              LR_size_units = "pixels",
                              
                              LR_outputSharpeningOn = true,
                              LR_outputSharpeningMedia = "screen",
                              LR_outputSharpeningLevel = 3,
                              
                              LR_minimizeEmbeddedMetadata = true,
                              LR_removeLocationMetadata = false,
                              LR_embeddedMetadataOption = "copyrightOnly",
                              
                              LR_includeVideoFiles = false,    -- Videos are handles separately
                              
                              LR_useWatermark = false,
                              
                              LR_exportFiltersFromThisPlugin = {},
                              
                              LR_cantExportBecause = nil,
                           }
                           local originalExportSession = LrExportSession( { photosToExport = { rendition.photo },
                                                                           exportSettings = originalExportSessionSettings } )
                           originalExportSession.doExportOnNewTask()
                           for _, originalRendition in originalExportSession:renditions{ stopIfCanceled = true } do
                              local success, pathOrMessage = originalRendition:waitForRender()
                              
                              -- Check for cancellation again after photo has been rendered.
                              if progressScope:isCanceled() then break end
            
                              if success then
                                 local originalFilename = LrPathUtils.child( originalImagesDir, filename )
                                 if pathOrMessage ~= originalFilename then
                                    LrFileUtils.delete( originalFilename )
                                    success = LrFileUtils.move( pathOrMessage, originalFilename )
                                 end
                                 if success then
                                    createdFiles[ #createdFiles + 1 ] = { filename, rendition.photo }
                                 else
                                    table.insert( failures, filename )
                                 end
                              else
                                 table.insert( failures, filename )
                              end   -- not success (render preview)
                           end   -- for (render preview)
                        else
                           createdFiles[ #createdFiles + 1 ] = { filename, rendition.photo }
                        end
                     else
                        table.insert( failures, filename )
                     end
                  else
                     table.insert( failures, filename )
                  end   -- not success (render preview)
   
               end   -- for (render preview)

            end   -- not isVideo

         end   -- success (copy)

      end   -- success (render large)
      
   end   -- for (render larges)
   
   -- Copy Unite Gallery
   local resources_source = LrPathUtils.child( _PLUGIN.path, "resources" )
   for filePath in LrFileUtils.recursiveFiles( resources_source ) do
      local subpath = LrPathUtils.makeRelative( LrPathUtils.parent( filePath ), resources_source )
      local targetpath = LrPathUtils.makeAbsolute( subpath, exportParams.path )

      LrFileUtils.createAllDirectories( targetpath )
      
      local file_target = LrPathUtils.child( targetpath, LrPathUtils.leafName( filePath ) )
      LrFileUtils.delete( file_target )
      local success, reason = LrFileUtils.copy( filePath, file_target )
      if not success then
         table.insert( failures, subpath )
      end
   end
   
   -- Create index.html
   local env = {
      title = exportParams.title,
      creator_enabled = exportParams.creator_enabled,
      creator_title = exportParams.creator_title,
      creator_url = exportParams.creator_url,
      other_link_enabled = exportParams.other_link_enabled,
      other_link_title = exportParams.other_link_title,
      other_link_url = exportParams.other_link_url,
      original_res_link_enabled = exportParams.original_res_link_enabled,
      original_res_link_title = exportParams.original_res_link_title,
      files = createdFiles,
   }
   local index_html = template.compile_file( LrPathUtils.child( _PLUGIN.path, 'index.html' ) )
   local indexHtmlFileName = LrPathUtils.child( exportParams.path, "index.html" )
   local indexHtmlFile = io.open(indexHtmlFileName, "w")
   template.print(index_html, env, function(s) indexHtmlFile:write(s) end)
   indexHtmlFile:close()

   -- Error report
   if #failures > 0 then
      local message
      if #failures == 1 then
         message = LOC "$$$/UniteGallery/Errors/OneFileFailed=1 file failed to be created correctly."
      else
         message = LOC ( "$$$/UniteGallery/Errors/SomeFileFailed=^1 files failed to be created correctly.", #failures )
      end
      LrDialogs.message( message, table.concat( failures, "\n" ) )
   end
   
end
