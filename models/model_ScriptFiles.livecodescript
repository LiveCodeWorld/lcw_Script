﻿script "model_ScriptFiles"
--> MetaData
-
license: GPLv3
name: model_ScriptFiles
type: model
version: 0.9

/*
We are moving over from old comma based hKeys to new format.
This is for the following reasons:

- revAvailable handlers returns in this format
- the tree widget does nto work well with keys that contain commas
- It reads better on screen and in the wiki

Need to rename these "project" handlers to "object_"
Working on handlers from "Overlay | File | Props" --- need to check them
*/

--> Working on
-

--> Props
-
getprop script_DotText [pOverlayName]
   put the long id of the target into sObject
   put the script_DotFile [pOverlayName] of sObject into dotFile
   --
   put url ("file:" & dotFile) into dotText
   return dotText
end script_DotText

getprop script_DotFile [pOverlayName]
   put the long id of the target into sObject
   get scriptFile_ConstructDot (sObject, pOverlayName)
   return it
end script_DotFile

getprop script_DotFiles [pLong]
   put the script_MetadataFiles [pLong] of the target into dotFiles
   --
   filter dotFiles with "*.dot"
   return dotFiles
end script_DotFiles


--> Props
-
getprop overlay_Folder [pDontCreate]
   -- /metadata/objects/ 
   -- it is the metadata for for a script object
   
   put the textStack_MetadataFolder of the target into metadataFolder
   put metadataFolder & "objects/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end overlay_Folder

getprop script_OverlayFile [pDontCreate]
   put the long id of the target into sObject
   put the overlay_Folder [pDontCreate] of sObject into overlayFolder
   
   -- put overlayFolder & "overlaydata.array" into someFile
   put overlay_ArrayFile (overlayFolder) into someFile
   return someFile
end script_OverlayFile

getprop script_CmapFile [pOverlayName]
   put the long id of the target into sObject
   put the textStack_MetadataFolder [true] of sObject into scriptFolder
   
   _NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".cmapx" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end script_CmapFile


--> Script | File | SVG
-
getprop script_HkeyArrayFile
   put the metadataObject_Folder of the target into metadataFolder
   put metadataFolder & "scriptHkey.array" into hkeyArrayFile
   return hkeyArrayFile
end script_HkeyArrayFile

getprop script_SvgFile [graphStyle]
   if graphStyle is empty then put "hierarchical" into shortFile
   put the long id of the target into sObject
   
   put the metadataObject_Folder [pDontCreate] of sObject into metadataFolder
   put metadataFolder & shortFile & ".svg" into svgFile
   return svgFile
end script_SvgFile

getprop script_DotFiles
   put the script_MetadataFiles of the target into shortDotFiles
   --
   filter shortDotFiles with "*.dot"
   return shortDotFiles
end script_DotFiles

getprop script_SvgFiles
   put the script_MetadataFiles [true] of the target into svgFiles
   --
   filter svgFiles with "*.svg"
   return svgFiles
   
   put the long id of the target into sObject
   put the metadataObject_Folder [pDontCreate] of sObject into metadataFolder
   put overlay_ListScriptSvgShortFiles (metadataFolder)into shortSvgFiles
   put file_AddFolderToPaths (shortSvgFiles, overlayFolder, false, ".svg") into svgFiles
   return svgFiles
end script_SvgFiles

getprop script_SvgShortFiles
   put the script_MetadataFiles [false] of the target into shortSvgFiles
   --
   filter shortSvgFiles with "*.svg"
   return shortSvgFiles
end script_SvgShortFiles

getprop script_MetadataFiles [pLong]
   put the long id of the target into sObject
   --
   put the metadataObject_Folder [true] of sObject into metadataFolder
   put files (metadataFolder) into shortFiles
   --
   if pLong is false then
      return shortFiles
   else
      put file_AddFolderToPaths (shortFiles, metadataFolder, false) into longFiles
      return longFiles
   end if
end script_MetadataFiles

getprop script_GraphImageFile [pOverlayName]
   put the long id of the target into sObject
   return scriptFile_ConstructImage (sObject, pOverlayName)
end script_GraphImageFile

getprop script_ImageFiles
   put the script_Files of the target into somePngs
   filter somePngs with "*.png"
   return somePngs
end script_ImageFiles

getprop script_GraphImageFile [pOverlayName]
   put the long id of the target into sObject
   return scriptFile_ConstructImage (sObject, pOverlayName)
end script_GraphImageFile

getprop script_ImageFiles
   put the script_Files of the target into somePngs
   filter somePngs with "*.png"
   return somePngs
end script_ImageFiles


--> Folder | Synonyms
-
getprop script_OverlayFolder [pDontCreate]
   -- same as the metadata_Folder of sObject or the metadataObject_Folder of sObject
   -- /metadata/objects/stack/overlay/ 
   -- which is not the "project" metadata folder
   -- it is the metadata for for a script object
   
   put the metadataObject_Folder [pDontCreate] of the target into metadataFolder
   return metadataFolder
end script_OverlayFolder

getprop script_Folder [pDontCreate]
   -- easier to remember synonym for "the dataObject_Folder"
   put the dataObject_Folder [pDontCreate] of the target into scriptFolder
   return scriptFolder
end script_Folder


--> Folder | Metadata
-
getprop metadata_Folder [shortHkey]
   if shortHkey is empty then
      return the metadataObject_Folder of the target
   else
      return the metadataHandler_Folder [shortHkey] of the target
   end if
end metadata_Folder

