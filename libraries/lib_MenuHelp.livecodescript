script "lib_MenuHelp"
--> MetaData
-
license: GPLv3
name: lib_MenuHelp
type: library
version: 0.1


--> Working on
-
command hkey_SetMenuItemHelpInfo hKey, @gMenuTitle, @hkeyPageTitle, @menuSubDomain, @hkeySlug
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put menu_CommandToText (hName) into hkeyPageTitle
   put fedwiki_ConstructSlug (hkeyPageTitle) into hkeySlug
   --
   put hkey_GetMenuTitle (hKey) into gMenuTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of gMenuTitle = "Global" then
      put help_ConstructMenuSubDomain (gMenuTitle) into menuSubDomain
      return hObject
   else
      -- could be a local menu such as "Dev | Menu" of a global menu
      get the script_Type of hObject
      if it = "menu" then
         put the script_metadata ["name"] of hObject into gMenuTitle
         replace "_" with " | " in gMenuTitle
         --
         put the script_MenuTitles of hObject into mTitles
         filter mTitles with "Global | *"
         --
         set the wholematches to true
         if gMenuTitle is among the lines of mTitles then
            put help_ConstructMenuSubDomain (gMenuTitle) into menuSubDomain
            return hObject
         else
            breakpoint
            lcw_AnswerWarning merge ("[[gMenuTitle]] is not present. Menu is not prepared for indexing!")
            return empty
         end if
      else
         -- it's a bit old and not yet organised
         breakpoint
         lcw_AnswerWarning "Menu is not prepared for indexing!"
         return empty
      end if
   end if
end hkey_SetMenuItemHelpInfo


--> Help | Menu | Check
-
command help_CheckUpdateMenuItem hKey
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   
   -- check menu.livecode.world
   if help_CheckMenu (gMenuTitle) is true then
      help_UpdateMenu gMenuTitle, "reference"
      if the result is empty then
         breakpoint -- should create
      end if
   else
      help_CreateMenu gMenuTitle
   end if
   
   -- check subdomain welcome-visitors
   if fedwiki_IsWiki (menuSubDomain) is true then
      -- if help_CheckMenuSubdomain (hKey) is true then
      help_UpdateMenuSubdomain hKey, "reference"
      if the result is empty then
         breakpoint -- should create
      end if
   else
      help_CreateMenuSubdomain hKey
   end if
end help_CheckUpdateMenuItem

function help_CheckMenu gMenuTitle
   put help_FetchMenuHelpArray (gMenuTitle) into pageArray
   return pageArray is not empty
end help_CheckMenu

function help_CheckMenuSubdomain hKey
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   put fedwiki_IsWiki (menuSubDomain) into subdomainExists
   return subdomainExists
end help_CheckMenuSubdomain


--> Help | Menu | Item
-
command help_CreateMenuItem hKey, pScriptHelp
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   --
   if word 1 of gMenuTitle is not "Global" then return empty
   
   -- fetch a handler template    
   put help_HkeyCurlyData (hKey, false) into hkeyCurlyData
   put help_FetchNewPageArray (hkeyPageTitle, "handler", hkeyCurlyData, pScriptHelp) into hkeyPageArray
   --
   pageArray_Store menuSubDomain, hkeySlug, hkeyPageArray
   return the result
end help_CreateMenuItem

command help_UpdateMenuItem hKey
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   put pageArray_Fetch (menuSubDomain, hkeySlug) into hkeyPageArray
   if hkeyPageArray is empty then return empty
   --
   put help_HkeyCurlyData (hKey, true) into curlyData
   curly_MergePageArray hkeyPageArray, curlyData
   --
   pageArray_Store menuSubDomain, hkeySlug, hkeyPageArray
   return hkeyPageArray
end help_UpdateMenuItem


--> Help | Menu | Subdomain | Create
-
command help_CreateMenuSubdomain hKey
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   put the result into mController
   --
   put fedwiki_IsWiki (menuSubDomain) into subDomainExists
   if subDomainExists is false then
      return merge ("error, subdomain [[menuSubDomain]] does not exist")
   end if
   
   -- fetch, rename and store menuPageArray
   put menu_ConstructPageTitle (gMenuTitle) into menuPageTitle
   put fedwiki_ConstructSlug (menuPageTitle) into menuPageSlug
   put pageArray_Fetch ("menu.livecode.world", menuPageSlug) into menuPageArray
   if menuPageArray is empty then
      return merge ("error, there is no page [[menuPageSlug]] on menu.livecode.world to clone")
   end if
   --
   put help_ConstructMenuStory (gMenuTitle, "reference", mController) into storyArray
   pageArray_ReplaceSectionBody menuPageArray, "Menu", storyArray
   --
   pageArray_Rename menuPageArray, "Welcome Visitors"
   pageArray_StripJournal menuPageArray
   pageArray_AddFork menuPageArray, "handler.livecode.world,model.livecode.world,fedwiki.org"
   --
   pageArray_Store menuSubDomain, "welcome-visitors", menuPageArray
   --
   if the result is empty then
      return menuPageArray
   else
      return the result
   end if
