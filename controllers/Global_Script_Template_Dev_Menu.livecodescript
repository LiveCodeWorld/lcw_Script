script "Global | Script | Template | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Template | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Script | Template | Dev | Menu
-
on menu_SetMenu displayView
   put "Global | HTML | TagCloud | Menu" into gMenuTitle
   put lcw_Ask ("Choose a menu for this template:", gMenuTitle) into gMenuTitle
   --
   set the scaffold_MenuTitle of displayView to gMenuTitle
end menu_SetMenu

private on _
end _

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

private on __
end __

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

private on ___
end ___

on menu_RevealTemplateFolder
   put scaffold_GetFolder() into someFolder
   finder_Reveal someFolder
end menu_RevealTemplateFolder

on menu_TopLevel textDisplayView
   put the stack_Name of textDisplayView into stackName
   toplevel stackName
end menu_TopLevel

on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on ___
end ___

on menu_MenuEdit displayView
   menu_Edit "Global | Script | Template | Dev | Menu"
end menu_MenuEdit
