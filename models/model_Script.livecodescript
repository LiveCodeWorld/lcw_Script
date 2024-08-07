﻿script "model_Script"
--> MetaData
-
license: GPLv3
name: model_Script
type: model
version: 0.3

/*
Handlers that work on the scripts of objects
*/


--> Working on
-
getprop script_HandlerNames [pNotPrivate]
   put the revAvailableHandlers of the target into handlerTable
   switch pNotPrivate
      case true
      case false
      case empty
         put hTable_GetHandlerNames (handlerTable, pNotPrivate) into hNames
         break
      default
         put toUpper (char 1 of pNotPrivate) && "*" into someFilter
         filter handlerTable with someFilter
         put hTable_GetHandlerNames (handlerTable, true) into hNames
   end switch
   return hNames
end script_HandlerNames

getprop script_CommandLines
   put the script_HandlerNames ["M"] of the target into cNames
   -- put the long id of the target into scriptObject
   -- put the script of scriptObject into someScript
   -- put script_ExtractCommandLines (someScript, scriptObject) into cNames
   return cNames
end script_CommandLines

getprop script_CommandHandlers
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractCommandHandlers (someScript, scriptObject)
end script_CommandHandlers

getprop script_FunctionHandlers
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractFunctionHandlers (someScript, scriptObject)
end script_FunctionHandlers

command script_StripPropHandlers @someScript, hTable
   sort descending numeric lines of hTable by word 3 of each
   repeat for each line hTableLine in hTable
      if word 1 of hTableLine is among the items of "G,S" then
         put word 1 to 2 of hTableLine into shortHkey
         script_DeleteHandler someScript, shortHkey, hTable
      end if
   end repeat
end script_StripPropHandlers


--> Script | Handler | More
-
getprop script_Hkeys [fetchHow]
   switch fetchHow
      case "short"
         return the script_ShortHKeys of the target
      case "hArray"
         return the hArray_Hkeys of the target
      case "script"
         return the script_ArrayHkeys of the target
      case "all"
         return the script_FirstHkeys of the target
      default
         try
            put the long id of the target into tObject
            put the revAvailableHandlers of tObject into handlerTable
            return hTable_GetHkeys (handlerTable,  tObject) 
         catch someError
            return empty -- a locked stack
         end try
   end switch
end script_Hkeys

getprop script_ShortHKeys
   -- this is the new version of shortHekys
   -- should be able to use "the revAvailableHandlers" instead
   -- as scripts should be able to handle processing raw revAvailableHandlers table without removing the line info
   -- simply by taking word 1 to 2 of item 1....
   try
      put the long id of the target into tObject
      put the revAvailableHandlers of tObject into handlerTable
      return hTable_GetShortHkeys (handlerTable) 
   catch someError
      return empty -- a locked stack
   end try
end script_ShortHKeys

getprop script_FirstHkeys [returnShort]
   -- revAvailableHandlers only return first handler.
   try
      put the long id of the target into tObject
      put revRuggedID (tObject) into tObject
      put the revAvailableHandlers of tObject into handlerTable
      repeat for each line someLine in handlerTable
         put word 1 of someLine into hTableType
         replace "M" with "c" in hTableType
         put tolower (hTableType) into hType
         
         put word 2 of someLine into hName
         if returnShort is true then
            put hName,hType & CR after hKeys
         else
            put hName,hType,tObject,1 & CR after hKeys
         end if
      end repeat
      delete char -1 of hKeys
      return hKeys
   catch someError
      return empty -- a locked stack
   end try
end script_FirstHkeys

getprop script_MessageHandlers
   return the script_Events of the target
end script_MessageHandlers

getprop script_Events
   put the long id of the target into scriptObject
   put the script_AndBehavior of scriptObject into someScript
   put script_ExtractMessageHandlers (someScript, scriptObject) into scriptEvents
   return scriptEvents
end script_Events

getprop script_SetProp [handlerName]
   put the script of the target into someScript
   -- return script_ExtractSetPropHandlers(someScript)
   put script_GetSetProp (handlerName, someScript) into someHandlers
   return someHandlers
