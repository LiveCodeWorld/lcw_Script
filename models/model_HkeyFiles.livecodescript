script "model_HkeyFiles"
--> MetaData
-
license: GPLv3
name: model_HkeyFiles
type: model
version: 0.2

/*
Handlers, their calls and their metadata are now stored in a folder that reflects the folder structure of project and object scripts:

Scripts are stored as merge files inside the dataObject_Folder eg:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/lcw_script.txt

Handlers and calls are stored inside the dataObject_Folder:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/M someCommand/lcw_handler.txt
-  put textStack_ConstructHandlerFolder (hKey, objectScriptFolder) into hkeyFolder

While hander graphs and dependency arrays are stored inside the metadataObject_Folder:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/M someCommand/lcw_handler.txt

The old hkey_Folder was here:
-  put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
*/

--> Working on
-
function hkey_Files hKey
   -- put hkey_Folder (hKey) into someFolder
   put hkey_DataFolder (hKey, true) into someFolder
   put folder_ShortFiles (someFolder) into someFiles
   return someFiles
end hkey_Files

function hkey_GraphFiles hKey, pOverlayName, pVersionName
   put library_HandlerFile (hKey, empty, true) into dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapFile, xdotFile, dotArrayFile, pOverlayName
   put dotFile,imageFile,cmapFile,xdotFile,dotArrayFile,pOverlayName into someFiles
   replace comma with  CR in someFiles
   return someFiles
end hkey_GraphFiles


--> TextStack | Construct
-
function textStack_ConstructCallsFile hKeyLine, dataFolder
   put textStack_ConstructHandlerFolder (hKeyLine, dataFolder) & "lcw_calls.txt" into callsFile
   return callsFile
end textStack_ConstructCallsFile

function textStack_ConstructHandlerFile shortHkey, dataFolder
   -- see also "hkey_HandlerFile"
   put textStack_ConstructHandlerFolder (shortHkey, dataFolder) & "lcw_handler.txt" into handlerFile
   return handlerFile
end textStack_ConstructHandlerFile

function textStack_ConstructHandlerFolder hKeyLine, dataFolder
   hkey_Normalize hKeyLine
   text_AddTrailing dataFolder, slash
   put word 1 to 2 of hKeyLine into folderName
   put dataFolder & "handlers/" & folderName & "/" into handlerFolder
   return handlerFolder
end textStack_ConstructHandlerFolder


--> Hkey | Files | List
-
function hkey_ListSvgFiles hKey
   put hkey_MetadataFolder (hKey) into someFolder
   put file_ListShort (someFolder) into someFiles
   filter someFiles with "*.svg"
   return someFiles
end hkey_ListSvgFiles

function hkey_ImageMapPngs hKey
   put hkey_MetadataFolder (hKey) into someFolder
   put file_ListShort (someFolder) into someFiles
   filter somePngs with "*.png"
   return somePngs
end hkey_ImageMapPngs

function hkey_ListShortFolders
   put library_PluginFolder ("opn_Text/rev/handlers/") into helpFolder
   put the defaultfolder into oFolder
   set the defaultfolder to helpFolder
   put the folders into tFolders
   filter tFolders without ".*"
   set the defaultfolder to oFolder  
   return tFolders
end hkey_ListShortFolders 

function hkey_ListShortVersionFolders hKey
   local versionNames
   put hkey_ListShortFolders() into shortFolders
   
   put hkey_FolderName (hKey) into folderName
   filter shortFolders with (folderName & " *")
   return shortFolders
end hkey_ListShortVersionFolders


--> hkey | Handler | File
-
function hkey_HandlerFile hKey, pDontCreate
   put hkey_DataFolder (hKey, pDontCreate) into dataFolder
   put textStack_ConstructHandlerFile (hKey, dataFolder) into handlerFile
   return handlerFile
end hkey_HandlerFile

command hkey_DeleteHandlerFile hKey
   put hkey_HandlerFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHandlerFile


-->  Hkey | Folder | Model
-
function hkey_MetadataFolder hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the metadataObject_Folder of hObject into metaDataFolder
   put textStack_ConstructHandlerFolder (hKey, metaDataFolder) into hkeyMetadataFolder
   return hkeyMetadataFolder
end hkey_MetadataFolder

function hkey_DataFolder hKey, pDontCreate
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the dataObject_Folder [pDontCreate] of hObject into dataFolder
   return dataFolder
end hkey_DataFolder

