script "Global | Rename | Menu | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Rename | Menu | Menu
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
   put the display_View of tObject into dView
   return dView
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Rename | Menu | Menu
-
on menu_EditMenu dView
   put the displayed_Data of dView into dData
   put dData ["mTitle"] into mTitle
   --
   menu_Edit mTitle
end menu_EditMenu

on menu_EnvironmentMenus dView
   put the displayed_Data of dView into dData
   put dData ["mTitle"] into mTitle
   --
   display_EnvironmentMenus false, mTitle
end menu_EnvironmentMenus

getprop disabled_EditMenu [dView]
   put the displayed_Data of dView into dData
   put dData ["mTitle"] into mTitle
   --
   put menu_GetGlobalController(mTitle) into mController
   return exists (mController) is false
end disabled_EditMenu

on menu_FixControllerName dView
   put the displayed_Data of dView into dData
   put dData ["mController"] into mController
   if exists (mController) is false then
      breakpoint
   end if
   --
   ask_FixMenuControllerStackName mController
   put the result into newStackName
end menu_FixControllerName

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
   return menu_DevTitle ("Global | Rename | Menu | Menu")
end submenu_Dev
