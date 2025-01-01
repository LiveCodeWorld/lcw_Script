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
on menu_Help hKey
   if the shiftKey is "Down" then
      launch_HkeyHelp hKey
   else
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put platform_WikiDomain ("handler") into wikiDomain
      display_WikiPage wikiDomain, hName
   end if
   --
   if (the result is empty) or (the shiftKey is "Down") then
      draft_HandlerHelp hKey
   end if
end menu_Help

on submenu_HelpTools
   return "Global | Hkey | Help | Menu"
end submenu_HelpTools

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

private on ___
end ___

on submenu_Dev
   return "Global | Dev | ScriptEditor | List | Authoring | Menu"
end submenu_Dev
