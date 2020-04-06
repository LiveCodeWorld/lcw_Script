script "lib_Debug"
--> MetaData
-
license: GPLv3
name: lib_Debug
type: library
version: 0.1


--> Display | Debug
-
command display_DebugHistory pAlsoArray
   put "mDoubleUp_DebugHistory" into mDoubleUp
   --
   put line 1 to -2 of the executionContexts into eContexts
   put debug_ConstructHistoryArray (eContexts) into debugHistoryArray
   if pAlsoArray is true then
      _DisplayDebugHistoryArray debugHistoryArray
   end if
   --
   put debugHistoryArray [1]["revRuggedID"] into rObject
   put the name of rObject into firstObjectName
   --
   put _ConstructDebugHistoryHandlers (debugHistoryArray) into debugHistoryLines
   --
   display_Lines debugHistoryLines, firstObjectName, mDoubleUp, "Debug History", true
   put the result into indexView
   --
   set the title_Menu of indexView to "Global | Debug | Tree | Menu"
   set the line_Menu of indexView to "Global | Debug | Tree | Line | Menu"
   set the debug_HistoryArray of indexView to debugHistoryArray
   --
   return indexView
end display_DebugHistory

command display_DebugHistoryArray
   put line 1 to -2 of the executionContexts into eContexts
   put debug_ConstructHistoryArray (eContexts) into debugHistoryArray
   _DisplayDebugHistoryArray debugHistoryArray
   put the result into displayView
   return displayView
end display_DebugHistoryArray

private command _DisplayDebugHistoryArray debugHistoryArray
   put debugHistoryArray [1]["revRuggedID"] into rObject
   put the name of rObject into displayTitle
   put ",Execution Contexts" after displayTitle
   --
   display_Array debugHistoryArray, displayTitle
   --
   put the result into displayView
   return displayView
end _DisplayDebugHistoryArray


--> Debug | Display | Events
-
on mDoubleUp_DebugHistory indexView, hName
   put the hilited_Line of indexView into lineNum
   put the debug_HistoryArray of indexView into debugHistoryArray
   --
   put debugHistoryArray [lineNum]["revRuggedID"] into rObject
   put debugHistoryArray [lineNum]["behavior"] into bObject
   put debugHistoryArray [lineNum]["lineNum"] into lineNum
   --
   if bObject is empty then 
      scriptEditor_EditAndScroll rObject, lineNum   
   else
      scriptEditor_EditAndScroll bObject, lineNum   
   end if
end mDoubleUp_DebugHistory


--> Debug
-
function debug_ConstructHistoryArray eContexts 
   /*
   The executionContexts is similar to a call stack, it consists of a list of contexts, one per line, with the most recent context at the end. Each context is a string of the following 3 or 4 comma-delimited items:
   1. object long id
   2. handler name
   3. line number
   4. behavior object long id if the context is from a behavior script
   
   group id 1003 of card id 1002 of stack "Display Index 14",mouseDown,168,stack "/Users/fortyfoxes/Documents/git-repos/LiveCodeWorld/lcw_Menus/modules/View_Index_Simple/behaviors/behavior_ViewIndexSimple.livecodescript"
   group id 1003 of card id 1002 of stack "Display Index 14",_doFieldDown,59,stack "/Users/fortyfoxes/Documents/git-repos/LiveCodeWorld/lcw_Menus/modules/View_Index_Simple/behaviors/behavior_ViewIndexSimple.livecodescript"
   stack "/Users/fortyfoxes/Documents/git-repos/LiveCodeWorld/lcw_Menus/libraries/lib_MenuArray.livecodescript",mArray_PopUp,798
   */
   
   put 0 into lineNum
   repeat for each line someLine in eContexts
      add 1 to lineNum
      --
      put item 1 of someLine into sObject
      put the object_NameArray of sObject into debugHistoryArray [lineNum]["object"]
      put revRuggedID (sObject) into debugHistoryArray [lineNum]["revRuggedID"]
      --      --
      put item 2 of someLine into debugHistoryArray [lineNum]["handler"]
      put item 3 of someLine into debugHistoryArray [lineNum]["lineNum"]
      put item 4 of someLine into bObject
      --
      if exists (bObject) then
         put revRuggedID (bObject) into debugHistoryArray [lineNum]["behavior"]
      end if
      --      
   end repeat
   return debugHistoryArray
