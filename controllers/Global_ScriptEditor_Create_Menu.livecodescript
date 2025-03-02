script "Global | ScriptEditor | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Create | Menu
type: controller
version: 0.5

/*
This menu is for creating standard LCW elements from the scripteditor menu.
*/

local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target

function module_MenuNameFromViewOrMenuTitle viewOrModuleName
   if word 1 of viewOrModuleName = "-->" then
      delete word 1 of viewOrModuleName
   end if
   view_NormalizePiped viewOrModuleName
   replace "|" with "_" in viewOrModuleName
   return viewOrModuleName
end module_MenuNameFromViewOrMenuTitle


--> Global | ScriptEditor | Create | Menu
-
on menu_CreateNewProject
   project_AskCreate
   put the result into newProjectName
   display_Project newProjectName
end menu_CreateNewProject

on menu_CreateModule sObject
   put the project_Name of sObject into projectName
   put lcw_Ask ("What name would you like for this module?", "View|Something") into moduleName
   module_CreateWithObject moduleName, projectName
   
   project_UpdateArray projectName
   display_Project projectName
end menu_CreateModule

private on _
end _

on insert_CreateMenu
   return "Global | Project | Create | Menu"
end insert_CreateMenu


/*
on menu_CreateView scriptObject
   breakpoint
   -- template_ConstructCloneStack
   template_ConstructStackFromObject scriptObject
end menu_CreateView

getprop disabled_CreateView [scriptObject]
   put the view_Name of scriptObject into vName
   return vName is empty
end disabled_CreateView

on menu_CreateBehavior scriptObject
   breakpoint
   
   put "Choose a name for your script-only behavior stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "behavior_" & scriptName into suggestedAnswer
   
   put the project_Name of scriptObject into projectName
   breakpoint
   ask_CreateProjectStack "behaviors", projectName, someQuestion, suggestedAnswer
end menu_CreateBehavior

on menu_CreateLibrary scriptObject
   put "Choose a name for your script-only library stack...." into someQuestion
   
   if the index_View of scriptObject is empty then
      put the script_MetaData ["name"] of scriptObject into scriptName
      if scriptName is empty then put "Example" into scriptName
      if char 1 to 4 of scriptName is not "lib_" then
         put "lib_" & scriptName into suggestedAnswer
      else
         put scriptName into suggestedAnswer
      end if
      put the project_Folder of scriptObject into projectFolder
   else
      breakpoint
      -- put the clipboarddata ["text"] into suggestedAnswer
      put scriptObject into indexView
      
      put "lib_XXX" into suggestedAnswer
      put the title_Text of indexView into projectName
      put project_GetFolder (projectName) into projectFolder
   end if
   
   put lcw_Ask (someQuestion, suggestedAnswer) into stackName
   
   project_CreateStack projectFolder, stackName, "libraries", "library"
   put the result into homeStackPath
   
   start using stack stackName
   lcw_Notify ("Stack" && kwote (stackName) && "is now known and used!")
   edit the script of stack stackName
end menu_CreateLibrary

on menu_CreateMenuStack scriptObject
   put the project_Folder of scriptObject into projectFolder
   put the project_Name of scriptObject into projectName
   
   put _askMenuTitle (projectName) into gMenuTitle
   
   display_AskCreateMenu projectFolder, gMenuTitle
   put the result into controllerStackObject
   
   lcw_Notify ("Created menu" && kwote (controllerStackObject) & "!")
   edit the script of controllerStackObject
end menu_CreateMenuStack
*/
