script "lib_DisplayScriptTemplate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayScriptTemplate
type: library
version: 0.1

/*
This library is for displaying and editing script templates that use the "lib_Scaffolding" library
*/

--> Working on
-
command display_ScriptTemplate templateName, pDisplayView, pMenuTitle
   if pMenuTitle is empty then put "Global | Script | Template | Menu" into pMenuTitle
   put scaffold_GetFile (templateName) into someFile
   --
   if exists (pDisplayView) then
      lock screen
      put "file:" & someFile into someUrl
      put url someUrl into someText
      set the displayed_Text of pDisplayView to someText
      --
      set the displayed_File of pDisplayView to someFile
      set the title_Text of pDisplayView to templateName
      set the menu_Title of pDisplayView to pMenuTitle
      unlock screen
   else
      display_TextFile someFile, templateName, pMenuTitle, "Script Template"
      put the result into pDisplayView
   end if
   --
   return pDisplayView
end display_ScriptTemplate

command display_AskNewTemplate sObject
   if sObject is empty then
      put the clipboarddata ["text"] into someScript
      put "Give the copied script an template name..." into someQuestion
   else if exists (sObject) then
      put "Give the objects script an template name..." into someQuestion
      put the script of sObject into someScript
   else
      breakpoint
   end if
   put lcw_Ask (someQuestion, "Some Template") into templateName
   
   scaffold_SetTemplate templateName, someScript
   put the result into savedUrl
   --
   display_ScriptTemplate templateName
   put the result into textDisplayView
   return textDisplayView
end display_AskNewTemplate
