script "Global | Hkey | Calls | Outside | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Hkey | Calls | Outside | Menu
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
   return dView
end menu_Target

private function _DisplayedObect tObject
   put the displayed_Object of tObject into sObject
   return sObject
end _DisplayedObect

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Hkey | Calls | Outside | Menu
-
on menu_Show dView, showHow
   put collection_GetData() into collectedData
   --
   switch showHow
      case "Short Hkeys"
         put collection_ListShortKeys(collectedData) into dData
         break
      case "Long Hkeys"
         put collection_ListHkeys (collectedData) into dData
         break
      case "Collected Data"
         put collectedData into dData
         break
   end switch
   --
   set the displayed_Data of dView to dData
end menu_Show

getprop show_Params [dView]
   return the menuItem_CaseParams [the params] of me
   -- return menu_CaseParams (the params)
end show_Params

on menu_CollectOutside dView
   put the displayed_Data of dView into collectedData
   --
   put collection_ListHkeys (collectedData) into hKeys
   -- display_Data hKeys, "Deps", "Collection"
   set the displayed_Data of dView to hKeys
end menu_CollectOutside

function collection_ListShortKeys collectedData
   put collectedData ["shortkeyArray"] into shortkeyArray
   put keys (shortkeyArray) into shortKeys
   sort shortKeys
   return shortKeys
end collection_ListShortKeys

function collection_ListHkeys collectedData
   put collectedData ["shortkeyArray"] into shortkeyArray
   repeat for each key shortKey in shortkeyArray
      put shortkeyArray [shortKey]["hKey"] into hKeyArray
      put keys (hKeyArray) into foundHKeys
      put line 1 of foundHKeys into hKey
      put hKey & CR after hKeys
   end repeat
   delete char -1 of hKeys
   return hKeys
end collection_ListHkeys

private on _
end _

on menu_DeleteCollection dView
   collection_SetData empty
   set the displayed_Data of dView to empty 
end menu_DeleteCollection

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Hkey | Calls | Outside | Menu")
end submenu_Dev