end script_SetProp

getprop script_GetProp [handlerName]
   put the script of the target into someScript
   put script_GetGetProp (handlerName, someScript) into someHandler
   -- return script_ExtractGetPropHandlers (someScript, scriptObject)
   return someHandler
end script_GetProp

getprop script_Command [cName]
   put the script of the target into someScript
   put script_GetCommand(cName, someScript) into commandHandler
   return commandHandler
end script_Command

getprop script_Function [fName]
   put the script of the target into someScript
   return script_GetFunction (fName, someScript)
end script_Function


--> Script | Handler | Offsets 
-
function script_ExtractHandler hKey, pSomeScript, pNotPrivate
   -- this version uses offsets to find the handler not an hArray index
   local startHandler, endHandler
   if pSomeScript is empty then
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      if exists(scriptObject) is false then return empty
      put the script of scriptObject into pSomeScript
   end if
   hkey_SetOffsets hKey, startHandler, endHandler, pSomeScript, pNotPrivate
   put the result into someHandler
   return someHandler
end script_ExtractHandler


--> Script | Handler
-
/*
These handers process scripts without hTable
instead they use regular expressions like "(?mi)^(private +" & onWord & " +" & handlerName & ")\W"
*/

function script_GetFunction fName, someScript, pNotPrivate
   local startHandler, endHandler
   if pNotPrivate is not true then
      script_SetPrivateHandlerOffsets startHandler, endHandler, fName, "function", someScript
      put the result into someHandler
      if someHandler is not empty then return someHandler
   end if
   
   script_SetHandlerOffsets startHandler, endHandler, fName, "function", someScript
   put the result into someHandler
   return someHandler
end script_GetFunction

function script_GetCommand cName, someScript, pNotPrivate
   local startHandler, endHandler
   if pNotPrivate is not true then
      script_SetPrivateHandlerOffsets startHandler, endHandler, cName, "on", someScript
      put the result into someHandler
      if someHandler is not empty then return someHandler
   end if
   
   script_SetHandlerOffsets startHandler, endHandler, cName, "on", someScript
   put the result into someHandler
   return someHandler
end script_GetCommand

function script_GetGetProp propName, someScript
   local startHandler, endHandler
   script_SetHandlerOffsets startHandler, endHandler, propName, "getprop", someScript
   put the result into someHandler
   return someHandler
end script_GetGetProp

function script_GetSetProp propName, someScript
   local startHandler, endHandler
   script_SetHandlerOffsets startHandler, endHandler, propName, "setprop", someScript
   put the result into someHandler
   return someHandler
end script_GetSetProp

function script_ExtractHandler handlerName, onWord, someScript, notPrivate
   -- picks the public handler first (should really pick the first in the hierarchy)
   put script_ExtractPublicHandler (handlerName, onWord, someScript) into foundHandler
   if foundHandler is not empty then
      return foundHandler
   else if notPrivate is not true then
      put script_ExtractPrivateHandler (handlerName, onWord, someScript) into foundHandler
      return foundHandler
   end if
   return empty
end script_ExtractHandler

function script_ExtractPublicHandler handlerName, onWord, someScript
   script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
   put the result into foundHandler
   return foundHandler
end script_ExtractPublicHandler

function script_ExtractPrivateHandler handlerName, onWord, someScript
   script_SetPrivateHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
   put the result into foundHandler
   return foundHandler
end script_ExtractPrivateHandler

command script_SetHandlerOffsets @startHandler, @endHandler, handlerName, onWord, someScript
   local startH, endHandlerName, startEndHandlerLine, endH
   
   -- this will fail if the end has a space before it (can happen)
   -- put "(?mi)^(" & onWord & " +" & handlerName & ")\W" after regExp
   
   -- lets not distinguish between "command" and "on" as they are functinally equivalent
   if onword is among the items of "command,on" then put "(command|on)" into onWord
   
   put word 1 of handlerName into handlerName
   text_EscapeRegularExpression handlerName
   put "(?mi)^\s*(" & onWord & " +" & handlerName & ")\W" after regExp
   
   put CR & someScript & CR into someScript
   if matchchunk (someScript, regExp, startHandler, endHandlerName, startEnd, endEnd) is true then
      put script_MatchEnd (handlerName, startHandler, someScript) into endHandler
      if endHandler is empty then
         put 0 into startHandler
         put 0 into endHandler
         return empty
      else
         -- because of CR insertion around someScript
         put char startHandler to endHandler of someScript into someHandler
         subtract 1 from startHandler
         subtract 1 from endHandler
         return someHandler
      end if
   else
      put 0 into startHandler
      put 0 into endHandler
      return empty
   end if
