script "model_HandlerLibrary"
--> MetaData
-
license: GPLv3
name: model_HandlerLibrary
type: model
version: 0.6

/*
Model for fetching and saving handlers and calls.
Here we also organise the handlers that allows us to construct these calls in the first place.

-- "script_ExportAndIndexMenus" in stack "lib_Update"

We are moving away from the idea of a separate repository for library handlers.
Publishing a handler is now going to be the same as publishing a project - that is a folder in GitHub

These projects will contain libs, and models, and back and front scripts
We will also publish handlers in behaviors that are not marked private or are getprop and setprop handlers
The assumption is that these "could" be used in a general sense. The sense of publishing now is to add them to a globa index of handlers that point to the pubished projects.

This global database does not need to store a separate copies of the handlers.
It should also be used to find dependcies fast, and to be created fast by looping through the project files.

More things named handler_XXX over at suite "--> Handler Index" in stack lib_Hkey

Moving over to storing handler calls in hTableLine format.

The reasons for moving over from old comma based hKeys to new format are:

- 1) revAvailableHandlers returns in the hTableLine word based format
- 2) The tree widget does nto work well with keys that contain commas
- 3) It reads better on screen and in the wiki
*/



--> Working on
-
function hkey_FromName hName, phType, pWikiDomain
   -- looks up a handler in wiki
   if pWikiDomain is empty then put "handler.livecode.world" into pWikiDomain
   if phType is empty then put "C" into phType
   
   # Get pageData of page titles hName from sitemap
   put wikiSiteMap_GetArray (pWikiDomain) into sMapArray
   put indexArray_ConstructNameArray (sMapArray, "title") into titleArray
   
   put titleArray [hName] into handlerPageData
   if handlerPageData is not an array then
      put "Error, cannot locate handler in wiki:" && hName into sError
   end if
   
   put handlerPageData ["synopsis"] into synopsis
   put wikiText_GetLinkArray (synopsis) into linkArray
   
   put wiki_ExtractFirstGitHubLink (linkArray) into permaBit
   github_DeconstructPermaBit permaBit, repoName, projectName, sPath, sCommit, startLineNum, endLineNum
   if the result is true then
      set the itemdelimiter to slash
      put item 1 of sPath into typeFolder
      put item 2 of sPath into shortFile
   end if
   
   # Find mController
   put env_ConstructProjectFolder (projectName) & sPath into sFile
   if there is a stack sFile then
      put the name of stack sFile into mController
      put hKeyLine_Construct (hName, phType, mController) into hKey
      return hKey
   else
      breakpoint
      put "Error, cannot locate handler:" && permaBit into sError
      return empty
   end if
end hkey_FromName

command dispatch_Controller mHandlerName, mHandlerTarget, mHandlerParam, pWikiDomain
   -- mHandlerName = the params?
   if mHandlerName contains quote then
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
   dispatch_NamedHandler hName, mTarget, mParam, pWikiDomain
   return the result -- not used
end dispatch_Controller

command dispatch_NamedHandler hName, mTarget, mParam, pWikiDomain
   -- does not execute handler in context of tObject
   put hkey_FromName (hName, pWikiDomain) into hKey
   if hkey is empty then return "Error, cannot locate handler in wiki:" && hName
   
   hkeyLine_Deconstruct hKey, hName, hType, mController
   dispatch hName to mController with mTarget,mParam
   switch it
      case "handled"
         break
      case "unhandled"
         break
      default -- "passed"
   end switch
   --
   return hKey
end dispatch_NamedHandler

function wiki_ExtractFirstGitHubLink linkArray
   repeat for each key indexNum in linkArray
      put linkArray [indexNum]["link"] into gLink
      if gLink begins with "github.com/" then
         return gLink
      end if
   end repeat
   return empty
end wiki_ExtractFirstGitHubLink


--> Props
-
getprop exported_HandlerCalls [shortHkey]
   put the dataObject_Folder of the target into dataFolder
   put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
   return shortCalls
end exported_HandlerCalls

