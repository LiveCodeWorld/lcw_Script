script "lib_ScriptEditor"
--> MetaData
-
license: GPLv3
name: lib_ScriptEditor
type: library
version: 0.2


--> Working on
-
function scriptEditor_PaneObject paneName
   put rev_ScriptEditorPanesGroup() into paneGroup
   if exists (control paneName of paneGroup) is false then return empty
   
   put the long id of control paneName of paneGroup into paneObject
   return paneObject
end scriptEditor_PaneObject
   

--> ScriptEditor | Pane
-
function scriptEditor_PaneExists tabName, pEditorNum
   put scriptEditor_ListPaneNames (pEditorNum) into paneItems
   return tabName is among the items of paneItems
end scriptEditor_PaneExists

function scriptEditor_ListPaneNames pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into panesGroup
   put value ("seAvailablePanes()", panesGroup) into btnNames
   return btnNames
end scriptEditor_ListPaneNames

function scriptEditor_ListVisiblePanes pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into panesGroup
   put value ("seVisiblePanes()", panesGroup) into btnNames
   return btnNames
end scriptEditor_ListVisiblePanes

function scriptEditor_ListPaneTabNames pEditorNum
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into paneTabsGroup
   put the group_ButtonNameList of paneTabsGroup into btnNames
   return btnNames
end scriptEditor_ListPaneTabNames

function scriptEditor_GetActivePane pEditorNum
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into scriptEditorPanesGroup
   dispatch "getCurrentTab" to scriptEditorPanesGroup
   put the result into paneName
   return paneName
end scriptEditor_GetActivePane

command scriptEditor_SetActivePane paneName, pEditorNum
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into paneTabsGroup
   dispatch "setCurrentTab" to paneTabsGroup with paneName
   return it
   
   -- put rev_ScriptEditorPanesGroup() into paneGroup
   -- dispatch "showPane" to paneGroup with "Notes"
end scriptEditor_SetActivePane


--> ScriptEditor | Pane | Creation
-
function scriptEditor_PaneView pPaneName, pEditorNum
   if pPaneName is empty then
      put scriptEditor_GetActivePane (pEditorNum) into pPaneName
   end if
   put rev_ScriptEditorPanesGroup (pEditorNum) into scriptEditorPanesGroup
   put the long id of control pPaneName of scriptEditorPanesGroup into paneView
   return paneView
end scriptEditor_PaneView

command scriptEditor_EditPaneBehavior
   edit the script of stack "revSEStackBehavior"
end scriptEditor_EditPaneBehavior

command scriptEditor_AddPane tabName, viewName, pEditorNum
   put scriptEditor_PaneObject (tabName) into paneObject
   if exists (paneObject) is true then
      scriptEditor_SetActivePane tabName, pEditorNum
      return paneObject
   end if
   
   put rev_ScriptEditorPanesGroup (pEditorNum) into paneGroup
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into paneTabsGroup
   if exists (btn tabName of paneTabsGroup) is true then return false
   
   view_NormalizeName viewName
   if exists (stack viewName) is false then return empty
   put the template_View of card 1 of stack viewName into someView
   if exists (someView) is false then return empty
   
   lock screen
   copy someView to paneGroup
   put it into copiedPaneView
   set the name of copiedPaneView to tabName
   
   scriptEditor_SetPaneTabsGroupBehavior pEditorNum
   
   clone btn "Search Results" of paneTabsGroup
   put it into clonedTabButton
   set the name of clonedTabButton to tabName
   
   scriptEditor_ResizePane pEditorNum
   scriptEditor_SetActivePane tabName, pEditorNum
   unlock screen
   return copiedPaneView
end scriptEditor_AddPane

command scriptEditor_RemovePane tabName, pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into paneGroup
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into paneTabsGroup
   if exists (btn tabName of paneTabsGroup) is false then return false
   
   lock screen
   delete btn tabName of paneTabsGroup
   delete control tabName of paneGroup
   
   scriptEditor_ResizePane pEditorNum
   put scriptEditor_ListPaneTabNames (pEditorNum) into tabNames
   put item 1 of tabNames into paneName
   scriptEditor_SetActivePane paneName, pEditorNum
   unlock screen
   return paneGroup