end script_SetHandlerOffsets

command script_SetPrivateHandlerOffsets @startHandler, @endHandler, handlerName, onWord, someScript
   local startH, endHandlerName, startEndHandlerLine, endH
   
   put word 1 of handlerName into handlerName
   text_EscapeRegularExpression handlerName  
   
   if onword is among the items of "command,on" then put "(command|on)" into onWord
   put "(?mi)^(private +" & onWord & " +" & handlerName & ")\W" into regExp
   
   put CR & someScript & CR into someScript
   if matchchunk (someScript, regExp, startHandler, endHandlerName, startEnd, endEnd) is true then
      put script_MatchEnd (handlerName, startHandler, someScript) into endHandler
      if endHandler is empty then
         put 0 into startHandler
         put 0 into endHandler
         return empty
      else
         -- because of CR insertion around someScript
         put char startHandler to endHandler of someScript into someHandler
         subtract 1 from startHandler
         subtract 1 from endHandler
         return someHandler
      end if
   else
      put 0 into startHandler
      put 0 into endHandler
      return empty
   end if
end script_SetPrivateHandlerOffsets


--> Private
-
private function _ScriptHandlersStart hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   switch hType
      case "a"
         put "after" into handlerStartLine
         break
      case "b"
         put "before" into handlerStartLine
         break
      case "m"
      case "c"
         put "command" into handlerStartLine
         break
      case "pc"
         put "private command" into handlerStartLine
         break
      case "f"
         put "function" into handlerStartLine
         break
      case "pf"
         put "private function" into handlerStartLine
         break
      case "g"
         put "getprop" into handlerStartLine
         break
      case "s"
         put "setprop" into handlerStartLine
         break
   end switch
   put space & hName after handlerStartLine
   return handlerStartLine
end _ScriptHandlersStart

private function script_MatchEnd handlerName, startHandler, someScript
   put CR after someScript -- in case handler is at end
   put "(?mi)^\s*(" & "end" & " +" & handlerName & ")\W" into regExp
   
   -- this will fail if the end has a space before it (can happen)
   -- put "(?mi)^(" & "end" & " +" & handlerName & ")\W" into regExp
   
   delete char 1 to startHandler of someScript
   if matchchunk(someScript, regExp, startEndHandlerLine, endH) is true then
      put startHandler + endH - 0 into endHandler
      return endHandler
   else
      return empty
   end if
end script_MatchEnd

command hkey_SetOffsets hKey, @startHandler, @endHandler, pScript, notPrivate
   -- much better in general to use the revAvailableHandlers of pObject
   -- see "handler_Get"
   
   -- get offsets to first found handler only
   put 0 into startHandler
   put 0 into endHandler
   hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
   
   if pScript is empty then
      if exists(scriptObject) is false then return empty
      put the script of scriptObject into pScript
   end if
   
   if char 1 of handlerType = "p" then
      if notPrivate is true then return empty
      delete char 1 of handlerType
      put handler_ConvertType (handlerType) into onWord
      script_SetPrivateHandlerOffsets startHandler, endHandler, handlerName, onWord, pScript
   else
      put handler_ConvertType (handlerType) into onWord
      script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, pScript
   end if   
   put the result into foundHandler
   return foundHandler
end hkey_SetOffsets

command text_EscapeRegularExpression @someString
   put "\" & tab & quote & "[]|*.?()" into specialChars
   repeat for each char specialChar in specialChars
      replace specialChar with "\" & specialChar in someString
   end repeat
end text_EscapeRegularExpression
