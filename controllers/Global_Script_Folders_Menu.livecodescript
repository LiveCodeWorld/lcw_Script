script "Global_Script_Folders_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Folders_Menu
type: controller
version: 0.2


--> Global | Script | Folders | Menu
-
on menu_ScriptOverlayFolder scriptObject
   put the script_OverlayFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_ScriptOverlayFolder

on menu_ProjectOverlayFolder scriptObject
   put the project_OverlayFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_ProjectOverlayFolder

on menu_OverlayFolder scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_OverlayFolder

on _
end _

on menu_DataObjectFolder scriptObject
   put the dataObject_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_DataObjectFolder

on menu_MetaDataObjectFolder scriptObject
   put the metadataObject_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_MetaDataObjectFolder

on _
end _

on menu_DataObjectsFolder scriptObject
   put the dataObjects_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_DataObjectsFolder

on menu_MetaDataObjectsFolder scriptObject
   put the metadataObjects_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_MetaDataObjectsFolder

on _
end _

on menu_ProjectOverlaySvg hObject
   put the projectOverlay_SvgFile of hObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      display_SVG svgFile
   end if
end menu_ProjectOverlaySvg

on menu_ProjectOverlayDot scriptObject
   put the projectOverlay_File ["lcw_Menus.dot"] of scriptObject into someFile
   atom_DisplayFile someFile
end menu_ProjectOverlayDot

on menu_ProcessedHkeyArray scriptObject
   put the projectOverlay_Array ["processedHkey.array"] of scriptObject into hkeyArray
   --
   display_ScriptHkeyArray hKeyArray, scriptObject
end menu_ProcessedHkeyArray

on menu_ProjectOverlayData scriptObject
   put the projectOverlay_Array ["overlayData.array"] of scriptObject into someArray
   --
   display_Array someArray, "projectOverlay_Array"
end menu_ProjectOverlayData

on menu_ProjectOverlayFile scriptObject
   put the projectOverlay_File of scriptObject into someFile
   display_File someFile
end menu_ProjectOverlayFile

on _
end _

on menu_TextstackMetadataFolder scriptObject
   put the textStack_MetadataFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_TextstackMetadataFolder

on menu_TextstackDataFolder scriptObject
   put the textStack_Folder of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_TextstackDataFolder

on menu_TextstackFolder scriptObject
   put the textStack_Folder of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_TextstackFolder

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   display_Folder projectFolder
end menu_ProjectFolder

on menu_RevealMainstackDotText scriptObject
   put the project_OverlayFolder [true] of scriptObject into overlayFolder
   put overlay_ConstructFile ("dot", overlayFolder, "Mainstack Structure") into someFile
   
   display_File someFile
end menu_RevealMainstackDotText

on menu_OpenHandlerLibraryFolder
   put library_HkeyFolder (empty, false) into hkeyFolder
   display_Folder hkeyFolder
end menu_OpenHandlerLibraryFolder


--> Global | Script | Folders | Menu | Disabled
-
getprop disabled_ProjectOverlayDot [scriptObject]
   put the projectOverlay_File ["lcw_Menus.dot"] of scriptObject into someFile
   put there is not a file someFile into fileIsMissing
   return fileIsMissing
end disabled_ProjectOverlayDot

getprop disabled_ProjectOverlaySvg [scriptObject]
   put the projectOverlay_SvgFile of scriptObject into someFile
   put there is not a file someFile into fileIsMissing
   return fileIsMissing
end disabled_ProjectOverlaySvg

getprop disabled_ProjectOverlayData [scriptObject]
   put the projectOverlay_File ["overlayData.array"] of scriptObject into someFile
   put there is not a file someFile into fileIsMissing
   return fileIsMissing
end disabled_ProjectOverlayData

getprop disabled_ProcessedHkeyArray [scriptObject]
   put the projectOverlay_File ["processedHkey.array"] of scriptObject into someFile
   put there is not a file someFile into fileIsMissing
   return fileIsMissing
end disabled_ProcessedHkeyArray

getprop disabled_ProjectOverlayFile [scriptObject]
   put the projectOverlay_File of scriptObject into someFile
   put there is not a file someFile into fileIsMissing
   return fileIsMissing
end disabled_ProjectOverlayFile

getprop disabled_ProjectOverlayFolder [scriptObject]
   put the project_OverlayFolder of scriptObject into someFolder
   if there is a folder someFolder then
      return false
   else
      return true
   end if
end disabled_ProjectOverlayFolder

getprop disabled_ScriptOverlayFolder [scriptObject]
   put the script_OverlayFolder of scriptObject into someFolder
   if there is a folder someFolder then
      return false
   else
      return true
   end if
end disabled_ScriptOverlayFolder


--> Deps
-
command display_File someFile
   put someFile
   if there is a file someFile then
      finder_Reveal someFile
      lcw_Notify "Here is the file..."
   else
      put someFile
      answer warning "File does not exist!"
   end if
end display_File

command display_Folder someFolder
   put someFolder
   if there is a folder someFolder then
      finder_Reveal someFolder
      lcw_Notify "Here is the folder..."
   else
      put someFolder
      answer warning "Folder does not exist!"
   end if
end display_Folder