end debug_ConstructHistoryArray


--> Debug | Comments
-
function script_GetCommentAboveMe
   get line -2 of the executioncontexts
   put item -1 of it into lineNum
   -- put item -2 of it into hName
   put item 1 to -3 of it into scriptObject
   put the script of scriptObject into someScript
   
   -- test until we find a line with content
   repeat with testLineNum = (lineNum - 1) down to 1
      put word 1 to -1 of line testLineNum of someScript into scriptLine
      if scriptLine is not empty then exit repeat 
   end repeat
   if scriptLine is empty then return empty -- a blank script
   
   switch
      case char 1 to 2 of scriptLine = "--"
         delete char 1 to 2 of scriptLine
         return word 1 to -1 of scriptLine
      case char 1 of scriptLine = "#"
         repeat while char 1 of scriptLine = "#"
            delete char 1 ofscriptLine
         end repeat
         return word 1 to -1 of scriptLine
      case char -2 to -1 of scriptLine = "*/"
         -- a multiline comment
         put testLineNum into lastLineNum
         
         -- test until we find a line with content
         repeat with testLineNum = (lastLineNum - 1) down to 1
            put word 1 to -1 of line testLineNum of someScript into scriptLine
            if char 1 to 2 of scriptLine = "/*" then
               put testLineNum into startLineNum
               put line startLineNum to lastLineNum of someScript into multiComment
               put word 1 to -1 of multiComment into multiComment
               delete char 1 to 2 of multiComment
               delete char -2 to -1 of multiComment
               put word 1 to -1 of multiComment into multiComment
               
               repeat for each line cLine in multiComment
                  put word 1 to -1 of cLine & CR after cleanMultiComment
               end repeat
               delete char -1 of cleanMultiComment
               return cleanMultiComment
            end if
         end repeat
         return empty -- no start of comment ???
      default
         return empty -- not a comment
   end switch
end script_GetCommentAboveMe

function script_GetLineAboveMe
   get line -2 of the executioncontexts
   put item -1 of it into lineNum
   -- put item -2 of it into hName
   put item 1 to -3 of it into scriptObject
   
   put line (lineNum - 1) of the script of scriptObject into scriptLine
   return word 1 to -1 of scriptLine
end script_GetLineAboveMe

function script_CallingObject
   get the executioncontexts
   put item 1 of line -3 of it into callingObject
   return callingObject
end script_CallingObject


--> Deps
-
getprop object_NameArray
   put the long id of the target into tObject   
   put the short id of the target into shortID
   put the name of tObject into sName
   --
   put empty into nameArray [sName]
   --
   put the name of the stack_Object of tObject into shortStackObject
   --
   if the number of cards of stackObject > 1 then
      put the name of the card_Object of tObject into cName
      put empty into nameArray [sName][cName]
      put shortID into nameArray [sName][cName][shortStackObject]
   else
      put the name of the card_Object of tObject into cName
      put shortID into nameArray [sName][shortStackObject]
   end if
   return nameArray
end object_NameArray


--> Private
-
private function _ConstructDebugHistoryHandlers debugHistoryArray
   put item 2 of the extents of debugHistoryArray into maxLineNum
   repeat with lineNum = 1 to maxLineNum
      put debugHistoryArray [lineNum]["handler"] into hName
      put hName & CR after hNames
   end repeat
   delete char -1 of hNames
   return hNames
end _ConstructDebugHistoryHandlers

private function _ConstructDebugHistoryLines debugHistoryArray
   repeat for each key lineNum in debugHistoryArray
      put debugHistoryArray [lineNum]["revRuggedID"] into sObject
      put debugHistoryArray [lineNum]["handler"] into hName
      --
      put hName && "of" && sObject & CR after debugHistoryLines
   end repeat
   delete char -1 of debugHistoryLines
   return debugHistoryLines
end _ConstructDebugHistoryLines
