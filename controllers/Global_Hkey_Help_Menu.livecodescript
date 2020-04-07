script "Global_Hkey_Help_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Help_Menu
type: menu
target: hKey
version: 0.2


--> Menu | Init
-
local LocalArray

on menu_Init tObject
   -- assumes we are interacting with Script Editor list field
   
   put scriptEditor_GetHkey() into hKey
   put hKey into LocalArray ["hKey"]
   --
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

getprop menu_Target [tObject]
   -- put scriptEditor_GetHkey() into hKey
   return LocalArray ["hKey"]
end menu_Target

getprop disabled_CreateMenuPage [hKey]
   put hkey_GetMenuTitle (hKey) into gMenuTitle
   put help_FetchMenuHelpArray (gMenuTitle) into pageArray
   if pageArray is empty then
      return false
   else
      return true
   end if
end disabled_CreateMenuPage

-- getprop disabled_CreateSubdomain [hKey]
put lcw_FetchMenuItemHelpArray (hKey, true) into pageArray
if pageArray is empty then
   return false
else
   return true
end if
end disabled_CreateSubdomain

getprop disabled_MenuHandlerHelp [hKey]
   if LocalArray ["isMenu"] is true then
      return false
   else
      return "delete"
   end if
end disabled_MenuHandlerHelp

getprop disabled_MenuItemHelp [hKey]
   put lcw_FetchMenuItemHelpArray (hKey) into pageArray
   if pageArray is empty then
      return false
   else
      return true
   end if
end disabled_MenuItemHelp

getprop disabled_HandlerHelp [hKey]
   if LocalArray ["isHandler"] is true then
      return false
   else
      return "delete"
   end if
end disabled_HandlerHelp


--> Global | Hkey | Help | Menu
-
on menu_HandlerHelp hKey
   help_LaunchMenuItem hKey
   if the result is empty then
      lcw_CreateHandlerHelp hKey
      put the result into pageArray
      if pageArray is not an array then
         breakpoint
      else
         help_LaunchMenuItem hKey
      end if
   end if
end menu_HandlerHelp

on menu_MenuHandlerHelp hKey
   help_LaunchMenuItem hKey
   if the result is empty then
      help_CheckUpdateMenuItem hKey
      help_CreateMenuItem hKey
      help_LaunchMenuItem hKey
   end if
end menu_MenuHandlerHelp

on _
end _

on menu_TransporterHelp hKey
   put transport_HelpURL (hKey, true) into someURL
   if someURL is empty then
      transport_CreateHelp hKey
      put transport_HelpURL (hKey) into someURL
   end if
   launch url someURL
end menu_TransporterHelp

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
   switch
      case hkey_IsMenuHandler (hKey)
         help_UpdateMenuItem hKey
         if the result is empty then
            -- create new
            breakpoint
         end if
         break
      case hkey_IsTransportHandler (hKey)
         transport_UpdateHelp hKey
         put transport_HelpURL (hKey, true) into someURL
         launch url someURL
         break
      default
         lcw_UpdateHandlerHelp hKey
         help_LaunchMenuItem hKey, true
   end switch
end menu_UpdateMetadata

on _
end _

on menu_EditMenu
   menu_Edit
end menu_EditMenu

on submenu_HkeyHelpDev
   return "Dev | Menu"
end submenu_HkeyHelpDev


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

getprop disabled_TransporterHelp [hKey]
   if LocalArray ["isTransport"] is true then
      return false
   else
      return "delete"
   end if
end disabled_TransporterHelp


--> Dev | Menu
-
on menu_CreateMenuPage hKey
   put _Stackname (hKey) into stackName
   put help_MenuPageTitle (stackName) into gMenuTitle
   --
   help_CreateMenu gMenuTitle
   --
   help_LaunchMenu stackName
end menu_CreateMenuPage

on menu_UpdateMenuPage hKey
   put _Stackname (hKey) into stackName
   put help_MenuPageTitle (stackName) into gMenuTitle
   --
   help_UpdateMenu gMenuTitle, "reference"
   --
   help_LaunchMenu stackName
end menu_UpdateMenuPage

on _
end _

on menu_CreateSubdomain hKey
   help_CreateMenuSubdomain hKey
   --
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the stack_Name of hObject into stackName
   help_LaunchMenuSubdomain stackName
end menu_CreateSubdomain

on menu_UpdateSubdomain hKey
   help_UpdateMenuSubdomain hKey, "reference"
   --
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the stack_Name of hObject into stackName
   help_LaunchMenuSubdomain stackName
end menu_UpdateSubdomain

on _
end _

on menu_EditMenu
   menu_Edit
end menu_EditMenu


--> Private
-
private function _Stackname hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the stack_Name of hObject into stackName
   return stackName
end _Stackname

