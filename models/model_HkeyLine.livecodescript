﻿script "model_HkeyLine"
--> MetaData
-
license: GPLv3
name: model_HkeyLine
type: model
version: 0.2

/*
-- M hkeyLine_Deconstruct of stack "lib_ScriptArray"

This is the new version of the hKey syntax which does not use comma's.
It is also more readable (at the cost of inserting "of' at word 3).

Here we start to collect handlers specifically created for this format, 
and work-in-progress transitional handlers.

See also lib_FindHkey
*/


--> Working on
-

--> Props
-
getprop hkey_Line [hKey]
   put the revAvailableHandlers of the target into hTable
   hkey_Normalize hKey
   put the result into shortHkey
   repeat for each line hTableLine in hTable
      if word 1 to 2 of hTableLine = word 1 to 2 of shortHkey then
         return hTableLine
      end if
   end repeat
   return empty
end hkey_Line

getprop hkey_Lines
   -- latest version of hKeys
   -- see "script_Hkeys" and "script_FirstHkeys"
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put hTable_GetHkeys (hTable, hObject) into hkeyLines
   return hkeyLines
end hkey_Lines

getprop hkey_LineNums [shortHkey]
   put the long id of the target into hObject
   hkeyLine_Offsets hObject, shortHkey, sLineNum, eLineNum
   if the result is empty then return empty
   --
   return sLineNum,eLineNum
end hkey_LineNums


--> Hkey | Do both
-
command hkey_Normalize @hKey
   -- same as old "hkeyLine_Normalize"
   put hkeyLine_FromHkey (hKey) into hKey
   put word 1 to 2 of hKey into shortHkey
   return shortHkey
end hkey_Normalize

function hkey_Construct hName, hType, tObject
   if exists (tObject) is false then
      put "Missing" into hObject
   end if
   replace "C" with "M" in hType
   put hKeyLine_Construct (hName, hType, tObject) into hKeyLine
   return hKeyLine
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   -- will deconstruct both
   -- move over to hkeyLine_Deconstruct
   
   if the number of items of hkey = 1 then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put 1 into hNum
   else
      -- old version
      put word 1 to -1 of item 1 of hKey into hName
      put word 1 to -1 of item 2 of hKey into hType
      if hType is empty then put "c" into hType
      put word 1 to -1 of item 3 of hKey into hObject
      put item 4 of hKey into hNum
      if hNum is empty then put 1 into hNum
   end if
   
   put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct

function hkey_FromShort shortHkeys, hObject
   repeat for each line shortHkey in shortHkeys
      put hKeyLine_AddObject (shortHkey, hObject) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   return hkeyLines
end hkey_FromShort


--> hKeyLine
-
command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

function hkeyLine_FromHkey hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put toUpper(hType) into hType
   put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHkey

function hkeyLine_ToHkey hKeyLine
   -- was "hkey_TableLineToShort"
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   return hName,hType,hObject,1
end hkeyLine_ToHkey

command hkeyLine_DeconstructStart handlerLine, @hName, @hType, @privateBit
   if token 1 of handlerLine = "private" then
      put "p" into privateBit
      put token 3 of handlerLine into hName
   else
      put empty into privateBit
      put token 2 of handlerLine into hName
   end if
   put handler_GetType (handlerLine) into hType
end hkeyLine_DeconstructStart


--> hKeyLine
-
command hkeyLine_Offsets hObject, shortHkey, @sLineNum, @eLineNum
   -- uses revAvailableHandleers
   put the hkey_Line [shortHkey] of hObject into hTableLine
   if hTableLine is empty then return empty
   --
   put word 2 of hTableLine into hName
   put word 3 of hTableLine + 1 into sLineNum
   put word 4 of hTableLine + 1 into eLineNum
   return hName
end hkeyLine_Offsets

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hkeyLine_ScriptLineToType scriptLine
   put word 1 of scriptLine into onWord
   switch onWord
      case "private"
         put word 2 of scriptLine into onWord
         put _ScriptLineToType (onWord) into hType
         return "P" & hType
      default
         put _ScriptLineToType (onWord) into hType
         return hType
   end switch
end hkeyLine_ScriptLineToType


--> Private
-
private function _ScriptLineToType onWord
   switch onWord
      case "after"
         return "A"
      case "before"
         return "N"
         break
      case "function"
         return "F"
      case "on"
      case "command"
         return "M"
      case "getprop"
         return "G"
      case "setprop"
         return "S"
      default
         return empty
   end switch
end _ScriptLineToType
