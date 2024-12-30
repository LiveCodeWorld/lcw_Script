script "Global | Script | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Tree | Menu
type: controller
target: sObject
version: 0.2
deps: model_PageArray, lib_MediaWiki, lib_PageArray


--> Variable
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
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

private function _TitleKeys sTitle
   put _EmptyHkeyArray(sTitle) into shortHkeyArray
   put keys (shortHkeyArray) into hKeys
   sort hKeys
   return hKeys
end _TitleKeys

private function _MyKeys
   put _MyEmptyHkeyArray() into shortHkeyArray
   put keys (shortHkeyArray) into hKeys
   sort hKeys
   return hKeys
end _MyKeys

private function _EmptyHkeyArray sTitle
   put display_FindView ("Script", sTitle) into fView
   put the displayed_ScriptArray of fView into minusScriptArray
   put scriptArray_ShortHkeyArray(minusScriptArray) into minusArray
   return minusArray
end _EmptyHkeyArray

private function _MyEmptyHkeyArray
   put LocalArray ["dView"] into dView
   put the displayed_ScriptArray of dView into scriptArray
   put scriptArray_ShortHkeyArray(scriptArray) into shortHkeyArray
   return shortHkeyArray
end _MyEmptyHkeyArray

private function _OtherNames
   put display_ListViews ("Script") into sViews
   put LocalArray ["dView"] into dView
   line_Delete dView, sViews
   --
   repeat for each line sView in sViews
      -- put the stack_Label of sView into sLabel
      put the title_Text of sView into sTitle
      put sTitle & CR after sTitles
   end repeat
   delete char -1 of sTitles
   return sTitles
end _OtherNames

command scriptArray_AddLong @longHkeyArray, shortHkeyArray, sObject
   repeat for each key shortHkey in shortHkeyArray
      put shortHkey && "of" && sObject into hKey
      put empty into longHkeyArray [hKey]
   end repeat
end scriptArray_AddLong


--> Global | Script | Tree | Menu
-
on menu_CombineAll sObject
   local longHkeyArray
   put display_ListViews ("Script") into dViews
   repeat for each line dView in dViews
      put the title_Text of dView into sObject
      put the displayed_ScriptArray of dView into scriptArray
      --
      put scriptArray_ShortHkeyArray(scriptArray) into shortHkeyArray
      scriptArray_AddLong longHkeyArray, shortHkeyArray, sObject
   end repeat
   --
   -- display_Tool longHkeyArray, "All", "Script Compare", "lcw_Script"
   display_ScriptFromHkeys longHkeyArray, "Script Compare"
   put the result into dView
end menu_CombineAll

on menu_Compare sObject, rightObject
   put _MyKeys() into leftKeys
   put _TitleKeys (rightObject) into rightKeys
   
   # Title
   put hkey_ConstructCompareArray (leftKeys, rightKeys) into cArray
   --
   put revRuggedID(sObject) into leftObject
   put leftObject && "vs" && rightObject into sTitle
   
   display_Tool cArray, sTitle, "Script Compare", "lcw_Script"
   put the result into dView
   
   # Props
   set the displayed_Object of dView to sObject
   set the script_CompareArray of dView to cArray
   put the displayed_RightObject of dView to rightObject
   return dView
end menu_Compare

getprop compare_Params
   return _OtherNames()
end compare_Params

on menu_Subtract sObject, sTitle
   local minusArray
   local leftArray
   
   put _EmptyHkeyArray(sTitle) into minusArray
   put _MyEmptyHkeyArray() into shortHkeyArray
   
   # Subtract
   difference shortHkeyArray with minusArray into leftArray
   --
   -- set the displayed_Data of dView to leftHkeys
   display_Data leftArray, "Left", "Script"
end menu_Subtract

getprop subtract_Params
   return _OtherNames()
end subtract_Params

on menu_DisplayShortHkeys
   put LocalArray ["dView"] into dView
   put the displayed_ScriptArray of dView into scriptArray
   --
   if the tree_IsIndex of dView is true then
      set the displayed_Data of dView to scriptArray
   else
      put scriptArray_ShortHkeys(scriptArray) into shortHkeys
      set the displayed_Data of dView to shortHkeys
   end if
end menu_DisplayShortHkeys

getprop checked_DisplayShortHkeys
   put LocalArray ["dView"] into dView
   return the tree_IsIndex of dView
end checked_DisplayShortHkeys

private on __
end __

on menu_DisplayScriptDeps sObject
   if the shiftKey is "Down" then
      put "hierarchical" into graphStyle
   end if
   display_ScriptDeps sObject, graphStyle
end menu_DisplayScriptDeps

getprop checked_DisplayScriptDeps [sObject]
   put the script_HkeyArrayFile of sObject into sFile
   return there is a file sFile
end checked_DisplayScriptDeps

on menu_DisplayBehaviorHkeyArray sObject
   put the shiftkey is not "down" into fromFolder
   put the module_BehaviorDepHkeyArray [fromFolder] of sObject into hKeyArray
   set the script_HkeyArray of sObject to hKeyArray
   --
   display_ScriptHkeyArrayDeps hkeyArray, sObject, "hierarchy" -- "fdp"
end menu_DisplayBehaviorHkeyArray

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

private on ____
end ____

on menu_Refresh sObject
   display_ScriptTools sObject
end menu_Refresh

on menu_DisplayGitStatus sObject
   display_GitStatus sObject
end menu_DisplayGitStatus

private on _____
end _____

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

private on ______
end ______

on menu_SaveDisplayedScriptArray
   put LocalArray ["dView"] into dView
   put the displayed_Data of dView into scriptArray
   --
   set the displayed_ScriptArray of dView to scriptArray
end menu_SaveDisplayedScriptArray

on submenu_Dev
   return menu_Create ("Global | Script | Dev | Menu")
end submenu_Dev
