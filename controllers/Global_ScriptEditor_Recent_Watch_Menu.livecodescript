script "Global_ScriptEditor_Recent_Watch_Menu"
--> MetaData
-
name: Global | ScriptEditor | Recent | Watch | Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 1.0

/*
This is designed to be the main or the default menu for manipulating a script in an editor.
As such it is currently used in the Livecode IDE's script editor.
You can attach it anywhere you want. I personally add it to the Script Editors "watch" button on the top right bar of the editor.

Modify to use "Global | ScriptEditor | Header | Menu"
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
-- on menu_Init tObject
-- a hack (we keep getting this reset by Livecode)
ide_AddRevEditScriptStack "LCW"
rev_AddBehaviorHacks
end menu_Init

getprop menu_Target
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
   return sObject
end menu_Target

-- getprop menu_IsSimple
   return false
end menu_IsSimple


--> Menu | Props
-
getprop editIdeBehavior_Params
   put project_ListBehaviorStackNames ("lcw") into stackNames
   return stackNames
end editIdeBehavior_Params


--> Global | ScriptEditor | Recent | Watch | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on _
end _

on submenu_Script
   return "Global | ScriptEditor | Script | Menu"
end submenu_Script

on menu_EditIdeBehavior sObject, stackName
   edit the script of stack stackName
end menu_EditIdeBehavior

on submenu_SetIdeBehavior
   return "Global | ScriptEditor | Behavior | Menu"
end submenu_SetIdeBehavior
