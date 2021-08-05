script "Global | Edited | Tree | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Edited | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
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
   --
   put the script_IsDifferent of sObject is true into LocalArray ["scriptIsDifferent"]
end menu_Init

getprop menu_Target [tObject]
   -- called once for each menu
   return tObject
end menu_Target

getprop recentScripts_Params
   put LocalArray ["recentObjects"] into recentObjects
   return recentObjects
end recentScripts_Params


--> Global | Edited | Tree | Menu
-
on menu_SaveEdited
   stack_SaveEdited "all"
   display_EditedStacks
end menu_SaveEdited

on menu_RecentScripts indexView, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on _
end _

on submenu_Tabs
   return "Global | ScriptEditor | Tabs | Menu"
end submenu_Tabs

on menu_Refresh
   display_EditedStacks
end menu_Refresh


--> Dev | Menu
-
on submenu_Dev
   return "Dev | Menu"
end submenu_Dev
