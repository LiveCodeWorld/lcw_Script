﻿script "Global | Script | Changes | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Script | Changes | Menu
type: controller
version: 0.3


--> Menu | Init
-
on mDoubleUp_SaveStack indexView, mStackName
   put the bad_StackArray of indexView into testArray
   put testArray ["bad path"][mStackName] into stackPath
   switch
      case there is a file stackPath
         put "OK"
         break
      default
         put "Missing:" && stackPath
   end switch
end mDoubleUp_SaveStack

getprop displayRecentExports_Params
   return "5 min,10 min,20 min,30 min,300 min,-,ask"
end displayRecentExports_Params


--> Global | Script | Changes | Menu
-
on menu_DisplayRecentChanges indexView
   display_RecentExports 300, indexView, true
end menu_DisplayRecentChanges

on menu_FilterForChanged indexView
   display_RecentExports empty, indexView, false
end menu_FilterForChanged

on _
end _

on menu_DisplayRecentExports mTarget, howLong
   if howLong = "ask" then
      put lcw_Ask ("How many hours...", 60) into someHours
      if someHours is not a number then exit to top
      put someHours * 60 into howLong
   end if
   display_RecentExports howLong
end menu_DisplayRecentExports

on _
end _

on menu_SaveAllEdited
   stack_SaveRecentStacks
   put the result into savedStacks
   --
   lcw_Notify "Saved all edited stack"
   put savedStacks
end menu_SaveAllEdited

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CheckUnsaved
   -- put the openstacks
   -- put the mainstacks
   put revloadedstacks ("application") into appStackNames
   sort appStackNames
   --
   repeat for each line stackName in appStackNames
      put the mainstack of stack stackName into mainStackName
      put the effective filename of stack stackName into stackPath
      switch 
         case there is a file stackPath
            -- it's all good
            put stackPath into testArray ["good"][mainStackName]
            break
         case stackPath is empty
            put stackPath into testArray ["empty path"][mainStackName]
            break
         default
            put stackPath into testArray ["bad path"][mainStackName]
      end switch
   end repeat
   --
   
   -- display_Array testArray
   put testArray ["bad path"] into badPathArray
   --
   put keys (badPathArray) into badStackNames
   sort badStackNames
   display_Lines badStackNames, "Bad Stacks", "mDoubleUp_SaveStack"
   put the result into displayView
   -- set the title_Menu of displayView to "Global | Test | Menu"
   set the bad_StackArray of displayView to testArray
   
   answer folder "Choose a recue folder..."
   put it into rescueFolder
   set the itemdelimiter to slash
   repeat for each key mStackName in badPathArray
      put badPathArray [mStackName] into stackPath
      put item -1 of stackPath into shortFile
      put item 1 to -2 of stackPath & slash into oldFolder
      put rescueFolder & slash & shortFile into newPath
      
      breakpoint
      folder_CreateNested oldFolder
      save stack mStackName
      -- save stack mStackName as newFile
   end repeat
end menu_CheckUnsaved
