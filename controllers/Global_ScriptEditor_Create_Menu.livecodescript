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
   dispatch_Controller the params
   
   /*
   project_AskCreate
   put the result into newProjectName
   display_Project newProjectName
   */
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

on menu_TestDispatch sObject
   dispatch_Controller the params
   -- dispatch_Controller "ScriptEditor|Create", sObject, "test"
end menu_TestDispatch

getprop testDispatch_Params
   return "1,2,3"
end testDispatch_Params

command dispatch_Controller mHandlerName, mHandlerTarget, mHandlerParam 
   put wikiSiteMap_GetArray ("handler.livecode.world") into sMapArray
   put indexArray_ConstructNameArray (sMapArray, "title") into titleArray
   put the name of the target into tObject
   
   if mHandlerName contains quote then
      -- assume mHandlerName = the params
      put word 1 of mHandlerName into hName
      put word 2 to -1 of item 1 of mHandlerName into mTarget
      text_TopAndTail mTarget, quote
      --
      put item 2 of mHandlerName into mParam
      text_TopAndTail mParam, quote
   else
      put mHandlerName into hName
      put mHandlerTarget into mTarget
      put mHandlerParam into mParam
   end if
   --
   put titleArray [hName] into handlerPageData
   put handlerPageData ["synopsis"] into synopsis
   put wikiText_GetLinkArray (synopsis) into linkArray
   --
   -- display_Data linkArray
   put _ExtractFirstGitHubLink (linkArray) into permaLink
   github_DeconstructPermalink permaLink, sRepo, sPath, sCommit, startLineNum, endLineNum
   
   set the itemdelimiter to slash
   put sRepo into projectName
   put item 1 of sPath into hType
   put item 2 of sPath into shortFile
   -- display_Data handlerPageData
   
   
   # Check recursion
   if dsaf is not mTarget then
      -- dispatch hName to hObject with mTarget
   end if
end dispatch_Controller

function _ExtractFirstGitHubLink linkArray
   repeat for each key indexNum in linkArray
      -- [https://github.com/LiveCodeWorld/lcw_Script/blob/a1aade15b73b6748b51b2172ee1585b8122acc3e/controllers/Global_ScriptEditor_Create_Menu.livecodescript#L35-L39 github]
      -- put linkArray [indexNum]["text"]
      put linkArray [indexNum]["link"] into gLink
      if gLink begins with "github.com/" then
         return gLink
      end if
   end repeat
   return empty
end _ExtractFirstGitHubLink

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
