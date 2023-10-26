script "model_ScriptExport"
--> MetaData
-
name: model_ScriptExport
type: model
author: David Bovill
copyright: David Bovill
license: GPLv3
version: 0.91

/*
This model handles exported scripts and handlers.

It uses a "merge" technique to combine individual handlers with an exported script template. This is surprisingly fast and has a number of advantages:

-  changes to individual handlers show up in git
-  spotlight and similar tools can easily find and index handlers
-  avoids duplication of handlers
-- makes it easy to see duplicate handlers and badly formatted scripts

There were problems with text encoding and git - so we started to export scripts as binary and use "hack_UpdateBinFile" to fiddle / fix things
This needs looking into again.
For now we look to move all access to this model so we can make changes globally.

Uses "script_ExportAndIndexMenus"

For old name format you can change ShortHandlerFile = "script.txt" -- old and "_ConstructHandlerFile" to "_ConstructOldHandlerFile"

private command hack_UpdateBinFile @someData, someFile
   if someData contains numtochar (13) then
      -- old "file" export
      breakpoint
      replace numtochar (13) with CR in someData
      put someData into url ("binfile:" & someFile)
   end if
end hack_UpdateBinFile
*/

--> Variables
-
local LocalArray -- used by the script_MergeLines function to restore the original script
constant ShortHandlerFile = "lcw_Handler.txt" -- new


--> Working on
-
getprop script_IsDifferent
   -- even if the only difference is whitespace (we tolerate empty space at start and end of scripts)
   -- which means a diff program may show no diference when this returns true
   put the long id of the target into targetObject
   try
      put the script of targetObject into someScript
      put the exported_Script of targetObject into exportedScript
      --
      -- get DiffCompare (someScript, exportedScript, 0) into uDiff
      --
      if exportedScript is empty then return false -- added as if there is no exported script to compare it is no different
      put word 1 to -1 of exportedScript is not word 1 to -1 of someScript into someBoolean
      return someBoolean
   catch someError
      return empty  -- script may be protected
   end try
end script_IsDifferent

/*
Not unicode compiant - but scripts should be ascii?

These work for handlers and scripts.
If you use these handlers then we have a single place to test / switch / ensure we use the correct binary or text encoding for stored script files.
At one time Git was not dealing with Livecode OSX files for instance.
*/
function text_Get someFile
   -- was "script_FetchRaw"
   -- put url ("binfile:" & someFile) into someText
   put url ("file:" & someFile) into someText
   return someText
end text_Get

command text_Set someFile, someText
   put someFile into scriptFolder
   set the itemdelimiter to slash
   put empty into item -1 of scriptFolder
   folder_CreateNested scriptFolder
   -- put word 1 to -1 of someText into url ("binfile:" & scriptFile)
   put word 1 to -1 of someText into url ("file:" & someFile)
   return the result
end text_Set


--> Merge | Export | _FetchHandler
-
/*
This handler and it's private deps is called when "script_ReconstructFromExported" does a "merge"
As we only know objectScriptFolder (and not scriptObject) we must work things out from the folder name.
*/

private function _FetchHandler hName, hType
   -- called when "script_ReconstructFromExported" does a "merge"
   put LocalArray ["objectScriptFolder"] into objectScriptFolder
   --
   put _ConstructHandlerFile (hName, hType, objectScriptFolder) into handlerFile
   -- put _ConstructOldHandlerFile (hName, hType, objectScriptFolder) into handlerFile
   
   if there is a file handlerFile then
      put text_Get (handlerFile) into someHandler
      return someHandler
   else
      return empty
   end if
end _FetchHandler

private function _ConstructHandlerFile hName, hType, objectScriptFolder
   -- g person_View
   put objectScriptFolder & "handlers/" & hType && hName & "/" into handlerFolder
   put handlerFolder & ShortHandlerFile into handlerFile
   return handlerFile
end _ConstructHandlerFile

private function _ConstructOldHandlerFile hName, hType, objectScriptFolder
   -- person_View_g
   put objectScriptFolder & "handlers/" & hName & "_" & hType & "/" into handlerFolder
   put handlerFolder & ShortHandlerFile into handlerFile
   return handlerFile
end _ConstructOldHandlerFile


