script "Global | ScriptEditor | Behavior | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Behavior | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop checked_ApplyButton
   put rev_CompileButton() into compileButton
   if exists (compileButton) is false then return false
   --
   put scriptEditor_CompileButtonBehavior() into bObject
   if exists (bObject) is false then return false
   --
   get the behavior of compileButton
   put it = bObject into someBoolean
   return someBoolean
end checked_ApplyButton


--> Global | ScriptEditor | Behavior | Dev | Menu
-
on menu_EditApplyScript mTarget
   put rev_CompileButton() into compileButton
   put the long owner of compileButton into oControl
   put the long owner of oControl into ooControl
   put the behavior of ooControl into toolbarBehavior
   --
   edit the script of toolbarBehavior
   --
   put the stack_Folder of stack "revSEToolbarBehavior" into toolbarBehaviorFolder
   -- finder_Reveal toolbarBehaviorFolder
end menu_EditApplyScript

on menu_ApplyButton mTarget
   put rev_CompileButton() into compileButton
   put scriptEditor_CompileButtonBehavior() into bObject
   set the behavior of compileButton to bObject
end menu_ApplyButton

