script "Global | Edited | Tree | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Edited | Tree | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called once for each menu
   return tObject
end menu_Target


--> Global | Edited | Tree | Line | Menu
-
on menu_DisplayLocalChanges indexView
   breakppoint
   put the selected_Line of indexView into stackName
   put the name of stack stackName into scriptObject
   --
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
