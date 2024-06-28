script "Global | Script | Dep | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Dep | Menu
type: controller
version: 0.3

/*
This menu is for processing whole scripts to extract their dependencies.
*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put dView into LocalArray ["dView"]
   --
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

private function _DisplayedData
   put LocalArray ["dView"] into dView
   put the displayed_Data of dView into dData
   return dData
end _DisplayedData

private function _AllDepKeys sObject
   put LocalArray ["dView"] into dView
   --
   put _HkeyArray (sObject) into hkeyArray
   put array_ListKeys (hkeyArray) into hKeys
   return hKeys
end _AllDepKeys

private function _HkeyArray sObject
   if the shiftkey is "down" then
      put the module_BehaviorDepHkeyArray [true] of sObject into hKeyArray
      -- put the script_HkeyArray of sObject into hKeyArray
      return hKeyArray
   else
      return LocalArray ["hkeyArray"]
   end if
end _HkeyArray

private function _GraphStyles
   -- return "hierarchical,fast undirected spring"
   return dot_ListGraphStyles()
end _GraphStyles

private command _DisplayDepScript depScript, sObject
   display_Text depScript, the name of sObject, "Dependency Script"
end _DisplayDepScript

getprop displayDotText_Params [sObject]
   put the script_DotFiles [false] of sObject into shortFiles
   return shortFiles
end displayDotText_Params


--> Global | Script | Dep | Menu
-
on menu_DraftHelp sObject, overlayName
   draft_ScriptHelp sObject, overlayName
end menu_DraftHelp

getprop draftHelp_Params [sObject]
   put the script_DotFiles [false] of sObject into overlayNames
   replace ".dot" with empty in overlayNames
   return overlayNames
end draftHelp_Params

private function _HkeyArray sObject
   if the shiftKey is "Down" then
      put the script_HkeyArray of sObject into hkeyArray
   else 
      put LocalArray ["dView"] into dView
      put the displayed_HkeyArray of dView into hkeyArray
   end if
   return hkeyArray
end _HkeyArray

on menu_Show sObject, showHow
   put LocalArray ["dView"] into dView
   put the strip_MissingProps of dView into stripMissingProps
   put the title_Text of dView into hKey
   --
   put _HkeyArray (sObject) into hkeyArray
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissingProps, hKey) into dData
   --
   set the displayed_Data of dView to dData
   set the show_How of dView to showHow
end menu_Show

getprop show_Param [sObject]
   put LocalArray ["dView"] into dView
   put the show_How of dView into showHow
   if showHow is empty then put "projects" into showHow
   return showHow
end show_Param

getprop show_Params
   return "projects,stacks,hKeys,depKeys,-,hkeyArray"
end show_Params

on submenu_Missing
   return "Global | HkeyArray | Tree | Menu"
end submenu_Missing

private on _
end _

on menu_CreateBehaviorHkeyArray sObject
   put the module_BehaviorDepHkeyArray [true] of sObject into hKeyArray
   if fromFolder is true then
      set the script_HkeyArray of sObject to hKeyArray
   end if
   --
   display_ScriptHkeyArrayDeps hkeyArray, sObject
end menu_CreateBehaviorHkeyArray

on menu_AllDepHkeys sObject
   put _AllDepKeys() into hKeys
   hkey_SortIndex hKeys
   --
   put the number of lines of hKeys into keyNum
   put keyNum && "Hkeys" into sTitle
   put LocalArray ["dView"] into dView
   set the displayed_Data [sTitle] of dView to hKeys
end menu_AllDepHkeys

on menu_FilteredDepKeys sObject
   put _HkeyArray (sObject) into hkeyArray
   --
   put the module_ExternalHkeys [hKeyArray] of sObject into hKeys
   --
   put the number of lines of hKeys into keyNum
   put "Filtered Deps" && keyNum && "Hkeys" into sTitle
   set the displayed_Data [sTitle] of _dView() to hKeys
end menu_FilteredDepKeys

on menu_CollectDisplayed sObject
   put _DisplayedData() into hKeys
   put hkey_CollectFromObjects (hKeys, true) into depScript
   --
   _DisplayDepScript depScript, sObject
end menu_CollectDisplayed

on menu_CreateDepScriptStack sObject
   put the module_BehaviorDepScript of sObject into depScript
   put empty into  depScript
   --
   module_CreateBehaviorDepStack sObject, depScript
   if item 1 of the result = "Error" then
      _DisplayDepScript depScript, sObject
      --
      lcw_AnswerWarning "Cannot create behavior stack as it already exists!", LocalArray ["dView"]
   else
      put the result into depStackName
   end if
   edit the script of stack depStackName
   return depHkeyArray
end menu_CreateDepScriptStack

private on __
end __

on menu_DisplayMissing sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   display_MissingHkey hkeyArray, sObject
end menu_DisplayMissing

on menu_DisplayWalkHierarchy sObject
   put the walk_Hierarchy of sObject into searchObjects
   --
   display_Data searchObjects, the name of sObject, "Search Objects"
end menu_DisplayWalkHierarchy

on submenu_HkeyArray
   return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_HkeyArray

private on ___
end ___

on menu_ScriptHkeyArray sObject
   put the script_HkeyArrayFile of sObject into sFile
   if there is not a file sFile then
      put _HkeyArray() into hkeyArray 
      set the script_HkeyArray of sObject to hKeyArray
   else
      display_ScriptDependencyData sObject
   end if
end menu_ScriptHkeyArray

getprop checked_ScriptHkeyArray [sObject]
   put the script_HkeyArrayFile of sObject into sFile
   return there is a file sFile
end checked_ScriptHkeyArray

on menu_HkeyArrayGraph sObject, graphStyle
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, graphStyle
   put the result into svgFile
   --
   put the name of sObject into sLabel
   display_SVG svgFile, sLabel
end menu_HkeyArrayGraph

getprop hkeyArrayGraph_Params
   return _GraphStyles()
end hkeyArrayGraph_Params

on menu_GraphModuleBehavior sObject, graphStyle
   put the walk_ModuleBehaviorHkeyArray of sObject into hkeyArray
   --
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, graphStyle
   put the result into svgFile
   --
   put the name of sObject into sLabel
   display_SVG svgFile, sLabel
end menu_GraphModuleBehavior

getprop graphModuleBehavior_Params
   return _GraphStyles()
end graphModuleBehavior_Params

private on ____
end ____

on menu_ModuleBehaviorHierarchy sObject
   put the module_BehaviorHierarchy of sObject into oIndex
   display_Data oIndex, the name of sObject, "the module_BehaviorHierarchy"
end menu_ModuleBehaviorHierarchy

on menu_ReconstructHkeyArray sObject
   put name of sObject into sName
   put LocalArray ["dView"] into dView
   lcw_Answer "Walk scrip hierarchy and save hkeyarray for [[var]]?", dView, sName
   --
   put the walk_HkeyArray of sObject into hKeyArray
   put the script_HkeyArray of sObject into hKeyArray
end menu_ReconstructHkeyArray

private on _____
end _____

on menu_DisplayDotText sObject
   put the script_DotFile of sObject into dotFile
   --
   put the name of sObject into displayTitle
   put "" into mTitle
   display_TextFile dotFile, displayTitle, mTitle, "Dot"
end menu_DisplayDotText

on menu_RevealScriptSvgFile sObject
   put the script_SvgFile of sObject into svgFile
   finder_Reveal svgFile
end menu_RevealScriptSvgFile

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

private on ______
end ______

on menu_Recreate sObject
   put the walk_ModuleBehaviorHkeyArray of sObject into hkeyArray
   display_ScriptHkeyArrayDeps hkeyArray, sObject
   put the result into dView
   --
   put the module_Name of sObject into mName
   lcw_Answer "Save the hkey array for module '[[var]]' and replace the script_HkeyArray?", dView, mName
   --
   set the script_HkeyArray of sObject to hKeyArray
   --
   return dView
end menu_Recreate

on menu_Refresh sObject
   put LocalArray ["dView"] into dView
   lock screen
   put the displayed_Object of dView into sObject
   set the title_Text of dView  to the name of sObject
   --
   if the shiftKey is "Down" then
      put the dep_ProjectArray of sObject into hKeyArray
      set the script_HkeyArray of sObject to hKeyArray
   else
      put the script_HkeyArray of sObject into hKeyArray
   end if
   display_ScriptHkeyArrayDeps hkeyArray, sObject
   unlock screen
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Script | Dep | Menu")
end submenu_Dev