getprop metadataHandler_Folder [shortHkey]
   put the long id of the target into tObject
   --
   put word 1 to 2 of shortHkey into shortHkey
   put shortHkey && "of" && tObject into hKey
   put hkey_MetadataFolder (hKey) into metadataHekyFolder
   --
   return metadataHekyFolder
end metadataHandler_Folder

getprop metadataObject_Folder [pDontCreate]
   -- lib_IDE/metadata/objects/stack/
   -- the objects metadataObject_Folder (not the textStack_MetadataFolder
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into tObject
   put the metadataObjects_Folder [pDontCreate] of tObject into metadataObjectsFolder
   
   put the defaultstack into tObject
   put the short name of tObject into stackName
   put the mainstack of tObject into mainStackName
   
   if stackName = mainStackName then
      put metadataObjectsFolder into metadataObjectFolder
   else
      put metadataObjectsFolder & "substacks/" & stackName & "/" into metadataObjectFolder
   end if
   --
   switch word 1 of tObject
      case "stack"
         put "stack/" after metadataObjectFolder
         break
      default
         put word 1 of tObject & "_" & word 3 of tObject & "/" after metadataObjectFolder
   end switch
   --
   if pDontCreate is not true then folder_CreateNested metadataObjectFolder
   return metadataObjectFolder
end metadataObject_Folder

getprop metadataObjects_Folder [pDontCreate]
   -- /metadata/objects/ 
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/
   -- it is the metadata for a script object
   
   put the textStack_MetadataFolder [pDontCreate] of the target into metadataFolder
   put metadataFolder & "objects/" into metadataObjectsFolder
   if pDontCreate is false then folder_CreateNested metadataObjectsFolder
   return metadataObjectsFolder
end metadataObjects_Folder

getprop metadataProject_Folder [pDontCreate]   
   -- /metadata/project/ 
   put the textStack_MetadataFolder of the target into metadataFolder
   put metadataFolder & "project/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end metadataProject_Folder


--> Folder | Data | Objects
-
getprop dataObject_Folder [pDontCreate]
   /*
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/
   
   This is an object specific data folder.
   -- where the script_File (lcw_Script.txt), handler_Folder (handlers) and other data related to the object is stored.
   
   All object specific data folders are within "the dataObjects_Folder"
   Which in turn is within "the textStack_DataFolder"
   */
   
   put the long id of the target into tObject
   put the dataObjects_Folder [pDontCreate] of tObject into dataObjectsFolder
   
   put the defaultstack into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      put dataObjectsFolder into dataFolder
   else
      put dataObjectsFolder & "substacks/" & stackName & "/" into dataFolder
   end if
   
   switch word 1 of tObject
      case "stack"
         put "stack/" after dataFolder
         break
      default
         put word 1 of tObject & "_" & word 3 of tObject & "/" after dataFolder
   end switch
   if pDontCreate is not true then folder_CreateNested dataFolder
   return dataFolder
end dataObject_Folder

getprop dataObjects_Folder [pDontCreate]
   /*
   -- /lcw_User/lcw_Metadata/LCW/data/objects/
   */
   put the textStack_DataFolder [pDontCreate] of the target into textStackDataFolder
   put textStackDataFolder & "objects/" into dataObjectsFolder
   return dataObjectsFolder
end dataObjects_Folder


--> Script | Object File Properteis
-
getprop script_File [pDontCreate]
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/script.txt
   put pDontCreate is not false into pDontCreate
   put the dataObject_Folder [true] of the target into dataFolder
   put textStack_ScriptFile (dataFolder, pDontCreate) into scriptFile
   return scriptFile
end script_File

getprop script_HelpFile [pDontCreate]
   put the long id of the target into sObject
   put the textStack_MetadataFolder [pDontCreate] of sObject into metadataFolder
   put metadataFolder & "help.html" into someFile
   return someFile
end script_HelpFile

getprop script_HelpFile [pDontCreate]
   put the long id of the target into sObject
   put the textStack_MetadataFolder [pDontCreate] of sObject into metadataFolder
   put metadataFolder & "help.html" into someFile
   return someFile
end script_HelpFile

getprop script_OverlayFile [pDontCreate]
   put the long id of the target into sObject
   put the overlay_Folder [pDontCreate] of sObject into overlayFolder
   
   -- put overlayFolder & "overlaydata.array" into someFile
   put overlay_ArrayFile (overlayFolder) into someFile
   return someFile
end script_OverlayFile

getprop script_CmapFile [pOverlayName]
   put the long id of the target into sObject
   put the textStack_MetadataFolder [true] of sObject into scriptFolder
   
   _NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".cmapx" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end script_CmapFile

getprop script_Files
   put the long id of the target into sObject
   put the textStack_MetadataFolder [true] of sObject into metadataFolder
   put file_ListShort (metadataFolder) into someFiles
   return someFiles
end script_Files


--> ScriptFile
-
function scriptFile_ConstructImage sObject, pOverlayName
   put the textStack_MetadataFolder [true] of sObject into scriptFolder
   _NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & "." & "png" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptFile_ConstructImage

function scriptFile_ConstructDot sObject, pOverlayName
   put the metadataObject_Folder [true] of sObject into scriptFolder
   _NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".dot" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptFile_ConstructDot


--> Private
-
private command _NormalizeGraphName @pOverlayName, overlayFolder
   -- seems a wrong default?
   if pOverlayName is empty then
      put overlay_GetData (overlayFolder) into overlayData
      put line 1 of keys (overlayData) into pOverlayName
      if pOverlayName is empty then put "undirected spring" into pOverlayName
   end if
   return pOverlayName
end _NormalizeGraphName
