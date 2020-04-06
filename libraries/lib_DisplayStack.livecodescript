script "lib_DisplayStack"
--> MetaData
-
license: GPLv3
name: lib_DisplayStack
type: library
version: 0.3

/*
Compare with "lib_DisplayGraph"
*/


--> Props
-
getprop script_HkeyArray [externalObjects]
   local hKeyLinkArray
   --
   put the long id of the target into targetObject
   put walk_TargetHandlers (targetObject) into hKeyArray
   return hKeyArray
end script_HkeyArray

getprop stack_PlaceArray
   /*
   -- see also "hkeyLine_WalkExportedHkeyArray"
   
   This only looks at calls, and hkeys in the actual object.
   It does not walk the dependency tree.
   It is not a recursive search.
   usefull for a quick look at first level dependencies.
   */
   
   local pDepArray
   
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   put the dataObject_Folder of tObject into dataFolder
   put revRuggedID (tObject) into rObject
   
   repeat for each line hTableLine in hTable
      put word 1 to 2 of hTableLine into shortHkey
      put hKeyLine_Construct (shortHkey, rObject) into pHkey
      put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
      put shortCalls into pDepArray ["Handlers"][pHkey]
      
      set the wholematches to false
      repeat for each line shortCall in shortCalls
         put the found_Hkey [shortCall] of tObject into externalHkey
         if externalHkey is empty then
            put empty into pDepArray ["Missing"][rObject][shortCall][pHkey]
         else
            hkey_Deconstruct externalHkey, cName, cType, cObject, cNum
            put the project_Name of cObject into cProjectName
            put hKeyLine_Construct (shortCall, cObject) into cHkey
            put empty into pDepArray ["Calls"][cProjectName][cObject][cHkey][pHkey]
         end if
      end repeat
   end repeat
   return pDepArray
end stack_PlaceArray


--> Working on
-
command display_Script sObject
   -- display_DotArray graphData, pTitle
   
   put the name of sObject into someTitle
   put someTitle & comma & "Script" into displayTitle
   --
   -- put the script_OverlayData of sObject into scriptArray
   -- put the object_ScriptArray of sObject into scriptArray
   put the script_SuiteArray of sObject into scriptArray
   --
   put "Global | Script | Tree | Menu" into mTitle
   put "Global | Script | Tree | Line | Menu" into mLineTitle
   put "" into inspectCommand
   put "" into mDoubleUpCommand
   --
   display_Array scriptArray, displayTitle, mTitle, mLineTitle, inspectCommand, mDoubleUpCommand
   put the result into treeView
   set the displayed_Object of treeView to sObject
   return treeView
end display_Script


--> Display
-
command display_ScriptArray scriptObject
   put the script_HkeyArray of scriptObject into hKeyArray
   --
   graph_CreateScriptObjectHkeyArray hkeyArray, scriptObject
   put the result into imageFile
   display_HandlerSVG imageFile
   --
   put the name of scriptObject into objectName
   put merge ("[[objectName]],display_ScriptArray") into someTitle
   --
   _DisplayHkeyArray hKeyArray, someTitle, stackObject
   return indexView
end display_ScriptArray


--> Display | Not fully working
-
command display_StackDeps stackObject
   put the project_Name of stackObject into projectName
   put merge ("[[stackObject]],[[projectName]]") into someTitle
   
   put the script_HkeyArray of stackObject into depArray
   -- put the stack_PlaceArray of stackObject into depArray
   --
   _DisplayHkeyArray depArray, someTitle, stackObject
   return indexView
end display_StackDeps


--> Display | Not tested recently
-
command display_RigStackLibs pDisplayView
   put rig_ListStackFiles() into shortStackFiles
   display_ServerStacks shortStackFiles, pDisplayView
end display_RigStackLibs

command display_ServerStacks shortStackFiles, pDisplayView
   put server_GetURL() into serverURL
   if exists (pDisplayView) is false then put display_FindView ("Stack Libraries", serverURL) into pDisplayView
   
   if exists (pDisplayView) then
      set the displayed_index of pDisplayView to shortStackFiles
   else 
      display_Lines shortStackFiles, serverURL, "mDoubleUp_CheckRigStack", "Stack Libraries", true
      put the result into pDisplayView
      --
      put rig_GetFolder ("stacks") into folderPath
      set the folder_Path of pDisplayView to folderPath
      set the title_Menu of pDisplayView to "Global | Display | Rig | Stacks | Menu"
   end if
   set the line_Menu of pDisplayView to "Global | Display | Rig | Stacks | Line | Menu"
   return pDisplayView
end display_ServerStacks

command display_Stacks stackNames, pSomeTitle, pIndexView
   if pSomeTitle is empty then put "Found" into pSomeTitle
   
   put "mDouble_DisplayStack" into mDoubleUp
   
   if exists (pIndexView) is false then
      put empty into mUp
      -- display_Index stackNames, pStackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      display_Lines stackNames, pSomeTitle, mDoubleUp, "Stacks"
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to stackNames
      set the stack_Title of pIndexView to pStackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      unlock screen
      return pIndexView
   end if
end display_Stacks


