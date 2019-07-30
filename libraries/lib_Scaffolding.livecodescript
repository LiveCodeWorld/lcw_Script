script "lib_Scaffolding"
--> MetaData
-
license: GPLv3
name: lib_Scaffolding
type: library
version: 0.3


 --> Scaffold
-
command scaffold_SaveDisplayed indexView
   put the title_Text of indexView into tName
   if tName = "Title" or tName is empty then
      put lcw_Ask ("What naem would you like to give this template text?", tName) into tName
   end if
   put the view_Text of indexView into someText
   scaffold_SetTemplate tName, someText
   put the result into savedUrl
   return tName
end scaffold_SaveDisplayed


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
