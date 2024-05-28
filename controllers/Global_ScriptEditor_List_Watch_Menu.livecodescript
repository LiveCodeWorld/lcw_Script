script "Global | ScriptEditor | List | Watch | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | List | Watch | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put scriptEditor_GetHkey() into hKey
   return hKey
end menu_Target


--> Global | ScriptEditor | List | Watch | Menu
-
on menu_HandlerCurlyData hKey
   put help_HkeyCurlyData (hKey, false) into curlyData
   --
   display_Data curlyData, hKey, "help_HkeyCurlyData()"
end menu_HandlerCurlyData

on menu_ObjectCurlyData hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the script_MetaData ["type"] of hObject into scriptType
   --
   put help_ObjectCurlyData (hObject, scriptType) into curlyData
   --
   display_Data curlyData, hObject, "help_ObjectCurlyData()"
end menu_ObjectCurlyData

on submenu_HelpMenu
   return "Global | Hkey | Help | Menu"
end submenu_HelpMenu

private on _
end _

on submenu_SendHkey
   return "Global | Hkey | Send | Menu"
end submenu_SendHkey

on submenu_GraphHandler
   return "Global | Hkey | Walk | Menu"
end submenu_GraphHandler

private on __
end __

on submenu_HandlerCalls
   return "Global | Handler | Calls | Menu"
end submenu_HandlerCalls

on submenu_Files
   return "Global | Script | Folders | Menu"
end submenu_Files

on submenu_Dev
   return "Global | Dev | ScriptEditor | List | Authoring | Menu"
end submenu_Dev
