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
*/


--> Working on
-
private function _ConstructWhereRefArray hKey
   /*
   "type": "reference",
   "id": "4ecda1442570d900",
   "site": "model.livecode.world",
   "slug": "modelpagearray",
   "title": "model_PageArray",
   "text": "model.livecode.world"
   */
   help_SetHkeyInfo hKey, wikiDomain, pageSlug, pageTitle
   put wikiDomain into refText
   put fedwiki_ConstructStoryRefArray (pageSlug, wikiDomain, refText, pageTitle) into refArray
   return refArray
end _ConstructWhereRefArray

command help_SetHkeyInfo hKey, @wikiDomain, @pageSlug, @pageTitle
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the stack_Name of hObject into pageTitle
   put the script_Type of hObject into scriptType
   put help_ConstructObjectDomain (scriptType) into wikiDomain
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   return scriptType
end help_SetHkeyInfo


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
   /*
   -- https://github.com/livecode/livecode-ide/blob/develop/Tools/Toolset/libraries/revidedocumentationlibrary.livecodescript#L198-L200
   -- https://github.com/livecode/livecode-ide/blob/develop/Toolset/libraries/revidedocumentationlibrary.livecodescript#L383-L385
   
   - [ideDocsFetchLibraryEntries](https://github.com/livecode/livecode-ide/blob/develop/Toolset/libraries/revidedocumentationlibrary.livecodescript#L383-L385)
   - [ideDocsFetchLCBEntries](https://github.com/livecode/livecode-ide/blob/develop/Toolset/libraries/revidedocumentationlibrary.livecodescript#L407-L409)
   - [ideDocsUpdateDatabase](https://github.com/livecode/livecode-ide/blob/develop/Toolset/libraries/revidedocumentationlibrary.livecodescript#L426-L447)
   */
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


--> LCW | Help | Create
-
command lcw_CreateHandlerHelp hKey, pScriptHelp
   switch
      case hkey_IsMenuHandler (hKey) is true
         lcw_CreateMenuItemHelp hKey, pScriptHelp
         break
      case hkey_IsTransportHandler (hKey)
         transport_CreateHelp hKey, pScriptHelp
         break
      default
         put help_ConstructHandlerTitle (hKey) into pageTitle
         put _HkeyCurlyData (hKey, false) into curlyData
         --
         help_Create pageTitle, "handler", curlyData, pScriptHelp
   end switch
   put the result into shellResult -- error, fetching ip address for droplet AtopiaDropletName
   return shellResult
end lcw_CreateHandlerHelp

command lcw_UpdateHandlerHelp hKey
   put lcw_FetchHandlerArray (hKey) into pageArray
   put _HkeyCurlyData (hKey, true) into curlyData
   curly_MergePageArray pageArray, curlyData
   lcw_StoreHandlerArray hKey, pageArray
end lcw_UpdateHandlerHelp

command lcw_CreateMenuItemHelp hKey, pScriptHelp
   put empty into curlyData
   put help_ConstructMenuTitle (stackName) into pageTitle
   help_Create pageTitle, "handler", curlyData, pScriptHelp
   put the result into shellResult -- error, fetching ip address for droplet AtopiaDropletName
   return shellResult
end lcw_CreateMenuItemHelp


--> Help | Object
-
command lcw_CreateObjectHelp sObject
   put the stack_Name of sObject into stackName
   put the script_Type of sObject into scriptType
   put the script_MetaData ["script_Help"] of sObject into pScriptHelp
   --
   put _ObjectCurlyData (sObject) into curlyData
   help_Create stackName, scriptType, curlyData, pScriptHelp
   put the result into shellResult
   return shellResult
end lcw_CreateObjectHelp

command lcw_UpdateObjectHelp sObject
   -- does not use script_Help to update first paragraph
   put lcw_FetchObjectPageArray (sObject) into pageArray
   put _ObjectCurlyData (sObject) into curlyData
   curly_MergePageArray pageArray, curlyData
   lcw_StoreObjectPageArray sObject, pageArray
end lcw_UpdateObjectHelp


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

command help_Launch tObject
   put the help_Url of tObject into someURL
   launch url someURL
   return someURL
end help_Launch