--> Script | Reconstruct
-
function script_ReconstructFromExported dataFolder, pDontMerge
   text_AddTrailing dataFolder, slash
   put textStack_ScriptFile (dataFolder, pDontCreate) into scriptFile
   --
   put text_Get (scriptFile) into rawScript
   if pDontMerge is true then
      return rawScript
   else
      put dataFolder into LocalArray ["objectScriptFolder"]
      put dataFolder & "handlers/" into handlersFolder
      if there is a folder handlersFolder then
         put merge (rawScript) into fullScript
         return fullScript & CR -- extra CR as IDE adds this to scripts displayed
      else
         return rawScript
      end if
   end if
end script_ReconstructFromExported

function textStack_ScriptFile dataFolder, pDontCreate
   -- from "model_TextStack"
   if pDontCreate is false then
      folder_CreateNested dataFolder
   else
      text_AddTrailing dataFolder, slash
   end if
   put dataFolder & ShortHandlerFile into someFile
   return someFile
end textStack_ScriptFile


--> Props
-
getprop exported_Script [pDontMerge]
   put the dataObject_Folder of the target into dataFolder
   put script_ReconstructFromExported (dataFolder, pDontMerge) into someScript
   return someScript
end exported_Script

setprop exported_Script [pExportCalls] someScript
   put the long id of the target into scriptObject
   script_ExportAndIndexMenus scriptObject, pExportCalls
   put the script_File of scriptObject into scriptFile
   return scriptFile
end exported_Script

setprop script_IsIndexed someBoolean
   put the long id of the target into scriptObject
   if someBoolean is true then
      script_IndexHarrayAndUpateMenus scriptObject
      put the result into mTitleTableArray
      return mTitleTableArray
   else
      breakpoint -- not done yet
      return empty
   end if
end script_IsIndexed

getprop script_Raw
   put the script_File of the target into scriptFile
   put text_Get (scriptFile) into rawScript
   return rawScript
end script_Raw

getprop script_MergeArray
   put the script of the target into someScript
   put script_ConstructMergeArray (someScript) into scriptMergeArray
   return scriptMergeArray
end script_MergeArray



--> Script | Merge | Utils
-
/*
This suite of handlers uses LocalArray so that the merge function can work across handlers.
It depends of a particular file and folder structure of the exported script template and handlers.
*/

function script_MergeHandlers scriptFile, someScript
   put scriptFile into objectScriptFolder
   set the itemdelimiter to "/"
   delete item -1 of objectScriptFolder
   put objectScriptFolder into LocalArray ["objectScriptFolder"]
   
   put objectScriptFolder & "/handlers/" into handlersFolder
   if there is a folder handlersFolder then
      return merge (someScript)
   else
      return someScript
   end if
end script_MergeHandlers

function script_ConstructMergeArray someScript
   -- 20% faster than not using revAvailableHandlers
   -- 50% slower than fetching from disk
   -- 10x slower than just using revAvailableHandlers
   -- hashing ony makes 5% difference
   put the revAvailableHandlers of tObject into handlerTable
   put handlerTable into mergeScriptArray ["handlerTable"]
   
   sort numeric descending handlerTable by word 3 of each
   repeat for each line handlerTableLine in handlerTable
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put hName,hType into shortHkey
      put line startLineNum to endLineNum of someScript into someHandler
      put sha1_Hash (someHandler) into mergeScriptArray ["handler"][shortHkey]["sha1"]
      put someHandler into mergeScriptArray ["handler"][shortHkey]
      
      put "[[ library_FetchHandler (" & shortHkey & ") ]]" into line startLineNum to endLineNum of someScript
   end repeat
   put someScript into mergeScriptArray ["mergeScript"]
   return mergeScriptArray
end script_ConstructMergeArray

function script_MergeLines mergeScript, handlerTable
   -- put merge (mergeScript) into remergedScript -- not safe when mergeScript contains odd chars?
   sort numeric ascending handlerTable by word 3 of each
   
   repeat for each line handlerTableLine in handlerTable
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put hName,hType into shortHkey
      put library_FetchHandler (shortHkey) into someHandler
      put someHandler into line startLineNum of mergeScript
   end repeat
   return mergeScript
end script_MergeLines
