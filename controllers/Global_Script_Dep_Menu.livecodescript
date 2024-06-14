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

private function _HkeyArray
   return LocalArray ["hkeyArray"]
end _HkeyArray

getprop hkeyArrayGraph_Params
   return "hierarchical,fast undirected spring"
end hkeyArrayGraph_Params

getprop displayDotText_Params [sObject]
   put the script_DotFiles [false] of sObject into shortFiles
   return shortFiles
end displayDotText_Params


--> Global | Script | Dep | Menu
-
on menu_DraftHelp sObject
   draft_ScriptHelp sObject
end menu_DraftHelp

private on ____
end ____

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
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, graphStyle
   put the result into svgFile
   --
   put the name of sObject into sLabel
   display_SVG svgFile, sLabel
end menu_HkeyArrayGraph

on menu_DisplayMissing sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   --
   display_MissingHkey hkeyArray, sObject
end menu_DisplayMissing

private on _
end _

on submenu_Show
   return "Global | HkeyArray | Tree | Menu"
end submenu_Show

on menu_Refresh sObject
   display_ScriptDeps sObject
end menu_Refresh

private on __
end __

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

private on ___
end ___

on menu_TestStackDeps sObject
   put the dep_Stacks of sObject
end menu_TestStackDeps

on menu_ListDepStacks sObject
   put LocalArray ["hkeyArray"] into hkeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into depObjectData
   --
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
   put "libs:" && libNames into libDepLine -- dep_StackNames
   put "projects:" && projectNames into projectDepLine -- dep_StackNames
   
   put libDepLine & CR & projectDepLine
end menu_ListDepStacks

on submenu_Dev
   return menu_DevTitle ("Global | Script | Dep | Menu")
end submenu_Dev
