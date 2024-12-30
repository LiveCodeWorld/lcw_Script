script "lib_DisplayHandler"
--> MetaData
-
license: GPLv3
name: lib_DisplayHandler
type: library
version: 0.1

/*
These handlers walk the hkey dependency graph using exported handler_Call values.
These values are stored in the handler_Folder, and retrieved using "hkey_FetchCalls (hKeyLine)"
*/


--> Working on
-
command svg_BrowserNavigate clickedURL
   put the svg_View of the target into svgView
   
   # Hkey from clicked url
   set the itemdelimiter to slash
   if item 3 of clickedURL is not "libbrowser_dummy_url" then return false
   put item -1 of clickedURL into urlEncodedHKey
   put urldecode (urlEncodedHKey) into hKey
   replace "'" with quote in hKey
   
   # Graph props from "display_ScriptHkeyArrayDeps" and 
   put the displayed_Object of svgView into sObject
   put the displayed_HkeyArray of svgView into hkeyArray
   put the displayed_GraphStyle of svgView into pGraphStyle
   --
   put the svg_File of svgView into svgFile
   
   # Do something
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   --
   switch hObject
      case empty
         put clickedURL
         break
      case "missing"
         put hkey_Find (hKey) into foundHkey
         if foundHkey is empty then
            -- find in hKeyArray?
            put hKey
            breakpoint
            display_SpotlightHandler hKey
         else
            hKey_Edit foundHkey
         end if
         break
      default
         hKey_Edit hKey
   end switch
end svg_BrowserNavigate


--> Display
-
command display_CollectedHkeys hKeys, sTitle
   # Collect and display script
   put script_CollectFromObjects (hKeys, true) into newDepScript
   display_Text newDepScript, sTitle, "Found but Outside Script"
   return the result
end display_CollectedHkeys

function collection_GetData
   put the model_Array ["collection.array"] of stack "lcw_Script" into collectionData
   return collectionData
end collection_GetData

command collection_SetData collectionData
   set the model_Array ["collection.array"] of stack "lcw_Script" to collectionData
   return the result
end collection_SetData

command display_CallsOutside hkeyArray, sObject, pHkey
   put array_ListKeys (hkeyArray) into hKeys
   put hkeyIndex_FilterOutside (hKeys, sObject, true) into outsideKeys
   
   put collection_GetData() into collectionData
   --
   if pHkey is empty then
      put revRuggedId(sObject) into sObject
      put hkeyArray into collectionData ["collection"][sObject]
   else
      put hkeyArray into collectionData ["collection"][pHkey]
   end if
   --
   repeat for each line hKey in outsideKeys
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put the result into shortHkey
      --
      put empty into collectionData ["shortkeyArray"][shortHkey]["hkey"][hKey]
   end repeat   
   --
   collection_SetData collectionData
   
   -- put the name of sObject into sTitle
   display_Tool collectionData, "Collection Data", "Hkey Calls Outside", "lcw_Script"
   put the result into dView
   --
   return dView
end display_CallsOutside

function colour_RgbToHSV
   return true
end colour_RgbToHSV

function hkey_ConstructMissingData hKeys, sObject, searchObjects, pDisplayView
   put hkey_ListShort (hKeys) into allShortHkeys
   --
   repeat with lineNum = 1 to the number of lines of hKeys
      if the commandKey is "down" then breakpoint
      if the shiftKey is "down" then exit repeat
      --
      put line lineNum of hKeys into hKey
      --
      if exists (pDisplayView) then
         set the hilited_Element of pDisplayView to hKey
      end if
      
      # List handler calls = allHandlerKeys
      put walk_ConstructHkeyArray (hKey, searchObjects) into handlerHkeyArray
      put array_ListKeys (handlerHkeyArray) into allHandlerKeys
      
      repeat for each line handlerHkey in allHandlerKeys
         put word 1 to 2 of handlerHkey into shortHandlerKey
         --
         switch
            case handlerHkey is among the lines of hKeys
               put empty into foundArray [handlerHkey]
               break
            case word -1 of handlerHkey = "Missing"
               put empty into missingArray [handlerHkey]
               break
            case shortHandlerKey is among the lines of allShortHkeys
               put empty into inShortArray [handlerHkey]
               break
            default
               put empty into foundButOutsideArray [handlerHkey]
         end switch
      end repeat
   end repeat
   --
   put foundArray into missingData ["foundArray"]
   put missingArray into missingData ["missingArray"]
   put inShortArray into missingData ["inShortArray"]
   put foundButOutsideArray into missingData ["foundButOutsideArray"]
   --
   return missingData
