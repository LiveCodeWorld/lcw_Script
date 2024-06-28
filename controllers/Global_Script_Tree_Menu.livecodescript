script "Global | Script | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Tree | Menu
type: controller
target: sObject
version: 0.2
deps: model_PageArray, lib_MediaWiki, lib_PageArray


--> Menu | Init
-
getprop menu_Target [tObject]
   -- put the title_Text of displayView into sObject
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
on menu_DisplayScriptDeps sObject
   display_ScriptDeps sObject
end menu_DisplayScriptDeps

getprop checked_DisplayScriptDeps [sObject]
   put the script_HkeyArrayFile of sObject into sFile
   return there is a file sFile
end checked_DisplayScriptDeps

on menu_CreateBehaviorHkeyArray sObject
   put the shiftkey is "down" into fromFolder
   put the module_BehaviorDepHkeyArray [fromFolder] of sObject into hKeyArray
   set the script_HkeyArray of sObject to hKeyArray
   --
   display_ScriptHkeyArrayDeps hkeyArray, sObject
end menu_CreateBehaviorHkeyArray

on menu_DisplayLocalChanges sObject
   put the script of sObject into nowScript
   put the exported_Script of sObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

getProp disabled_DisplayLocalChanges [sObject]
   return the script_IsDifferent of sObject is false
end disabled_DisplayLocalChanges

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
