script "Global | Script | Template | Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Template_Menu
type: controller
version: 0.2

local LocalArray


--> Global | Script | Template | Menu
-
on menu_Save indexView
   scaffold_SaveDisplayed indexView
   put the result into templateName
   --
   put scaffold_GetTemplate (templateName) into savedText
   --
   lcw_Notify merge ("Stored text as scaffold template '[[templateName]]'")
end menu_Save

on menu_DisplayTemplate textDisplayView, templateName
   display_ScriptTemplate templateName
end menu_DisplayTemplate

on menu_RevealTemplate
   put scaffold_GetFolder() into someFolder
   finder_Reveal someFolder
end menu_RevealTemplate

on _
end _

on menu_NewTemplateFromClipboard
   ask "What would you like to call this template as..." with "template_name"
   put it into templateName
   if templateName is empty then exit to top
   
   put the clipboarddata ["text"] into someScript
   scaffold_SetTemplate templateName, someScript
   put the result into savedUrl
   
   display_ScriptTemplate templateName
end menu_NewTemplateFromClipboard

on menu_CopyTemplateToClipboard mTarget, templateName
   put scaffold_GetTemplate (templateName) into templateScript
   set the clipboarddata ["text"] to templateScript
   lcw_Notify "Script copied to clipboard!"
end menu_CopyTemplateToClipboard

on _
end _

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

on menu_SaveAs textDisplayView
   put the view_Text of textDisplayView into someScript
   put the title_Text of textDisplayView into templateName
   
   ask "What would you like to save this template as..." with templateName
   put it into templateName
   if templateName is empty then exit to top
   
   scaffold_SetTemplate templateName, someScript
   put the result into newUrl
   
   set the displayed_Url of textDisplayView to newUrl
   set the title_Text of textDisplayView to templateName
end menu_SaveAs

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev

    
--> Global | Script | Template | Menu | Props
-
getprop template_Names [mTarget]
    return scaffold_ListShortFiles()
end template_Names


--> Global | Script | Template | Menu | Disabled
-
-- getprop disabled_Save [textDisplayView]
   put LocalArray ["textDisplayView"]  into textDisplayView
   put exists (textDisplayView) into isTextDisplay
   return isTextDisplay is false
end disabled_Save

-- getprop disabled_SaveAs [textDisplayView]
   put LocalArray ["textDisplayView"]  into textDisplayView
   put exists (textDisplayView) into isTextDisplay
   return isTextDisplay is false
end disabled_SaveAs


--> Dev | Menu
-
on menu_ViewProperty someView, someProp
   view_DoPropertyMenu someProp, someView
end menu_ViewProperty

getprop some_Props [mTarget]
   -- put the name of mTarget
   put the view_PropertyMenu of mTarget into viewPropertyMenu
   return viewPropertyMenu
end some_Props

on _
end _

on menu_EditBehavior textDisplayView
   put the behavior of textDisplayView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_TopLevel textDisplayView
   put the stack_Name of textDisplayView into stackName
   toplevel stackName
end menu_TopLevel

on _
end _

on menu_EditThisTemplate mTarget
   put the displayed_File of mTarget into someFile  
   text_EditFile someFile
end menu_EditThisTemplate

on menu_EditTemplate mTarget, templateName
   put scaffold_GetFolder (templateName) into someFile
   atom_DisplayFile someFile
   return the result
end menu_EditTemplate

on _
end _

on menu_CopyMergeScriptToClipboard mTarget, templateName
   put scaffold_GetTemplate (templateName) into templateScript
   
   -- could get all the script metadata
   put user_GetName() into ObjectAuthor
   put scriptEditor_Object() into scriptObject
   put the view_Name of scriptObject into viewName
   
   put merge (templateScript) into someScript
   set the clipboarddata ["text"] to merge (someScript)
   
   put someScript
   lcw_Notify "Script copied to clipboard!"
end menu_CopyMergeScriptToClipboard



--> Menu | Props
-
-- on menu_Init
   put menu_GetTargetObject() into tObject
   if word 1 of tObject = "card" then put the long id of grp 1 of tObject into tObject
   put the textDisplay_View of tObject into textDisplayView
   put textDisplayView into LocalArray ["textDisplayView"]   
end menu_Init

-- getprop menu_Target [mTitlePath]
   put LocalArray ["textDisplayView"]  into textDisplayView
   return textDisplayView
end menu_Target


--> Deps
-
command text_EditFile someFile
   atom_DisplayFile someFile
   if the result is not empty then
      put "edit" && kwote(someFile) into someShell
      put shell (someShell) into shellResult
   end if
end text_EditFile
