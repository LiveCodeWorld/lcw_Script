script "Global_Script_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Tree_Menu
type: controller
target: scriptObject
version: 0.2


--> Menu | Props
-
getprop hack_Params
   return "Compile,Menu,Script,Handler,Search"
end hack_Params

getprop displayTemplate_Params
   return scaffold_ListShortFiles()
end displayTemplate_Params


--> Global | Script | Tree | Menu
-
on menu_EditObjectScript sObject
   edit the script of sObject
end menu_EditObjectScript

on menu_CreateScriptObjectGraph sObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_CreateScriptObjectGraph sObject, pProjectName, pGraphStyle, pProcessObject, pForceCreate
   --
   display_ObjectDepArray sObject
end menu_CreateScriptObjectGraph

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on menu_DisplayTemplate sObject, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

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

on submenu_Project
   return "Global | Project | Stack | Menu"
end submenu_Project

on submenu_ScriptMainstack
   return "Global | Script | Mainstack | Menu"
end submenu_ScriptMainstack

on _
end _

on submenu_Rig
   return "Global | Rig | Files | Menu"
end submenu_Rig

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on _
end _

on menu_Hack seGroup, whichBehavior
   switch whichBehavior
      case "Compile"
         put scriptEditor_CompileButtonBehavior() into bObject
         break
      case "Menu"
         put scriptEditor_HistoryButtonBehavior() into bObejct
         break
      case "Script"
         put scriptEditor_ScriptFieldBehavior() into bObject
         break
      case "Handler"
         put scriptEditor_HandlerListBehavior() into bObject
         break
      case "Search"
         put scriptEditor_FindFieldBehavior() into bObject
         break
   end switch
   edit the script of bObject
end menu_Hack
