script "Global | HkeyArray | Missing | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | HkeyArray | Missing | Line | Menu
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
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return true
end menu_CheckTarget


--> Global | HkeyArray | Missing | Line | Menu
-
on menu_SelectedPath displayView
   put the selected_Path of displayView
end menu_SelectedPath

