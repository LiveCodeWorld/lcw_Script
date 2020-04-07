script "lib_Help"
--> MetaData
-
license: GPLv3
name: lib_Help
type: library
version: 0.3
deps: lcw_Wiki

/*
lcw_Help uses the livecode.world federated wiki to store it's help.
As such you need to initiate the lcw_Wiki rpject for these handelrs to work.

This is a new library designed to use Fedwiki for writing notes and help about LCW project stacks.
This is a first step in an experiment in literate coding in Livecode and wiki.

== TO DO ==
Work out what to do with handlers, There see to be too many of them

private function _ConstructGithubPara hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_HandlerURL [hKey] of hObject && "github" into githubLink
   put "You can view the source here - [" & githubLink & "]" into githubPara
   return githubPara
end _ConstructGithubPara
*/


--> Props
-
getprop help_Url [pCheckURL]
   put the long id of the target into tObject
   put the stack_Name of tObject into stackName
   put the script_Type of tObject into scriptType
   put help_ConstructURL (stackName, scriptType, pCheckURL) into someURL
   return someURL
end help_Url

getprop script_MarkdownHandlerIndex
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   repeat for each line hTableLine in hTable
      put word 1 of hTableLine into hType
      if char 1 of hType = "P" then next repeat
      
      put word 2 of hTableLine into hName
      put word 3 of hTableLine + 1 into sLineNum
      put word 4 of hTableLine + 1 into eLineNum
      
      put github_handlerURL (hObject, sLineNum, eLineNum) into githubURL 
      put "- [" & hName & "](" & githubURL & ")" & CR after markdownIndex
   end repeat
   delete char -1 of markdownIndex
   return markdownIndex
end script_MarkdownHandlerindex


--> Working on
-
command help_Create pageTitle, scriptType, curlyData, pScriptHelp
   -- put "handler.livecode.world" into helpDomain
   put help_ConstructDomain (scriptType) into helpDomain
   --
   put help_FetchNewPageArray (pageTitle, scriptType, curlyData, pScriptHelp) into pageArray
   --
   if pageArray is empty then
      return merge ("Error, cannot find template on '[[wikiDomain]]' for '[[scriptType]]'")
   end if
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   pageArray_Store helpDomain, pageSlug, pageArray
   --
   put the result into shellResult -- error, fetching ip address for droplet AtopiaDropletName
   if shellResult is empty then
      return pageArray
   else
      return shellResult
   end if
end help_Create


--> Help
-
function help_ConstructHandlerTitle hKey
   -- here we can experiment with different types of names
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   return hName
end help_ConstructHandlerTitle

function help_FetchNewPageArray pageTitle, scriptType, curlyData, pScriptHelp
   put help_ConstructDomain (scriptType) into wikiDomain
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   put help_FetchTemplateArray (scriptType) into pageArray
   if pageArray_Check (pageArray) is false then return empty
   
   if pScriptHelp is not empty then put pScriptHelp into pageArray ["story"][1]["text"]
   --
   pageArray_Rename pageArray, pageTitle
   curly_MergePageArray pageArray, curlyData
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "handler.livecode.world,model.livecode.world,fedwiki.org"
   return pageArray
end help_FetchNewPageArray


--> LCW | Handler | Help
-
command lcw_CreateHandlerHelp hKey, pScriptHelp
   put hkey_IsMenuHandler (hKey) into isMenuHandler
   switch
      case isMenuHandler is true
         help_CreateMenuItem hKey, pScriptHelp
         break
      case hkey_IsTransportHandler (hKey)
         transport_CreateHelp hKey, pScriptHelp
         break
      default
         put help_ConstructHandlerTitle (hKey) into pageTitle
         put help_HkeyCurlyData (hKey, false) into curlyData
         --
         help_Create pageTitle, "handler", curlyData, pScriptHelp
   end switch
   put the result into shellResult -- error, fetching ip address for droplet AtopiaDropletName
   return shellResult
end lcw_CreateHandlerHelp

command lcw_UpdateHandlerHelp hKey
   put lcw_FetchHandlerArray (hKey) into pageArray
   put help_HkeyCurlyData (hKey, true) into curlyData
   curly_MergePageArray pageArray, curlyData
   lcw_StoreHandlerArray hKey, pageArray
end lcw_UpdateHandlerHelp


--> Help | Construct
-
function help_ConstructURL stackName, scriptType, pCheckURL
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put help_ConstructTitle (stackName, scriptType) into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   if pCheckURL is true then
      put fedwiki_IsWikiPage (fedwikiDomain, pageSlug) into isWiki
      if isWiki is false then
         return empty
      end if
   end if
   put fedwiki_PageUrl (fedwikiDomain, pageSlug) into someURL
   return someURL
end help_ConstructURL

function help_ConstructTitle stackName, scriptType
   switch
      case scriptType = "transport"
         return help_ConstructTransportTitle (stackName)
      case scriptType is "controller"
      case scriptType is "menu"
         return help_ConstructMenuPageTitle (stackName)
      default
         return stackName
   end switch
end help_ConstructTitle

function help_ConstructTransportTitle stackName
   set the itemdelimiter to "."
   put text_InitialCaps (item 1 of stackName) && "Transport" after pageTitle
   return pageTitle
end help_ConstructTransportTitle


--> LCW | Help
-
command lcw_CreateObjectHelp sObject
   put the stack_Name of sObject into stackName
   put the script_Type of sObject into scriptType
   switch scriptType
      case "menu"
         put help_MenuPageTitle (stackName) into gMenuTitle
         help_CreateMenu gMenuTitle
         break
      default
         put the script_MetaData ["script_Help"] of sObject into pScriptHelp
         --
         put help_ObjectCurlyData (sObject, scriptType) into curlyData
         put curlyData ["title"] into pageTitle
         --
         help_Create pageTitle, scriptType, curlyData, pScriptHelp
         put the result into shellResult
         return shellResult
   end switch
end lcw_CreateObjectHelp

command lcw_UpdateObjectHelp sObject
   -- does not use script_Help to update first paragraph
   put lcw_FetchObjectPageArray (sObject) into pageArray
   put help_ObjectCurlyData (sObject) into curlyData
   curly_MergePageArray pageArray, curlyData
   lcw_StoreObjectPageArray sObject, pageArray
end lcw_UpdateObjectHelp

function help_ObjectCurlyData sObject, scriptType
   local curlyData
   --   
   -- put hkey_GetDotText (sObject) into curlyData ["id"]["b6853287820608f3"]   
   put the object_Yaml of sObject into curlyData ["id"]["da8cf69872f38050"]
   --
   put the script_ExternalCalls of sObject into externalCalls
   put the script_HandlerNames [true] of sObject into handlerNames
   --
   put fedwiki_MarkdownIndex (handlerNames) into curlyData ["id"]["5ac622dfbefa2589"]
   put fedwiki_HkeyMarkdownIndex (externalCalls) into curlyData ["id"]["8b1940e31f034b01"]
   --
   _AddGithubObjectCurlyData curlyData, sObject
   _AddObjectCurlyData curlyData, scriptType, sObject
   -- put the result into pageTitle
   --
   return curlyData
end help_ObjectCurlyData

private command _AddGithubObjectCurlyData @curlyData, sObject
   put the github_LaunchURL of sObject into githubURL
   --
   put githubURL && "github" into curlyData ["all"]["github link"]
   --
   put githubURL && "github" into githubLink
   put "You can view the source here - [" & githubLink & "]" into githubPara
   put githubPara into curlyData ["id"]["8869c0772777be8e"]
end _AddGithubObjectCurlyData

private command _AddObjectCurlyData @curlyData, scriptType, sObject
   put the stack_Name of sObject into stackName
   --
   switch scriptType
      case "menu"
      case "controller"
         -- put the script_Metadata ["name"] of sObject into stackName
         put help_MenuPageTitle (stackName) into menuTitle
         put the menu_Handlers [menuTitle] of sObject into mHandlers
         put mHandlers into curlyData ["all"]["Menu Handler Index"]
         --
         put help_ConstructMenuPageTitle (stackName) into pageTitle
         put pageTitle into curlyData ["title"]
         --
         return pageTitle
      case "ide"         
         -- put github_handlerURL (sObject) into curlyData ["all"]["github link"]
         put the script_MarkdownHandlerindex of sObject into curlyData ["all"]["Handler List"]
         put relFolder into curlyData ["all"]["rel folder"]
         put shortFile into curlyData ["all"]["short file"]
         break
      case "transport"
         break
      case "home"
      case "project"
         put the project_Deps of sObject into projectDeps
         put fedwiki_MarkdownIndex (projectDeps) into markdownIndex
         put markdownIndex into curlyData ["all"]["Project Dep List"]
         break
      case "library"
         -- put "8869c0772777be8e" into githubLinkID
         --put the script_MarkdownHandlerindex of tObject into curlyData ["all"]["Handler List"]
         -- put the script_Deps of tObject into curlyData ["all"]["Stack Deps"]
      default
         -- some random object?
   end switch
   
   put stackName into curlyData ["title"]
   return stackName
