script "Global | ScriptEditor | Script | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Script | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target

getprop displayTemplate_Params
   return scaffold_ListShortFiles()
end displayTemplate_Params


--> Global | ScriptEditor | Script | Menu
-
on menu_ScriptTools sObject
   display_ScriptTools sObject
end menu_ScriptTools

on menu_DisplayRigControllers
   if env_ProjectIsActive("lcw_RevIgniter") is false then
      lcw_Answer "Do you want to start the lcw_RevIgniter project?"
      --
      project_Start "lcw_Revigniter"
   end if
   --
   display_RigControllerArray
   ide_SetScriptEditorTitles "RevIgniter"
end menu_DisplayRigControllers

on _
end _

on menu_DisplayTemplate sObject, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on menu_NewTemplateFromScript sObject
   display_AskNewTemplate sObject
end menu_NewTemplateFromScript


--> Dev
-
on _ViewIndex sObject
   display_ViewIndex sObject   
end _ViewIndex

on _DisplayEdited
   display_EditedStacks
end _DisplayEdited