end help_CreateMenuSubdomain

command help_UpdateMenuSubdomain hKey, pHow
   -- no checks at the moment
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   put the result into mController
   --
   put fedwiki_IsWiki (menuSubDomain) into subDomainExists
   if subDomainExists is false then return empty
   --
   put pageArray_Fetch (menuSubDomain, "welcome-visitors") into pageArray
   if pageArray is empty then return empty
   --
   put help_ConstructMenuStory (gMenuTitle, pHow, mController) into storyArray
   pageArray_ReplaceSectionBody pageArray, "Menu", storyArray
   --
   help_MenuItemMergeAndStore hKey, menuSubDomain, pageArray, true
   --
   return the result
end help_UpdateMenuSubdomain


--> Help | Menu | Create
-
command help_UpdateMenu gMenuTitle, pHow, pMenuController
   if pMenuController is empty then
      put menu_GetGlobalController (gMenuTitle) into pMenuController
   end if
   --
   put menu_StripGlobal (gMenuTitle) into menuPageTitle
   put fedwiki_ConstructSlug (menuPageTitle) into menuPageSlug
   --
   put pageArray_Fetch ("menu.livecode.world", menuPageSlug) into pageArray
   if pageArray is empty then return empty
   --
   put help_ConstructMenuStory (gMenuTitle, pHow, pMenuController) into storyArray
   pageArray_ReplaceSectionBody pageArray, "Menu", storyArray
   --
   help_MenuMergeAndStore pMenuController, pageArray
   --
   return the result
end help_UpdateMenu

command help_CreateMenu gMenuTitle, pMenuController
   if pMenuController is empty then
      put menu_GetGlobalController (gMenuTitle) into pMenuController
   end if
   put help_CreateMenuPageArray (gMenuTitle, pMenuController, "links") into pageArray
   if pageArray is empty then return empty
   -- 
   help_MenuMergeAndStore pMenuController, pageArray
   --
   return the result
end help_CreateMenu

function help_CreateMenuPageArray gMenuTitle, mController, pHow
   put menu_StripGlobal (gMenuTitle) into pageTitle
   
   -- fetch template
   put pageArray_Fetch ("menu.livecode.world", "menu-template") into pageArray
   pageArray_Rename pageArray, pageTitle
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "handler.livecode.world,model.livecode.world,fedwiki.org"
   
   -- replace Menu section
   put help_ConstructMenuStory (gMenuTitle, pHow, mController) into storyArray
   pageArray_ReplaceSectionBody pageArray, "Menu", storyArray
   --
   return pageArray
end help_CreateMenuPageArray


--> Help | Launch
-
command help_Launch tObject
   put the help_Url of tObject into someURL
   launch url someURL
   return someURL
end help_Launch

command help_LaunchMenu stackName
   put help_ConstructMenuUrl (stackName, true) into someURL
   if someURL is empty then return empty
   launch url someURL
   return someURL
end help_LaunchMenu

command help_LaunchMenuSubdomain stackName
   put help_ConstructMenuPageTitle (stackName) into pageTitle
   put help_MenuSubDomain (pageTitle) into menuSubDomain
   put help_ConstructURL (menuSubDomain) into someURL
   
   if someURL is empty then return empty
   launch url someURL
   return someURL
end help_LaunchMenuSubdomain

command help_LaunchMenuItem hKey
   put help_ConstructHkeyUrl (hKey, true) into someURL
   if someURL is empty then return empty
   launch url someURL
   return someURL
end help_LaunchMenuItem

function help_ConstructMenuUrl stackName, pCheckURL
   put help_ConstructDomain ("menu") into wikiDomain
   put help_ConstructMenuPageTitle (stackName) into menuPageTitle
   put fedwiki_ConstructSlug (menuPageTitle) into pageSlug
   --
   put help_ConstructURL (wikiDomain, pageSlug, pCheckURL) into someURL
   return someURL
end help_ConstructMenuUrl

function help_ConstructHkeyUrl hKey, pCheckURL
   help_SetHkeyInfo hKey, wikiDomain, pageSlug, pageTitle
   --
   put help_ConstructURL (wikiDomain, pageSlug, pCheckURL) into someURL
   return someURL
end help_ConstructHkeyUrl

function help_ConstructURL wikiDomain, pSlug, pCheckURL
   if pCheckURL is true then
      put fedwiki_IsWikiPage (wikiDomain, pSlug) into isWiki
      if isWiki is false then return empty
   end if
   --
   put fedwiki_PageUrl (wikiDomain, pSlug) into someURL
   return someURL
end help_ConstructURL


--> Help | Menu
-
function help_FetchMenuHelpArray gMenuTitle
   -- fetch wiki-page in "menu.livecode.world"
   put menu_StripGlobal (gMenuTitle) into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   put pageArray_Fetch ("menu.livecode.world", pageSlug) into pageArray
   return pageArray
end help_FetchMenuHelpArray

