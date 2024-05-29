script "Global | Script | Dep | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Dep | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Script | Dep | Dev | Menu
-
on submenu_Display
   return "Global | Project | Display | Menu"
end submenu_Display

on submenu_Create
   return "Global | Project | Create | Menu"
end submenu_Create

on submenu_MenuTools
   return "Global | MenuTools | Menu"
end submenu_MenuTools

on menu_CreateHkeyArrayObjectGraph sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   graph_CreateScriptObjectHkeyArray hkeyArray, sObject -- in the metadataObject_Folder of sObject
   put the result into svgFile
   --
   _DisplaySvgFile svgFile, the name of sObject
end menu_CreateHkeyArrayObjectGraph

on menu_DisplayObjectSvg sObject
   put the script_SvgFile of sObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      _DisplaySvgFile svgFile, the name of sObject
   end if
end menu_DisplayObjectSvg

on _
end _

on menu_DisplayTextStackHkeyArray sObject
   put the projectOverlay_Array ["processedHkey.array"] of sObject into processedHkeyArray
   display_ScriptHkeyArray processedHkeyArray, sObject
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

on menu_DisplayProjectSvg sObject
   put the projectOverlay_SvgFile of sObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      _DisplaySvgFile svgFile, the name of sObject
   end if
end menu_DisplayProjectSvg

on menu_ProjectOverlaySvgFile sObject
   put the projectOverlay_SvgFile of sObject into svgFile
   finder_Reveal svgFile
end menu_ProjectOverlaySvgFile

on _
end _

on menu_CreateTransporterGraphs sObject
   transporter_CreateGraph sObject, true, true
end menu_CreateTransporterGraphs

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


--> Deps
-
private command _DisplaySvgFile svgFile, sLabel
   display_SVG svgFile, sLabel
   put the result into displayView
   if exists (displayView) is false then
      lcw_AnswerWarning "SVG file is empty!", displayView
   end if
end _DisplaySvgFile

