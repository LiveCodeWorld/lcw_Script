﻿script "Global_ScriptEditor_Header_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Header_Menu
type: controller
version: 0.6

/*
This menu is desinged to act as a constant header with a common set of tools,
while you switch menu tool environments.
*/


--> Menu | Props
-
local LocalArray

on menu_Init
   put stack_ListEditedNames() into editedStackNames
   repeat for each line stackName in editedStackNames
      switch
         case exists (stack stackName) is false
         case word 1 of stackName = "Untitled"
            next repeat
         default
            put stackName & CR after goodEditedStackNames
      end switch
   end repeat
   delete char -1 of goodEditedStackNames
   put goodEditedStackNames into LocalArray ["editedStackNames"]
   
   put scriptEditor_ListEditingObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   put keys (friendlyArray) into LocalArray ["recentObjects"]
   --
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
end menu_Init

getprop menu_Target [tObject]
   put LocalArray ["sObject"] into sObject
   return sObject
end menu_Target

getprop editIdeMenu_Params
   return ide_ListMenuElements()
end editIdeMenu_Params

getprop setMenu_Param
   return ide_ShortTitle ("Recent")
end setMenu_Param

getprop setMenu_Params
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end setMenu_Params

getprop recentScripts_Params
   put LocalArray ["recentObjects"] into recentObjects
   return recentObjects
end recentScripts_Params

getprop disabled_ObjectProperties [scriptObject]
   put the stack_Name of scriptObject into stackName
   if the scriptonly of stack stackName is true then
      return "delete"
   else
      return false
   end if
end disabled_ObjectProperties

getprop disabled_RecentScripts
   put LocalArray ["recentObjects"] into recentObjects
   if recentObjects is empty then
      return true
   else
      return false
   end if
end disabled_RecentScripts

getprop disabled_SaveRecentStacks
   put LocalArray ["editedStackNames"] into editedStackNames
   put LocalArray ["friendlyArray"] into friendlyArray
   --
   repeat for each line editedStackName in editedStackNames
      repeat for each key recentObject in friendlyArray
         if the short name of recentObject = editedStackName then
            put editedStackName & CR after editedRecentStackNames
         end if
      end repeat
   end repeat
   delete char -1 of editedRecentStackNames
   if editedRecentStackNames is empty then
      return true
   else
      return false
   end if
end disabled_SaveRecentStacks

getprop disabled_SaveEdited
   put LocalArray ["editedStackNames"] into editedStackNames
   if editedStackNames is empty then
      -- return true
      return "delete"
   else
      return false
   end if
end disabled_SaveEdited

getprop disabled_MenuTools [scriptObject]
   get the script_Type of scriptObject
   if it = "controller" then
      return false
   else
      return true
   end if
end disabled_MenuTools

getprop disabled_DisplayLocalChanges [scriptObject]
   if the script_IsDifferent of scriptObject is true then
      return false
   else
      -- return true
      return "delete"
   end if
end disabled_DisplayLocalChanges


--> Global | ScriptEditor | Header | Menu
-
on menu_DisplayLocalChanges scriptObject
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on menu_RecentScripts scriptObject, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on menu_SaveEdited
   stack_SaveEdited "all"
end menu_SaveEdited

on _
end _

on submenu_Help
   return "Global | Script | Help | Menu"
end submenu_Help

on menu_SetMenu sObject, mTitle
   ide_SetMenuTitle "Recent", mTitle
end menu_SetMenu

on menu_EditIdeMenu sObject, mElement
   ide_EditMenu mElement
end menu_EditIdeMenu

on _
end _

on submenu_MenuTools
   return "Global | MenuTools | Menu"
end submenu_MenuTools

on submenu_Go
   return "Global | ScriptEditor | Go | Menu"
end submenu_Go

on submenu_Tabs
   return "Global | ScriptEditor | Tabs | Menu"
end submenu_Tabs

on submenu_MyMenu
   return "Global | ScriptEditor | Recent | Custom | Menu"
end submenu_MyMenu


--> Deps
-
command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly
