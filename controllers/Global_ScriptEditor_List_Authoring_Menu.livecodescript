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

on submenu_Files
   return "Global | Script | Folders | Menu"
end submenu_Files

on submenu_HandlerCalls
   return "Global | Handler | Calls | Menu"
end submenu_HandlerCalls

on menu_MenuHelp
   launch_MenuHelp "Global | ScriptEditor | List | Authoring | Menu"
end menu_MenuHelp

on submenu_Dev
return menu_Create ("Global | Dev | ScriptEditor | List | Authoring | Menu")
end submenu_Dev
