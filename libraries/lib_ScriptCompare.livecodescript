script "lib_ScriptCompare"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ScriptCompare
type: library
version: 0.1

/*
This is a new library to compare two scripts.

In particular we wish to seek and remove duplicates, but also find handlers in common.
*/


--> Working on
-
function hkey_FunctionalArray hKeys, pUseShort
   local fArray
   if hKeys is an array then
      -- unique and fast
      repeat for each key hKey in hKeys
         put hKey_Functional (hKey, pUseShort) into fKey
         put empty into fArray [fKey]
      end repeat
   else
      repeat for each line hKey in hKeys
         put hKey_Functional (hKey, pUseShort) into fKey
         put empty into fArray [fKey]
      end repeat
   end if
   return fArray
end hkey_FunctionalArray
   
function hKey_Functional hKey, pUseShort
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put hKey_functionalType (hType) into fType
   put fType into word 1 of hKey
   if pUseShort is true then
      return word 1 to 2 of hKey
   else
      return hKey
   end if
end hKey_Functional

function hKey_FunctionalType hType
   switch
      case hType is among the items of "M,C"
         put "c" into fType
         break
         -- case char 1 of hType is "P"
      default
         put hType into fType
   end switch
   return fType
end hKey_FunctionalType

function script_CompareArray leftObject, rightObject
   
end script_CompareArray

function hkeyIndex_EventArrayKeys hKeys
   if hKeys is an array then
      filter keys of hKeys with pattern "M *"
      return hKeys
   else
      filter hKeys with pattern "M *"
      repeat for each line hKey in hKeys
         put empty into eventKeys [hKey]
      end repeat
      return eventKeys
   end if
end hkeyIndex_EventArrayKeys

function hkey_ConstructCompareArray leftKeys, rightKeys
   local leftKeyArray, rightKeyArray, commonArray, bothArray, uLeftArray, uRightArray
   --
   put hkeyIndex_EventArrayKeys (leftKeys) into compareArray ["leftEvents"]
   put hkeyIndex_EventArrayKeys( rightKeys) into compareArray ["rightEvents"]
   
   put hkey_FunctionalArray (leftKeys, true) into leftKeyArray
   put hkey_FunctionalArray (rightKeys, true) into rightKeyArray
   
   union leftKeyArray with rightKeyArray into bothArray
   intersect leftKeyArray with rightKeyArray into commonArray
   difference leftKeyArray with commonArray into uLeftArray
   difference rightKeyArray with commonArray into uRightArray
   
   put leftKeyArray into compareArray ["left"]
   put rightKeyArray into compareArray ["right"]
   --
   put commonArray into compareArray ["common"]
   put bothArray into compareArray ["both"]
   put commonArray into compareArray ["common"]
   put uLeftArray into compareArray ["onlyLeft"]
   put uRightArray into compareArray ["onlyRight"]
   --
   return compareArray   
end hkey_ConstructCompareArray

function handler_StemIndex handlerIndex
   if handlerIndex is empty then put handler_GetIndex() into handlerIndex
   filter handlerIndex with "*_*"
   
   -- this is case sensitive (so get  keys applescript and appleScript)!
   split handlerIndex with CR and "_"
   put keys(handlerIndex) into stemIndex
   put index_SetUnique(stemIndex) into stemIndex
   
   sort stemIndex
   return word 1 to -1 of stemIndex
end handler_StemIndex


--> Script | Compare
-


--> Deps
-
