script "lib_ScriptArray"
--> MetaData
-
name: lib_ScriptArray
type: library
version: 0.5
author: David Bovill
copyright: David Bovill
license: GPLv3


--> Working on
-
--> Script | Array
-
getprop object_ScriptArray
   put the rugged_ID of the target into rObject
   try
      put the script of rObject into someScript
      put script_ConstructArray (someScript, rObject) into scriptData
      return scriptData
   catch e
      return empty -- it's locked !
   end try
end object_ScriptArray

getprop script_Array [pIndexSuites]
   -- this is broken due to 2 different formats being returned
   -- can speed up
   if the hArray_IsCurrent of the target is true then
      -- no need to parse the script as it is already correctly parsed stored in the global array
      put the hArray_ScriptData of the target into scriptData
      if pIndexSuites is false then
         hArray_StripSuitesFromScriptDataArray scriptData
      end if
      return scriptData
   else
      return the object_ScriptArray of the target
   end if
end script_Array

getprop script_ArrayHkeys
   try
      put the script_Array of the target into scriptArray
      repeat for each key indexNum in scriptArray
         put scriptArray [indexNum]["hKey"] into hKey
         if hKey is not empty then
            put hKey & CR after hKeys
         end if
      end repeat
      delete char -1 of hKeys
      return hKeys
   catch someError
      return empty -- a locked stack
   end try
end script_ArrayHkeys

getprop script_DuplicateKeyArray
   put the script_Array of the target into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum] into handerArray
      put handerArray ["hKey"] into hKey
      if hKey is empty then
         put hKey & CR after uniqueKeys
      else
         hkey_Deconstruct hKey, handlerName, hType, scriptObject, handlerNum
         if handlerNum > 1 then
            put handerArray into duplicateArray [hKey]         
         end if
      end if
   end repeat
   delete char - 1 of uniqueKeys
   return duplicateArray
end script_DuplicateKeyArray

getprop script_BreakdownArray [pKeepSpacer]
   put the script_Array of the target into scriptArray
   return script_ConstructBreakDownArray (scriptArray)
end script_BreakdownArray

getprop hArray_Hkeys
   put the hArray_ScriptData of the target into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum]["hKey"] into hKey
      if hKey is not empty then
         put hKey & CR after hKeys
      end if
   end repeat
   delete char -1 of hKeys
   return hKeys
end hArray_Hkeys


--> ScriptArray
-
/* 
This is a newer version of creating an array from a script.
Uses a repeat loop
*/

function script_ConstructArray someScript, rObject, pIsExpanded
   -- used by "object_ScriptArray"
   -- does same as "hArray_ConstructScriptArray" ?
   
   put pIsExpanded is true into pIsExpanded
   local suiteTitle
   put 1 into indexNum
   put 1 into lineNum
   put false into commentBlock
   repeat for each line scriptLine in someScript
      switch
         case word 1 of scriptLine = "/*"
            put true into commentBlock
            break
         case commentBlock is true
            -- keep looping till end of block
            if word -1 of scriptLine = "*/" then
               -- could put this commented out section in the index?
               put false into commentBlock
            end if
            break
         case word 1 of scriptLine = "-->"
            put word 2 to -1 of scriptLine into suiteTitle
            
            put "t" into dataArray [indexNum]["lineType"]
            put lineNum into dataArray [indexNum]["startLineNum"]
            put suiteTitle into dataArray [indexNum]["scriptLine"]
            put true into dataArray [indexNum]["isExpanded"]
            
            add 1 to indexNum
            break
         case token 1 of scriptLine is among the items of "command,on,function,getprop,setprop,private"
            if word 2 of scriptLine = "_" then break -- don't index divider handlers
            
            put char 1 of scriptLine into lineType
            if hType = "o" then put "c" into lineType
            
            put word 2 of scriptLine into hName
            -- put word 2 to -1 of scriptLine into hParams
            
            put countArray [hName][lineType] into hNum
            add 1 to hNum
            put hNum into countArray [hName][lineType]
            
            put hName,lineType,rObject,hNum into hKey
            put lineNum into startLineNum
            
            put hKey into dataArray [indexNum]["hKey"]
            put lineType into dataArray [indexNum]["lineType"]
            put suiteTitle into dataArray [indexNum]["suiteTitle"]
            put scriptLine into dataArray [indexNum]["scriptLine"]
            put pIsExpanded into dataArray [indexNum]["isExpanded"]
            
            break
         case token 1 of scriptLine = "end" and token 2 of scriptLine = hName
            put lineNum into endLineNum
            put startLineNum into dataArray [indexNum]["startLineNum"]
            put endLineNum into dataArray [indexNum]["endLineNum"]
            put line startLineNum to endLineNum of someScript into dataArray [indexNum]["handler"]
            
            add 1 to indexNum
            break
         case token 1 of scriptLine is empty
            -- it's a comment or some junk
            -- however script suites are also comments (so put at end of tests)!
            -- not actually needed
         default
            -- should not happen ???
      end switch
      add 1 to lineNum
   end repeat
   return dataArray
