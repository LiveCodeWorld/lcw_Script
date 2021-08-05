script "Global | Script | Dep | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Dep | Menu
type: controller
version: 0.2

/*This menu is for processing whole scripts to extract their dependencies.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put the displayed_Object of displayView into sObject
   put the displayed_HkeyArray of displayView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put displayView into LocalArray ["displayView"]
   --
   return sObject
end menu_Target


--> Global | Script | Dep | Menu
-
on menu_HkeyArrayGraph sObject
   local pGraphStyle, pProcessObject, projectName
   --
   -- display_CreateScriptObjectGraph sObject, projectName, pGraphStyle, pProcessObject, false
   -- display_ObjectDepArray sObject
   
   put LocalArray ["hkeyArray"] into hkeyArray
   graph_CreateScriptObjectHkeyArray hkeyArray, sObject, "fast undirected spring"
   put the result into svgFile
   --
   display_SVG svgFile
end menu_HkeyArrayGraph

on menu_DisplayMissing sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   display_MissingHkey hkeyArray, sObject
end menu_DisplayMissing

on menu_Refresh sObject
   display_ScriptDeps sObject
end menu_Refresh

on _
end _

on submenu_Show
   return "Global | HkeyArray | Tree | Menu"
end submenu_Show

on submenu_Display
   return "Global | Project | Display | Menu"
end submenu_Display

on submenu_Create
   return "Global | Project | Create | Menu"
end submenu_Create

on submenu_MenuTools
   return "Global | MenuTools | Menu"
end submenu_MenuTools

on _
end _

on menu_ScriptSvgFile sObject
   put the script_SvgFile of sObject into svgFile
   finder_Reveal svgFile
end menu_ScriptSvgFile

on menu_MetadaDataFolder sObject
   -- same as the metadata_Folder of sObject
   put the metadataObject_Folder of sObject into metadataFolder
   finder_Reveal metadataFolder
   --
   put the script_OverlayFolder of sObject into scriptOverlayFolder
   put scriptOverlayFolder = metadataFolder
end menu_MetadaDataFolder

on menu_OverlayFolder sObject
   put the overlay_Folder of sObject into objectFolder
   finder_Reveal objectFolder
end menu_OverlayFolder

on _
end _

on menu_ListDepStacks sObject
   put LocalArray ["displayView"] into displayView
   -- put the title_Text of displayView into sObject
   put the displayed_Data of displayView into depObjectData
   delete variable depObjectData [sObject]
   --
   put keys (depObjectData) into depStacks
   repeat for each line stackObject in depStacks
      put the short name of stackObject into libName
      put libName & ", " after libNames
      put the project_Name of stackObject into projectName
      put libName into projectArray [projectName]
   end repeat
   delete char -2 to -1 of libNames
   sort libNames
   put keys (projectArray) into projectNames
   sort projectNames
   replace CR with ", " in projectNames
   --
   put "libss:" && libNames into libDepLine -- dep_StackNames
   put "projeects:" && projectNames into projectDepLine -- dep_StackNames
   
   put libDepLine & CR & projectDepLine
end menu_ListDepStacks

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CreateHkeyArrayObjectGraph sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   graph_CreateScriptObjectHkeyArray hkeyArray, sObject -- in the metadataObject_Folder of sObject
   
   put the result into svgFile
   --
   _DisplaySvgFile svgFile
end menu_CreateHkeyArrayObjectGraph

on menu_DisplayObjectSvg sObject
   put the script_SvgFile of sObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      _DisplaySvgFile svgFile
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
      _DisplaySvgFile svgFile
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


--> Dev | Menu | Props
-


--> Deps
-
private command _DisplaySvgFile svgFile
   display_SVG svgFile
   put the result into displayView
   if exists (displayView) is false then
      lcw_AnswerWarning "SVG file is empty!", displayView
   end if
end _DisplaySvgFile
