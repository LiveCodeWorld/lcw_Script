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
-- getprop disabled_Project [scriptObject]
return word 1 of scriptObject is not "stack"
end disabled_Project
   
-- getprop disabled_DisplayView [scriptObject]
   put the view_Name of scriptObject into vName
   put vName is empty into someBoolean
   if someBoolean is true then
      return "delete"
   else
      return false
   end if
end disabled_DisplayView



--> Deps
-
private command _safeGoProjectStack projectStackName
   if exists (stack projectStackName) then
      go to stack projectStackName
      show stack projectStackName
   else
      answer merge ("Cannot locate stack '[[projectStackName]]'")
      put projectStackName
   end if
end _safeGoProjectStack

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly
