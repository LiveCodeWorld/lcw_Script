script "Global_Script_PlaceArray_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_PlaceArray_Menu
type: controller
version: 0.1

/*
This menu was "Global | Script | Menu"
*/


--> Menu | Props
-
getprop menu_Target [mTitlePath]
   -- not called in nested menus
   -- so will be called when used directly in a display_Index palette
   put _getScriptObject() into scriptObject
   return scriptObject
end menu_Target

private function _getScriptObject
   put menu_GetTopTargetObject() into mTarget
   put the index_View of mTarget into indexView
   if exists (indexView) then
      put the view_Object of mTarget into someView
      if exists (someView) is false then return mTarget
      put the displayed_Object of someView into scriptObject
   else  
      put scriptEditor_Object() into scriptObject
   end if
   return scriptObject
end _getScriptObject

on menu_Init mTarget
   put the index_View of mTarget into indexView
   if exists (indexView) then
      put the displayed_Object of indexView into scriptObject
      put the script_FirstHkeys [true] of scriptObject into shortHkeys
      set the view_Index of scriptObject to shortHkeys
   else
      -- beep
   end if
end menu_Init


--> Global | Script | PlaceArray | Menu
-
on menu_ExportHandlersAndCalls scriptObject
   script_UpdateHarrayAndExport scriptObject, true
   put the result into scriptFile
end menu_ExportHandlersAndCalls

on menu_UpdateHandlerHashArray scriptObject
   object_UpdateHandlerHashArray scriptObject, true
end menu_UpdateHandlerHashArray scriptObject

on _
end _

on menu_DisplayHkeyPlaceArray scriptObject
   put the script_HkeyPlaceArray of scriptObject into hkeyPlaceArray
   
   display_Array hkeyPlaceArray, scriptObject
   put the result into indexView
   set the displayed_Object of indexView to scriptObject
end menu_DisplayHkeyPlaceArray

on menu_ExportScriptAndIndexMenus scriptObject
   put the dataObject_Folder of scriptObject into scriptObjectFolder
   revDeleteFolder scriptObjectFolder
   script_ExportAndIndexMenus scriptObject
   put the exported_Script of scriptObject
end menu_ExportScriptAndIndexMenus

on _
end _

-- on submenu_EditScripts
return "Global | Script | Edit | Menu"
end submenu_EditScripts

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditScriptHelp scriptObject
   put the script_Help of scriptObject into scriptHelp
   put lcw_Ask (merge("Give a description for [[scriptObject]]..."), scriptHelp) into scriptHelp
   set the script_Help of scriptObject to scriptHelp
   lcw_Notify merge ("Saved description for [[scriptObject]].")
end menu_EditScriptHelp

on _
end _

on menu_DeleteObjectFromPlaceArray scriptObject
   hkeyline_DeletePlaceObject scriptObject
   put the result into deletedHkeys
   display_Index deletedHkeys, "Removed from Place array"
end menu_DeleteObjectFromPlaceArray

on menu_AddObjectToPlaceArray scriptObject
   hkeyline_DeletePlaceObject scriptObject
   put the result into deletedHkeys
   display_Index deletedHkeys, "Removed from Place array"
end menu_AddObjectToPlaceArray

on menu_AddScriptHandlersToLibrary scriptObject, someBoolean
   library_ExportAllHandlersFromObject scriptObject, someBoolean
end menu_AddScriptHandlersToLibrary

on menu_OpenHandlerLibraryFolder
   put library_HkeyFolder (empty, false) into hkeyFolder
   finder_Reveal hkeyFolder
end menu_OpenHandlerLibraryFolder


--> Global | Script | PlaceArray | Menu | Props
-

--> Global | Script | PlaceArray | Menu | Disabled
-
getprop disabled_DisplayFoundCalls [stackObject]
   if word 1 of stackObject is not "stack" then return true
   return the scriptonly of stackObject is false
end disabled_DisplayFoundCalls

getprop disabled_AnalizeScript [scriptObject]
   return false
   if LocalArray ["overlayNames"] is empty then
      return "delete"
   else
      return false
   end if
end disabled_AnalizeScript