end _AddObjectCurlyData


--> LCW | Handler | Model | Wrappers
-
function lcw_FetchHandlerTags hKey
   put lcw_FetchPageData (hKey) into pageData
   put pageData_GetText (pageData, "handlerTags") into handlerTags
   replace "[[" with empty in handlerTags
   replace "]]" with empty in handlerTags
   replace "-" with empty in handlerTags
   replace space with empty in handlerTags
   return handlerTags
end lcw_FetchHandlerTags

function lcw_FetchPageData hKey
   put lcw_FetchHandlerArray (hKey) into pageData
   _SetHkeyPageItemDictionary pageData
   return lcw_FetchPageData
end lcw_FetchPageData


--> Help
-
command help_IndentHandler @someHandler
   put word 1 to -1 of someHandler into someHandler
   repeat for each line hLine in someHandler
      put word 1 to -1 of hLine into goodLine
      put offset (goodLine, hLine) into spaceNum
      if spaceNum = 1 then
         put goodLine & CR after goodHandler
      else
         put round (spaceNum/2) into newSpaceNum
         put char 1 to newSpaceNum of hLine & goodLine & CR after goodHandler
      end if
   end repeat
   delete char -1 of goodHandler
   put goodHandler into someHandler
end help_IndentHandler


--> Help | Construct
-
function help_ConstructDomain scriptType
   put scriptType & ".livecode.world" into wikiDomain
   return wikiDomain
end help_ConstructDomain


--> Help | Template | Model
-
function help_FetchTemplateArray scriptType, pStripJournal
   -- see also "federation_FetchTemplateArray"
   put help_FetchTemplateJson (scriptType) into templateJSON
   put json_ToArray (templateJSON) into templateArray
   if pStripJournal is true then
      pageArray_StripJournal templateArray
   end if
   return templateArray
end help_FetchTemplateArray

function help_FetchTemplateJson scriptType
   put help_ConstructDomain (scriptType) into fedwikiDomain
   put scriptType & "-" & "template" into pageSlug
   put fedwiki_FetchPageJson (fedwikiDomain, pageSlug) into pageJSON
   return pageJSON
end help_FetchTemplateJson

function help_HkeyCurlyData hKey, pUpdate
   -- also used by handlers in "lib_Transport"
   -- uses both "github_LaunchURL" and "github_RelativePath"
   local curlyData
   --
   -- newer tider style
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_HandlerURL [hKey] of hObject into curlyData ["all"]["githubHandlerURL"]
   put hkey_GetType (hKey) into curlyData ["all"]["handlerType"]
   
   -- older exerimental style
   help_SetHkeyInfo hKey, wikiDomain, pageSlug, pageTitle
   put pageArray_ConstructReference (pageSlug, wikiDomain, wikiDomain, pageTitle) into itemArray
   curly_SetReplaceArray curlyData, itemArray, "4ecda1442570d900"
   --
   _SetHkeyPageItemDictionary curlyData
   --
   put hkey_FetchHandler (hKey) into someHandler
   help_IndentHandler someHandler
   curly_SetData curlyData, "someHandler", someHandler
   --
   put hkey_GetDotText (hKey) into dotText
   if dotText is not empty then
      curly_SetData curlyData, "dotText", dotText
   end if
   --
   --  
   put _ConstructHandlerMetadata (hKey) into handlerMetadata
   curly_SetData curlyData, "handlerMetadata", handlerMetadata
   --
   put _ConstructHandlerSyntax (someHandler, hKey) into handlerSyntax
   curly_SetData curlyData, "handlerSyntax", handlerSyntax
   --
   put _ConstructCallList (someHandler, hKey) into callList
   curly_SetData curlyData, "callList", callList
   --
   put _ConstructParamList (someHandler) into paramList
   curly_SetData curlyData, "paramList", paramList
   --
   put _ConstructHandlerTags (hKey, pUpdate) into handlerTags -- also look inside handler
   curly_SetData curlyData, "handlerTags", handlerTags
   --
   return curlyData
