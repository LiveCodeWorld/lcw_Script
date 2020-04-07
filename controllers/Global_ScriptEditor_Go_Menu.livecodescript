script "Global | ScriptEditor | Go | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Go | Menu
type: controller
target: scriptObject
version: 0.2

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-


--> Global | ScriptEditor | Go | Menu
-
on menu_ObjectProperties sObject
   revIDEInspectObjects sObject
   -- object_Inspect sObject
end menu_ObjectProperties

on menu_FindLoadedStack sObject
   -- put the stacksinuse into stackNames
   put revLoadedStacks ("all") into stackNames
   --
   put "*" & the short name of sObject & "*" into someFilter
   put lcw_Ask ("Filter stacksinuse with...", someFilter) into someFilter
   --
   filter stackNames with someFilter
   put empty into pIndexView
   display_Stacks stackNames, "Found Stacks"
end menu_FindLoadedStack

on menu_GoToStack sObject
   object_GoTo sObject
end menu_GoToStack

on menu_OpenInFinder sObject
   put the stack_Name of scriptObject into stackName
   stack_RevealInFinder stackName
end menu_OpenInFinder

on _
end _

on menu_Terminal sObject
   put the stack_Folder of sObject into stackFolder
   launch_Terminal stackFolder
end menu_Terminal

on menu_GitStatus sObject
   put the stack_Folder of scriptObject into stackFolder
   display_GitFolderStatus stackFolder
end menu_GitStatus


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
