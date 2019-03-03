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


--> Menu | Props
-
on menu_Init
   -- a hack (we keep getting this reset by Livecode)
   ide_AddRevEditScriptStack "LCW"
   rev_AddBehaviorHacks
   --
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
end menu_Init

getprop menu_Target [mTitlePath]
   put LocalArray ["sObject"] into sObject
   return sObject
end menu_Target


--> Global | ScriptEditor | Recent | Watch | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on _
end _

on menu_DisplayRigControllers
   if project_IsActive("lcw_RevIgniter") is false then
      lcw_Answer "Do you want to start the lcw_RevIgniter project?"
      --
      project_Start "lcw_Revigniter"
   end if
   --
   display_RigControllerArray
   ide_SetScriptEditorTitles "RevIgniter"
end menu_DisplayRigControllers

on menu_DisplayScript sObject
   display_Script sObject
end menu_DisplayScript

on _
end _

on submenu_Git
   return "Global | GIT | Menu"
end submenu_Git

on menu_ViewTools sObject
   display_ViewIndex sObject   
end menu_ViewTools


--> Global | ScriptEditor | Recent | Watch | Menu | Props
-

--> Global | ScriptEditor | Recent | Watch | Menu | Disabled
-
