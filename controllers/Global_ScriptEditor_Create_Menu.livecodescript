script "Global | ScriptEditor | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Create | Menu
type: controller
version: 0.5

local LocalArray


--> Global | ScriptEditor | Create | Menu
-
/*
This menu is for creating standard script only stcks in the right library folders.
*/

on menu_CreateNewProject
   project_AskCreate
end menu_CreateNewProject

on _
end _

on menu_CreateView scriptObject
   breakpoint
   -- template_ConstructCloneStack
   template_ConstructStackFromObject scriptObject
end menu_CreateView

on menu_CreateModel scriptObject, projectChoice
   breakpoint
   put "Choose a name for your script only model stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "model_" & scriptName into suggestedAnswer
   
   project_CreateScriptOnlyStack "models", someQuestion, suggestedAnswer, projectChoice
end menu_CreateModel

on menu_CreateBehavior scriptObject
   breakpoint
   put "Choose a name for your script-only behavior stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "behavior_" & scriptName into suggestedAnswer
   
   project_CreateScriptOnlyStack "behaviors", someQuestion, suggestedAnswer
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
   
   project_CreateMenu projectFolder, gMenuTitle
   put the result into controllerStackObject
   
   lcw_Notify ("Created menu" && kwote (controllerStackObject) & "!")
   edit the script of controllerStackObject
end menu_CreateMenuStack

private function _askMenuTitle projectName
   put line 1 of the clipboarddata ["text"] into maybeMenuTitle
   if word -1 of maybeMenuTitle = "Menu" then
      put maybeMenuTitle into suggestedAnswer
   else
      set the itemdelimiter to "_"
      put "Global |" && item -1 of projectName && "| Menu" into suggestedAnswer
   end if
   
   put "What is the name of your global menu...." into someQuestion
   put lcw_Ask (someQuestion, suggestedAnswer) into gMenuTitle
   return gMenuTitle
   
   /*
   put "Choose a name for your script only menu stack...." into someQuestion
   put line 1 of the clipboarddata ["text"] into maybeMenuTitle
   if word -1 of maybeMenuTitle = "Menu" then
      put module_MenuNameFromViewOrMenuTitle (maybeMenuTitle) into suggestedAnswer
   else
      put "Global_Example_Menu" into suggestedAnswer
   end if
   
   put lcw_Ask (someQuestion, suggestedAnswer) into moduleStackName
   
   */
end _askMenuTitle

function module_MenuNameFromViewOrMenuTitle viewOrModuleName
   if word 1 of viewOrModuleName = "-->" then
      delete word 1 of viewOrModuleName
   end if
   view_NormalizePiped viewOrModuleName
   replace "|" with "_" in viewOrModuleName
   return viewOrModuleName
end module_MenuNameFromViewOrMenuTitle

on _
end _

on menu_SetWorkingProject mTarget, projectChoice
   env_SetProjectFocus projectChoice
end menu_SetWorkingProject


--> Global | ScriptEditor | Create | Menu | Props
-
getprop project_Choice [scriptObject]
   put the project_Name of scriptObject into projectName
   return projectName
end project_Choice

getprop project_Choices
   return library_ListProjectNames ()
end project_Choices


--> Global | ScriptEditor | Create | Menu | Disabled
-
getprop disabled_CreateView [scriptObject]
   put the view_Name of scriptObject into vName
   return vName is empty
end disabled_CreateView
