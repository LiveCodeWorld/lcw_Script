﻿script "Global_Script_Exported_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Exported_Menu
type: controller
version: 0.1

/*
These tools work on exported scripts.

The menu_target for these handlers is the scriptObject that owns the script currently presented by the Script Editor.
These menu tools should therefore work equally well on any LiveCode object,
and in particular either along side any of the more specific version control tools for GIT or Fossil.
*/


--> Global | Script | Exported | Menu
-
on menu_CheckRecentScriptExports
   put lcw_Ask ("Search for scripts that changed in the last howmany minutes?", 20) into pMinutes
   put pMinutes * 60 into pSeconds
   
   -- put spotlight_ListRecentlyExportedObjectScripts (pSeconds) into someObjects
   if pSeconds is empty then put 20 * 60 into pSeconds
   put spotlight_ListRecentlyExportedScriptFiles (pSeconds) into scriptFiles
   
   local pMouseDoubleUpHandler, pTitleMenu
   put merge ("Files changed in last [[pMinutes]] minutes") into pTitle
   put $HOME into pFolderToStrip
   display_Files scriptFiles, pFolderToStrip, pMouseDoubleUpHandler, pTitleMenu, pTitle
   
   -- display_Outline someObjects, "Recently Exported Script Objects"
   -- display_Index someObjects, "Recently Exported Script Objects"
   -- _DisplayFoundDifferences someObjects, "Could not find any errors in the objects of recently exported scripts!"
end menu_CheckRecentScriptExports

-- on menu_CheckAllScriptExports
   set the cursor to watch
   put spotlight_ListExportedScriptFiles() into scriptFiles
   put script_FileToObject (scriptFiles) into someObjects
   
   _DisplayFoundDifferences someObjects, "Could not find any errors in all the objects of exported scripts!"
end menu_CheckAllScriptExports

on menu_DisplayMergeScript sObject
   if exists (sObject) then
      put the mergeScript_File of sObject into scriptFile
   else
      put the dataObject_Folder of sObject into someFolder
      answer file "Choose a script file to display..." with someFolder
      put it into scriptFile
      if it is empty then exit to top
   end if
   --
   put url ("file:" & scriptFile) into mergeScript
   put script_MergeHandlers (scriptFile, mergeScript) into someScript
   --
   put someScript
   --
   set the itemdelimiter to slash
   put item -2 of scriptFile into rObject
   if item -4 of scriptFile = "substacks" then
      put item -7 of scriptFile into mStackName
      put item -3 of scriptFile into substackName
      
      put mStackName into stackLabel
      put rObject && "of stack" && kwote (substackName) into someTitle
   else
      put item -3 of scriptFile into stackLabel
   end if
   --
   display_TextFile scriptFile, someTitle, "Global | Script | Merge | Menu", stackLabel
   put the result into displayView
   return displayView
end menu_DisplayMergeScript

on _
end _

on menu_EditExportedScript scriptObject
   put the exported_Script of scriptObject into exportedScript
   script_CreateAndEditHashCard exportedScript
end menu_EditExportedScript

on menu_EditRawExportedScript scriptObject
   put the exported_Script [true] of scriptObject into exportedScript
   script_CreateAndEditHashCard exportedScript
end menu_EditRawExportedScript


--> Menu | Props
-

--> Deps
command _DisplayFoundDifferences someObjects, someComment
   put script_ConstructExportErrorArray (someObjects) into exportErrorArray
   
   if exportErrorArray is not an array then
      lcw_Notify someComment, true
      return empty
   end if
   
   put "Scripts which differ from exported scripts" into someTitle
   display_Array exportErrorArray, someTitle, "Global | Script | Duplicates | Menu", "Global | Script | Duplicates | Line | Menu", empty, "display_ObjectScript"
   put the result into treeView
 
   return exportErrorArray
end _DisplayFoundDifferences

