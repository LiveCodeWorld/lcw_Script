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
   -- called first
   pass menu_Target
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Script | Dep | Line | Menu
-
on menu_TestChecked
  put menu_GetChecked (the params)
end menu_TestChecked

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
