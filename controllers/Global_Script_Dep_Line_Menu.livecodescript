script "Global | Script | Dep | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Script | Dep | Line | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Display | Events
-
on mDoubleUp_ScriptDep dView, someValue, sPath
   if the optionKey is "Down" then breakpoint
   --
   put the selected_Path of dView into sPath
   --
   _Find sPath, dView
   --
   return dView
end mDoubleUp_ScriptDep

command _Find sPath, dView
   replace comma with CR in sPath
   put the displayed_Object of dView into sObject
   
   switch the number of lines of sPath
      case 4
         put line -1 of sPath into hKey
         put line -2 of sPath into shortMissingHkey
         --
         put the displayed_HkeyArray of dView into hkeyArray
         --
         hkey_Edit hKey
         --
         -- display_MissingHkey hkeyArray, sObject
         break
      case 3
         put line 3 of sPath into objectHkeyParent
         hkey_Edit objectHkeyParent
         break
      case 1
         put sPath into hKey
         if word -1 of hKey = "Missing" then
            put _FindMissing (hKey, sObject) into hKey
            if hKey is empty then
               put sPath
            else
               hkey_Edit hKey
            end if
         else
            hkey_Edit hKey
         end if
         break
      default
         put line -1 of sPath into hObject
         hkey_Edit hObject
   end switch
end _Find

private function _FindMissing shortHkey, sObject
   put word 1 to 2 of shortHkey into shortHkey
   
   if exists (sObject) then
      put the walk_Hierarchy of sObject into searchObjects
   else
      put env_ScriptHierarchy (true) into searchObjects
   end if
   --
   put hkey_FindPublicOrPrivate (shortHkey, searchObjects) into hKey
   return hkey
end _FindMissing

function _ProjectDepKeys dView
   put the top_Data [2] of dView into stackArray
   delete variable stackArray ["top"]
   put keys (stackArray) into hkeys
   return hkeys  
end _ProjectDepKeys

private command _DeconstructPath dView, @pName, @sObject, @depKey, @callKeys
   put the selected_Path of dView into sPath
   --
   put item 1 of sPath into pName
   put item 2 of sPath into sObject
   put item 3 of sPath into depKey
   --
   -- put item 4 of sPath into callKey -- issue: could be "top"
   -- put the selected_TopData [item 1 to 3 of sPath] of dView into sArray
   put the top_Data [3] of dView into sArray
   delete variable sArray ["top"]
   put keys(sArray) into callKeys
   --
   return sPath
end _DeconstructPath


--> Menu | Props
-
getprop menu_Target [tObject]   
   put the display_View of tObject into dView
   --
   put the selected_Path of dView into sPath
   put sPath into LocalArray ["sPath"]
   --
   return dView
end menu_Target


--> Global | Script | Dep | Line | Menu
-
on menu_FindMissing dView
   put the displayed_Object of dView into sObject
   put the selected_Line of dView into shortMissingHkey
   
   # Find All
   -- put the found_Hkey [shortMissingHkey] of sObject into foundKeys
   put the hkey_FindAll [shortMissingHkey] of sObject into foundKeys
   switch
      case foundKeys is empty
         put shortMissingHkey
         break
      case the number of lines of foundKeys = 1
         hkey_Edit foundKeys
         break
      default
         display_MissingHkeys foundKeys, sObject
   end switch
end menu_FindMissing

-- getprop disabled_FindMissing [dView]
   if the tree_IsIndex of dView is true then return false
   
   return item 1 of LocalArray ["sPath"] is not "Missing"
end disabled_FindMissing

on menu_EditHkey dView
   put the selected_Path of dView into sPath
   put the number of items of sPath into pNum
   put item 1 of sPath into pName
   put item -1 of sPath into shortHkey
   --
   switch
      case pNum = 4
         put item 4 of sPath into hKey
         break
      case pName is "Missing"
         break
      case pNum = 3
         put item 2 of sPath into sObject
         put the hkey_Either [shortHkey] of sObject into hkey
         break
      default
         put the displayed_Object of dView into sObject
         put _FindMissing (shortHkey, sObject) into hKey
   end switch
   --
   hkey_Edit hKey
end menu_EditHkey

getprop disabled_EditHkey [dView]
   -- put the selected_Path of dView into sPath
   put LocalArray ["sPath"] into sPath
   put item 3 of sPath into shortHkey
   switch the number of items of sPath
      case 3
      case 4
         return false
         break
      default
         return true
   end switch
end disabled_EditHkey

on menu_EditScript dView
   _DeconstructPath dView, pName, sObject, depKey, callKeys
   --
   edit the script of sObject
end menu_EditScript

on menu_DraftHelp dView
   _DeconstructPath dView, pName, sObject, depKey, callKeys
   --
   draft_HandlerHelp depKey 
end menu_DraftHelp

private on _
end _

on menu_CollectProjectDeps dView
   put _ProjectDepKeys (dView) into depKeys
   put the title_Text of dView into pTitle
   --
   display_ScriptFromHkeys depKeys, pTitle
end menu_CollectProjectDeps

private on __
end __

on menu_AddToExtraDictionary dView
   put the selected_Line of dView into shortHkey
   put word 2 of shortHkey into pName
   put lcw_Ask ("Add term to extra dictionary?", pName, dView) into newTerm
   --
   ide_AddToDictionaryTerms newTerm
   --
   menu_Refresh dView
end menu_AddToExtraDictionary

on menu_DeleteElement dView
   put the selected_Path of dView
end menu_DeleteElement

on menu_Refresh dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   display_ScriptHkeyArrayDeps hkeyArray, sObject
end menu_Refresh