function lcw_FetchMenuItemHelpArray hKey, pFetchWelcome
   hkey_SetMenuItemHelpInfo hKey, gMenuTitle, hkeyPageTitle, menuSubDomain, hkeySlug
   if pFetchWelcome is true then
      -- wiki farms return json for welcome visitors wehn site does not exist!
      if fedwiki_IsWiki (menuSubDomain) is false then
         return empty
      end if
      put pageArray_Fetch (menuSubDomain, "welcome-visitors") into pageArray
   else
      put pageArray_Fetch (menuSubDomain, hkeySlug) into pageArray
   end if
   return pageArray
end lcw_FetchMenuItemHelpArray


--> Help | Menu | Info
-
function help_ConstructMenuSubDomain gMenuTitle
   put menu_StripGlobal (gMenuTitle) into pageTitle
   put help_MenuSubDomain (pageTitle) into menuSubDomain
   return menuSubDomain
end help_ConstructMenuSubDomain

function help_MenuSubDomain pageTitle
   set the itemdelimiter to "|"
   put the number of items of pageTitle - 1 into maxNum
   repeat with itemNum = maxNum down to 1
      put word 1 to -1 of item itemNum of pageTitle into dBit
      put tolower (dBit) & "." after firstBit
   end repeat
   put firstBit & "menu.livecode.world" into menuSubDomain
   return menuSubDomain
end help_MenuSubDomain

function menu_ConstructPageTitle gMenuTitle
   -- see similar "help_ConstructMenuPageTitle"
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of gMenuTitle = "Global" then
      delete item 1 of gMenuTitle
   end if
   return word 1 to -1 of gMenuTitle
end menu_ConstructPageTitle

function help_ConstructMenuPageTitle stackName
   -- remove first "Global" item for brevity of title
   set the itemdelimiter to "_"
   if item 1 of stackName = "Global" then
      delete item 1 of stackName
   end if
   put help_MenuPageTitle (stackName) into pageTitle
   return pageTitle
end help_ConstructMenuPageTitle

function help_MenuPageTitle stackName
   replace "_" with " | " in stackName
   return stackName
end help_MenuPageTitle

function menu_StripGlobal gMenuTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of gMenuTitle = "Global" then
      delete item 1 of gMenuTitle
   end if
   put word 1 to -1 of gMenuTitle into pageTitle 
   return pageTitle
end menu_StripGlobal


--> Help | Menu | Construct
-
command pageArray_ReplaceSectionBody @pageArray, sectionTitle, storyArray
   pageArray_DeleteSectionBody pageArray, sectionTitle 
   put the result into titleItemNum
   pageArray_InsertStory pageArray, storyArray, titleItemNum
   return titleItemNum
end pageArray_ReplaceSectionBody

function help_ConstructMenuStory mTitle, pHow, pMenuController
   local pageArray
   if pMenuController is empty then
      put menu_GetGlobalController (gMenuTitle) into pMenuController
   end if
   if exists (pMenuController) is false then return empty
   
   put the menu_Index [mTitle] of pMenuController into mHandlers
   repeat for each line hName in mHandlers 
      switch
         case hName = "-"
            pageArray_AddPagefold pageArray, "."
            break
         case pHow is "handler"
            put fedwiki_ConstructSlug (hName) into pageSlug
            put menu_CommandToText (hName) into mText
            --
            pageArray_AddReference pageArray, pageSlug, "handler.livecode.world", mText, hName
            break
         case pHow is "reference"
            put menu_CommandToText (hName) into mText
            put fedwiki_ConstructSlug (mText) into pageSlug  
            put help_ConstructMenuSubDomain (mTitle) into menuSubDomain
            --
            pageArray_AddReference pageArray, pageSlug, menuSubDomain, hName, mText
            break
         default
            put menu_CommandToText (hName) into mText
            put hkey_Construct (hName, "M", pMenuController) into hKey
            put the github_HandlerURL [hKey] of pMenuController into handlerURL
            put "-" && mText && "- [" & handlerURL && "github]" into someMarkdown
            --
            pageArray_AddMarkdown pageArray, someMarkdown
      end switch   
   end repeat
   return pageArray ["story"]
end help_ConstructMenuStory


--> Private
-
private command help_MenuMergeAndStore mController, pageArray
   put pageArray ["title"] into pageTitle -- could get from stackName ?
   --
   put help_ConstructDomain ("menu") into wikiDomain
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put help_ObjectCurlyData (mController, "menu") into curlyData
   curly_MergePageArray pageArray, curlyData
   --
   pageArray_Store wikiDomain, pageSlug, pageArray
   put the result into shellResult
   if shellResult is empty then
      return pageArray
   else
      return shellResult
   end if
end help_MenuMergeAndStore

private command help_MenuItemMergeAndStore hKey, menuSubDomain, pageArray, pUpdate
   put pageArray ["title"] into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put help_HkeyCurlyData (hKey, pUpdate) into curlyData
   curly_MergePageArray pageArray, curlyData
   --
   pageArray_Store menuSubDomain, pageSlug, pageArray
   put the result into shellResult
   if shellResult is empty then
      return pageArray
   else
      return shellResult
   end if
end help_MenuItemMergeAndStore