end script_ConstructArray


--> Script | Checks
-
function script_ConstructExportErrorArray someObjects
   repeat for each line someObject in someObjects
      try
         set the cursor to busy
         if exists (someObject) is false then next repeat
         try
            put the script of someObject into objectScript
         catch e
            next repeat -- must be a locked library
         end try
         
         put revRuggedID (someObject) into rObject
         --put the stack_Object of someObject into stackObject
         put token -1 of rObject into stackName
         if char 1 to 3 of stackName = "rev" then
            next repeat
         end if
         
         put the mobile_Name of someObject into mobileName
         put "Checking script of" && kwote (mobileName) into someTitle
         lcw_Notify someTitle
         
         put the exported_Script of someObject into exportedScript
         switch
            case exportedScript is empty and objectScript is empty
               next repeat
            case exportedScript is empty and objectScript is not empty
               put empty into exportErrorArray ["Not Exported"][mobileName][rObject]
               break
            case objectScript is not exportedScript
               put empty into exportErrorArray ["Export Differs"][mobileName][rObject]
               break
         end switch
      catch e
         breakpoint
      end try
   end repeat
   return exportErrorArray
end script_ConstructExportErrorArray

function script_ConstructBreakDownArray scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum] into handerArray
      put handerArray ["hKey"] into hKey
      
      if pKeepSpacer is not true and hKey = "-,c" then next repeat
      
      if hKey is not empty then -- could be metadata etc
         hkey_Deconstruct hKey, handlerName, hType, scriptObject, handlerNum
         if handlerNum > 1 then
            put handerArray into duplicateArray [hKey]
         else
            put hKey & CR after uniqueKeys      
         end if
      end if
   end repeat
   delete char - 1 of uniqueKeys
   
   put uniqueKeys into breakdownArray ["uniqueKeys"]
   put duplicateArray into breakdownArray ["duplicateArray"]
   put scriptArray into breakdownArray ["scriptArray"]
   return breakdownArray
end script_ConstructBreakDownArray


--> Script Array | Wrappers
-
function script_ExtractCommandHandlers someScript, scriptObject
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   return handlerArray ["command"]
end script_ExtractCommandHandlers

function script_ExtractFunctionHandlers someScript, scriptObject
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   return handlerArray ["function"]
end script_ExtractFunctionHandlers

function script_SlowExtractGetPropHandlers someScript, scriptObject
   -- slower but talerant of white space
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   put handlerArray ["getprop"] into handlerNames
   put handlerNames
   return handlerNames
end script_SlowExtractGetPropHandlers

function script_SlowExtractSetPropHandlers someScript, scriptObject
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   put handlerArray ["setprop"] into handlerNames
   return handlerNames
end script_SlowExtractSetPropHandlers

function script_ExtractMessageHandlers someScript, scriptObject
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   return handlerArray ["message"]
end script_ExtractMessageHandlers

function script_GetSectionHandlerArray sectionName, someScript
   put script_GetSuite (sectionName, someScript) into someScript
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   return handlerArray
end script_GetSectionHandlerArray

function script_ExtractHandlerLines someScript, scriptObject
   -- best get rid of?
   -- replace "[" with " [ " in someScript	#  -- hack ???
   
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   return handlerArray ["handlerLines"]
end script_ExtractHandlerLines

function script_GetOffsetTable someScript, scriptObject
   local scriptOffestTable
   -- put script_ExtractHandlerLines(someScript, scriptObject) into handlerLines
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   put handlerArray ["handlerLines"] into handlerLines
   repeat for each line handlerLine in handlerLines
      put word 1 of handlerLine into onWord
      put word 2 of handlerLine into handlerName
      script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
      put handler_GetType(handlerLine) into hType
      
      put handlerName,hType,startHandler,endHandler & CR after scriptOffestTable
   end repeat
   delete last char of scriptOffestTable
   return scriptOffestTable
end script_GetOffsetTable

