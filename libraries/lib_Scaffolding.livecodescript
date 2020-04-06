script "lib_Scaffolding"
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


--> Script Template
-
function scaffold_ListShortFiles
   put scaffold_GetFolder() into scriptTemplateFolder
   put folder_ShortFiles (scriptTemplateFolder) into shortFiles
   return shortFiles
end scaffold_ListShortFiles


--> Script Template | Files
 -
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


--> Scaffold | Model
-
function scaffold_GetTemplate tName
   put scaffold_GetUrl (tName) into someUrl
   put url someUrl into someScript
   return someScript
end scaffold_GetTemplate

command scaffold_SetTemplate tName, someText
   put scaffold_GetUrl (tName) into someUrl
   put someText into url someUrl
   return someUrl
end scaffold_SetTemplate

command scaffold_DeleteTemplate tName
    put scaffold_GetFile (tName) into someFile
    delete file someFile
    return someFile
end scaffold_DeleteTemplate
