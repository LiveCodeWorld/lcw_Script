script "lib_ScriptFetch"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ScriptFetch
type: library
version: 0.1

/*
A modern library for getting and fetching scripts.
*/


--> Working on
-


--> Script | Get
-
function script_CollectFromObjects hKeys, pSort
   local newScript
   if hKeys is an array then
      put keys (hKeys) into hKeys
      hkey_SortIndex hKeys
   else if pSort is true then
      hkey_SortIndex hKeys
   end if
   put word 1 to -1 of hKeys into hKeys
   
   # Messages first
   filter hKeys with "M *" into messagekeys
   repeat for each line hKey in messagekeys
      put handler_Get (hKey) into someHandler
      text_AddParagraph someHandler, newScript
   end repeat
   
   filter hKeys without "M *"
   repeat for each line hKey in hKeys
      put handler_Get (hKey) into someHandler
      text_AddParagraph someHandler, newScript
   end repeat
   return newScript
end script_CollectFromObjects


--> Script | Library | Fetch
-
function script_FromHkeys hKeys, pMakePrivate
   local newScript, missingHkeys
   script_FetchFromHkeys hKeys, newScript, missingHkeys, pMakePrivate
   return newScript
end script_FromHkeys

command script_FetchFromHkeys hKeys, @newScript, @missingHkeys, pMakePrivate
   -- utitlity for returning missing keys as well
   put word 1 to -1 of hKeys into hKeys
   sort hKeys
   repeat for each line hKey in hKeys
      put hkey_FetchHandler (hKey) into someHandler
      if someHandler is empty then
         line_Add hKey, missingHkeys
      else
         if pMakePrivate is true and word 1 of dsfa is not "private" then
            put "private" & space before someHandler
         end if
         text_AddParagraph someHandler, newScript
      end if
   end repeat
end script_FetchFromHkeys


--> HkeyArray | Suite | Old
-
command hkeyArray_ConstructDependencySuite hkeyArray, pStripScriptObject, @depSuite, pStripObjects, pStripProps, pMakePrivate
   local depScript
   
   put array_ListKeys (hkeyArray) into allCalls
   -- hkey_StripDuplicates allCalls
   put the result into duplicateHkeyArray
   
   put hkey_ConstructDepArray (allCalls, pMakePrivate) into depArray
   
   if exists (pStripScriptObject) is true then
      -- strip the nodes from the scriptObject whose hkeyArray we are processing
      hkey_SimpleStripObject allCalls, pStripScriptObject
      put the result into strippedKeys
   end if
   
   if pStripProps is true then
      -- this does not do a network walk (does this matter?)
      hkey_StripGetProps allCalls
      line_Add the result, strippedKeys
      
      hkey_StripSetProps allCalls
      line_Add the result, strippedKeys
   end if
   
   -- now let's recursively strip the nodes from the objects in pStripObjects we don't want
   repeat for each line stripObject in pStripObjects
      -- take care that the object name is fromatted correctly
      if exists(stripObject) is false then
         put merge ("Cannot find [[stripObject]]!") into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      -- lets get rid of any calls to the objects we are stripping
      -- hkeyArray_RemoveObjectLinks hkeyArray, stripObject
      hkey_SimpleStripObject allCalls, stripObject
      line_Add the result, strippedKeys
   end repeat
   
   put strippedKeys into depArray ["strippedKeys"]
   put depArray ["depSuite"] into depSuite
   
   -- put script_ConstructDependencySuite (allCalls) into depSuite
   return depArray
end hkeyArray_ConstructDependencySuite

function hkey_ConstructDepArray allCalls, pMakePrivate
   local depScript, missingHkeys
   
   sort allCalls
   hkey_StripDuplicates allCalls
   put the result into duplicateHkeyArray
   
   script_FetchFromHkeys allCalls, depScript, missingHkeys, pMakePrivate
   put script_ConstructSuite ("Deps", depScript) into depSuite
   put depSuite into depArray ["depSuite"]
   
   put allCalls into depArray ["uniqueHkeys"]
   put missingHkeys into depArray ["missingHkeys"]
   put duplicateHkeyArray into depArray ["duplicateHkeyArray"]
   return depArray
end hkey_ConstructDepArray
