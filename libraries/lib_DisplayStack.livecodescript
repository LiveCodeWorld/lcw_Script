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

--> Display | Events
-
command mDoubleUp_DisplayShortHkey displayView, shortHkey
   put the title_Text of displayView into sObject
   --
   put the selected_Path of displayView into clickedPath
   if the number of items of clickedPath = 2 then
      put item 1 of clickedPath into suiteTitle
      -- put item 2 of clickedPath into shortHkey
   end if
   --
   put hKeyLine_AddObject (shortHkey, sObject) into hKey
   hkey_Edit hKey
end mDoubleUp_DisplayShortHkey

command mDoubleUp_DisplayStack indexView, stackName
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
end mDoubleUp_DisplayStack

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


--> Display
-
command display_SpotlightStacks pStackName
   if pStackName is empty then
      put lcw_Ask("Find a stack in LCW...", "lib_Display") into pStackName
   end if
   put merge ("Searched for '[[pStackName]]'") into someTitle
   --
   put spotlight_FindStack (pStackName) into stackPaths
   --
   display_StackPaths stackPaths, someTitle, pIndexView
   return the result
end display_SpotlightStacks

command display_StackPaths stackPaths, pSomeTitle, pIndexView
   local mUp
   
   if pSomeTitle is empty then put "Found Stacks" into pSomeTitle
   --
   put stack_ConstructNameNameArray (stackPaths) into nameArray
   -- put stack_PathsToNames (stackPaths) into stackNames
   put keys (nameArray) into stackNames
   sort stackNames
   
   put "Global | Project | Stacks | Tree | Menu" into titleMenu
   put "Global | Project | Stacks | Tree | Line | Menu" into lineMenu
   put "mDoubleUp_DisplayStack" into mDoubleUp
   --
   if exists (pIndexView) is false then
      display_Lines stackNames, pSomeTitle, mDoubleUp, "Stacks"
      put the result into indexView
      --
      set the title_Menu of indexView to titleMenu
      set the line_Menu of indexView to lineMenu
      set the field_Style of indexView to "click"
   else
      set the view_Index [pSomeTitle] of pIndexView to stackNames
   end if
   return pIndexView
end display_StackPaths

command display_Stacks stackNames, pSomeTitle, pIndexView
   if pSomeTitle is empty then put "Found" into pSomeTitle
   
   put "mDoubleUp_DisplayStack" into mDoubleUp
   
   if exists (pIndexView) is false then
      put empty into mUp
      display_Lines stackNames, pSomeTitle, mDoubleUp, "Stacks"
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to stackNames
      set the stack_Title of pIndexView to pStackTitle
      set the mouse_DoubleUp of pIndexView to mDoubleUp
      unlock screen
      return pIndexView
   end if
end display_Stacks


--> Stack | Names
-
function stack_ListNames pWhichNames
   switch pWhichNames
      default -- case "open but not rev"
         put the openstacks into someNames
         filter someNames without "rev*"
         line_Delete "Message Box", someNames
         sort someNames
         return someNames
   end switch
end stack_ListNames

function stack_ListObjects pWhichNames
   put stack_ListNames (pWhichNames) into stackNames
   repeat for each line stackName in stackNames
      put the name of stack stackName into stackObject
      put stackObject & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_ListObjects

function stack_LoadedWithoutFiles
   repeat for each line stackName in the mainstacks
      if the filename of stack stackName is empty then
         put stackName & CR after stackNamesWithoutFiles
      end if
   end repeat
   filter stackNamesWithoutFiles without "rev*"
   return word 1 to -1 of stackNamesWithoutFiles
end stack_LoadedWithoutFiles

function stack_GetSubStacks someFile
   set lockmessages to true
   put the mainstacks into oMainStacks
   if exists(stack someFile) is false then return empty
   
   put the short name of stack someFile into shortName
   put the substacks of stack someFile into subStackNames
   
   set the wholematches to true
   if not(shortName is among the lines of oMainStacks) then delete stack someFile
   set lockmessages to false
   return subStackNames
end stack_GetSubStacks


--> Stack | Outlines
-
function stack_SubStackOutline stackNames
   put empty into stackNameOutline
   repeat for each line stackName in stackNames
      put the substacks of stack stackname into subStackNames
      put stackName & return after stackNameOutline
      if subStackNames is not empty then
         put outline_IncreaseIndent(subStackNames, 1) & return after stackNameOutline
      end if
   end repeat
   delete last char of stackNameOutline
   return stackNameOutline
end stack_SubStackOutline

