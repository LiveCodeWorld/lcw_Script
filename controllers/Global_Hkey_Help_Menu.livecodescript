script "Global_Hkey_Help_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Help_Menu
type: controller
version: 0.1


--> Global | Hkey | Help | Menu | Props
-
local LocalArray

on menu_Init tObject, hKey
   switch
      case hkey_IsMenuHandler (hKey)
         put true into LocalArray ["isMenu"]
         put false into LocalArray ["isTransport"]
         put false into LocalArray ["isHandler"]
         break
      case hkey_IsTransportHandler (hKey)
         put true into LocalArray ["isTransport"]
         put false into LocalArray ["isMenu"]
         put false into LocalArray ["isHandler"]
         break
      default
         put true into LocalArray ["isHandler"]
         put false into LocalArray ["isMenu"]
         put false into LocalArray ["isTransport"]
   end switch
end menu_Init


--> Global | Hkey | Help | Menu
-
on menu_HandlerHelp hKey
   help_HkeyLaunch hKey, true
end menu_HandlerHelp

on menu_TransporterHelp hKey
   put transport_HelpURL (hKey, true) into someURL
   if someURL is empty then
      transport_CreateHelp hKey
      put transport_HelpURL (hKey) into someURL
   end if
   launch url someURL
end menu_TransporterHelp

on menu_MenuHandlerHelp hKey
   breakpoint
   put help_ConstructHkeyUrl (hKey, true) into someURL
   if someURL is empty then
      help_CreateFromHandler hKey
   else
      launch url someURL
   end if
end menu_MenuHandlerHelp

on menu_UpdateHelpGraph hKey
   switch
      case LocalArray ["isTransport"]
         put transport_FetchPageArray (hKey) into pageArray
         transport_UpdatePageGraph pageArray, hKey
         transport_StorePageArray hKey, pageArray
         break
      default
         put lcw_FetchHandlerArray (hKey) into pageArray
         --
         put hkey_GetDotText (hKey) into dotText
         pageArray_ReplaceGraph pageArray, dotText
         --
         lcw_StoreHandlerArray hKey, pageArray
   end switch
end menu_UpdateHelpGraph

on menu_UpdateMetadata hKey
   lcw_UpdateHandlerHelp hKey
   help_HkeyLaunch hKey, true
end menu_UpdateMetadata


--> Global | Hkey | Help | Menu | Disabled
-
getprop disabled_UpdateHelpGraph [hKey]
   put help_ConstructHkeyUrl (hKey, true) into someURL
   if someURL is not empty then
      -- if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_UpdateHelpGraph

getprop disabled_MenuHandlerHelp [hKey]
   if LocalArray ["isMenu"] is true then
      return false
   else
      return "delete"
   end if
end disabled_MenuHandlerHelp

getprop disabled_HandlerHelp [hKey]
   if LocalArray ["isHandler"] is true then
      return false
   else
      return "delete"
   end if
end disabled_HandlerHelp

getprop disabled_TransporterHelp [hKey]
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_TransporterHelp
