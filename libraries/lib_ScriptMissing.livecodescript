script "lib_ScriptMissing"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ScriptMissing
type: library
version: 0.1

/*Some help*/


--> Working on
-
command scriptMissing_FindAndUpdate @objectDepArray, searchObjects
   put objectDepArray ["Missing"] into missingArray
   delete variable objectDepArray ["Missing"]
   --
   put scriptMissing_FindFromMissingArray (missingArray, searchObjects) into foundMissingObjectDepArray
   union objectDepArray with foundMissingObjectDepArray recursively
   --
   return foundMissingObjectDepArray
end scriptMissing_FindAndUpdate

function scriptMissing_FindFromMissingArray missingArray, searchObjects
   put the keys of missingArray into missingShortHkeys
   replace " of Missing" with empty in missingShortHkeys
   --
   put scriptMissing_FindObjectDepArray (missingShortHkeys, searchObjects) into foundMissingObjectDepArray
   --
   return foundMissingObjectDepArray
end scriptMissing_FindFromMissingArray

function scriptMissing_FindObjectDepArray missingShortHkeys, searchObjects 
   -- _FilterRevigniter missingShortHkeys
   -- put the result into missingRigHkeys
   
   -- lets find all the missingHkeys
   repeat for each line missingShortHkey in missingShortHkeys
      if char 1 to 3 of word 2 of missingShortHkey = "rig" then
         put empty into foundMissingHkeyArray ["revIgniter"][missingShortHkey]
         next repeat
      end if
      
      -- put hkey_PublicFind (missingShortHkey, searchObjects) into foundMissingHkey
      put hkey_FindPublicOrPrivate (missingShortHkey, searchObjects) into foundMissingHkey
      -- comment
      switch
         case foundMissingHkey is empty
            put "Still Missing" into cantFindArray [missingShortHkey]
            break
         default
            put empty into foundMissingHkeyObjectArray ["found"][foundMissingHkey]
      end switch
   end repeat
   put the keys of foundMissingHkeyObjectArray ["found"] into foundMissingHkeys
   
   -- now lets recursively find the dependencies of each of the foundHkeys
   put hkey_SearchHierarchyDependencyArray (foundMissingHkeys, searchObjects, true) into stillMissingHKeyArray
   put hkeyArray_GetStackDepArray (stillMissingHKeyArray) into stillMissingObjectDepArray 
   --
   put stillMissingObjectDepArray ["Missing"] into foundStillMissingHkeyArray
   union foundStillMissingHkeyArray with cantFindArray
   put the keys of foundStillMissingHkeyArray into foundStillMissingHkeys
   --
   _FilterRevigniter foundStillMissingHkeys
   put the result into stillMissingRigHkeys
   --
   -- split missingRigHkeys by CR as set
   put foundMissingHkeyArray ["revIgniter"] into missingRigHkeys
   split stillMissingRigHkeys by CR as set
   union missingRigHkeys with stillMissingRigHkeys
   --
   if the keys of missingRigHkeys is not empty then
      put missingRigHkeys into stillMissingObjectDepArray ["revIgniter"]
   end if
   --
   if foundStillMissingHkeys is not empty then
      split foundStillMissingHkeys by CR as set
      put foundStillMissingHkeys into stillMissingObjectDepArray ["Missing"]
   end if
   --
   return stillMissingObjectDepArray
end scriptMissing_FindObjectDepArray


--> Script | Missing
-
function scriptMissing_ListHkeys sObject
   scriptMissing_CollectCalls sObject, callObjectArray, missingArray, revIgniterArray
   put keys (missingArray) into mKeys
   repeat for each line mKey in mKeys
      put word 1 to 2 of mKey into shortMissing
      put shortMissing & CR after missingHkeys
   end repeat
   delete char -1 of missingHkeys
   return missingHkeys
end scriptMissing_ListHkeys

command scriptMissing_CollectCalls sObject, @callObjectArray, @missingArray, @revIgniterArray
   put the rig_ControllerHkeys of sObject into hKeys
   repeat for each line hKey in hKeys
      put hkey_GetLinkArray (hKey) into hkeyLinkArray
      hkeyArray_SetObjectArray callObjectArray, hkeyLinkArray
   end repeat
   
   put revRuggedID (sObject) into sObject
   delete variable callObjectArray [sObject]
   put callObjectArray ["Missing"] into missingArray
   delete variable callObjectArray ["Missing"]
   put callObjectArray ["revIgniter"] into revIgniterArray
   delete variable callObjectArray ["revIgniter"]
   put keys (callObjectArray) into depStacks
   return depStacks
end scriptMissing_CollectCalls


--> Private
-
private command _FilterRevigniter @stillMissingHkeys
   put stillMissingHkeys into revIgniterHkeys
   filter revIgniterHkeys with "* rig*"
   filter stillMissingHkeys without "* rig*"
   return revIgniterHkeys
end _FilterRevigniter
