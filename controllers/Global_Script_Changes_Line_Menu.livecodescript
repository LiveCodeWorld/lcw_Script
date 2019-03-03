script "Global_Script_Changes_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Changes_Line_Menu
type: controller
version: 0.1


--> Global | Script | Changes | Line | Menu
-
on menu_DisplayLocalChanges indexView
   put the selected_Index of indexView into scriptObject
   
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges


--> Global | Script | Changes | Line | Menu | Props
-

--> Global | Script | Changes | Line | Menu | Disabled
-