--> Display | Events
-
command mDouble_DisplayStack indexView, stackName
   switch
      case exists (stack stackName) is false
         answer merge("Could not find stack '[[stackName]]'.")
         break
      case the scriptonly of stack stackName is true
         edit the script of stack stackName
         break
      default
         go to stack stackName
   end switch
end mDouble_DisplayStack

command mDoubleUp_CheckRigStack displayView, shortFile
   /*
   put the folder_Path of displayView into folderPath
   put server_GetURL() into serverURL
   put server_GetSshUser() into sshUser
   put server_GetSshKeyPath() into sshKeyPath
   */
   -- edit the script of the behavior of displayView
   -- put rig_StackIsSameAsLocal (shortFile)
   
   put word 2 of the clickLine into lineNum
   put the line_Colour [lineNum] of displayView into someColour
   
   switch someColour
      case "255,0,0" -- red
         -- stack does not exist
         put spotlight_FindStack (shortFile)     
         answer warning "Stack does not exist. You probably need to load a library."
         exit to top
         break
      case "0,0,255" -- blue
         -- stacks differ
         set the cursor to watch
         put rig_FetchStack (shortFile) into remoteStackData
         put stack_ExtractScriptOnlyName (remoteStackData) into stackName
         put the stack_Data of stack stackName into localStackData
         
         edit the script of stack stackName
         terminal_Diff remoteStackData, localStackData, "Remote", "Local"
         break
      default -- dark green
         -- stacks same
         set the cursor to watch
         put rig_FetchStack (shortFile) into remoteStackData
         put stack_ExtractScriptOnlyName (remoteStackData) into stackName
         --
         put the scriptonly of stack stackName into isScriptOnly
         put the filename of stack stackName into someFile
         put spotlight_GetFileKind (someFile) into fileKind
         --
         put isScriptOnly & CR & someFile & CR & fileKind
         if the optionKey is "down" then
            edit the script of stack stackName
         end if
   end switch
end mDoubleUp_CheckRigStack


--> Walk
-
function walk_TargetHandlers targetObject, pExternalObjects, pUseExportedCalls
   local hKeyLinkArray
   put revRuggedID (targetObject) into rObject
   put the revAvailableHandlers of rObject into hTable
   repeat for each line hLine in hTable
      set the cursor to busy
      put word 1 to 2 of hLine into shortHkey
      put hKeyLine_Construct (shortHkey, rObject) into hKeyLine
      --
      if pUseExportedCalls is true then
         put hkey_FetchCalls (hKeyLine) into shortCallHkeyLines
      else
         put the handler_Calls [hKeyLine] of targetObject into shortCallHkeyLines
      end if
      --
      repeat for each line shortCallHkeyLine in shortCallHkeyLines 
         walk_FoundShortHkeyLine shortCallHkeyLine, hKeyLine, pExternalObjects, hKeyLinkArray
      end repeat
   end repeat
   return hKeyLinkArray
end walk_TargetHandlers

private command walk_FoundShortHkeyLine shortCallHkeyLine, parentHKeyLine, pExternalObjects, @hKeyLinkArray, pUseExportedCalls
   -- was hkeyLine_WalkExportedHkeyArray
   hkeyLine_Deconstruct parentHKeyLine, pName, pType, pObject
   put hkey_Find (shortCallHkeyLine, pObject, pExternalObjects) into foundCall
   --
   if foundCall is empty then 
      put hKeyLine_Construct (shortCallHkeyLine, "Missing") into missingCall
      put true into hKeyLinkArray [parentHKeyLine][missingCall]
      return empty
   end if
   --
   hkeyLine_Deconstruct foundCall, fName, fType, fObject
   if exists (fObject) is false then
      put hKeyLine_Construct (shortCallHkeyLine, "Missing") into missingCall
      put true into hKeyLinkArray [parentHKeyLine][missingCall]
      return empty
   end if
   --
   if hKeyLinkArray [parentHKeyLine][foundCall] is true then
      return empty -- already indexed (don't recurse)
   end if
   
   -- add it to the array
   put true into hKeyLinkArray [parentHKeyLine][foundCall]
   
   -- now lets repeat and recurse for each call found
   if pUseExportedCalls is true then
      put hkey_FetchCalls (foundCall) into childShortHkeyLines   
   else
      put the handler_Calls [foundCall] of fObject into childShortHkeyLines    
   end if
   repeat for each line childShortHkeyLine in childShortHkeyLines
      set the cursor to busy
      walk_FoundShortHkeyLine childShortHkeyLine, foundCall, pExternalObjects, hKeyLinkArray
   end repeat
   return empty
end walk_FoundShortHkeyLine


--> Private
-
private command _DisplayHkeyArray depArray, someTitle, displayedObject
   put "Global | HkeyArray | Tree | Deps | Menu" into mTitle
   put "Global | HkeyArray | Menu" into mLineTitle
   display_Array depArray, someTitle, mTitle, mLineTitle, "mouse_EditHkey", "mouse_EditHkey"
   put the result into treeView
   set the displayed_Object of treeView to displayedObject
   return treeView
end _DisplayHkeyArray
