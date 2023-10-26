script "Global | ScriptEditor | Header | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Header | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [seTarget]
   put the se_DisplayedObject of seTarget into scriptObject
   return scriptObject
end menu_Target


--> Global | ScriptEditor | Header | Dev | Menu
-
on menu_FormatScript scriptObject
   put the se_Name of LocalArray ["seTargetControl"] into seName
   --
   se_FormatAndApply seName
   put the script_Diff of scriptObject 
end menu_FormatScript

on menu_TestIsDifferent scriptObject
   -- put DiffCompareFiles (pFrom, pTo, pContext)
   put the exported_Script of scriptObject into exportedScript
   put the name of scriptObject into sTitle
   display_Text exportedScript, sTitle, "the exported_Script"
   --
   script_ExportAndIndexMenus scriptObject
end menu_TestIsDifferent
