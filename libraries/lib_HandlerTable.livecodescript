script "lib_HandlerTable"
--> MetaData
-
license: GPLv3
name: lib_HandlerTable
type: library
version: 0.3

/*
These handdlers manipulate the hTable format returned by the native revAvailableHandlers property of LiveCode.
In general the handlers loop through the table looking for matches.
We distingusish between the following forms of search:
- Exact matches ("Exact")
- Match either provate handlers of public handlers ("Either")
-Flexibly match nadlers the same way Livecode calls them - ie don't distinguish "on" and "command" ("Flexible")

The "Flexible" handlers are not fully tested, and the logic might be not quite right.
*/


--> Props
-
getprop short_Hkeys [hFilter]
   put the revAvailableHandlers of the target into hTable
   put hTable_ListShortHkeys (hTable, hFilter) into shortHkeys
   return shortHkeys
end short_Hkeys

getprop handler_Names [hFilter]
   put the revAvailableHandlers of the target into hTable
   put hTable_ListHanderNames (hTable, hFilter) into hNames
   return hNames
end handler_Names

getprop handler_From [hKeyOrNumber]
   put the revAvailableHandlers of the target into hTable
   --
   if hKeyOrNumber is a number then
      put hTable_GetHandler (hTable, hKeyOrNumber) into someHandler
   else
      put word 5 to -1 of line 1 of hTable into scriptObject
      --
      put hKeyLine_AddObject (hKeyOrNumber, scriptObject) into hKey
      htable_ExactLineOffsets hKey, hTable, startLineNum, endLineNum
      if the result is false then return empty
      
      put the script of scriptObject into someScript
      put line startLineNum to endLineNum of someScript into someHandler
   end if
   return someHandler
end handler_From


--> Working on
-
function hTable_GetHandler hTable, lineNum, pSomeScript
   hTable_SetHandlerOffsets hTable, lineNum, startLineNum, endLineNum, scriptObject
   if the result is false then return empty
   --
   if pSomeScript is empty then put the script of scriptObject into pSomeScript
   --
   put line startLineNum to endLineNum of pSomeScript into someHandler
   return someHandler
end hTable_GetHandler

command hTable_SetHandlerOffsets hTable, lineNum, @startLineNum, @endLineNum, @scriptObject
   -- given a lineNum within a handler return the handler lineNum offset
   put word 5 to -1 of line 1 of hTable into scriptObject
   put 0 into startLineNum
   put 0 into endLineNum
   --
   sort numeric lines of hTable by word 3 of each
   repeat for each line hTableLine in hTable
      put word 3 of hTableLine into startLineNum
      if startLineNum >= lineNum then
         put word 4 of hTableLine into endLineNum
         return true
      end if
   end repeat
   return false
end hTable_SetHandlerOffsets


--> hTable | List
-
function hTable_ListHanderNames hTable, hFilter
   if hFilter is not empty then filter hTable with hFilter
   repeat for each line someLine in hTable
      put word 2 of someLine & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end hTable_ListHanderNames

function hTable_ListShortHkeys hTable, hFilter
   if hFilter is not empty then filter hTable with hFilter
   repeat for each line someLine in hTable
      put word 1 to 2 of someLine & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end hTable_ListShortHkeys


--> hTable
-
function hTable_GetHkeys hTable, hObject
   put revRuggedID (hObject) into hObject
   repeat for each line someLine in hTable
      put word 1 of someLine into hType
      put word 2 of someLine into hName
      put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   return hkeyLines
end hTable_GetHkeys

function hTable_GetShortHkeys hTable
   sort numeric lines of hTable by word 3 of each
   repeat for each line someLine in hTable
      put word 1 to 2 of someLine into hTableLine
      put hTableLine & CR after hTableLines
   end repeat
   delete char -1 of hTableLines
   return hTableLines
end hTable_GetShortHkeys

function hTable_GetHandlerNames hTable, pNotPrivate
   if pNotPrivate is true then
      filter hTable without "P*"
   end if
   sort numeric lines of hTable by word 3 of each
   repeat for each line someLine in hTable
      put word 2 of someLine into hName
      put hName & CR after hNames
   end repeat
   delete char -1 of hNames
   return hNames
end hTable_GetHandlerNames


--> hTable | Flexible
-
function hTable_GetFlexible searchHkeyLine, hTable, tObject, pMatchPrivate
   hTable_FlexibleLineOffsets searchHkeyLine, hTable, startLineNum, endLineNum, pMatchPrivate
   if the result is false then return empty
   
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end hTable_GetFlexible

command hTable_FlexibleLineOffsets shortHkey, hTable, @startLineNum, @endLineNum, pMatchPrivate
   hkey_Normalize shortHkey
   
   -- this should get offsets for a call as a script would
   -- so it ignores the difference betweeen "on" and "command"
   --
   if hTable is empty then
      put 0 into startLineNum
      put 0 into endLineNum
      return false
   end if
   --
   put word 1 of shortHkey into hType
   put word 2 of shortHkey into hName
   --
   repeat for each line hLine in hTable      
      put word 2 of hLine into hTableName
      if hTableName is not hName then next repeat
      --
      put word 1 of hLine into hTableType
      switch
         case hTableType = hType
            -- matches same type
         case pMatchPrivate is true and char -1 of hTableType = hType
            --if private matches private same type
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end hTable_FlexibleLineOffsets


--> hTable | Public or Private
-
function htable_GetExact searchHkeyLine, hTable, tObject
   -- searches hTable for the hType and hName in searchHkeyLine (searchHkeyLine = "PF _GetSomething .....")
   -- as fast as possible
   
   htable_ExactLineOffsets searchHkeyLine, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetExact

command htable_ExactLineOffsets searchHkeyLine, hTable, @startLineNum, @endLineNum
   hkey_Normalize searchHkeyLine
   -- searches hTable for the hType and hName in searchHkeyLine (as fast as possible)
   put word 1 to 2 of searchHkeyLine into shortHkeyLine
   repeat for each line hLine in hTable
      if word 1 to 2 of hLine = shortHkeyLine then
         put word 3 of hLine into startLineNum
         put word 4 of hLine into endLineNum
         return true
      end if
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_ExactLineOffsets


--> hTable | Public or Private
-
function htable_GetEither searchHkeyLine, hTable, tObject
   -- searches hTable for the hType and hName in searchHkeyLine
   -- as fast as possible
   htable_EitherLineOffsets searchHkeyLine, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetEither

command htable_EitherLineOffsets searchHkeyLine, hTable, @startLineNum, @endLineNum
   hkey_Normalize searchHkeyLine
   -- as fast as possible
   -- searches hTable for the hType and hName in searchHkeyLine
   -- matches either private of public handlers
   put char -1 of word 1 of searchHkeyLine into publicType
   
   put word 2 of searchHkeyLine into hName
   repeat for each line hLine in hTable
      put char -1 of word 1 of hLine into foundPublicType
      if word 2 of hLine = hName and publicType = foundPublicType then
         put word 3 of hLine into startLineNum
         put word 4 of hLine into endLineNum
         return true
      end if
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_EitherLineOffsets