setprop exported_HandlerCalls [shortHkey] shortCalls
   put the dataObject_Folder of the target into dataFolder
   handler_StoreCalls shortHkey, dataFolder, shortCalls
   return the result
end exported_HandlerCalls

getprop exported_Handler [shortHkey]
   put the dataObject_Folder of the target into dataFolder
   put handler_Fetch (shortHkey, dataFolder) into someHandler
   return someHandler
end exported_Handler

setprop exported_Handler [shortHkey] someHandler
   put the dataObject_Folder of the target into dataFolder
   handler_Save shortHkey, dataFolder, someHandler
end exported_Handler


--> Handler | Process
-
command handler_ProcessAndExportCalls hkeyLine, dataFolder, someHandler, pSkipHkeyComponents, pSkipHkeyProps
   put handler_ConstructCallArray (someHandler, pSkipHkeyComponents, pSkipHkeyProps) into handlerCallArray
   -- put handlerCallArray ["filteredCalls"] into shortCalls   
   put handlerCallArray ["hkeyCalls"] into shortCalls
   
   handler_StoreCalls hkeyLine, dataFolder, shortCalls  
   return shortCalls 
end handler_ProcessAndExportCalls


--> Handler | Calls | Model
-
function handler_FetchCalls hkeyLine, dataFolder
   put textStack_ConstructCallsFile (hkeyLine, dataFolder) into callsFile
   -- put url ("binfile:" & callsFile) into shortHkeys
   put url ("file:" & callsFile) into shortHkeys
   return shortHkeys
end handler_FetchCalls

command handler_StoreCalls hkey, dataFolder, shortCalls
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/lcw_calls.txt
   put textStack_ConstructCallsFile (hkey, dataFolder) into callsFile
   text_Set callsFile, shortCalls
   return shortCalls 
end handler_StoreCalls


--> Hkey | Calls | Model
-
function hkey_FetchCalls hKey
   put hkey_CallsFile (hKey) into callsFile
   put text_Get (callsFile) into shortCalls
   return shortCalls
end hkey_FetchCalls

command hkey_StoreCalls hKey, hKeyCalls
   put hkey_CallsFile (hKey) into callsFile
   if hKeyCalls is empty then
      delete file callsFile
      return empty
   else
      -- put hKeyCalls into url ("binfile:" & someFile)
      text_Set callsFile, hKeyCalls
      return someFile
   end if
end hkey_StoreCalls


--> Handler | DataFolder | Model
-
/*
These handlers extract handlers from exported handler files
For handlers that work on exported handlers see "model_Script"
*/

function handler_Fetch shortHkey, dataFolder
   put textStack_ConstructHandlerFile (shortHkey, dataFolder, true) into handlerFile
   put text_Get (handlerFile) into someHandler
   return someHandler
end handler_Fetch

command handler_Save shortHkey, dataFolder, someHandler, pExportCalls
   put textStack_ConstructHandlerFile (shortHkey, dataFolder, false) into handlerFile
   text_Set handlerFile, someHandler
   if pExportCalls is true then
      handler_ProcessAndExportCalls shortHkey, dataFolder, someHandler
      put the result into shortCalls
      put shortHkey & CR & dataFolder & CR & shortCalls
   end if
   return handlerFile
end handler_Save


--> hKey | Handler | Model
-
function hkey_FetchHandler hKeyLine
   hKey_Deconstruct hKeyLine, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   put the dataObject_Folder of hObject into dataFolder
   put handler_Fetch (hKeyLine, dataFolder) into someHandler
   return someHandler
end hkey_FetchHandler

command hkey_StoreHandler hKey, someHandler 
   put hkey_HandlerFile (hKey, false) into someFile
   if someHandler is empty then
      delete file someFile
   else
      text_Set someFile, someHandler
   end if
end hkey_StoreHandler

command hkey_ExportHandler hKey, pExportCalls
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   put the dataObject_Folder of hObject into dataFolder
   put handler_Fetch (hKey, dataFolder) into someHandler
   
   handler_Save hKey, dataFolder, someHandler, pExportCalls
   return someHandler
end hkey_ExportHandler
