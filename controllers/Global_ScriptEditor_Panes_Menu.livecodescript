script "Global_ScriptEditor_Panes_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Panes_Menu
type: controller
version: 0.1


--> Global | ScriptEditor | Panes | Menu
-
on menu_CreateDepsPane
   put "View|ScriptEditor|SVG" into viewName
   scriptEditor_AddPane "Deps", viewName   
end menu_CreateDepsPane

on menu_RemovePane mTarget, tabName
   scriptEditor_RemovePane tabName
end menu_RemovePane

on _
end _

on menu_Edit hKey, someName
   switch someName
      case "lib_ScriptEditor"
      case "lib_Ide"
      case "lib_IdeHack"
      case "model_IDE"
      case "-"  
      case "behavior_RevScriptEditorStack"
      case "revSEStackBehavior"
         edit the script of stack someName
         break
      case "Panes Group"
         put rev_ScriptEditorPanesGroup () into panesGroup
         edit the script of panesGroup
         break
      case "Panes Tab Group"
         put rev_ScriptEditorPaneTabsGroup() into panesTabGroup
         edit the script of panesTabGroup
         break
      case "-"
      case "Editor"
      case "scripttabs" 
      case "toolbar"
      case "handlerlist"
      case "leftbar"
      case "filterfield"
      case "variablespane" 
      case "documentationpane"
      case "filterfield"
      case "variablescheckbox"
         
      case "gutter"
      case "interactive find"
      default
         put revIDEScriptEditorBehavior (someName) into stackName
         edit the script of stack stackName
   end switch
end menu_Edit
   
on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Panes | Menu | Props
-
getprop tab_Names
   return scriptEditor_ListPaneNames()
end tab_Names


--> Global | ScriptEditor | Panes | Menu | Disabled
-
getprop disabled_RemovePane
   if scriptEditor_PaneExists ("Deps") is true then
      return false
   else
      return true
   end if
end disabled_RemovePane

getprop disabled_CreateDepsPane
   if scriptEditor_PaneExists ("Deps") is true then
      return true
   else
      return false
   end if
end disabled_CreateDepsPane


--> Dev | Menu
-
on menu_CreatePane mTarget, vName
   switch vName
      case "Notes"
         put "View|LiveCode|ScriptEditor|Pane" into viewName
         break
      case "Deps"
         put "View|ScriptEditor|SVG" into viewName
         break
      case "Svg"
         put "View|Image|SVG" into viewName
         break
      case "Browser"
         put "View|Layout|HeaderAndFooter" into viewName
         break
   end switch
   scriptEditor_AddPane vName, viewName
end menu_CreatePane

on menu_TestSvgFile hKey
   put hkey_SvgFile (hKey) into imageFile
   if there is a file imageFile then
      finder_Reveal imageFile
      -- display_ScriptEditorSvg imageFile
      set the svg_File [true] of control 1 of card 1 of stack "Display SVG 1" to imageFile
      put scriptEditor_PaneObject ("Deps") into paneObject
      set the svg_File [true] of control 1 of paneObject to imageFile
   else
      put imageFile
   end if
end menu_TestSvgFile

on menu_ResizePane
   scriptEditor_ResizePane
   scriptEditor_SetActivePane "Notes"
end menu_ResizePane

on menu_ShowPane
   scriptEditor_SetActivePane "Notes"
end menu_ShowPane