end scriptEditor_RemovePane

command scriptEditor_ResizePane pEditorNum
   scriptEditor_ResizeTabsPane pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into paneGroup
   dispatch "resize" to paneGroup
end scriptEditor_ResizePane

command scriptEditor_ResizeTabsPane
   put rev_ScriptEditorPaneTabsGroup (pEditorNum) into paneTabsGroup
   put scriptEditor_ListPaneNames() into paneNames
   
   lock screen
   local tLeft, tBottom
   put the left of paneTabsGroup into tLeft
   put the bottom of paneTabsGroup into tBottom
   
   repeat for each item tPane in paneNames
      put the long id of button tPane of paneTabsGroup into tabButton
      set the bottomLeft of tabButton to tLeft, tBottom
      add the width of tabButton to tLeft
   end repeat
   unlock screen
end scriptEditor_ResizeTabsPane

command scriptEditor_SetPaneTabsGroupBehavior pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into scriptEditorPanesGroup
   put the name of stack "behavior_RevScriptEditorStack" into bObject
   set the behavior of scriptEditorPanesGroup to bObject
end scriptEditor_SetPaneTabsGroupBehavior


--> ScriptEditor | Tabs
-
function scriptEditor_ListTabScriptObjects
   send "revSEGetTargetObjects" to rev_ScriptEditorGroup()
   put the result into ruggedIDs
   return ruggedIDs
end scriptEditor_ListTabScriptObjects

command scriptEditor_ActivateTab someObject, pSetScript
   put revRuggedId (someObject) into someObject
   put scriptEditor_ListTabScriptObjects() into ruggedIDs
   set the wholematches to true
   if someObject is not among the lines of ruggedIDs then return false
   
   put rev_ScriptEditorGroup() into revScriptEditorGroup
   dispatch "revSESetCurrentObject" to revScriptEditorGroup with someObject
   
   if pSetScript is not empty then
      put rev_GetCachedScript (someObject) into oldCachedScript
      rev_SetScriptEditorField pSetScript
      set the clipboarddata to oldCachedScript
      return oldCachedScript
   else
      return true
   end if
end scriptEditor_ActivateTab

command scriptEditor_CloseTab scriptObject, pDontWarn, pDontCloseIfLast, pDontChangeTab
   # Parameters
   #   pObject : reference to the object to remove
   #   pDontWarn : whether or not to warn the user of losing unapplied changes (optional, defaults to false)
   #   pDontCloseIfLast : optional, defaults to false. If true, then the script editor will not be closed when the last tab is deleted.
   #   pDontChangeTab : optional, defaults to false, If true, then the script editor will not attempt to change tabs after removing the object
   # Description
   #   Removes the specified object from this script editor. If the removed object is the current
   #   editing object, then changes the current object to the last selected object.
   
   put scriptEditor_ListTabScriptObjects() into tabScriptObjects
   put the rugged_ID of scriptObject into scriptObject
   if scriptObject is among the lines of tabScriptObjects then
      
      put rev_ScriptEditorGroup() into editorObject
      put rev_ScriptEditorField() into editorObject
      
      dispatch "revSERemoveTargetObject" to editorObject with scriptObject,pDontWarn,pDontCloseIfLast,pDontChangeTab
      switch it
         case "handled" -- the message was handled and not passed
            break
         case "unhandled" -- no matching handlers were found
            break
         case "passed" -- the message was handled but passed by all handlers
            break
      end switch
      return true
   else
      return false
   end if
end scriptEditor_CloseTab

command scriptEditor_CreateNewTab someObject
   put rev_ScriptEditorGroup() into revScriptEditorGroup
   -- send "revSEAddTargetObject someObject" to revScriptEditorGroup
   dispatch "revSEAddTargetObject" to revScriptEditorGroup with someObject
   put the result someError
   return someError
end scriptEditor_CreateNewTab
