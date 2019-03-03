script "Global_Script_Changes_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Changes_Menu
type: controller
version: 0.2


--> Global | Script | Changes | Menu
-
on menu_FilterForChanged indexView
   put the displayed_Index of indexView into scriptObjects
   repeat for each line scriptObject in scriptObjects
      if the script_IsDifferent of scriptObject is true then
         put scriptObject & CR after changedScriptObjects
      end if
   end repeat
   delete char -1 of changedScriptObjects
   set the displayed_Index of indexView to changedScriptObjects
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


--> Global | Script | Changes | Menu | Props
-
getprop how_Longs
   return "5 min,10 min,20 min,30 min,300 min,-,ask"
end how_Longs


--> Global | Script | Changes | Menu | Disabled
-
