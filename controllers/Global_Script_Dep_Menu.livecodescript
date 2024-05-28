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

getprop hkeyArrayGraph_Params
   return "hierarchical,fast undirected spring"
end hkeyArrayGraph_Params


--> Global | Script | Dep | Menu
-
on menu_HkeyArrayGraph sObject, graphStyle
   put LocalArray ["hkeyArray"] into hkeyArray
   graph_CreateScriptObjectHkeyArray hkeyArray, sObject, graphStyle
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

private on _
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

private on __
end __

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