command help_HkeyLaunch hKey, pCreate
   put help_ConstructHkeyUrl (hKey, true) into someURL
   if someURL is empty and pCreate is true then
      lcw_CreateHandlerHelp hKey
      put help_ConstructHkeyUrl (hKey) into someURL
   end if
   launch url someURL
end help_HkeyLaunch


--> Help | Create
-
command help_Create pageTitle, scriptType, curlyData, pScriptHelp
   put help_ConstructObjectDomain (scriptType) into wikiDomain
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put help_FetchTemplateArray (scriptType) into pageArray
   fedwiki_RenamePage pageArray, pageTitle
   if pScriptHelp is not empty then put pScriptHelp into pageArray ["story"][1]["text"]
   curly_MergePageArray pageArray, curlyData
   --/*
   fedwiki_StripJournal pageArray
   fedwiki_AddJournal pageArray, "handler.livecode.world,model.livecode.world,fedwiki.org"
   -- */
   pageArray_Store wikiDomain, pageSlug, pageArray
   put the result into shellResult -- error, fetching ip address for droplet AtopiaDropletName
   return shellResult
end help_Create

function help_ConstructURL stackName, scriptType, pCheckURL
   put help_ConstructObjectDomain (scriptType) into fedwikiDomain
   put fedwiki_ConstructSlug (stackName) into pageSlug
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

function help_ConstructHkeyUrl hKey, pCheckURL
   help_TitleAndDomain hKey, pageTitle, wikiDomain
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   if pCheckURL is true then
      put fedwiki_IsWikiPage (wikiDomain, pageSlug) into isWiki
      if isWiki is false then
         return empty
      end if
   end if
   put fedwiki_PageUrl (wikiDomain, pageSlug) into someURL
   return someURL
end help_ConstructHkeyUrl

function help_ConstructObjectDomain scriptType
   put scriptType & ".livecode.world" into wikiDomain
   return wikiDomain
end help_ConstructObjectDomain

command help_TitleAndDomain hKey, @pageTitle, @wikiDomain
   switch
      case hkey_IsMenuHandler (hKey)
         breakpoint
         put "menu.livecode.world" into wikiDomain
         break
      case hkey_IsTransportHandler (hKey)
         put "transport.fedwiki.org" into wikiDomain
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put the stack_Name of hObject into stackName
         put help_ConstructTransportTitle (stackName) into pageTitle 
         break
      default
         -- not a special handler so add to global library
         put "handler.livecode.world" into wikiDomain
         put help_ConstructHandlerTitle (hKey) into pageTitle
   end switch
end help_TitleAndDomain

function help_ConstructTitle stackName, scriptType
   switch
      case scriptType = "transport"
         return help_ConstructTransportTitle (stackName)
      case scriptType is among the items of "controller,menu"
         return help_ConstructMenuTitle (stackName)
      default
         return stackName
   end switch
end help_ConstructTitle

function help_ConstructHandlerTitle hKey
   -- here we can experiment with different types of names
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   return hName
end help_ConstructHandlerTitle

function help_ConstructMenuTitle stackName
   replace "_" with " | " in stackName
   return stackName
end help_ConstructMenuTitle

function help_ConstructTransportTitle stackName
   set the itemdelimiter to "."
   put text_InitialCaps (item 1 of stackName) && "Transport" after pageTitle
   return pageTitle
end help_ConstructTransportTitle


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


--> Help | Template | Model
-
function help_FetchTemplateArray scriptType, pStripJournal
   put help_FetchTemplateJson (scriptType) into templateJSON
   put json_ToArray (templateJSON) into templateArray
   if pStripJournal is true then
      fedwiki_StripJournal templateArray
   end if
   return templateArray
end help_FetchTemplateArray

function help_FetchTemplateJson scriptType
   -- http://library.livecode.world/library-template.json
   put help_ConstructObjectDomain (scriptType) into fedwikiDomain
   put scriptType & "-" & "template" into pageSlug
   --
   put pageJson_Fetch (fedwikiDomain, pageSlug) into pageJSON
   return pageJSON
end help_FetchTemplateJson


