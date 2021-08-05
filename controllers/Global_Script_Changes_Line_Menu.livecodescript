script "Global_Script_Changes_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Changes_Line_Menu
type: controller
version: 0.3


--> Global | Script | Changes | Line | Menu
-
on menu_DisplayLocalChanges indexView
   put the selected_Index of indexView into scriptObject
   --
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject & CR into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on _
end _

on menu_ImportExported indexView
   put the selected_Index of indexView into scriptObject
   --
   lcw_Answer "Re-import the exported script for this object?", indexView
   --
   scriptEditor_CloseTab scriptObject, true, false, false
   --
   put the script of scriptObject into nowScript
   set the clipboardData ["text"] to nowScript
   --
   put the exported_Script of scriptObject into exportedScript
   set the script of scriptObject to exportedScript
   --
   edit the script of scriptObject
   --
   lcw_Notify "Not saved changed scriptObject. Copied objects script to clipboard in case you change your mind!"
end menu_ImportExported

on menu_SaveStack indexView
   put the selected_Index of indexView into scriptObject
   --
   put the stack_Name of scriptObject into stackName
   save stack stackName
   --
   put the name of stack stackName into stackObject
   answer merge ("Saved [[stackObject]]")
end menu_SaveStack

on _
end _

on menu_EditScript indexView
   put the selected_Index of indexView into scriptObject
   --
   edit the script of scriptObject
end menu_EditScript

on menu_CloseScriptEditorTab indexView
   put the selected_Index of indexView into scriptObject
   --
   scriptEditor_CloseTab scriptObject, true, false, false
end menu_CloseScriptEditorTab

on menu_TidyScriptLines indexView
   put the selected_Index of indexView into scriptObject
   --
   put the script of scriptObject into nowScript
   text_StripTrailingSpaces nowScript
   set the script of scriptObject to nowScript
   --
   script_ExportHandlersAndCalls scriptObject
   --
   display_RecentExports
end menu_TidyScriptLines
