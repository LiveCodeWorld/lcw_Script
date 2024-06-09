script "Global | ScriptEditor | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop editHackBehavior_Params
   put project_ListBehaviorStackNames ("lcw") into stackNames
   return stackNames
end editHackBehavior_Params

getprop editMenu_Params
   put ide_ListMenuElements() into shortNames
   return shortNames
end editMenu_Params

getprop menuSet_Param
   return ide_ShortTitle ("Recent")
end menuSet_Param

getprop menuSet_Params
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end menuSet_Params

getprop editIdeBehavior_Params
   return ide_ListToolBarBehaviorNames()
end editIdeBehavior_Params


--> Global | ScriptEditor | Menu
-
on menu_EditMenu mTarget, mTitle
   ide_EditMenu mTitle
end menu_EditMenu

on menu_MenuSet mTarget, mTitle
   ide_SetScriptEditorTitles mTitle
end menu_MenuSet

private command _
end _

on submenu_SetIdeBehavior
   return "Global | ScriptEditor | Behavior | Menu"
end submenu_SetIdeBehavior

on menu_EditIdeBehavior mTarget, bName
   edit the script of stack bName
end menu_EditIdeBehavior

on menu_EditHackBehavior sObject, stackName
   edit the script of stack stackName
end menu_EditHackBehavior

private command __
end __

on menu_InitLcw
   ide_InitLcw
end menu_InitLcw

on menu_ResetIdeMenus
   ide_ResetMenus
end menu_ResetIdeMenus