--> Private
-
private function _ObjectCurlyData sObject, pNotScriptHelp
   local curlyData
   --   
   -- put hkey_GetDotText (sObject) into curlyData ["id"]["b6853287820608f3"]   
   put the object_Yaml of sObject into curlyData ["id"]["da8cf69872f38050"]
   put the script_ExternalCalls of sObject into externalCalls
   put fedwiki_HkeyMarkdownIndex (externalCalls) into curlyData ["id"]["8b1940e31f034b01"]
   put _ObjectGithubPara (sObject) into curlyData ["id"]["8869c0772777be8e"]
   put the script_HandlerNames [true] of sObject into handlerNames
   put fedwiki_MarkdownIndex (handlerNames) into curlyData ["id"]["5ac622dfbefa2589"]
   --
   return curlyData
end _ObjectCurlyData

private function _HkeyCurlyData hKey, pUpdate
   -- uses both "github_LaunchURL" and "github_RelativePath"
   local curlyData
   --
   put _ConstructWhereRefArray (hKey) into itemArray
   curly_SetReplaceArray curlyData, itemArray, "4ecda1442570d900"
   --
   put hkey_GetType (hKey) into handlerType
   put handlerType into curlyData ["all"]["handlerType"]
   --
   _SetHkeyPageItemDictionary curlyData
   --
   put hkey_FetchHandler (hKey) into someHandler
   help_IndentHandler someHandler
   put hkey_GetDotText (hKey) into dotText
   --
   put _ConstructGithubPara (hKey) into githubPara -- also look inside handler
   put _ConstructHandlerMetadata (hKey) into handlerMetadata
   put _ConstructHandlerSyntax (someHandler, hKey) into handlerSyntax
   put _ConstructCallList (someHandler, hKey) into callList
   put _ConstructParamList (someHandler) into paramList
   put _ConstructHandlerTags (hKey, pUpdate) into handlerTags -- also look inside handler
   --
   curly_SetData curlyData, "someHandler", someHandler
   curly_SetData curlyData, "handlerSyntax", handlerSyntax
   curly_SetData curlyData, "handlerMetadata", handlerMetadata
   curly_SetData curlyData, "callList", callList
   curly_SetData curlyData, "handlerTags", handlerTags
   if dotText is not empty then
      curly_SetData curlyData, "dotText", dotText
   end if
   curly_SetData curlyData, "paramList", paramList
   curly_SetData curlyData, "githubPara", githubPara
   --
   return curlyData
end _HkeyCurlyData

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

private function _ObjectGithubPara sObject, githubURL
   put githubURL && "github" into githubLink
   put "You can view the source here - [" & githubLink & "]" into githubPara
   return githubPara
end _ObjectGithubPara

private function _ConstructHandlerMetadata hKey, relPath
   put hkey_GetType (hKey) into handlerType
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_RelativePath of hObject into relPath
   
   put "Type:" && handlerType & CR after handlerMetaData
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

private function _ConstructGithubPara hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the github_HandlerURL [hKey] of hObject && "github" into githubLink
   put "You can view the source here - [" & githubLink & "]" into githubPara
   return githubPara
end _ConstructGithubPara


--> Private | Junk?
-
private function _ConstructCurlyData scriptType, pageTitle, pageSlug, stackName, tObject
   -- this handler get specific things to fill in the curl merge template
   put the github_LaunchURL of tObject && "github" into githubLink
   put githubLink into curlyData ["all"]["github link"]
   
   switch scriptType
      case "ide"         
         put github_handlerURL (tObject) into curlyData ["all"]["github link"]
         put the script_MarkdownHandlerindex of tObject into curlyData ["all"]["Handler List"]
         put relFolder into curlyData ["all"]["rel folder"]
         put shortFile into curlyData ["all"]["short file"]
         break
      case "transport"
         put _TransportCurlyData (tObject) into curlyData
         break
      case "controller"
         put the menu_Handlers [pageTitle] of tObject into mHandlers
         put mHandlers into curlyData ["all"]["Menu Handler Index"]
         break
      case "home"
      case "project"
         put the project_Deps of tObject into projectDeps
         put fedwiki_MarkdownIndex (projectDeps) into markdownIndex
         put markdownIndex into curlyData ["all"]["Project Dep List"]
         break
      case "library"
         -- put "8869c0772777be8e" into githubLinkID
         put the script_MarkdownHandlerindex of tObject into curlyData ["all"]["Handler List"]
         -- put the script_Deps of tObject into curlyData ["all"]["Stack Deps"]
      default
         -- some random object?
   end switch
   --
   return curlyData
end _ConstructCurlyData
