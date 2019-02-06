script "Global_Script_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Tree_Menu
type: controllers
version: 0.2


--> Global | Script | Tree | Menu
-
on menu_EditObjectScript sObject
   edit the script of sObject
end menu_EditObjectScript

on menu_DisplayObjectGraph sObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_ObjectGraph sObject, projectName, pGraphStyle, pProcessObject, false
   --
   display_ObjectDepArray sObject
end menu_DisplayObjectGraph

on menu_DisplayTemplate sObject, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on submenu_Folders
   return "Global | Script | Folders | Menu"
end submenu_Folders

on submenu_ScriptDeps
   return "Global | Script | Dep | Menu"
end submenu_ScriptDeps

on submenu_Overlay
   return "Global | Overlay | Menu"
end submenu_Overlay

on _
end _

on submenu_ScriptExport
   return "Global | Script | Exported | Menu"
end submenu_ScriptExport

on submenu_TestExport
   return "Global | Object | Export | Test | Menu"
end submenu_TestExport

on _
end _

on _
end _

on submenu_Project
   return "Global | Project | Stack | Menu"
end submenu_Project

on submenu_ScriptMainstack
   return "Global | Script | Mainstack | Menu"
end submenu_ScriptMainstack


--> Global | Script | Tree | Menu | Deps
-
getprop template_Names [mTarget]
    return scaffold_ListShortFiles()
end template_Names


--> Global | Script | Tree | Menu | Disabled
-
