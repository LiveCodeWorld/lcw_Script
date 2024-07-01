script "Global | Hkey | Calls | Outside | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Hkey | Calls | Outside | Line | Menu
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
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Hkey | Calls | Outside | Line | Menu
-
on menu_HkeyCallsOutsideLine dView
   put the selected_Path of dView into sPath
   put item 2 of sPath into shortHkey
   put item 3 of sPath into sObject
   put item 4 of sPath into hKey
   --
   put handler_Get (hKey, true)
end menu_HkeyCallsOutsideLine

getprop disbled_HkeyCallsOutsideLine [dView]
   put the selected_Path of dView into sPath
   return item 1 of sPath is not "shortHkeyArray"
end disbled_HkeyCallsOutsideLine

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
   return menu_DevTitle ("Global | Hkey | Calls | Outside | Line | Menu")
end submenu_Dev
