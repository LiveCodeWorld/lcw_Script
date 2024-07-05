script "lib_Handler"
--> MetaData
-
license: GPLv3
name: lib_Handler
type: library
version: 0.2

/*
See also stack "model_Script"
*/


getprop handler_Names [hFilter]
   put the revAvailableHandlers of the target into hTable
   put hTable_ListHanderNames (hTable, hFilter) into hNames
   return hNames
end handler_Names

getprop handler_From [hKeyOrNumber]
   put the revAvailableHandlers of the target into hTable
   --
   if hKeyOrNumber is a number then
      put hTable_HandlerFromLineNum (hTable, hKeyOrNumber) into someHandler
   else
      put hTable_GetHandler (hKeyOrNumber, hTable) into someHandler
      return someHandler
      
      /*
      put word 5 to -1 of line 1 of hTable into scriptObject
      --
      put hKeyLine_AddObject (hKeyOrNumber, scriptObject) into hKey
      htable_ExactLineOffsets hKey, hTable, startLineNum, endLineNum
      if the result is false then return empty
      
      put the script of scriptObject into someScript
      put line startLineNum to endLineNum of someScript into someHandler
      */
   end if
   return someHandler
end handler_From

function handler_Get hKey, pMatchPrivate
   -- defaults to matching private or public
   hkey_Deconstruct hKey, hName, hType, hObject, hNum 
   try
      put the revAvailableHandlers of hObject into hTable
      --
      if pMatchPrivate is not false then
         htable_EitherLineOffsets hKey, hTable, startLineNum, endLineNum
      else
         hTable_FlexibleLineOffsets hKey, hTable, startLineNum, endLineNum
      end if
      put the script of hObject into someScript
      put line startLineNum to endLineNum of someScript into foundHandler
      return foundHandler
   catch someError
      return empty -- a locked stack
   end try
end handler_Get


--> Script | Handler | Model
-
/*
These handlers extract handlers from an objects script.
For handlers that work on exported handlers see "model_HandlerLibrary"
*/

getprop script_HandlerExists [shortHKey]
   if shortHKey is empty then return empty
   put the revAvailableHandlers of the target into hTable
   --
   put space after word 1 to -1 of shortHKey
   if lineOffset (shortHKey, hTable) = 0 then
      return false
   else
      return true
   end if
end script_HandlerExists

getprop script_Handler [shortHKey]
   if shortHKey is empty then return empty
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put the script of hObject into someScript
   put htable_GetHandler (shortHKey, hTable, someScript) into foundHandler
   return foundHandler
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

command script_DeleteHandler @someScript, hkeyLine, hTable
   htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   put endLineNum + 1 into afterEndLineNum
   put word 1 to -1 of line afterEndLineNum of someScript into lineAfterEnd
   if lineAfterEnd is empty then add 1 to endLineNum
   delete line startLineNum to endLineNum of someScript
   return startLineNum,endLineNum
end script_DeleteHandler

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
               put _ScriptHandlersStart (shortHkey) into hLine
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


--> Handler | Get
-
function hkeyLine_GetHandlers hkeyLines, hTable, someScript
   repeat for each line hkeyLine in hkeyLines
      put htable_GetHandler (hkeyLine, hTable, someScript) into foundHandler
      if foundHandler is empty then next repeat
      put foundHandler & CR & CR after foundHandlers
   end repeat
   delete char -2 to -1 of foundHandlers
   return foundHandlers
end hkeyLine_GetHandlers


--> Props
-
getprop action_Key [aItems]
   put the long id of the target into tObject
   put item 1 of aItems into hName
   put item 2 of aItems into aIcon
   --
   put revRuggedID (tObject) into hObject
   put hKeyLine_Construct (hName, "M", hObject) into hKey
   --
   if aName is empty then
      return hKey
   else
      return hKey,aIcon
   end if
end action_Key

command action_Deconstruct actionKey, @hName, @hObject, @aIcon
   put item 1 of aKey into hKey
   put item 2 of aKey into aIcon
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
end action_Deconstruct

function action_Construct hName, hObject, aIcon
   put the handler_Key ["M test"] of hObject into hKey
   if aIcon is empty then
      return hKey
   else
      return hKey,aName
   end if
end action_Construct

getprop object_Hkey [hKey]
   return the handler_Key [hKey] of the target
end object_Hkey