function hkey_Folder hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   
   put the dataObject_Folder [true] of hObject into dataFolder
   put textStack_ConstructHandlerFolder (hKey, dataFolder) into handlerFolder
   return handlerFolder
end hkey_Folder

command hkey_DeleteFolder hKey
   put hkey_Folder (hKey) into hkeyFolder
   revDeleteFolder hkeyFolder
end hkey_DeleteFolder


--> Handler | Calls | File
-
function hkey_CallsFile hKey
   hkey_Normalize hKey
   put the result into shortHkey
   hKeyLine_Deconstruct hKey, hName, hType, hObject
   if exists (hObject) is false then return empty
   
   put the dataObject_Folder of hObject into dataFolder
   put dataFolder & "handlers/" & shortHkey & "/lcw_calls.txt" into callsFile
   return callsFile
end hkey_CallsFile


-->  Hkey | Files
-
function hkey_OverlayDataFile hKey, pDontCreate
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   return hkeyMetadataFolder & "overlaydata.array"
end hkey_OverlayDataFile

function hkey_CmapxFile hKey, pGraphStyle
   put hkey_MetadataFile (hKey, ".cmapx", pGraphStyle) into imageFile
   return imageFile
end hkey_CmapxFile

function hkey_HelpFile hKey, pGraphStyle
   return hkey_Folder (hKey, pDontCreate) & "help.html"
end hkey_HelpFile

function hkey_ImageFile hKey, pGraphStyle
   put hkey_MetadataFile (hKey, ".png", pGraphStyle) into imageFile
   return imageFile
end hkey_ImageFile

function hkey_DotFile hKey, pGraphStyle
   put hkey_MetadataFile (hKey, ".dot", pGraphStyle) into dotFile
   return dotFile
end hkey_DotFile

function hkey_SvgFile hKey, pGraphStyle
   put hkey_MetadataFile (hKey, ".svg", pGraphStyle) into svgFile
   return svgFile
end hkey_SvgFile

function hkey_MetadataFile hKey, fileExtension, pGraphStyle
   if pGraphStyle is empty then put "hierarchical" into pGraphStyle
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   put hkeyMetadataFolder & pGraphStyle & fileExtension into someFile
   return someFile
end hkey_MetadataFile


--> Hkey | Folders
-
/*
These handlers refer to the permanent fixed shared location of the files in hkey handler database.
*/
command hkey_DeconstructFolder scriptFolder, @shortHkey, @versionName
   set the itemdelimiter to "/"
   get item -1 of scriptFolder
   
   put word 1 of it into shortFolder
   put word 2 of it into versionName
   
   set the itemdelimiter to "_"
   put item 1 to -2 of shortFolder into handlerName
   put item -1 of shortFolder into handlerType
   put handlerName,handlerType into shortHkey
end hkey_DeconstructFolder

function hkey_FromFolder someFolder
   set the itemdelimiter to "/"
   put item - 1 of someFolder into shortFolder
   put hkey_FromShortFolder (shortFolder) into shortHkey
   return shortHkey
end hkey_FromFolder

function hkey_FromShortFolder shortFolder
   put word 1 of shortFolder into handlerInfo
   
   set the itemdelimiter to "_"
   put item -1 of handlerInfo into handlerType
   put item 1 to -2 of handlerInfo into handlerName
   
   set the itemdelimiter to comma
   if handlerType is not among the items of "g,s,c,f,m,pg,ps,pc,pf" then return empty
   return handlerName,handlerType
end hkey_FromShortFolder

function hkey_FolderName hKey
   put item 1 of hKey into hName
   put item 2 of hKey into hType
   if hType = "o" then put "c" into hType -- as "on" and "command" are functionally equivalent
   put hName & "_" & tolower (hType) into folderName
   return folderName
end hkey_FolderName


--> Hkey | Files | Delete
-
command hkey_DeleteArrayFile hKey
   put hkey_OverlayDataFile (hKey) into someFile
   delete file someFile
end hkey_DeleteArrayFile

command hkey_DeleteDotFile hKey
   put hkey_DotFile (hKey) into someFile
   delete file someFile
end hkey_DeleteDotFile

command hkey_DeleteImageMapPngs hKey
   put hkey_ImageMapPngs (hKey) into someFiles
   repeat for each line someFile in someFiles
      delete file someFile
   end repeat
end hkey_DeleteImageMapPngs

command hkey_DeleteImageFile hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   delete file someFile
end hkey_DeleteImageFile

command hkey_DeleteHelpFile hKey
   put hkey_HelpFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHelpFile
