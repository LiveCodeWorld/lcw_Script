script "model_Script"
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

--> Script | Handler | Model
-
/*
These handlers extract handlers from an objects script.
For handlers that work on exported handlers see "model_HandlerLibrary"
*/

getprop script_Handler [shortHKey]
   if shortHKey is empty then return empty
   hkey_Normalize shortHKey
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put the script of hObject into someScript
   
   put hkeyLine_GetHandlers (shortHKey, hTable, someScript) into someHandlers
   return someHandlers
end script_Handler

setprop script_Handler [shortHKey] someHandler
   if shortHKey is empty then return empty
   hkey_Normalize shortHKey
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put the script of hObject into someScript
   
   if someHandler is empty then
      script_DeleteHandler someScript, shortHKey, hTable
   else
      htable_ExactLineOffsets shortHKey, hTable, startLineNum, endLineNum
      put someHandler into line startLineNum to endLineNum of someScript
   end if
   set the script of hObject to someScript
   return someScript
end script_Handler

command script_StripPropHandlers @someScript, hTable
   sort descending numeric lines of hTable by word 3 of each
   repeat for each line hTableLine in hTable
      if word 1 of hTableLine is among the items of "G,S" then
         put word 1 to 2 of hTableLine into shortHkey
         script_DeleteHandler someScript, shortHkey, hTable
      end if
   end repeat
end script_StripPropHandlers

command script_DeleteHandler @someScript, hkeyLine, hTable
   htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   put endLineNum + 1 into afterEndLineNum
   put word 1 to -1 of line afterEndLineNum of someScript into lineAfterEnd
   if lineAfterEnd is empty then add 1 to endLineNum
   delete line startLineNum to endLineNum of someScript
   return startLineNum,endLineNum
end script_DeleteHandler


--> Script | Handler | More
-
getprop script_Handlers [whichType]
   try
      put the long id of the target into tObject
      put the revAvailableHandlers of tObject into handlerTable
      sort numeric handlerTable by word 3 of each
      repeat for each line someLine in handlerTable
         put word 1 of someLine into item 2 of shortHkey
         put word 2 of someLine into item 1 of shortHkey
         
         switch whichType
            case "markdown"
               --    - [G mobile_VerticalScroller](../blob/master/libraries/lib_MobileControls.livecodescript#L35-L42)
               put "- [" & word 1 to 2 of someLine & "]" & CR after hLines
               -- put "* [[" & shortHkey & "]]" & CR after hLines
               break
            case "start line"
               put hkeyLine_ConstructStart (shortHkey) into hLine
               put hLine & CR after hLines
            default
               put word 2 of someLine & CR after hLines
         end switch
      end repeat
      delete char -1 of hLines
      return hLines
   catch someError
      return empty -- a locked stack
   end try
end script_Handlers

getprop script_Hkeys [fetchHow]
   switch fetchHow
      case "short"
         return the script_ShortHKeys of the target
      case "hArray"
         return the hArray_Hkeys of the target
      case "script"
         return the script_ArrayHkeys of the target
      default -- case "revAvailableHandlers"
         return the script_FirstHkeys of the target
   end switch
end script_Hkeys

getprop script_HandlerNames [pNotPrivate]
   put the revAvailableHandlers of the target into handlerTable
   put hTable_GetHandlerNames (handlerTable, pNotPrivate) into hNames
   return hNames
end script_HandlerNames

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

getprop script_CommandHandlers
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractCommandHandlers(someScript, scriptObject)
end script_CommandHandlers

getprop script_CommandLines
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractCommandLines(someScript, scriptObject)
end script_CommandLines

getprop script_Function [fName]
   put the script of the target into someScript
   return script_GetFunction (fName, someScript)
end script_Function

getprop script_FunctionHandlers
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractFunctionHandlers (someScript, scriptObject)
end script_FunctionHandlers


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
