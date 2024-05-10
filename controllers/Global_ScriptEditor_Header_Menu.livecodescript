script "Global | ScriptEditor | Header | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Header | Menu
type: controller
version: 0.6

/*This menu is desinged to act as a constant header with a common set of tools,
while you switch menu tool environments.*/


--> Menu | Props
-
local LocalArray

getprop menu_Target [seTarget]
   put seTarget into LocalArray ["seTargetControl"]
   put the se_Stack of seTarget into seStack
   put seStack into LocalArray ["seStack"]
   put the se_DisplayedObject of seTarget into sObject
   -- put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
   --
   put the script_IsDifferent of sObject is true into LocalArray ["scriptIsDifferent"]
   put the script_Type of sObject into LocalArray ["scriptType"]
   --
   _Init
   return sObject
end menu_Target

private command _Init
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
end _Init

getprop disabled_DisplayLocalChanges [sObject]
   if LocalArray ["scriptIsDifferent"] then
      return false
   else
      return true -- "delete"
   end if
end disabled_DisplayLocalChanges

getprop editIdeMenu_Params
   return ide_ListMenuElements()
end editIdeMenu_Params

getprop setMenuGroup_Param
   return ide_ShortTitle ("Recent")
end setMenuGroup_Param

getprop setMenuGroup_Params
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end setMenuGroup_Params

getprop recentScripts_Params
   put LocalArray ["recentObjects"] into recentObjects
   return recentObjects
end recentScripts_Params

getprop disabled_ObjectProperties [sObject]
   put the stack_Name of sObject into stackName
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

getprop disabled_MenuTools [sObject]
   if LocalArray ["scriptType"]= "controller" then
      return false
   else
      return true
   end if
end disabled_MenuTools

getprop disabled_SaveEdited
   put LocalArray ["editedStackNames"] into editedStackNames
   if editedStackNames is empty then
      -- return true
      return "delete"
   else
      return false
   end if
end disabled_SaveEdited

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly sObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of sObject & space into tFriendlyName
   
   if the name of sObject is the short name of sObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of sObject after tFriendlyName
   else
      put quote & the short name of sObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly


--> Global | ScriptEditor | Header | Menu
-
on menu_DisplayLocalChanges sObject
   display_ScriptIsDifferent sObject
end menu_DisplayLocalChanges

on menu_RecentScripts sObject, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on menu_Clean sObject
   put LocalArray ["seStack"] into seStack
   lcw_Answer "Sure you want to format and clean start and end handler lines of [[sName]]", seStack, sObject
   --
   put the short name of seStack into seName
   se_Clean seName, true, true
   --
   put the script_Diff of sObject into uDiff
   if uDiff is not empty then
      display_ScriptDiff sObject, 3
   end if
end menu_Clean

on menu_SaveEdited
   stack_SaveEdited "all"
end menu_SaveEdited

private on _
end _

on submenu_Display
   return "Global | Project | Display | Menu"
end submenu_Display

on submenu_Create
   return "Global | Project | Create | Menu"
end submenu_Create

on submenu_MenuTools
   return "Global | MenuTools | Menu"
end submenu_MenuTools

on submenu_Ide
   return "Global | ScriptEditor | Menu"
end submenu_Ide

private on __
end __

on submenu_Go
   return "Global | ScriptEditor | Go | Menu"
end submenu_Go

on submenu_Tabs
   return "Global | ScriptEditor | Tabs | Menu"
end submenu_Tabs

-- on submenu_Ide
   return "Global | ScriptEditor | Menu"
end submenu_Ide

private on ___
end ___

on submenu_Git
   return "Global | GIT | Simple | Object | Menu"
end submenu_Git

 --on submenu_Help
   switch LocalArray ["scriptType"]
      case "menu"
      case "controller"
         return "Global | Help | Controller | Menu"
      default
         return "Global | Help | Object | Menu"
   end switch
end submenu_Help

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