getprop handler_Key [hKey]
   put the long id of the target into tObject
   put revRuggedID (tObject) into hObject
   --
   hkey_Deconstruct hKey, hName, hType, xObject, xNum
   put hKeyLine_Construct (hName, hType, hObject) into hKey
   --
   return hKey
end handler_Key

getprop handler_OverlayArray [shortHkey]
   put the handler_Key [shortHkey] of the target into hKey
   -- 
   put hkey_GetOverlayArray (hKey) into overlayArray
   return overlayArray
end handler_OverlayArray

getprop handler_File [shortHkey]
   put the dataObject_Folder [true] of the target into dataFolder
   put textStack_ConstructHandlerFile (shortHkey, dataFolder) into handlerFile
   return handlerFile
end handler_File

getprop handler_Folder [shortHkey]
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/
   put the dataObject_Folder [true] of the target into dataFolder
   if shortHkey is empty then
      put dataFolder & "handlers/" into handlerFolderRoot
      return handlerFolderRoot
   else
      put textStack_ConstructHandlerFolder (shortHkey, dataFolder) into handlerFolder
      return handlerFolder
   end if
end handler_Folder

getprop handler_InHierarchy [hKey]
   put the long id of the target into tObject
   hkey_Normalize hKey
   put the result into shortHkey
   
   put hkey_FoundArray (shortHKey, tObject) into foundArray
   put foundArray ["foundHkey"] into foundHkey
   if foundHkey is empty then return empty
   
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   try
      put the script of fObject into fScript
   catch e
      return empty -- stack locked
   end try
   
   put foundArray ["startLineNum"] into startLineNum
   put foundArray ["endLineNum"] into endLineNum
   put line startLineNum to endLineNum of fScript into fHandler
   return fHandler
end handler_InHierarchy


--> Handler
-
function handler_Construct hType, hName, hBody, pIsPrivate
   put tolower(char 1 of hName) into char 1 of hName
   --
   put hType && hName into someHandler
   put CR after someHandler
   repeat for each line scriptLine in hBody
      put "   " & scriptLine & CR after someHandler
   end repeat
   put "end" && word 1 of hName after someHandler
   --
   if pIsPrivate is true then
      put "private " before someHandler
   end if
   return someHandler
end handler_Construct

function hkey_GetObjectHandler hKey, pNotPrivate
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   if pNotPrivate is true then
      put the script of hObject into someScript
      put script_ExtractHandler (hKey, someScript, pNotPrivate) into someHandler
   else
      put the script_Handler [hKey] of hObject into someHandler
   end if
   return someHandler
end hkey_GetObjectHandler


--> Handler | Type
-
function hkey_GetType hKey, pCheck
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into goodHkey
   switch word 1 of goodHkey
      case "pf" -- should not be
         return "private function"
      case "f"
         return "function"
      case "pc" -- should not be
      case "pm" -- should not be
         return "private command"
      case "g"
         return "getprop"
      case "s"
         return "setprop"
      default
         -- case "m"
         -- case "o"
         return "command" -- could be "event" or "message"
   end switch
end hkey_GetType

function handler_GetType handlerLine
   if token 1 of handlerLine = "private" then
      delete token 1 of handlerLine
      put true into isPrivate
   end if
   
   switch token 1 of handlerLine
      case "on"
         put rev_MessageNames() into revMessageNames
         put token 2 of handlerLine into cName
         if cName is among the lines of revMessageNames then
            return _addPrivate ("m", isPrivate)    # message
         else
            return _addPrivate ("c", isPrivate)    # command
         end if
      case "command"
         return _addPrivate ("c", isPrivate)    # command
      case "function"
         return _addPrivate ("f", isPrivate)    # function
      case "getprop"
         return "g"	# getprop
      case "setprop"
         return "s"	# setprop
      default
         return empty
   end switch
end handler_GetType

function handler_ConvertType onWord
   switch char 1 of word 1 of onWord
      case "o"
         return "on"
      case "m"
         return "on"
      case "c"
         return "command"
      case "pc"
         return "private command"
      case "f"
         return "function"
      case "pf"
         return "private function"
      case "g"
         return "getprop"
      case "s"
         return "setprop"
      default
         return empty
   end switch
end handler_ConvertType


--> Private
-
private function _addPrivate hType, isPrivate
   if isPrivate is true then put "p" before hType
   return hType
end _addPrivate
