﻿script "lib_Scaffolding"
--> MetaData
-
license: GPLv3
name: lib_Scaffolding
type: library
version: 0.4

/*
This library is for storing and working with templates.

In particular we are using this library to store standardised scripts that we need to copy and paste with small modifications in several places,
like named  Controller / Menu and Behavior templates.
*/


--> Props
-
setprop scaffold_MenuTitle gMenuTitle
   if menu_Exists (gMenuTitle) is false then
      menu_Create gMenuTitle
      put the result into controllerObject
      edit the script of controllerObject
   end if
   put CR & "-" & CR & "Global | Script | Template | Menu" & tab & "submenu" after gMenuTitle
   --
   set the title_Menu of the target to gMenuTitle
   return gMenuTitle
end scaffold_MenuTitle


--> Snippet
-
function snippet_CurlyResult snippetPageSlug, sKey, sValue
   put snippet_Get (snippetPageSlug) into sSnippet
   put curly_ReplaceAll (sSnippet, sKey, sValue) into curlyResult
   return curlyResult
end snippet_CurlyResult

function snippet_Get tName
   put pageArray_Get ("scaffold.anarchive.earth", tName) into pageArray
   put pageArray_GetSectionText (pageArray, "Snippet") into snippetText
   return snippetText
end snippet_Get


--> Scaffold | Model
-
function scaffold_Get tName
   put scaffold_GetBinaryUrl (tName) into someUrl
   put url someUrl into utf8Text
   put textDecode (utf8Text, "UTF-8") into someText
   return someText
end scaffold_Get

command scaffold_Set tName, someText
   put scaffold_GetBinaryUrl (tName) into someUrl
   put textEncode (someText, "UTF-8") into utf8Text
   put utf8Text into url someUrl
   return someUrl
end scaffold_Set

-- function scaffold_Get tName
   put scaffold_GetUrl (tName) into someUrl
   put url someUrl into someScript
   return someScript
end scaffold_Get

-- command scaffold_Set tName, someText
   put scaffold_GetUrl (tName) into someUrl
   put someText into url someUrl
   return someUrl
end scaffold_Set

command scaffold_DeleteTemplate tName
    put scaffold_GetFile (tName) into someFile
    delete file someFile
    return someFile
end scaffold_DeleteTemplate


--> Scaffold
-
function scaffold_ListShortFiles
   put scaffold_GetFolder() into scriptTemplateFolder
   put file_ListShort (scriptTemplateFolder) into shortFiles
   sort shortFiles
   return shortFiles
end scaffold_ListShortFiles


--> Script Template | Files
-
function scaffold_GetBinaryUrl tName
   put scaffold_GetFile (tName) into someFile
   put "binfile:" & someFile into someURL
   return someURL
end scaffold_GetBinaryUrl

function scaffold_GetUrl tName
   put scaffold_GetFile (tName) into someFile
   put "file:" & someFile into someURL
   return someURL
end scaffold_GetUrl

function scaffold_GetFile shortFileBit
   put scaffold_GetFolder() into templateFile
   put shortFileBit after templateFile
   return templateFile
end scaffold_GetFile

function scaffold_GetFolder
   put project_GetFolder ("lcw_Script") into projectFolder
   put asset_GetFolder (projectFolder, "templates") into templateFolder
   return templateFolder
end scaffold_GetFolder
