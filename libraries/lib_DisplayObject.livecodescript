﻿script "lib_DisplayObject"
--> MetaData
-
license: GPLv3
name: lib_DisplayObject
type: library
version: 0.1


--> Display | Events
-
on mDouble_EditHkey indexView, shortHkey
   put the displayed_Object of indexView into hObject
   put hKeyLine_AddObject (shortHkey, hObject) into hKeyLine
   hkey_Edit hKeyLine
end mDouble_EditHkey

on mDoubleUp_ScriptDep displayView, someValue, sPath
   -- put the selected_Array of displayView into sArray
   -- put the parent_Array of displayView into sValue
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
         display_MissingHkey hkeyArray, sObject
         break
      case 3
         put line 3 of sPath into objectHkeyParent
         hkey_Edit objectHkeyParent
         break
      default
         put line -1 of sPath into hObject
         hkey_Edit hObject
   end switch
   --
   return displayView
end mDoubleUp_ScriptDep

on mDoubleUp_MissingHkey displayView, someLine
   put the title_Text of displayView into someTitle
   return displayView
end mDoubleUp_MissingHkey

command display_MissingHkey hkeyArray, pObject
   get hkeyArray_GetStackDepArray (hkeyArray)
   put it ["Missing"] into missingArray
   --
   if exists (pObject) then
      put the name of pObject into sTitle
   else
      put "HkeyArray" into sTitle
   end if
   display_Data missingArray, sTitle, "Missing Hkeys"
   display_SetInteractions the result, "HkeyArray | Missing", "mDoubleUp_MissingHkey"
   return the result
end display_MissingHkey


--> Display | Script | Walk
-
command display_ScriptDeps sObject
   -- put the hkey_ScriptHierarchy of sObject into searchObjects
   -- see "display_TransportObjectDeps" which uses the same "walk_GetObjectHkeyArray"
   
   put the walk_HkeyArray of sObject into hKeyArray
   -- put hkeyArray_GetStackDepArray (hkeyArray) into dArray
   --
   put the name of sObject into sTitle
   --
   display_HkeyArrayDeps hkeyArray, sTitle
   put the result into displayView
   --
   set the displayed_Object of displayView to sObject
   set the displayed_Style of displayView to "projects"
   --
   return displayView
end display_ScriptDeps

command display_HkeyArrayDeps hkeyArray, sTitle
   put hkeyArray_GetProjectDepArray (hkeyArray) into dArray
   --
   display_Data dArray, sTitle, "Script Deps"
   put the result into displayView
   --
   display_SetInteractions displayView, "Script | Dep", "mDoubleUp_ScriptDep"
   --
   set the displayed_HkeyArray of displayView to hkeyArray
   return displayView
end display_HkeyArrayDeps


--> Display
-
command display_ScriptObject scriptObject, someTitle, pHkeys
   put the project_Name of scriptObject into stackLabel
   if stackLabel is empty then put "Object" into stackLabel
   put merge ("[[the name of scriptObject]],[[stackLabel]]") into someTitle
   
   if pHkeys is empty then put the script_ShortHkeys of scriptObject into pHkeys
   put "mDouble_EditHkey" into mDoubleClick
   
   put empty into mUp
   put "Global | Script | Tree | Menu" into mTitle
   put "Global | Script | Tree | Line | Menu" into mLineTitle
   
   display_Index pHkeys, someTitle, mTitle, mLineTitle, mUp, mDoubleClick
   put the result into indexView
   set the displayed_Object of indexView to scriptObject
   set the multiple_Hilites of indexView to false
   return indexView
end display_ScriptObject
