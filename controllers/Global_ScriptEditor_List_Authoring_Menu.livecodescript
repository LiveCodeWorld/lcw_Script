script "Global | ScriptEditor | List | Authoring | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | List | Authoring | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put scriptEditor_GetHkey() into hKey
   return hKey
end menu_Target

getprop disabled_DisplayHkeySvg [hKey]
   put hkey_SvgFile (hKey) into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_DisplayHkeySvg


--> Global | ScriptEditor | List | Authoring | Menu
-
on submenu_SendHkey
   return "Global | Hkey | Send | Menu"
end submenu_SendHkey

on submenu_HelpMenu
   return "Global | Hkey | Help | Menu"
end submenu_HelpMenu

on _
end _

on submenu_GraphHandler
   return "Global | Hkey | Walk | Menu"
end submenu_GraphHandler

on menu_DisplayHkeySvg hKey
   put hkey_SvgFile (hKey) into svgFile
   if scriptEditor_PaneExists ("Deps") then
      display_ScriptEditorSvg svgFile
   end if
   
   put hkey into stackLabel
   display_SVG svgFile, stackLabel
end menu_DisplayHkeySvg

on _
end _

on submenu_HandlerFiles
   return "Global | Handler | Calls | Menu"
end submenu_HandlerFiles

on submenu_HandlerLibrary
   return "Global | Handler | Library | Menu"
end submenu_HandlerLibrary

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditOldMenu
   menu_Edit "Global | ScriptEditor | Hkey | Menu"
end menu_EditOldMenu

on _
end _

on _TestMergeHandler hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the exported_Script of hObject into exportedScript
   put the script of hObject into realScript
   if realScript is not exportedScript then
      put exportedScript
      answer warning "The scripts differ. Check for duplicate handlers?"
   else
      answer "Scripts are the same!" 
   end if
end _TestMergeHandler
