--[[----------------------------------------------------------------------------

UniteGalleryPluginManagerDialogSections.lua
Export dialog customization for Unite Gallery exporter

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'

--============================================================================--

UniteGalleryPluginManagerDialogSections = {}

-------------------------------------------------------------------------------

function UniteGalleryPluginManagerDialogSections.sectionsForBottomOfDialog( viewFactory, propertyTable )

   local f = viewFactory
   local bind = LrView.bind
   local share = LrView.share
   local prefs = LrPrefs.prefsForPlugin() 

   local result = {
   
      {
         title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Title=Logging",
         
         synopsis = bind { key = 'title', object = propertyTable },
         
         -- Enable logging
         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Method/Label=Method:",
               alignment = 'right',
               width = share 'labelWidth'
            },
            f:popup_menu {
               value = bind { key = "logging_method", bind_to_object = prefs },
               items = {
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Method/Off=None",
                     value = "off",
                  },
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Method/File=Logfile",
                     value = "logfile",
                  },
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Method/Console=Console",
                     value = "print",
                  },
               },
               tooltip = LOC "$$$/UniteGallery/PluginManager/BottomSection/Method/Tooltip=Activates logging to the given target system.",
            },
         },

         -- Log level
         f:row {
            f:static_text {
               title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Level/Label=Log Level:",
               alignment = 'right',
               width = share 'labelWidth'
            },
            f:popup_menu {
               enabled = bind { key = "logging_method",
                                bind_to_object = prefs,
                                transform = function( value, _ )
                                               return value == "logfile" or value == "print"
                                            end },
               value = bind { key = "logging_level", bind_to_object = prefs },
               items = {
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Level/Trace=Everything",
                     value = "trace",
                  },
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Level/Info=Normal",
                     value = "info",
                  },
                  {
                     title = LOC "$$$/UniteGallery/PluginManager/BottomSection/Level/Error=Errors",
                     value = "error",
                  },
               },
               tooltip = LOC "$$$/UniteGallery/PluginManager/BottomSection/Level/Tooltip=The amount of data that is written to the log system.",
            },
         },
      },
   }
   
   return result
end

