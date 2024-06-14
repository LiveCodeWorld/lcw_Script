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
   switch
      case line 1 of sPath = "Missing"
         _FindMissing sPath, dView
         break
      default
         put _ProjectDepKeys (dView)
   end switch
   --
   return displayView
end mDoubleUp_ScriptDep

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

command _FindMissing sPath, displayView
   switch the number of lines of sPath
      case 4
         put line -1 of sPath into hKey
         put line -2 of sPath into shortMissingHkey
         --
         put the displayed_Object of displayView into sObject
         put the displayed_HkeyArray of displayView into hkeyArray
         --
         hkey_Edit hKey
         --
         -- display_MissingHkey hkeyArray, sObject
         break
      case 3
         put line 3 of sPath into objectHkeyParent
         hkey_Edit objectHkeyParent
         break
      default
         put line -1 of sPath into hObject
         hkey_Edit hObject
   end switch
end _FindMissing

function _ProjectDepKeys dView
   put the top_Data [2] of dView into stackArray
   repeat for each key stackObject in stackArray
      put stackArray [stackObject] into hkeyData
      put keys (hkeyData) into hkeys
      put hKeys & CR after depKeys
   end repeat 
   delete char -1 of depKeys
   return depKeys  
end _ProjectDepKeys


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

getprop disabled_EditHkey [dView]
   put the selected_Line of dView into hKey
   if is_Hkey (hKey) then
      return false
   else
      return true
   end if
end disabled_EditHkey

getprop disabled_FindMissing [dView]
   return item 1 of LocalArray ["sPath"] is not "Missing"
end disabled_FindMissing

-- getprop disabled_CollectMissing [dView]
   return item 1 of LocalArray ["sPath"] is not "Missing"
end disabled_CollectMissing


--> Global | Script | Dep | Line | Menu
-
on menu_EditHkey dView
   _DeconstructPath dView, pName, sObject, depKey, callKeys
   --
   hkey_Edit depKey
end menu_EditHkey

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

on menu_FindMissing dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   
   put the found_Hkey [shortMissingHkey] of sObject into foundKey
   if foundKey is empty then
      breakpoint
   else
      hkey_Edit foundKey
   end if
end menu_FindMissing

private on __
end __

on menu_Info dView
   _DeconstructPath dView, pName, sObject, depKey, callKeys
   --
   get pName,sObject,depKey,callKeys
   replace comma with CR in it
   put it
end menu_Info
