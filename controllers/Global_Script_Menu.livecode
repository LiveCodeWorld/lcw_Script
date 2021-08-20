script "Global | Script | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Menu
type: controller
version: 0.5


--> Menu | Init
-
getprop menu_Target [tObject]
   put the displayed_Object of tObject into sObject
   
   if exists (sObject) is false then
      -- quick hack (should be a different menu)
      put the display_View of tObject into displayedView
      if exists (displayedView) is false then return tObject
      
      -- probably a display / index view showing the project lcw_Script
      put the title_Text of displayedView into projectName
      put the name of stack projectName into homeStackObject
      return homeStackObject
   else
      return sObject
   end if
end menu_Target

getprop menuStyle_Param [sObject]
   return the menu_Style of sObject
end menuStyle_Param

getprop menuStyle_Params
   return "Array,Old"
end menuStyle_Params

getprop setMenu_Param
   return ide_ShortTitle ("Recent")
end setMenu_Param

getprop setMenu_Params
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end setMenu_Params

getprop disabled_Compile
   put scriptEditor_CompileButtonBehavior() into bObject
   return exists (bObject) is false
end disabled_Compile

getprop disabled_History
   put scriptEditor_HistoryButtonBehavior() into bObject
   return exists (bObject) is false
end disabled_History

getprop disabled_Script
   put scriptEditor_ScriptFieldBehavior() into bObject
   return exists (bObject) is false
end disabled_Script

getprop disabled_Handler
   put scriptEditor_HandlerListBehavior() into bObject
   return exists (bObject) is false
end disabled_Handler

getprop disabled_Search
   put scriptEditor_FindFieldBehavior() into bObject
   return exists (bObject) is false
end disabled_Search


--> Global | Script | Menu
-
on menu_EditObjectScript sObject
   edit the script of sObject
end menu_EditObjectScript

on menu_EditObjectBehavior sObject
   put the behavior of sObject into bObject
   --
   edit the script of bObject
end menu_EditObjectBehavior

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _MenuStyle sObject, mStyle
   set the menu_Style of stack "lib_MenuArray" to mStyle
end _MenuStyle

on _
end _

on _Compile
   put scriptEditor_CompileButtonBehavior() into bObject
   edit the script of bObject
end _Compile

on _History
   put scriptEditor_HistoryButtonBehavior() into bObject
   edit the script of bObject
end _History

on _Script
   put scriptEditor_ScriptFieldBehavior() into bObject
   edit the script of bObject
end _Script

on _Handler
   put scriptEditor_HandlerListBehavior() into bObject
   edit the script of bObject
end _Handler

on _Search
   put scriptEditor_FindFieldBehavior() into bObject
   edit the script of bObject
end _Search

on _
end _

on _TestRecentMenu
   put "Recent" into ideElement
   put "Watch" into shortTitle
   --
   put ide_ConstructMenuController (ideElement, shortTitle) into mController
   if exists (mController) is true then
      menu_LoadFromScript mController
      put the result into menuTitleArray
   end if
   --
   ide_SetMenuTitle ideElement, shortTitle
   put ide_GetMenuTitle (ideElement) into mTitle
   --
   put ide_GetMenuController (ideElement) into mController
   put menu_GetGlobalController (mTitle) into mController
   --
   edit the script of mController
end _TestRecentMenu
