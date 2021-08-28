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
