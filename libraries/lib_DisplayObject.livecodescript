script "lib_DisplayObject"
--> MetaData
-
license: GPLv3
name: lib_DisplayObject
type: library
version: 0.1


--> Display | Script | Walk
-
command display_ScriptDeps sObject, pGraphStyle
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
   
   # Draw Graph
   if pGraphStyle is not empty then
      graph_CreateFromScriptHkeyArray hkeyArray, sObject, pGraphStyle
      put the result into svgFile
      --
      put the name of sObject into sLabel
      display_SVG svgFile, sLabel
   end if
   
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


--> Display | Events
-
on mDouble_EditHkey indexView, shortHkey
   breakpoint
   put the displayed_Object of indexView into hObject
   put hKeyLine_AddObject (shortHkey, hObject) into hKeyLine
   hkey_Edit hKeyLine
end mDouble_EditHkey

on mDoubleUp_MissingHkey displayView, someLine
   breakpoint
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
