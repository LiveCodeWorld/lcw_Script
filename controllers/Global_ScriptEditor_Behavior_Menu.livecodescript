script "Global | ScriptEditor | Behavior | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Behavior | Menu
type: controller
version: 0.3

/*
This menu lets you access intereting IDE behaviors.
.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [seTarget]
   put the se_DisplayedObject of seTarget into sObject
   return sObject
end menu_Target

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

getprop disabled_AfterActionCompile [sObject]
   put exists (stack "behavior_RevSEStackBehavior") into bExists
   return bExists is false
end disabled_AfterActionCompile

getprop checked_AfterActionCompile
   put ide_GetAfterActionCompile() into sBoolean
   return sBoolean
end checked_AfterActionCompile


--> Global | ScriptEditor | Behavior | Menu
-
on menu_AfterActionCompile sObject
   put ide_GetAfterActionCompile() into sBoolean
   ide_SetAfterActionCompile (sBoolean is false)
end menu_AfterActionCompile

on menu_RecentButton mTarget
   put rev_HistoryButton() into topRecentButton
   --
   put scriptEditor_HistoryButtonBehavior() into bObject
   --
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

private command _
end _

on menu_EditAfterActionBehavior sObject
   put the name of stack "behavior_RevSEStackBehavior" into actionBehavior
   edit the script of actionBehavior
end menu_EditAfterActionBehavior

on submenu_Dev
   return menu_DevTitle ("Global | ScriptEditor | Behavior | Menu")
end submenu_Dev
