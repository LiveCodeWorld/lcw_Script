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
function _ConstructHandlerMetadata hKey
   /*
   Type: function
   Introduced: 7.0
   OS: mac,windows,linux,ios,android
   Platforms: desktop,server,web,mobile
   Security: network
   Where: Toolset/libraries/revMetadataSet
   */
   
   put "Type:" && hkey_GetType (hKey) & CR after handlerMetaData
   put "Where:" && relPath & CR after handlerMetaData
   put "OS: all" & CR after handlerMetaData
   put "Platforms: all" & CR after handlerMetaData
   put "Checked: false" & CR after handlerMetaData
   --
   delete char -1 of handlerMetaData
   return handlerMetadata
end _ConstructHandlerMetadata

function _ConstructHandlerSyntax someHandler, hKey
   put line 1 of someHandler into handlerLine
   put word 2 to -1 of handlerLine into handlerSyntax
   return handlerSyntax
end _ConstructHandlerSyntax

function _ConstructHandlerTags hKey
   put hkey_ConstructKeywords (hKey) into handlerTags
   repeat for each item someWord in "from,to"
      line_Delete someWord, handlerTags
   end repeat
   put word 1 to -1 of handlerTags into handlerTags
   put fedwiki_ConstructMarkdownIndex (handlerTags) into handlerTagList
   replace CR with ", " in handlerTagList
   --
   return handlerTagList
end _ConstructHandlerTags

function _ConstructCallList someHandler, hKey
   put handler_ExtractCalls (someHandler) into shortCalls
   hkey_StoreCalls hKey, shortCalls
   -- put hkey_FetchCalls (hKey) into shortCalls
   repeat for each line shortCall in shortCalls
      put word 2 of shortCall & CR after callNames
   end repeat
   delete char -1 of callNames
   put fedwiki_ConstructMarkdownIndex (callNames) into callList
   return callList
end _ConstructCallList


--> Help | Curly | Hkey
-
function help_CurlyHkeyData hKey
   put _ConstructHandlerMetadata (hKey) into handlerMetadata
   put hkey_FetchHandler (hKey) into someHandler
   put _ConstructHandlerSyntax (someHandler, hKey) into handlerSyntax
   put _ConstructCallList (someHandler, hKey) into callList
   put hkey_GetDotText (hKey) into dotText
   put _ConstructHandlerTags (hKey) into handlerTags -- also look inside handler
   
   put _CurlyDataConstruct() into curlyData
   --
   curly_SetData curlyData, "someHandler", someHandler
   curly_SetData curlyData, "handlerSyntax", handlerSyntax
   curly_SetData curlyData, "handlerMetadata", handlerMetadata
   curly_SetData curlyData, "callList", callList
   curly_SetData curlyData, "handlerTags", handlerTags
   curly_SetData curlyData, "dotText", dotText
   --
   return curlyData
end help_CurlyHkeyData

command curly_SetData @curlyData, varName, varText
   -- curlyData should already have been prepped with "curly_SetPageItemArray"
   put curlyData ["pageItem"][varName] into itemID
   put varText into curlyData ["id"][itemID]
end curly_SetData

command curly_SetPageItemArray @curlyData, varName, pageItemID
   put pageItemID into curlyData ["pageItem"][varName]
end curly_SetPageItemArray

private function _CurlyDataConstruct
   local curlyData
   curly_SetPageItemArray curlyData, "someHandler", "39e7dd9a1560241a"
   curly_SetPageItemArray curlyData, "handlerSyntax", "54f306e694aa494b"
   curly_SetPageItemArray curlyData, "handlerMetadata", "da8cf69872f38050"
   curly_SetPageItemArray curlyData, "callList", "0c0d997d16532d79"
   curly_SetPageItemArray curlyData, "handlerTags", "26d290f03f2aa26e"
   curly_SetPageItemArray curlyData, "dotText", "b6853287820608f3"
   --
   return curlyData
end _CurlyDataConstruct

