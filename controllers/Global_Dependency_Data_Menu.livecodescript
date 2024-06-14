script "Global | Dependency | Data | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dependency | Data | Menu
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
   -- put display_MenuTarget (tObject) into dView
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Dependency | Data | Menu
-
on menu_DraftHelp dView
   put the displayed_Object of dView into sObject
   -- put the name of sObject
   --
   draft_ScriptHelp sObject
end menu_DraftHelp

private on _
end _

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Dependency | Data | Menu")
end submenu_Dev
