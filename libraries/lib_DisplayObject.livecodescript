script "lib_DisplayObject"
--> MetaData
-
license: GPLv3
name: lib_DisplayObject
type: library
version: 0.1


--> Display | Missing
-
command display_MissingHkeys hKeys, pObject
   if exists (pObject) then
      put the name of pObject into sTitle
   else
      put "Hkeys" into sTitle
   end if
   
   display_Tool hKeys, sTitle, "Missing Hkey", "lcw_Script"
   put the result into dView
   set the displayed_object of dView to pObject
   return dView
end display_MissingHkeys

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
   put the result into dView
   set the displayed_object of dView to pObject
   return dView
end display_MissingHkey


--> Display | Script | Walk
-
command display_ScriptDeps sObject, pGraphStyle
   put the script_HkeyArrayFile of sObject into sFile
   if there is a file sFile then
      put the script_HkeyArray of sObject into hKeyArray
      lcw_Notify "Using already created hkeyArray file!"
   else if the module_Name of sObject is empty then
      breakpoint
      put the walk_HkeyArray of sObject into hKeyArray
      set the script_HkeyArray of sObject to hKeyArray
   else
      breakpoint
      put the module_BehaviorDepHkeyArray of sObject into hKeyArray
      set the script_HkeyArray of sObject to hKeyArray
   end if
   --
   display_ScriptHkeyArrayDeps hkeyArray, sObject, pGraphStyle
   put the result into dView
   return dView
end display_ScriptDeps

command display_ScriptHkeyArrayDeps hkeyArray, sObject, pGraphStyle
   put the name of sObject into sTitle
   
   # Display HkeyArray
   display_HkeyArrayDeps hkeyArray, sTitle
   put the result into dView
   set the displayed_Object of dView to sObject
   set the displayed_Style of dView to "projects"
   
   # Draw and Display Graph
   if pGraphStyle is not empty then
      graph_CreateFromScriptHkeyArray hkeyArray, sObject, pGraphStyle
      put the result into svgFile
      --
      put the name of sObject into sLabel
      display_SVG svgFile, sLabel
   end if
   return dView
end display_ScriptHkeyArrayDeps

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