function help_CurlyObjectData hObject
   put the stack_Name of hObject into stackName
   --
   put the github_LaunchURL of hObject && "github" into githubLink
   put githubLink into curlyData ["all"]["github link"]
   --
   set the itemdelimiter to "."
   put item 1 of stackName into shortFile
   
   put the dep_StackNames of hObject into depStackNames
   put fedwiki_ConstructMarkdownIndex (depStackNames) into curlyData ["all"]["Deps List"]
   put merge ("https:/rest.livecode.world/[[shortFile]]") into curlyData ["all"]["restURL"]
   --
   put transport_IndexDotText (hObject) into dotText
   --
   return curlyData
end help_CurlyObjectData


--> Props
-
getprop help_Url [pCheckURL]
   put the long id of the target into tObject
   put the stack_Name of tObject into stackName
   put the script_Type of tObject into scriptType
   --
   put help_ConstructURL (stackName, scriptType, pCheckURL) into someURL
   --
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
      
      put handler_GitHubURL (hObject, sLineNum, eLineNum) into githubURL 
      put "- [" & hName & "](" & githubURL & ")" & CR after markdownIndex
   end repeat
   delete char -1 of markdownIndex
   return markdownIndex
end script_MarkdownHandlerindex


--> Working on
-
function help_ConstructHandlerTitle hKey
   -- here we can experiment with different types of names
   -- at the moment we use globally unique hName
   -- this is for handler help
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   -- put the result into cleanHkey
   -- put word 1 to 2 of cleanHkey into shortHkey
   return hName
end help_ConstructHandlerTitle


--> Handler | Github
-
function handler_GitHubURL sObject, pStartLineNum, pEndLineNum
   handler_DeconstructPath sObject, relPath, shortFile, relFolder
   put "https://github.com/livecode/livecode-ide/blob/develop/" & relPath into githubURL
   if pStartLineNum is not empty then
      put "#L" & pStartLineNum after githubURL
      put "-L" & pEndLineNum after githubURL
   end if
   return githubURL
end handler_GitHubURL

command handler_DeconstructPath sObject, @relPath, @shortFile, @relFolder
   set the itemdelimiter to slash
   put item (the number of items of the engine folder + 1) to -1 of the filename of sObject into relPath
   put relPath into relFolder
   put item -1 of relPath into shortFile
   put empty into item -1 of relFolder
end handler_DeconstructPath


--> Help | URL
-
function hkey_ConstructHelpUrl hKey, pCheckURL
   switch
      case hkey_IsMenuHandler (hKey)
         breakpoint
         put "menu.livecode.world" into wikiDomain
         break
      case hkey_IsTransportHandler (hKey)
         put "transport.fedwiki.org" into wikiDomain
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put the stack_Name of hObject into stackName
         put transport_ConstructHelpPageTitle (stackName) into pageTitle 
         break
      default
         put "handler.livecode.world" into wikiDomain
         put help_ConstructHandlerTitle (hKey) into pageTitle
   end switch
   --
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   if pCheckURL is true then
      put fedwiki_IsWikiPage (wikiDomain, pageSlug) into isWiki
      if isWiki is false then
         return empty
      end if
   end if
   put fedwiki_PageUrl (wikiDomain, pageSlug) into someURL
   return someURL
end hkey_ConstructHelpUrl

function help_ConstructURL stackName, scriptType, pCheckURL
   put help_ConstructDomain (scriptType) into fedwikiDomain
   _TitleAndSlugFromStack stackName, scriptType, pageTitle, pageSlug
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

function help_ConstructDomain scriptType
   switch scriptType
      case "transport"
         put "transport.fedwiki.org" into fedwikiDomain
         break
      case scriptType is empty
         breakpoint
         return false
      default
         put scriptType & ".livecode.world" into fedwikiDomain
   end switch
   return fedwikiDomain
end help_ConstructDomain


--> Help
-
command help_Launch tObject
   put the help_Url of tObject into someURL
   launch url someURL
   return someURL
end help_Launch

