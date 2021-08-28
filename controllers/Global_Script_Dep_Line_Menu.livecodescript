script "Global | Script | Dep | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Script | Dep | Line | Menu
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

getprop disabled_EditHkey [dView]
   put the selected_Line of dView into hKey
   if is_Hkey (hKey) then
      return false
   else
      return true
   end if
end disabled_EditHkey


--> Global | Script | Dep | Line | Menu
-
on menu_EditHkey dView
   put the selected_Line of dView into hKey
   hkey_Edit hKey
end menu_EditHkey

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
