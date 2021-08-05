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
getprop menu_Target [tObject]
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target


--> Global | ScriptEditor | Go | Menu
-
on menu_GoToStack sObject
   object_GoTo sObject
end menu_GoToStack

on menu_OpenInFinder sObject
   put the stack_Name of scriptObject into stackName
   stack_RevealInFinder stackName
end menu_OpenInFinder

on _
end _

on menu_ObjectProperties sObject
   revIDEInspectObjects sObject
   -- display_ObjectProperties sObject
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

on _
end _

on menu_DisplayTransporters
   display_Transporters
end menu_DisplayTransporters

on menu_DisplayTransportLibs
   display_TransporterLibs
end menu_DisplayTransportLibs

on _
end _

on menu_Terminal sObject
   put the stack_Folder of sObject into stackFolder
   launch_Terminal stackFolder
end menu_Terminal

on menu_GitStatus sObject
   put the stack_Folder of sObject into stackFolder
   display_GitFolderStatus stackFolder
end menu_GitStatus

on menu_NewScriptTemplate sObject
   display_AskNewTemplate sObject
end menu_NewScriptTemplate

on _
end _

on menu_SetMainScreen sObject
   object_GoTo sObject, true
end menu_SetMainScreen



--> Deps
-
