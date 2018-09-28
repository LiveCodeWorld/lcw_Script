script "Global_Script_Dep_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Dep_Menu
type: controller
version: 0.2

/*
This menu is for processing whole scripts to extract their dependencies.
*/

--> Variables
-
local LocalArray


--> Working on
-
/*
command graph_FilterProcessedArray @processedCalls, someKeyCall
   -- same as default
   -- traps and filters hKeyArray for "display_ObjectGraph"
   
   hkey_Deconstruct someKeyCall, hName, hType, hObject, hNum
   if hObject = "missing" then
      switch
         case hName is among the items of "jsonExport,jsonImport"
            -- skip (remove from missing)
            break
         case char 1 to 3 of hName = "rig"
            put "revIgniter" into item 3 of someKeyCall
            put someKeyCall & CR after processedCalls
            break
         default
            put someKeyCall & CR after processedCalls
      end switch
   else
      put someKeyCall & CR after processedCalls
   end if
end graph_FilterProcessedArray

command graph_TidyOverlayArray @overlayArray
   -- here we tidy names specifically for Hkey graphing.
   -- should dispatch / be able to customise
   
   put overlayArray ["data"]["idArray"] into idArray
   repeat for each key someID in idArray
      put idArray [someID] into hKey
      -- put word 2 of hKey into hName -- there is some old hKeys hanging around
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put hName into idArray [someID]
   end repeat
   put idArray into overlayArray ["data"]["idArray"]
end graph_TidyOverlayArray

*/


--> Global | Script | Dep | Menu
-
on menu_DisplayScript sObject
   display_Script sObject
end menu_DisplayScript

on _
end _

on menu_DisplayObjectGraph sObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_ObjectGraph sObject, projectName, pGraphStyle, pProcessObject, false
   --
   display_ObjectDepArray sObject
end menu_DisplayObjectGraph

on menu_DisplaySvg sObject
   put the projectOverlay_SvgFile of sObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      display_SVG svgFile
   end if
end menu_DisplaySvg

on _
end _

on menu_DisplayTextStackHkeyArray sObject
   put the projectOverlay_Array ["processedHkey.array"] of sObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, sObject
end menu_DisplayTextStackHkeyArray

on menu_DisplayScriptHkeyArray sObject
   put the projectOverlay_Array ["processedHkey.array"] of sObject into processedHkeyArray
   -- display_ScriptHkeyArray processedHkeyArray, sObject
   display_ObjectDepArray processedHkeyArray, sObject
end menu_DisplayScriptHkeyArray

on menu_DisplayTextstackHkeyObjectArray sObject
   put the textstack_HkeyObjectArray of sObject into depObjectArray
   display_Array depObjectArray, "the textstack_HkeyObjectArray"
end menu_DisplayTextstackHkeyObjectArray

on _
end _

on menu_ScriptLibraryDependencies sObject
   -- put the missing_HkeyArray of scriptObject into missingHkeyArray
   put the script_DepLibs of sObject into dependencyStacks
   display_Index dependencyStacks
end menu_ScriptLibraryDependencies

on menu_DisplayStackDepArray sObject
   put the stack_Object of sObject into stackObject
   display_StackDeps sObject
end menu_DisplayStackDepArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ClusterDepGraph hObject
   -- same as menu item "menu_CheckTransportGraph"
   put the dep_StackNames of hObject into stackNames
   put hObject into searchHierarchy
   repeat for each item stackName in stackNames
      if exists (stack stackName) is false then
         breakpoint
         next repeat
      end if
      put CR & the name of stack stackName after searchHierarchy
   end repeat
   --
   -- put hkey_SearchHierarchyDependencyArray (hKeys, searchHierarchy, true) into hKeyArray
   breakpoint
   display_ClusterDepGraph hkey, searchHierarchy, true
end menu_ClusterDepGraph

on menu_DisplayScriptArray hObject
   -- long nasty graph names
   -- displays hkeyArray
   breakpoint
   display_ScriptArray hObject
end menu_DisplayScriptArray

on menu_DisplayStackDeps hObject
   -- displays hkeyArray
   breakpoint
   display_StackDeps hObject -- lib_DisplayStack
end menu_DisplayStackDeps


--> Global | Script | Dep | Menu | Props
-
getprop p_Name [scriptObject]
   put the p_Name of scriptObject into pName
   return pName
end p_Name

getprop p_Names
   put library_ListProjectNames() into projectNames
   return projectNames
end p_Names


--> Global | Script | Dep | Menu | Disabled
-
getprop disabled_DisplayProjectSvg [scriptObject]
   put the projectOverlay_SvgFile of scriptObject into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_DisplayProjectSvg
