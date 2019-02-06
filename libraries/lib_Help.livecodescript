script "lib_Help"
--> MetaData
-
license: GPLv3
name: lib_Help
type: library
version: 0.2
deps: lcw_Wiki

/*
lcw_Help uses the livecode.world federated wiki to store it's help.
As such you need to initiate the lcw_Wiki rpject for these handelrs to work.

This is a new library designed to use Fedwiki for writing notes and help about LCW project stacks.
This is a first step in an experiment in literate coding in Livecode and wiki.

== TO DO ==
Work out what to do with handlers, There see to be too many of them
*/


--> Working on
-
command help_SetSlugAndDomain stackName, scriptType, @pageTitle, @pageSlug 
   put stackName into pageTitle
   put stackName into pageSlug
   --
   if scriptType is among the items of "controller,menu" then
      -- ugly hack
      -- menu controllers have inconsistant names
      -- therefore we make all of the following equivalent
      -- "Global | Test | Menu" = "Global_Test_Menu" => "global--test--menu"
      replace "_" with " | " in pageTitle
      replace "_" with "--" in pageSlug
   end if
   put fedwiki_ConstructSlug (pageSlug) into pageSlug
end help_SetSlugAndDomain

function _ConstructCurlyData scriptType, pageTitle, pageSlug, stackName, sObject
   -- this handler get specific things to fill in the curl merge template
   put github_ConstructLaunchUrl (stackName) && "github" into githubLink
   put githubLink into curlyData ["all"]["github link"]
   
   switch scriptType
      case "controller"
         put the menu_Handlers [pageTitle] of sObject into mHandlers
         put mHandlers into curlyData ["all"]["Menu Handler Index"]
         break
      case "home"
      case "project"
         put the project_Deps of sObject into projectDeps
         put fedwiki_ConstructMarkdownIndex (projectDeps) into markdownIndex
         put markdownIndex into curlyData ["all"]["Project Dep List"]
         break
      case "library"
         -- put "8869c0772777be8e" into githubLinkID
      default
         -- some random object?
   end switch
   --
   return curlyData
end _ConstructCurlyData


--> Props
-
getprop help_Exists
   put the help_Url [true] of the target is not empty into helpExists
   return helpExists
end help_Exists

getprop help_Url [pCheckURL]
   put the long id of the target into tObject
   --
   put the stack_Name of tObject into stackName
   -- put the stack_Type of tObject into stackType
   put the script_Type of tObject into scriptType
   --
   put help_ConstructURL (stackName, scriptType) into someURL
   _CheckHelpUrl someURL, stackName, scriptType, pCheckURL
   --
   return someURL
end help_Url


--> Help
-
command help_Launch sObject
   put the help_Url of sObject into someURL
   launch url someURL
   return someURL
end help_Launch

function help_GetScriptType sObject
   -- a bit of a hack to fix script_Type for Revigniter controllers
   put the script_Type of sObject into scriptType
   if scriptType is empty then
      -- might be a RevIgniter controller
      put the project_Folder of sObject
      -- put the controller_Folder of sObject into cFolder
      
   end if
end help_GetScriptType

command help_Create sObject, pScriptHelp
   put the stack_Name of sObject into stackName
   put the script_Type of sObject into scriptType
   --
   put help_ConstructDomain (scriptType) into fedwikiDomain
   help_SetSlugAndDomain stackName, scriptType, pageTitle, pageSlug
   --
   put help_FetchTemplateArray (scriptType) into templateArray
   put pageTitle into templateArray ["title"]
   
   -- use script help frm script metadata
   if pScriptHelp is empty then
      put the script_Help of sObject into pScriptHelp
      if pScriptHelp is empty then
         put "Describe the purpose of the script here..." into pScriptHelp
      end if
   end if
   
   -- let's set the first paragraph
   -- for other specific paragraphs lower down use something like
   -- fedwiki_SetStoryItemText templateArray, "10afaec7988d22e2", pScriptHelp
   put pScriptHelp into templateArray ["story"][1]["text"]
   
   -- use curly merge templates
   put _ConstructCurlyData (scriptType, pageTitle, pageSlug, stackName, sObject) into curlyArray
   fedwiki_MergeCurly templateArray, curlyArray
   
   -- store
   atopia_StoreWikiPageArray fedwikiDomain, pageSlug, templateArray
   put the result into shellResult
   return shellResult
end help_Create

command help_Update sObject
   put the stack_Name of sObject into stackName
   put the script_Type of sObject into scriptType
   --
   put the help_Url of sObject into someURL
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put fedwiki_ConstructSlug (stackName) into pageSlug
   
end help_Update


--> Help | Construct
-
function help_ConstructURL stackName, scriptType, pSolo
   -- http://lib.livecode.world/view/welcome-visitors/view/libdropbox
   put help_ConstructDomain (scriptType) into fedwikiDomain
   help_SetSlugAndDomain stackName, scriptType, pageTitle, pageSlug
   put fedwiki_PageUrl (fedwikiDomain, pageSlug) into someURL
   return someURL
end help_ConstructURL

function help_ConstructDomain scriptType
   put scriptType & ".livecode.world" into fedwikiDomain
   return fedwikiDomain
end help_ConstructDomain


--> Help | Template
-
function help_FetchTemplateArray scriptType
   put help_FetchTemplateJson (scriptType) into templateJSON
   put json_ToArray (templateJSON) into templateArray
   fedwiki_StripJournalToCreate templateArray
   return templateArray
end help_FetchTemplateArray

function help_FetchTemplateJson scriptType
   -- http://library.livecode.world/library-template.json
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put scriptType & "-" & "template" into pageSlug
   --
   put fedwiki_FetchPageJson (fedwikiDomain, pageSlug) into pageJSON
   return pageJSON
end help_FetchTemplateJson


--> Private
-
private command _CheckHelpUrl @someURL, stackName, scriptType, pCheckURL
   -- this requires project lcw_Wiki
   if pCheckURL is false then return empty
   
   put help_ConstructDomain (scriptType) into fedwikiDomain
   help_SetSlugAndDomain stackName, scriptType, pageTitle, pageSlug
   put fedwiki_IsWikiPage (fedwikiDomain, pageSlug) into isWiki
   if isWiki is false then
      put empty into someURL
   end if
   return isWiki
end _CheckHelpUrl
