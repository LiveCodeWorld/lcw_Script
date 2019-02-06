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
   put the title_Text of indexView into templateName
   put the view_Text of indexView into someText
   scaffold_SetTemplate templateName, someText
   put the result into savedUrl
   return templateName
end scaffold_SaveDisplayed


--> Script Template
-
function scaffold_ListShortFiles
    put scaffold_GetFolder() into scriptTemplateFolder
    return folder_ShortFiles (scriptTemplateFolder)
 end scaffold_ListShortFiles


--> Script Template | Files
 -
 function scaffold_GetUrl templateName
   put scaffold_GetFile (templateName) into someFile
   put "file:" & someFile into someURL
   return someURL
end scaffold_GetUrl

function scaffold_GetFile shortFileBit
   put project_GetFolder ("lcw_User") into projectFolder
   put asset_GetFolder (projectFolder, "templates") into templateFile
   put shortFileBit after templateFile
   return templateFile
end scaffold_GetFile

function scaffold_GetFolder
   put project_GetFolder ("lcw_User") into projectFolder
   put asset_GetFolder (projectFolder, "templates") into templateFolder
   return templateFolder
end scaffold_GetFolder


--> Scaffold | Model
-
function scaffold_GetTemplate templateName
   put scaffold_GetUrl (templateName) into someUrl
   put url someUrl into someScript
   return someScript
end scaffold_GetTemplate

command scaffold_SetTemplate templateName, someText
   put scaffold_GetUrl (templateName) into someUrl
   put someText into url someUrl
   return someUrl
end scaffold_SetTemplate

command scaffold_DeleteTemplate templateName
    put scaffold_GetFile (templateName) into someFile
    delete file someFile
    return someFile
end scaffold_DeleteTemplate