end hkey_ConstructMissingData

command display_CreateFastHandlerGraph hKey
   display_CreateHandlerGraph hKey, "fast undirected spring"
end display_CreateFastHandlerGraph

command display_CreateHandlerGraph hKey, pGraphStyle
   graph_Hkey hKey, pGraphStyle
   put the result into svgFile
   --
   display_SVG svgFile, hKey
   put the result into svgView
   --
   put hKey_GetArray (hkey) into hkeyArray
   set the link_Array of svgView to hkeyArray
   set the displayed_Hkey of svgView to hKey
   set the displayed_GraphStyle of svgView to pGraphStyle
   --
   return hKey
end display_CreateHandlerGraph

command display_HandlerDeps hKeyLine
   -- put hkeyLine_WalkExportedHkeyArray (hKeyLine) into hKeyArray
   -- display_HandlerDepArrays hKeyLine, hKeyArray
   
   put walk_ConstructHkeyArray (hKeyLine) into hKeyArray
   --
   display_HkeyArrayDeps hkeyArray, hKeyLine
   put the result into displayView
   --
   return displayView
end display_HandlerDeps


--> Props
-
getprop exported_HandlerHkeyArray [shortHkey]
   put the long id of the target into tObject
   hkey_Deconstruct shortHkey, hName, hType, hObject, hNum
   put revRuggedID (tObject) into hObject
   put hKeyLine_Construct (hName, hType, hObject) into hKeyLine
   put hkeyLine_WalkExportedHkeyArray (hKeyLine) into hKeyArray
   return hKeyArray
end exported_HandlerHkeyArray


--> Display | Handler Graph
-
command graph_TidyLinkArray @hkeyArray
   -- before graph arrays have been created
   -- let's just process hkeyArray for general hKey purposes
   put the long id of me into processObject
   hkeyArray_Process hkeyArray, processObject
end graph_TidyLinkArray

on hkey_Rename hkey
   hkey_Deconstruct hkey, hName, hType, hObject, hNum
   switch
      case hName is among the items of "jsonImport,jsonExport,transporter_RawJSON"
         return empty
      case hName begins with "rig"
         put "revIgniter" into hObject -- could be "stack 'revIgniter'"?
         put hKeyLine_Construct (hName, hType, hObject) into hkey
         return hkey
      default
         return hKey
   end switch
end hkey_Rename

command display_HandlerDepArrays hKeyLine, hKeyArray
   put hkeyArray_ToProjectDependencyArray (hKeyArray) into projectDependencyArray
   
   display_Data projectDependencyArray, hKeyLine, "display_HandlerDepArrays"
   put the result into displayView
   display_SetInteractions displayView, "HkeyArray | Tree", "hkeyLine_TreeClick"
   --
   set the displayed_Hkey of displayView to hKeyLine
   
   set the displayed_HkeyArray of displayView to hKeyArray
   -- set the displayed_Style of displayView to "Project Dependency Array"
   return displayView
end display_HandlerDepArrays

on hkeyLine_TreeClick displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
   return displayView
end hkeyLine_TreeClick


--> Display | HandlerDeps
-
function hkeyArray_ToProjectDependencyArray hTableLineArray
   -- Traverses the hkey dependency graph by crawling info stored in a stored HkeyPlaceArray
   
   local pDepArray
   repeat for each key hTableLine in hTableLineArray
      -- not strictly need. Skip for speed?
      put hkeyArray_FindParentArray (hTableLine, hTableLineArray) into parentArray
      put keys (parentArray) into parentkeys
      
      _AddTableLine pDepArray, hTableLine, parentArray
      put hTableLineArray [hTableLine] into hTableLineCallArray
      repeat for each key hTableLineCall in hTableLineCallArray
         _AddTableLine pDepArray, hTableLineCall, hTableLine
      end repeat
   end repeat
   return pDepArray
end hkeyArray_ToProjectDependencyArray

function hkeyArray_FindParentArray hTableLine, hTableLineArray
   repeat for each key testTableLine in hTableLineArray
      put hTableLineArray [testTableLine] into hTableLineCallArray
      if hTableLineCallArray  [hTableLine] is true then
         put true into parentArray [testTableLine]
      end if
   end repeat
   return parentArray