end help_HkeyCurlyData


--> Private
-
private command _SetHkeyPageItemDictionary @curlyData
   curly_SetItemIDArray curlyData, "refArray", "4ecda1442570d900"
   curly_SetItemIDArray curlyData, "someHandler", "39e7dd9a1560241a"
   curly_SetItemIDArray curlyData, "handlerSyntax", "54f306e694aa494b"
   curly_SetItemIDArray curlyData, "handlerMetadata", "da8cf69872f38050"
   curly_SetItemIDArray curlyData, "callList", "0c0d997d16532d79"
   curly_SetItemIDArray curlyData, "handlerTags", "26d290f03f2aa26e"
   curly_SetItemIDArray curlyData, "dotText", "b6853287820608f3"
   curly_SetItemIDArray curlyData, "paramList", "0a99c44502e29156"
   curly_SetItemIDArray curlyData, "githubPara", "8869c0772777be8e"
end _SetHkeyPageItemDictionary

private function _ConstructHandlerTags hKey, pUpdate
   local handlerTagList
   
   put hkey_ConstructKeywords (hKey) into handlerTags
   put "from,to" into notThese
   if pUpdate is true then
      put comma after handlerTags
      put lcw_FetchHandlerTags (hkey) into lcwHandlerTags
      repeat for each item lcwHandlerTag in lcwHandlerTags
         if lcwHandlerTag is not among the items of handlerTags then
            put lcwHandlerTag & comma after handlerTags
         end if
      end repeat
      delete char -1 of handlerTags
   end if
   
   repeat for each line someTag in handlerTags
      if someTag is among the items of notThese then next repeat
      put "[[" & someTag & "]], " after handlerTagList
   end repeat
   delete char -2 to -1 of handlerTagList
   return handlerTagList
end _ConstructHandlerTags

private function _ConstructHandlerMetadata hKey, relPath
   put hkey_GetType (hKey) into handlerType
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_RelativePath of hObject into relPath
   
   put "Type:" && handlerType & CR after handlerMetaData
   put "Project:" && the project_Name of hObject & CR after handlerMetaData
   put "Github:" && relPath & CR after handlerMetaData
   put "OS: all" & CR after handlerMetaData
   put "Platforms: all" & CR after handlerMetaData
   -- put "Checked: false" & CR after handlerMetaData
   --
   delete char -1 of handlerMetaData
   return handlerMetadata
end _ConstructHandlerMetadata

private function _ConstructHandlerSyntax someHandler, hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put line 1 of someHandler into handlerLine
   replace "@" with empty in handlerLine
   switch
      case hType contains "f"
         put word 2 of handlerLine && "(" & word 3 to -1 of handlerLine & ")" into handlerSyntax
         break
      case hType contains "c"
      case hType contains "m"
         put word 2 to -1 of handlerLine into handlerSyntax
         break
      default
         put "the" && word 2 to -1 of handlerLine into handlerSyntax
   end switch
   return handlerSyntax
end _ConstructHandlerSyntax

private function _ConstructCallList someHandler, hKey
   -- we store them as we find them - because we can
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the handler_PublicCalls [hKey] of hObject into shortPublicCalls
   --
   put handler_ExtractCalls (someHandler) into shortCalls
   hkey_StoreCalls hKey, shortCalls
   -- put hkey_FetchCalls (hKey) into shortCalls
   --
   repeat for each line shortCall in shortPublicCalls
      put word 2 of shortCall & CR after callNames
   end repeat
   delete char -1 of callNames
   put fedwiki_MarkdownIndex (callNames) into callList
   return callList
end _ConstructCallList

private function _ConstructParamList someHandler
   put word 1 to -1 of line 1 of someHandler into hLine
   if word 1 of hLine = "private" then delete word 1 of hLine
   put word 3 to -1 of hLine into paramList
   replace "[" with empty in paramList
   replace "]" with empty in paramList
   replace "@" with empty in paramList
   repeat for each item someParam in paramList
      put "-" && word 1 of someParam && ": param description goes here" & CR after paramTable
   end repeat
   delete char -1 of paramTable
   return paramTable
end _ConstructParamList


--> Private
-
