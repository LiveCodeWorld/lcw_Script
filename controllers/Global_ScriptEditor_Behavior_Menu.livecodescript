script "Global | ScriptEditor | Behavior | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | ScriptEditor | Behavior | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
getprop checked_HandlerField
   put rev_HandlerTreeField() into topHanderField
   if exists (topHanderField) is false then return false
   --
   put scriptEditor_HandlerListBehavior() into bObject
   if exists (bObject) is false then return false
   --
   get the behavior of topHanderField
   put it = bObject into someBoolean
   return someBoolean
end checked_HandlerField

getprop checked_RecentButton
   put rev_HistoryButton() into topRecentButton
   if exists (topRecentButton) is false then return false
   --
   put scriptEditor_HistoryButtonBehavior() into bObject
   if exists (bObject) is false then return false
   --
   get the behavior of topRecentButton
   put it = bObject into someBoolean
   return someBoolean
end checked_RecentButton


--> Global | ScriptEditor | Behavior | Menu
-
on menu_RecentButton mTarget
   put rev_HistoryButton() into topRecentButton
   --
   put scriptEditor_CompileButtonBehavior() into bObject
   set the behavior of topRecentButton to bObject
end menu_RecentButton

on menu_HandlerField mTarget
   put rev_HandlerTreeField() into topHanderField
   put scriptEditor_HandlerListBehavior() into bObject
   --
   put menu_GetChecked (the params) into isChecked
   --
   if isChecked then
      set the behavior of topHanderField to empty
   else
      set the behavior of topHanderField to bObject
   end if
end menu_HandlerField