end hkeyArray_FindParentArray


--> Hkey | Walk | Exported
-
function hkeyLine_WalkExportedHkeyArray hKeyLine, pProjectName
   /*
   Traverses the hkey dependency graph by crawling info stored in a stored HkeyPlaceArray
   
   Works out dependecy array from flat namespace of all hkeys in hkeyPlaceArray library.
   Does not look at pProjectName at the moment (for that need to return different arrays with "script_FetchHkeyPlaceArray (pProjectName)")
   */
   
   local hKeyLinkArray
   
   put script_FetchHkeyPlaceArray (pProjectName) into hkeyPlaceArray
   put hkey_FetchCalls (hKeyLine) into shortCallHkeyLines
   repeat for each line shortCallHkeyLine in shortCallHkeyLines 
      hkeyLine_WalkExportedHkeyArray shortCallHkeyLine, hKeyLine, hKeyLinkArray, hkeyPlaceArray
   end repeat
   return hKeyLinkArray
end hkeyLine_WalkExportedHkeyArray

private command hkeyLine_WalkExportedHkeyArray shortCallHkeyLine, parentHKeyLine, @hKeyLinkArray, hkeyPlaceArray
   hKeyLine_Deconstruct shortCallHkeyLine, cName, cType, hObject
   put hkey_GetPlace (shortCallHkeyLine, hkeyPlaceArray) into cObject -- find it
   
   if exists (cObject) is false then 
      put hKeyLine_AddObject (shortCallHkeyLine, "Missing") into missingCall
      put true into hKeyLinkArray [parentHKeyLine][missingCall]
      return empty
   end if
   
   put hKeyLine_AddObject (shortCallHkeyLine, cObject) into foundCall
   if hKeyLinkArray [parentHKeyLine][foundCall] is true then
      return empty -- already indexed (don't recurse)
   end if
   
   -- add it to the array
   put true into hKeyLinkArray [parentHKeyLine][foundCall]
   
   -- now lets repeat and recurse for each call found
   put hkey_FetchCalls (foundCall) into childShortHkeyLines   
   repeat for each line childShortHkeyLine in childShortHkeyLines
      hkeyLine_WalkExportedHkeyArray childShortHkeyLine, foundCall, hKeyLinkArray, hkeyPlaceArray
   end repeat
   
   return empty
end hkeyLine_WalkExportedHkeyArray


--> Display | Events
-
on mouse_EditHkey treeView, hTableLine
   if the optionKey is "Down" then breakpoint
   
   put the hilited_Element of treeView into hElement
   switch item 1 of hElement
      case "Missing"
         -- put hTableLine into parentTableLine
         put item -1 of hElement into missingTableLine
         put hTableLine into missingParent
         hkey_Edit missingParent
         put missingTableLine
         break
      case "Calls"  
         if the shiftKey is "Down" then
            put item 5 of hElement into hKeyLine
         else
            put item 4 of hElement into hKeyLine
         end if
         put item 3 of hElement into stackObject
         
         hkey_Edit hKeyLine
         
         put hkeyLine_FetchDuplicateArray (hKeyLine) into duplicateArray
         put keys (duplicateArray) into dupHkeys
         if the number of lines of dupHkeys > 1 then
            put merge ("[[hKeyLine]],duplicateArray") into someTitle
            put empty into mLineTitle
            display_Array duplicateArray, someTitle
            display_SetInteractions the result, "Hkey | Duplicate", hkeyLine_TreeClick
         end if
         break
      case "Handlers"
         put item -1 of hElement into hKeyLine
         hkey_Edit hKeyLine
         break
      default
         put item 1 of hElement into dObject
         put hTableLine into lineNums
         put the title_Text of treeView into hKeyLine
         -- put the displayed_Title of treeView into hTableLine
         -- put hKeyLine_AddObject (shortHkeyLine, dObject) into hKeyLine
         hkey_Edit hKeyLine
   end switch
end mouse_EditHkey


--> Private
-
private command _AddTableLine @pDepArray, hTableLine, parentTableLine
   hKeyLine_Deconstruct hTableLine, cName, cType, cObject
   if exists (cObject) is false then
      put parentTableLine into pDepArray ["Missing"][hTableLine]
   else
      put the project_Name of cObject into cProjectName
      put parentTableLine into pDepArray ["Calls"][cProjectName][cObject][hTableLine]
   end if
end _AddTableLine
