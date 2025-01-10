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

--> Working on
-
getprop handlerLine_Index [hFilter]
   put the revAvailableHandlers of the target into hTable
   sort numeric lines of hTable by word 3 of each
   if hFilter is not empty then filter hTable with hFilter
   --
   repeat for each line someLine in hTable
      put hkeyLine_ToHandlerLine (someLine) & CR after hLines
   end repeat
   delete char -1 of hLines
   return hLines
end handlerLine_Index

getprop handlerLine_Bullets [hFilter]
   put the revAvailableHandlers of the target into hTable
   sort numeric lines of hTable by word 3 of each
   if hFilter is not empty then filter hTable with hFilter
   --
   repeat for each line someLine in hTable
      -- put word 1 to 2 of someLine into shortHkey
      put hkeyLine_ToHandlerLine (someLine) into handlerLine
      put "- [[" & handlerLine & "]]" & CR after handlerLineBullets
   end repeat
   delete char -1 of handlerLineBullets
   return handlerLineBullets
end handlerLine_Bullets

function hkeyLine_ToHandlerLine hkeyLine
   put word 1 of hkeyLine into hkeyBit
   put word 2 of hkeyLine into hName
   --
   if char 1 of hkeyBit = "P" then
      put "private" & space into handlerLine
      delete char 1 of hkeyBit
   else
      put empty into handlerLine
   end if
   
   switch hkeyBit
      case "A"
         put "after" after handlerLine
         break
      case "N"
         put "before" after handlerLine
         break
      case "F"
         put "function" after handlerLine
         break
      case "M"
         put "on" after handlerLine
         break
      case "C"
         put "command" after handlerLine
         break
      case "G"
         put "getprop" after handlerLine
         break
      case "S"
         put "setprop" after handlerLine
         break
      default
         return empty
   end switch
   
   put space & hName after handlerLine
   return handlerLine
end hkeyLine_ToHandlerLine


--> Props
-
getprop short_Hkeys [hFilter]
   put the revAvailableHandlers of the target into hTable
   put hTable_ListShortHkeys (hTable, hFilter) into shortHkeys
   return shortHkeys
end short_Hkeys

getprop hkey_Either [shortHkey]
   -- returns public or private hkey in tObject
   put the revAvailableHandlers of the target into hTable
   put hTable_GetEither (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Either

getprop hkey_Or [shortHkey]
   put the revAvailableHandlers of the target into hTable
   put htable_GetOr (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Or

getprop hkey_Exact [shortHkey]
   -- this finds exactly what you specifiy in shortHkey
   put the revAvailableHandlers of the target into hTable
   put htable_GetExact (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Exact


--> Working on
-
function hTable_GetHandler hkeyLine, hTable, pSomeScript
   if pSomeScript is empty then
      put word 5 to -1 of line 1 of hTable into scriptObject
      if exists (scriptObject) is false then return "Error, cannot find object in hTable:" && scriptObject
      put the script of scriptObject into pSomeScript
   end if
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   
   # Line numbers
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   -- htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   if endLineNum = 0 then return empty
   
   # Handler
   put line startLineNum to endLineNum of pSomeScript into foundHandler
   return foundHandler
end hTable_GetHandler

function hTable_HandlerFromLineNum hTable, lineNum, pSomeScript
   hTable_SetHandlerOffsets hTable, lineNum, startLineNum, endLineNum, scriptObject
   if the result is false then return empty
   if pSomeScript is empty then put the script of scriptObject into pSomeScript
   --
   put line startLineNum to endLineNum of pSomeScript into someHandler
   return someHandler
end hTable_HandlerFromLineNum

command hTable_SetHandlerOffsets hTable, lineNum, @startLineNum, @endLineNum, @scriptObject
   -- Given a lineNum within a handler return the handler lineNum offset
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


--> hTable | Public or Private
-
function htable_GetExact searchHkeyLine, hTable
   -- searches hTable for the hType and hName in searchHkeyLine (searchHkeyLine = "PF _GetSomething .....")
   -- as fast as possible
   
   htable_ExactLineOffsets searchHkeyLine, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 5 to -1 of line 1 of hTable into tObject
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetExact

command htable_ExactLineOffsets searchHkeyLine, hTable, @startLineNum, @endLineNum
   -- hkey_Normalize searchHkeyLine
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

function htable_GetOr searchHkeyLine, hTable
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   --
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 5 to -1 of line 1 of hTable into tObject
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetOr

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets


--> hTable | Public or Private
-
function htable_GetEither searchHkeyLine, hTable
   -- matches either private of public handlers
   -- returns just the foundHkey (we dont need line numbers)
   put char -1 of word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into searchName
   
   repeat for each line hLine in hTable
      put word 2 of hLine into foundName
      put word 1 of hLine into foundPublicType
      if foundName is not searchName then next repeat
      
      put char -1 of foundPublicType into fType
      switch
         case hType = fType
         case (hType = "C") AND (fType = "M")
         case (hType = "M") AND (fType = "C")
            put word 5 to -1 of line 1 of hTable into hObject
            put hKeyLine_Construct (foundName, foundPublicType, hObject) into foundHkey
            return foundHkey
      end switch
   end repeat
   return empty
end htable_GetEither

command htable_EitherLineOffsets searchHkeyLine, hTable, @startLineNum, @endLineNum
   -- matches either private of public handlers
   put char -1 of word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into searchName
   
   repeat for each line hLine in hTable
      put word 2 of hLine into foundName
      put word 1 of hLine into foundPublicType
      if foundName is not searchName then next repeat
      
      put char -1 of foundPublicType into fType
      switch
         case hType = fType
         case (hType = "C") AND (fType = "M")
         case (hType = "M") AND (fType = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            --
            return hLine
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return empty
end htable_EitherLineOffsets

-- command htable_EitherLineOffsets searchHkeyLine, hTable, @startLineNum, @endLineNum
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
   -- same as GetEither? Not needed?
   -- this should get offsets for a call as a script would
   -- so it ignores the difference betweeen "on" and "command"
   hkey_Normalize shortHkey
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
            -- if private matches private same type
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end hTable_FlexibleLineOffsets
