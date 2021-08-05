script "Global | HkeyArray | Missing | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | HkeyArray | Missing | Menu
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
   put tObject into LocalArray ["tObject"]  
   put the display_View of tObject into displayView
   --
   put the displayed_HkeyArray of displayView into hKeyArray
   put the displayed_SearchType of displayView into pWhichSearch
   put the displayed_Transport of displayView into transportStack
   --
   put the title_Text of displayView into stackObject
   put the displayed_Array of displayView into missingArray
   --
   put stackObject into LocalArray ["stackObject"]
   put missingArray into LocalArray ["missingArray"]
   --
   -- put _GetOtherStackObjects (missingArray, stackObject, controllerStack) into LocalArray ["otherStackObjects"]
   --
   return displayView
end menu_Target

private function _GetOtherStackObjects missingArray, stackObject, controllerStack
   delete variable missingArray [controllerStack]
   delete variable missingArray [stackObject]
   --
   delete variable missingArray ["Missing"]
   delete variable missingArray ["revIgniter"]
   --
   put the keys of missingArray into otherStackObjects
   return otherStackObjects
end _GetOtherStackObjects


--> Global | HkeyArray | Missing | Menu
-
on menu_FindMissing displayView
   put LocalArray ["missingArray"] into missingArray
   --
   put env_ScriptHierarchy (true) into searchObjects
   put scriptMissing_FindFromMissingArray (missingArray, searchObjects) into foundMissingObjectDepArray
   --
   set the displayed_Data of displayView to foundMissingObjectDepArray
end menu_FindMissing

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment
