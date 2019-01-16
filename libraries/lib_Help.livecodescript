script "lib_Help"
--> MetaData
-
license: GPLv3
name: lib_Help
type: library
version: 0.2

/*
This is a new library designed to use Fedwiki for writing notes and help about LCW project stacks.
This is a first step in an experiment in literate coding in Livecode and wiki.

== TO DO ==
Work out what to do with handlers, There see to be too many of them
*/


--> Working on
-

--> Help | Template
-
function help_MergeTemplateArray scriptHelp, scriptType
   put "4c592d61e9b9302b" into scriptHelpID
   --
   put help_FetchTemplateArray (scriptType) into templateArray
   fedwiki_SetStoryItemText templateArray, scriptHelpID, scriptHelp
   --
   return templateArray
end help_MergeTemplateArray

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


--> Props
-
getprop help_Url [pCheckURL]
   put the long id of the target into tObject
   --
   put the stack_Name of tObject into stackName
   -- put the stack_Type of tObject into stackType
   put the script_Type of tObject into scriptType
   --
   put help_ConstructURL (stackName, scriptType) into someURL
   if pCheckURL is true then
      put fedwiki_ConstructSlug (stackName) into pageSlug
      put scriptType & ".livecode.world" into wikiDomain
      put fedwiki_IsWikiPage (pageSlug, wikiDomain)
   end if
   --
   return someURL
end help_Url


--> Help
-
function help_ConstructURL stackName, scriptType, pSolo
   -- http://lib.livecode.world/view/welcome-visitors/view/libdropbox
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put fedwiki_ConstructURL (stackName, fedwikiDomain) into someURL
   return someURL
end help_ConstructURL

command help_Create stackName, scriptType, pScriptHelp
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put fedwiki_ConstructSlug (stackName) into pageSlug
   --
   if pScriptHelp is empty then
      put the script_Help of stack stackName into pScriptHelp
      if pScriptHelp is empty then
         put "Describe the purpose of the script here..." into pScriptHelp
      end if
   end if
   put help_MergeTemplateArray (pScriptHelp, scriptType) into pageArray
   --
   atopia_StoreWikiPageArray fedwikiDomain, pageSlug, pageArray
   put the result into shellResult
   return shellResult
end help_Create

function help_ConstructDomain scriptType
   put scriptType & ".livecode.world" into fedwikiDomain
   return fedwikiDomain
end help_ConstructDomain
