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

on menu_Init tObject   
   put scaffold_ListShortFiles() into shortTemplateFiles
   sort shortTemplateFiles
   put shortTemplateFiles into LocalArray ["shortTemplateFiles"]
end menu_Init


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
   scaffold_SetTemplate tName, someText
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
on menu_SetMenu displayView
   put "Global | HTML | TagCloud | Menu" into gMenuTitle
   put lcw_Ask ("Choose a menu for this template:", gMenuTitle) into gMenuTitle
   --
   set the scaffold_MenuTitle of displayView to gMenuTitle
end menu_SetMenu

on _
end _

on menu_DisplayTemplate displayView, templateName
   if the shiftkey is "Down" then put empty into displayView
   display_ScriptTemplate templateName, displayView
end menu_DisplayTemplate

on menu_NewTemplateFromClipboard
   display_AskNewTemplate
end menu_NewTemplateFromClipboard

on menu_DeleteTemplate textDisplayView, templateName
   put merge ("Are you sure you want to delete the script template '[[templateName]]'. This cannot be undone!") into someWarning
   answer warning someWarning with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   scaffold_DeleteTemplate templateName
   put the result into deletedFile
   answer merge ("Deleted stored template script '[[templateName]]'!")
end menu_DeleteTemplate

on _
end _

on menu_Save indexView
   scaffold_SaveDisplayed indexView
   put the result into templateName
   --
   put scaffold_GetTemplate (templateName) into savedText
   --
   lcw_Notify merge ("Stored text as scaffold template '[[templateName]]'")
end menu_Save

on menu_SaveAs indexView
   put the view_Text of indexView into someScript
   put the title_Text of indexView into templateName
   
   ask "What would you like to save this template as..." with templateName
   put it into templateName
   if templateName is empty then exit to top
   
   scaffold_SetTemplate templateName, someScript
   put the result into newUrl
   
   set the displayed_Url of indexView to newUrl
   set the title_Text of indexView to templateName
end menu_SaveAs

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_DisplayBrowser
   display_ScaffoldHtml "Rough Blue"
end menu_DisplayBrowser

on menu_TextEditTemplate mTarget
   put the displayed_File of mTarget into someFile  
   text_EditFile someFile
end menu_TextEditTemplate

on menu_AtomEditTemplate mTarget, templateName
   put scaffold_GetFolder (templateName) into someFile
   atom_DisplayFile someFile
   return the result
end menu_AtomEditTemplate

on _
end _

on menu_CopyTemplateToClipboard indexView
   put the title_Text of indexView into templateName
   --
   put the view_Text of indexView into displayedScript
   put scaffold_GetTemplate (templateName) into templateScript
   if displayedScript is not templateScript then
      lcw_Answer "The stored and dispayed tmeplates differ. Do you want to continue and use the displayed version?"
   end if
   --
   set the clipboarddata ["text"] to displayedScript
   --
   lcw_Notify "Template copied to clipboard!"
end menu_CopyTemplateToClipboard

on menu_TestMergeScriptToClipboard mTarget
   put the title_Text of textDisplayView into templateName
   --
   put scaffold_GetTemplate (templateName) into templateScript
   
   -- could get all the script metadata
   put lcw_GetAuthor() into ObjectAuthor
   put scriptEditor_Object() into scriptObject
   put the view_Name of scriptObject into viewName
   --
   put merge (templateScript) into someScript
   --
   set the clipboarddata ["text"] to merge (someScript)
   put someScript
   lcw_Notify "Script copied to clipboard!"
end menu_TestMergeScriptToClipboard

on _
end _

on menu_RevealTemplateFolder
   put scaffold_GetFolder() into someFolder
   finder_Reveal someFolder
end menu_RevealTemplateFolder

on menu_TopLevel textDisplayView
   put the stack_Name of textDisplayView into stackName
   toplevel stackName
end menu_TopLevel
