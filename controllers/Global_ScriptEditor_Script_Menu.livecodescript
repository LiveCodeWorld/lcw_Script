script "Global | ScriptEditor | Script | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | ScriptEditor | Script | Menu
type: controller
version: 0.1

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

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop displayTemplate_Params
   return scaffold_ListShortFiles()
end displayTemplate_Params


--> Global | ScriptEditor | Script | Menu
-
on menu_ScriptTools sObject
   display_Script sObject
end menu_ScriptTools

on _
end _

on menu_DisplayTemplate sObject, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on menu_NewTemplateFromScript sObject
   display_AskNewTemplate sObject
end menu_NewTemplateFromScript

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


--> Dev
-
on _ViewIndex sObject
   display_ViewIndex sObject   
end _ViewIndex

on _DisplayEdited
   display_EditedStacks
end _DisplayEdited
