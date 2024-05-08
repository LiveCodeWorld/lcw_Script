script "model_Hkey"
--> MetaData
-
license: GPLv3
name: model_Hkey
type: model
version: 0.9

/*
A model for handlers using the hKey notation. 
The aim is to use this library for key handlers that refer to locally stored handler metadata.
*/


--> Working on
-
function hkey_GetDotText hKey, pGraphStyle
   put hkey_DotFile (hKey, pGraphStyle) into someFile
   put url ("file:" & someFile) into dotText
   return dotText
end hkey_GetDotText

command hkey_SetDotText hKey, dotText, pGraphStyle
   put hkey_DotFile (hKey, pGraphStyle) into someFile
   put dotText into url ("file:" & someFile)
   return someFile
end hkey_SetDotText


--> Hkey | MetaData | Image
-
function hkey_GetImage hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   get url ("binfile:" & someFile)
   return it
end hkey_GetImage

command hkey_SetImage hKey, imageFile, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   put imageFile into url ("binfile:" & someFile)
end hkey_SetImage


--> Hkey | Help
-
function hkey_FetchHelp hKey
   put hkey_HelpFile (hKey, true) into someFile
   put text_Get (someFile) into someHelp
   return someHelp
end hkey_FetchHelp

command hkey_StoreHelp hKey, helpText
   put hkey_HelpFile (hKey, false) into someFile
   if helptext is empty then
      delete file someFile
   else
      put helpText into url ("binfile:" & someFile)
   end if
   return someFile
end hkey_StoreHelp


--> hKey | Model | Versions
-
function hkey_ListVersionNames hKey
   put hkey_ListShortVersionFolders (hKey) into shortFolders
   repeat for each line shortFolder in shortFolders
      put word 2 to -1 of shortFolder & CR after versionNames
   end repeat
   delete char -1 of versionNames
   return versionNames
end hkey_ListVersionNames


--> hKey | Model | Arrays
-
function hkey_GetOverlayArray hKey, pOverlayName
   put hkey_FetchOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName] into overlayArray
   return overlayArray
end hkey_GetOverlayArray

function hkey_FetchOverlayData hKey
   put hkey_OverlayDataFile (hKey) into someFile
   -- put array_Get (hkeyArrayFile) into overlayData
   put url ("binfile:" & someFile) into encodedArray
   if encodedArray is empty then return empty
   put arraydecode (encodedArray) into overlayData
   return overlayData
end hkey_FetchOverlayData

command hkey_SaveOverlayData hKey, overlayData
   put hkey_OverlayDataFile (hKey) into someFile
   
   if overlayData is an array then
      put arrayencode (overlayData) into encodedArray
      put encodedArray into url ("binfile:" & someFile)
      return someFile
   else if overlayData is empty then
      put hkey_Files (hKey, pVersionName) into someFiles
      set the itemdelimiter to "/"
      repeat for each line someFile in someFiles
         put item -1 of someFile into shortFile
         if shortFile is among the items of "handler.txt/help.html" then next repeat
         delete file someFile
      end repeat
      return empty
   end if
end hkey_SaveOverlayData


--> Script | scriptLine
-
function hkey_GetScriptLine hKey, pHandler
   switch
      case pHandler is not empty
         return line 1 of pHandler
      case the number of items of hKey = 2
         put library_FetchHandler (hKey) into pHandler
         return line 1 of pHandler
      case the number of items of hKey = 4
         put hkey_ExtractHandlerFromObject (hKey) into pHandler
         return line 1 of pHandler
   end switch
   return empty
end hkey_GetScriptLine

function hkey_ScriptLineNum hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return lineNum
end hkey_ScriptLineNum

function hkey_ScriptLine hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return scriptLine
end hkey_ScriptLine


--> hkey | Model | BackLinks
-
/*
Probably better done with a live database, rather than this cache approach.
*/

command hkey_AddBackLink backKey, hKey
   put hkey_GetBackLinks (hKey) into backLinks
   line_Add backKey, backLinks
   hkey_SetBackLinks hKey, backLinks
end hkey_AddBackLink

function hkey_GetBackLinks hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   return backLinks
end hkey_GetBackLinks

command hkey_SetBackLinks hKey, backLinks, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   if backLinks is empty then
      delete local overlayArray ["data"]["backLinks"]
   else
      put backLinks into overlayArray ["data"]["backLinks"]
   end if
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   return the result
end hkey_SetBackLinks

command hkey_AddToBackLinks overlayData
   -- for each frontKey add the backKey to the backLinks
   put overlayData ["data"]["linkArray"] into hkeyArray
   repeat for each key backKey in hkeyArray
      put hkeyArray [backKey] into frontKeys
      repeat for each line frontKey in frontKeys
         set the cursor to busy
         put hkey_GetBackLinks (frontKey) into backLinks
         -- hkey_CheckBackLinks backLinks
         line_Add backKey, backLinks
         hkey_SetBackLinks frontKey, backLinks
      end repeat
   end repeat
end hkey_AddToBackLinks

command hkey_CheckBackLinks @backLinks
   -- line_Delete "backLinks", backLinks
   -- put empty into backLinks
   -- loop through the backLinks and check they are still current
end hkey_CheckBackLinks


--> Hkey | Wrappers
-
command hKey_DeconstructStoredArray hKey, @hKeyCalls, @backLinks, @allCalls, pVersionName, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName, pVersionName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdArray, dotClusterArray
   
   put linkArray [hKey] into hKeyCalls
   put array_AllNodes (linkArray) into allCalls
   sort allCalls
   line_Delete hKey, allCalls -- just in case
end hKey_DeconstructStoredArray


--> hkey | Model | Arrays | Utils
-
function hkey_GetGeometryArray hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put hFileArray ["data"]["geometry"] into geometryArray
   return geometryArray
end hkey_GetGeometryArray

command hkey_SetGeometryArray hKey, geometryArray, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put geometryArray into overlayArray ["data"]["geometry"]
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
end hkey_SetGeometryArray

command hkey_StripDefaultDotArray overlayArray
   put overlay_GetDefaultArray() into defaultArray
   overlayArray_StripDefaultProps overlayArray, defaultArray
end hkey_StripDefaultDotArray

command hkey_StripDefaultProps @overlayData
   repeat for each key graphName in overlayData
      put overlayData [graphName] into overlayArray
      overlayArray_StripDefaultProps overlayArray
      put overlayArray into overlayData [graphName]
   end repeat
end hkey_StripDefaultProps

command hkey_NormalizeGraphName @pOverlayName
   if pOverlayName is empty then
      put hkey_GetDefaultGraphName() into pOverlayName
   end if
end hkey_NormalizeGraphName

function hkey_GetDefaultGraphName
   put overlay_GetDefaultArray() into overlayDefaultArray
   put overlayArray_GetGraphProperty (overlayDefaultArray, "overlay_Name") into graphName
   return graphName
end hkey_GetDefaultGraphName
