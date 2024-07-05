script "Global | Script | Compare | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Script | Compare | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   --
   put the displayed_Object of dView into LocalArray ["leftObject"]
   put the script_CompareArray of dView into LocalArray ["cArray"]
   put the displayed_RightObject of dView into LocalArray ["rightObject"]
   
   return dView
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Script | Compare | Menu
-
on menu_ScriptCompare dView
   put the params
end menu_ScriptCompare

private on _
end _

on menu_CollectOnlyLeft dView
   put LocalArray ["leftObject"] into leftObject
   put LocalArray ["cArray"] into cArray
   put LocalArray ["rightObject"] into rightObject
   
   # leftEvents
   put cArray ["leftEvents"] into leftEventArray
   put keys (leftEventArray) into leftEventKeys
   sort lines of leftEventKeys
   --
   repeat for each line shortKey in leftEventKeys
      put the handler_From [shortKey] of leftObject into sHandler
      if sHandler is empty then
         breakpoint -- should not be
      end if
      put sHandler & CR&CR after cScript
   end repeat
   
   # onlyLeft
   put cArray ["onlyLeft"] into onlyLeftArray
   put keys (onlyLeftArray) into shortKeys
   sort lines of shortKeys
   --
   repeat for each line shortKey in shortKeys
      put the handler_From [shortKey] of leftObject into sHandler
      if sHandler is empty then
         breakpoint -- should not be
      end if
      put sHandler & CR&CR after cScript
   end repeat
   delete char -2 to -1 of cScript
   --
   display_Text cScript, leftObject, "Collected Script"
end menu_CollectOnlyLeft

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Script | Compare | Menu")
end submenu_Dev
