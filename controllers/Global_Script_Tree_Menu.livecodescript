script "Global | Script | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Tree | Menu
type: controller
target: scriptObject
version: 0.2
deps: model_PageArray, lib_MediaWiki, lib_PageArray


--> Menu | Init
-
getprop menu_Target [tObject]
   -- put the title_Text of displayView into scriptObject
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

getprop displayTemplate_Params
   return scaffold_ListShortFiles()
end displayTemplate_Params

getprop disabled_EditObjectBehavior [sObject]
   put the behavior of sObject into bObject
   switch
      case bObject is empty
         return "delete"
      case exists (bObject) is false
         return true
      default
         return false
   end switch
end disabled_EditObjectBehavior


--> Global | Script | Tree | Menu
-
on menu_ListScriptDeps sObject
   display_ScriptDeps sObject
end menu_ListScriptDeps

on menu_DisplayLocalChanges scriptObject
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

private on _
end _

on menu_EditObjectScript sObject
   edit the script of sObject
end menu_EditObjectScript

on menu_EditObjectBehavior sObject
   put the behavior of sObject into bObject
   edit the script of bObject
end menu_EditObjectBehavior

on menu_DisplayProject sObject
   put the project_Name of sObject into projectName
   --
   display_ProjectLibs projectName
end menu_DisplayProject

private on __
end __

on submenu_Display
   return "Global | Project | Display | Menu"
end submenu_Display

on submenu_Create
   return "Global | Project | Create | Menu"
end submenu_Create

on submenu_MenuTools
   return "Global | MenuTools | Menu"
end submenu_MenuTools

private on ___
end ___

on menu_Refresh sObject
   display_Script sObject
end menu_Refresh

on menu_DisplayGitStatus sObject
   display_GitStatus sObject
end menu_DisplayGitStatus

private on ____
end ____

on menu_CreateScriptObjectGraph sObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_CreateScriptObjectGraph sObject, pGraphStyle, pProcessObject
   --
   display_ObjectDepArray sObject
end menu_CreateScriptObjectGraph

on submenu_EditScript
   return "Global | Script | Menu"
end submenu_EditScript

on menu_DisplayTemplate sObject, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on submenu_Folders
   return "Global | Script | Folders | Menu"
end submenu_Folders

private on _____
end _____

on submenu_Dev
   return menu_Create ("Global | Script | Dev | Menu")
end submenu_Dev