function stack_ConstructHtmlIndex someFiles, unknownColour
   set the itemdelimiter to "/"
   repeat for each line someFile in someFiles
      put stack_GetShortName(someFile) into stackName
      put opn_GetFileName(stackName) into opnFile
      if opnFile is empty then
         if unknownColour is empty then
            put html_ConstructNameLink(stackName, someFile) & CR after someOutline
         else
            put html_ConstructNameLink(stackName, someFile) into someLink
            put html_ConstructColouredText(someLink, unknownColour) & CR after someOutline
         end if
      else
         put html_ConstructNameLink(stackName, someFile) & CR after someOutline
      end if
   end repeat
   delete last char of someOutline
   return someOutline
end stack_ConstructHtmlIndex

function stack_ConstructHtmlOutline someFolder, rootFolder, unknownColour, tabBit
   local htmlOutline
   set the cursor to busy
   
   put the directory into oDirectory
   set the directory to someFolder
   
   put the files into shortFiles
   filter shortFiles without ".*"
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into someFile
      put stack_GetShortName(someFile) into stackName
      
      -- this also checks that the file is a stack
      if stackName is empty then next repeat
      if rootFolder is empty then
         put someFile into fileLink
      else
         put file_GetRelativePath(someFile, rootFolder, commonPath) into fileLink
      end if
      
      -- put html_ConstructNameLink(stackName, fileLink) into nameLink
      put opn_GetFileName(stackName) into opnFile
      if opnFile is empty then
         if unknownColour is empty then
            put html_ConstructNameLink(stackName, fileLink) into nameLink
         else
            get html_ConstructNameLink(stackName, fileLink)
            put html_ConstructColouredText(it, unknownColour) into nameLink
         end if
      else
         put html_ConstructNameLink(stackName, fileLink) into nameLink
      end if
      
      put tabBit & nameLink into osTilte
      put osTilte & CR after htmlOutline
   end repeat
   
   put the folders into newShortFolders
   filter newShortFolders without ".*"
   
   repeat for each line shortFolder in newShortFolders
      put someFolder & shortFolder & "/" into nestedFolder
      put tabBit & tab into nextTabBit
      put stack_ConstructHtmlOutline (nestedFolder, rootFolder, unknownColour, nextTabBit) into nestedOutline
      
      put tabBit & shortFolder into osTilte
      if nestedOutline is empty then
         -- don't bother if there are no stacks there.
      else
         put osTilte & CR after htmlOutline
         put nestedOutline & CR after htmlOutline
      end if
   end repeat
   delete char -1 of htmlOutline
   
   set the directory to oDirectory
   return htmlOutline
end stack_ConstructHtmlOutline

function stack_ConstructNameOutline someFolder, @infoArray, excludeFolderList, includeInvisible, tabBit
   local shortFileOutline
   
   set the cursor to busy
   
   put infoArray["FolderIndex"] into folderIndex
   put infoArray["FileIndex"] into fileIndex 
   line_Insert someFolder, folderIndex
   put folderIndex into infoArray["FolderIndex"]
   
   put the directory into oDirectory
   set the directory to someFolder
   put the files into shortFiles
   if includeInvisible is not false then filter shortFiles without ".*"
   
   put the mainstacks into stacksInMemory
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into someFile
      
      line_Insert someFile, fileIndex
      try
         put the short name of stack someFile into stackName
         if stackName is not among the lines of stacksInMemory then delete stack stackName
         put tabBit & stackName into osTilte
         line_Insert osTilte, shortFileOutline
      catch tError
         -- lcw_Notify someFile
      end try
   end repeat
   put fileIndex into infoArray["FileIndex"]
   
   put the folders into newShortFolders
   if includeInvisible is not false then filter newShortFolders without ".*"
   
   repeat for each line shortFolder in newShortFolders
      if shortFolder is among the items of excludeFolderList then next repeat
      put someFolder & shortFolder & "/" into nestedFolder
      
      put tabBit & tab into nextTabBit
      put stack_ConstructNameOutline(nestedFolder, infoArray, excludeFolderList, includeInvisible, nextTabBit) into nestedOutline
      
      put tabBit & shortFolder into osTilte
      if nestedOutline is empty then
         -- don't bother if there are no stacks there.
         -- line_Insert osTilte, shortFileOutline
      else
         line_Insert osTilte, shortFileOutline
         put return & nestedOutline after shortFileOutline
      end if
   end repeat
   
   set the directory to oDirectory
   return shortFileOutline
end stack_ConstructNameOutline

function stack_OutlineFromObjectArray objectArray
   local stackArray
   repeat for each key objectName in objectArray
      put objectArray [objectName] into someObject
      object_Deconstruct someObject, someControl, cardObject, stackName
      indexArray_Add objectName, stackName, stackArray
   end repeat
   put array_ExpandSorted(stackArray, true) into stackOutline
   return stackOutline
end stack_OutlineFromObjectArray


--> Private
-
