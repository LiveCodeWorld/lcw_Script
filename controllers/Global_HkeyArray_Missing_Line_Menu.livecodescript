script "Global | HkeyArray | Missing | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | HkeyArray | Missing | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Events
-
on mDoubleUp_MissingHkey dView, someLine
   put the selected_Line of dView into shortHeky
   breakpoint
   put the title_Text of dView into sObject
   return displayView
end mDoubleUp_MissingHkey


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the selected_Path of dView into sPath
   put item 1 of sPath into LocalArray ["shortHkey"]
   --
   put dView into LocalArray ["dView"]
   put sPath into LocalArray ["sPath"]
   --
   put the title_Text of dView into sObject
   put the displayed_Object of dView into sObject
   return sObject
end menu_Target

getprop menu_CheckTarget [sObject]
   return exists (sObject)
end menu_CheckTarget


--> Global | HkeyArray | Missing | Line | Menu
-
on menu_FindMissingHkey sObject
   put LocalArray ["shortHkey"] into shortHkey
   --
   put the found_Hkey [shortHkey] of sObject into foundHkey
   if foundHkey is empty then
      put shortHkey
   else
      put foundHkey
   end if
end menu_FindMissingHkey

private on _
end _

on menu_SelectedPath sObject
   put LocalArray ["sPath"]
end menu_SelectedPath