command script_SetOffsetArrays someScript, @hKeyToOffsetArray, @offsetToCacheArray, scriptObject
   -- this hander is a real mess (slow and duplicates effort)
   -- as "script_ExtractHandlerLines" already parses every line (via "script_ConstructArraysFromScript")
   
   local handlerNumArray
   
   -- put the mobile_Name of scriptObject into scriptObject
   
   -- put script_ExtractHandlerLines(someScript) into handlerLines
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   put handlerArray ["handlerLines"] into handlerLines
   
   repeat for each line handlerLine in handlerLines
      put word 1 of handlerLine into onWord
      put word 2 of handlerLine into handlerName
      script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
      put char 1 of handler_GetType(handlerLine) into hType
      
      put handlerNumArray [handlerName,hType] into lastHandlerNum
      put lastHandlerNum + 1 into handlerNum
      put hkey_Construct(handlerName, hType, scriptObject, handlerNum) into handlerKey
      put handlerNum into handlerNumArray [handlerName,hType]
      
      -- while we are at it cache the script?
      put char startHandler to endHandler of someScript into someHandler
      
      put someHandler into offsetToCacheArray [startHandler,endHandler]
      put startHandler,endHandler into hKeyToOffsetArray [handlerKey]
      put handlerKey & CR after handlerKeys
   end repeat
   
   -- "orderedHandlerKeys" allow "number" ie handler 2 or 3rd "getMe"
   delete last char of handlerKeys
   put handlerKeys into hKeyToOffsetArray ["orderedHandlerKeys"]
   return handlerKeys
end script_SetOffsetArrays


--> Script Array | From Script
-
/* 
This is an older version of creating an array from a script.
Uses a repeat loop
*/

command script_ConstructArraysFromScript someScript, @handlerArray, @uniqueArray, @duplicateArray, scriptObject
   -- very slow as it loops through each line (use with care)
   
   local messageHandlers, commandHandlers, functionHandlers, setpropHandlers, getpropHandlers, orderedHandlers, errorHandlers, commandLines
   local handlerKeys, handlerName, hType, privateBit
   
   -- would be faster to do in repeat loop below
   local mulitLineComment
   script_ExtractAndStripMultiLineComments someScript, mulitLineComment
   
   put rev_MessageNames() into revMessageNames
   set the wholematches to true
   repeat for each line handlerLine in someScript
      if handlerLine is empty then next repeat
      --
      hkeyLine_DeconstructStart handlerLine, handlerName, hType, privateBit
      if handlerName = "_" then next repeat
      
      switch char 1 of hType
         case "f"
            put handlerName & CR after functionHandlers
            break
         case "g"
            put handlerName & CR after getpropHandlers
            break
         case "s"
            put handlerName & CR after setpropHandlers
            break
         case empty
            -- someJunk
            next repeat
         default -- (hType = "on" or hType = "command")
            if handlerName is among the lines of revMessageNames then
               put handlerName & CR after messageHandlers
            else
               put handlerName & CR after commandHandlers
               
               put handlerLine into commandLine
               delete token 1 of commandLine
               put commandLine & CR after commandLines
            end if
            break
      end switch
      
      put handlerLine & CR after handlerLines
      put handlerName & CR after orderedHandlers
      put char 1 of hType & privateBit into hType
      
      put handlerName & "," & hType into shortHKey
      put uniqueArray [shortHKey] into firstFoundObject
      
      if firstFoundObject is empty then
         put scriptObject into uniqueArray [shortHKey]
         put 1 into handlerNum
      else
         put duplicateArray [shortHKey] into duplicateIndex
         put the number of lines of duplicateIndex + 1 into handlerNum
         if handlerNum = 1 then
            put hkey_Construct (handlerName, hType, scriptObject, 1) & CR & hkey_Construct (handlerName, hType, scriptObject, 2) into duplicateIndex
         else
            put hkey_Construct (handlerName, hType, scriptObject, (handlerNum+1)) into duplicateKey
            line_Insert duplicateKey, duplicateIndex
         end if
         put duplicateIndex into duplicateArray [shortHKey]
      end if
      
      -- add last bit (new)
      if privateBit is not true then
         put hkey_Construct (handlerName, hType, scriptObject, handlerNum) into hKey
         put hKey & CR after notPrivateHkeys
      end if
      --
      if privateBit is empty then
         script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
      else
         script_SetPrivateHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
      end if
      put char startHandler to endHandler of someScript into someHandler
      put someHandler into handlerArray [hKey] -- this is a bit messy (better handlerArray ["handler"][hKey]
      -- put startHandler,endHandler into offsetArray [hKey]
   end repeat
   
   delete last char of handlerLines
   delete last char of commandLines
   delete last char of orderedHandlers
   
   delete last char of messageHandlers
   delete last char of commandHandlers
   delete last char of functionHandlers
   delete last char of getpropHandlers
   delete last char of setpropHandlers
   
   put handlerLines into handlerArray ["handlerLines"]
   put commandLines into handlerArray ["commandLines"]
   put orderedHandlers into handlerArray ["orderedHandlers"]
   
   put messageHandlers into handlerArray ["message"]
   put commandHandlers into handlerArray ["command"]
   put functionHandlers into handlerArray ["function"]
   put getpropHandlers into handlerArray ["getprop"]
   put setpropHandlers into handlerArray ["setprop"]
   
   delete last char of notPrivateHkeys
   return notPrivateHkeys
end script_ConstructArraysFromScript
