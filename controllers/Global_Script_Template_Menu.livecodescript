script "Global | Script | Template | Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Template_Menu
type: controller
version: 0.3


--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]   
   put scaffold_ListShortFiles() into shortTemplateFiles
   sort shortTemplateFiles
   put shortTemplateFiles into LocalArray ["shortTemplateFiles"]
   --
   put the display_View of tObject into indexView
   return indexView
end menu_Target


--> Menu | Props
-
getprop displayTemplate_Param [indexView]
   put the title_Text of indexView into templateName
   return templateName
end displayTemplate_Param

getprop displayTemplate_Params
   return LocalArray ["shortTemplateFiles"]
end displayTemplate_Params

getprop deleteTemplate_Params
   return LocalArray ["shortTemplateFiles"]
end deleteTemplate_Params

getprop editTemplate_Params
   return LocalArray ["shortTemplateFiles"]
end editTemplate_Params

getprop copyMergeScriptToClipboard_Params
   return LocalArray ["shortTemplateFiles"]
end copyMergeScriptToClipboard_Params

getprop copyTemplateToClipboard_Params
   return LocalArray ["shortTemplateFiles"]
end copyTemplateToClipboard_Params


--> Deps
-
command scaffold_SaveDisplayed indexView
   put the title_Text of indexView into tName
   if tName = "Title" or tName is empty then
      put lcw_Ask ("What naem would you like to give this template text?", tName) into tName
   end if
   put the view_Text of indexView into someText
   scaffold_Set tName, someText
   put the result into savedUrl
   return tName
end scaffold_SaveDisplayed

command text_EditFile someFile
   atom_DisplayFile someFile
   if the result is not empty then
      put "edit" && kwote(someFile) into someShell
      put shell (someShell) into shellResult
   end if
end text_EditFile


--> Global | Script | Template | Menu
-
on menu_DisplayTemplate displayView, templateName
   display_ScriptTemplate templateName, displayView
end menu_DisplayTemplate

on menu_NewTemplateFromClipboard
   display_AskNewTemplate
end menu_NewTemplateFromClipboard

on menu_DeleteTemplate textDisplayView, templateName
   put merge ("Are you sure you want to delete the script template '[[templateName]]'. This cannot be undone!") into someWarning
   answer warning someWarning with "OK" or "Cancel" as sheet
   if it is "Cancel" then exit to top
   
   scaffold_DeleteTemplate templateName
   put the result into deletedFile
   answer merge ("Deleted stored template script '[[templateName]]'!") as sheet
end menu_DeleteTemplate

private on __
end __

on menu_Save indexView
   scaffold_SaveDisplayed indexView
   put the result into templateName
   --
   put scaffold_Get (templateName) into savedText
   --
   lcw_Notify merge ("Stored text as scaffold template '[[templateName]]'")
end menu_Save

-- on menu_SaveBinary indexView
   put the title_Text of indexView into templateName
   put ".gv" after templateName
   --
   put the displayed_Text of indexView into someText
   scaffold_Get templateName, someText
   put the result into newUrl
   --
   put scaffold_Get (templateName) into someText
   set the displayed_Text of indexView to someText
   --
   set the displayed_Url of indexView to newUrl
   set the title_Text of indexView to templateName
end menu_SaveBinary

on menu_SaveAs indexView
   put the view_Text of indexView into someScript
   put the title_Text of indexView into templateName
   
   ask "What would you like to save this template as..." with templateName
   put it into templateName
   if templateName is empty then exit to top
   
   scaffold_Set templateName, someScript
   put the result into newUrl
   
   set the displayed_Url of indexView to newUrl
   set the title_Text of indexView to templateName
end menu_SaveAs

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Script | Template | Menu")
end submenu_Dev