command help_CreateFromObject tObject, pScriptHelp
   put the stack_Name of tObject into stackName
   put the script_Type of tObject into scriptType
   put the script_MetaData ["script_Help"] of tObject into pScriptHelp
   
   -- assumes it is a livecode.world domain)
   put help_ConstructDomain (scriptType) into fedwikiDomain
   _TitleAndSlugFromStack stackName, scriptType, pageTitle, pageSlug
   put _ConstructCurlyData (scriptType, pageTitle, pageSlug, stackName, tObject) into curlyArray
   
   help_Create pageTitle, scriptType, pageSlug, fedwikiDomain, curlyArray, pScriptHelp
   put the result into shellResult
   return shellResult
end help_CreateFromObject

command help_CreateFromHandler hKey, pScriptHelp
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into cleanHkey
   put word 1 to 2 of cleanHkey into shortHkey
   --
   switch
      case hkey_IsMenuHandler (hKey) is true
         put empty into curlyArray
         put fedwiki_ConstructSlug (hName) into pageSlug
         --
         help_Create hName, "menu", pageSlug, "menu.livecode.world", curlyArray, pScriptHelp
         break
      case hkey_IsTransportHandler (hKey)
         -- case the script_Type of hObject = "transport"
         -- case stackName ends with ".lc"
         transport_CreateHelp hKey, pScriptHelp
         break
      default
         put help_ConstructHandlerTitle (hKey) into pageTitle
         put fedwiki_ConstructSlug (pageTitle) into pageSlug
         put help_CurlyHkeyData (hKey) into curlyData
         help_Create hName, "handler", pageSlug, "handler.livecode.world", curlyData, pScriptHelp
   end switch
   put the result into shellResult
   return shellResult
end help_CreateFromHandler

command help_Create pageTitle, scriptType, pageSlug, fedwikiDomain, curlyData, pScriptHelp
   put help_FetchTemplateArray (scriptType) into templateArray
   put pageTitle into templateArray ["title"]
   
   -- use script help from script metadata
   if pScriptHelp is not empty then
      put pScriptHelp into templateArray ["story"][1]["text"]
   end if
   
   -- use curly merge templates
   pageArray_MergeCurly templateArray, curlyData
   fedwiki_StripJournal templateArray
   
   -- store
   atopia_StoreWikiPageArray fedwikiDomain, pageSlug, templateArray
   put the result into shellResult
   -- error, fetching ip address for droplet AtopiaDropletName
   return shellResult
end help_Create


--> Help | Template
-
function help_FetchTemplateArray scriptType
   put help_FetchTemplateJson (scriptType) into templateJSON
   put json_ToArray (templateJSON) into templateArray
   fedwiki_StripJournal templateArray
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
private command _TitleAndSlugFromStack stackName, scriptType, @pageTitle, @pageSlug 
   switch
      case scriptType = "transport"
         put transport_ConstructHelpPageTitle (stackName) into pageTitle 
         break
      case scriptType is among the items of "controller,menu"
         -- Ugly hack. menu_Controllers have inconsistant names
         -- Therefore we make all of the following equivalent
         -- "Global | Test | Menu" = "Global_Test_Menu" => "global--test--menu"
         put stackName into pageTitle
         replace "_" with " | " in pageTitle
         break
      default
         put stackName into pageTitle
   end switch
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
end _TitleAndSlugFromStack

private function _ConstructCurlyData scriptType, pageTitle, pageSlug, stackName, tObject
   -- this handler get specific things to fill in the curl merge template
   put the github_LaunchURL of tObject && "github" into githubLink
   put githubLink into curlyData ["all"]["github link"]
   
   switch scriptType
      case "ide"
         handler_DeconstructPath tObject, relPath, shortFile, relFolder
         
         put handler_GitHubURL (tObject) into curlyData ["all"]["github link"]
         put the script_MarkdownHandlerindex of tObject into curlyData ["all"]["Handler List"]
         put relFolder into curlyData ["all"]["rel folder"]
         put shortFile into curlyData ["all"]["short file"]
         break
      case "transport"
         put help_CurlyObjectData (tObject) into curlyData
         break
      case "controller"
         put the menu_Handlers [pageTitle] of tObject into mHandlers
         put mHandlers into curlyData ["all"]["Menu Handler Index"]
         break
      case "home"
      case "project"
         put the project_Deps of tObject into projectDeps
         put fedwiki_ConstructMarkdownIndex (projectDeps) into markdownIndex
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
