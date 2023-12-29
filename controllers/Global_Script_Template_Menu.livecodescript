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
on menu_SetSpace dView
   put 4 into owRepeat
   put 1 into nwRepeat
   --
   put the view_Text of dView into someScript
   put word 1 to -1 of someScript into someScript
   repeat with lineNum = 1 to the number of lines of someScript
      put line lineNum of someScript into sLine
      --
      get word 1 to -1 of sLine
      if it is empty then
         put empty into line lineNum of someScript 
      else
         put offset (it, sLine) into cNum
         put char 1 to (cNum -1) of sLine into wSpace
         put the number of chars of wSpace into wNum
         put wNum / owRepeat into iNum
         put iNum * nwRepeat into sNum
         put text_RepeatString (space, sNum) into newWhiteSpace
         --
         put newWhiteSpace & it into line lineNum of someScript 
      end if
   end repeat
   set the displayed_Data of dView to someScript
   -- display_Text someScript, "New Script", "Function"
end menu_SetSpace

on menu_ConstructFunction dView
   put the view_Text of dView into someScript
   put the title_Text of dView into templateName
   put "sJavascript" into scriptVar
   --
   put lcw_Ask ("Enter function name...", templateName, "Function name", dView) into fName
   --
   put word 1 to -1 of someScript into someScript
   put line 1 of someScript into firstLine
   if matchText (firstLine, "function (.+)\((.+)\).*" , sFunctionName, firstParams) is true then
      put fName && firstParams into hName 
      repeat for each item pName in firstParams
         put "'[[" & pName & "]]', " after mergeItems
      end repeat
      delete char -2 to -1 of mergeItems
      put sFunctionName & "(" & mergeItems & ")" into lastLine
   else
      put fName into hName 
      put empty into lastLine
   end if
   --
   put word 1 to -1 of someScript into someScript
   put quote && "&" && quote into qBit
   repeat for each line sLine in someScript
      replace "console.log" with "liveCode.javascript_Result" in sLine
      replace quote with qBit in sLine
      --
      if sLine is empty then
         -- put "put CR after" && scriptVar & CR after fBody
      else
         put "put" && kwote (sLine) && "& CR after" && scriptVar & CR after fBody
      end if
   end repeat
   --
   put "--" & CR after fBody
   --
   if lastLine is empty then
      put "delete char -1 of" && scriptVar & CR after fBody
   else
      put "put" && kwote (lastLine) && "& CR after" && scriptVar & CR after fBody
   end if
   --
   put "--" & CR after fBody
   put "return merge (" && scriptVar & ")" after fBody
   --
   put handler_Construct ("function", hName, fBody, false) into sHandler
   display_Text sHandler, fName, "Function"
end menu_ConstructFunction

private on _
end _

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

on menu_DropHtml
   put scaffold_Get ("Drop HTML") into someHTML
   display_Html someHTML, "Drop HTML", "system"
   put the result into browserView
   set the javascriptHandlers of browserview to "wiki_DroppedURL"
end menu_DropHtml

on submenu_Dev
   return menu_DevTitle ("Global | Script | Template | Menu")
end submenu_Dev
