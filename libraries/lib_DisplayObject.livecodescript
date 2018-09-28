script "lib_DisplayObject"
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
   put hKeyLine_Construct (shortHkey, hObject) into hKeyLine
   hkey_Edit hKeyLine
end mDouble_EditHkey


--> Display | Object
-
command display_ScriptObject scriptObject, someTitle, pHkeys
   put the project_Name of scriptObject into stackLabel
   if stackLabel is empty then put "Object" into stackLabel
   put merge ("[[the name of scriptObject]],[[stackLabel]]") into someTitle
   
   if pHkeys is empty then put the script_ShortHkeys of scriptObject into pHkeys
   put "mDouble_EditHkey" into mDoubleUp
   
   put empty into mUp
   put "Global | Script | Tree | Menu" into mTitle
   put "Global | Script | Tree | Line | Menu" into mLineTitle
   
   display_Index pHkeys, someTitle, mTitle, mLineTitle, mUp, mDoubleUp
   put the result into indexView
   set the displayed_Object of indexView to scriptObject
   set the multiple_Hilites of indexView to false
   return indexView
end display_ScriptObject
