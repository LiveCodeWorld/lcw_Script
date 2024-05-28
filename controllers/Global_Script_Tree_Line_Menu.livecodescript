script "Global | Script | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Tree | Line | Menu
type: controller
version: 0.1


--> Menu | Props
-
local LocalArray

on mDoubleUp_DisplayShortHkey displayView, shortHkey
   put the title_Text of displayView into sObject
   --
   put the selected_Path of displayView into clickedPath
   if the number of items of clickedPath = 2 then
      put item 1 of clickedPath into suiteTitle
   end if
   --
   put hKeyLine_AddObject (shortHkey, sObject) into hKey
   hkey_Edit hKey
end mDoubleUp_DisplayShortHkey

getprop menu_Target [tObject]
   put the tree_View of tObject into treeView
   get the selected_Path of treeView
   put treeView into LocalArray ["treeView"]
   --
   put item 1 of it into LocalArray ["suiteTitle"]
   put item 2 of it into shortHkey
   put shortHkey into LocalArray ["shortHkey"]
   --
   put the displayed_Object of treeView into hObject
   put shortHkey && "of" && hObject into hKey
   put hKey into LocalArray ["hKey"]
   --
   return treeView
end menu_Target

getprop disabled_HandlerSvg
   put LocalArray ["hKey"] into hKey
   --
   put hkey_SvgFile (hKey) into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_HandlerSvg

getprop disabled_HandlerOverlayArray
   put LocalArray ["hKey"] into hKey
   --
   put hkey_OverlayDataFile (hKey, true) into overlayDataFile
   if there is a file overlayDataFile then
      return false
   else
      return true
   end if
end disabled_HandlerOverlayArray


--> Global | Script | Tree | Line | Menu
-
on menu_EditHandler hObject
   put LocalArray ["hKey"] into hKey
   --
   hkey_Edit hKey
   --
   if the result is empty then
      -- not found
      put LocalArray ["treeView"] into treeView
      put merge ("Could not locate handler '[[hKey]]'?") into q
      dispatch "lcw_AnswerWarning" to indexView with q
   end if
end menu_EditHandler

on _
end _

on menu_GraphHandler hObject
   put LocalArray ["hKey"] into hKey
   --
   set the cursor to watch
   put the project_Name of hObject into projectName
   --
   graph_HkeyDependency hkey, projectName, "hierarchical"
   put the result into imageFile
   --
   display_HkeySVG hkey
end menu_GraphHandler

on _
end _

on menu_HandlerSvg hObject
   put LocalArray ["hKey"] into hKey
   --
   put hkey_SvgFile (hKey) into svgFile
   display_Svg svgFile
end menu_HandlerSvg

on menu_HandlerOverlayArray hObject
   put LocalArray ["hKey"] into hKey
   --
   -- put the handler_OverlayArray [hKey] of hObject into overlayArray
   put hkey_GetOverlayArray (hKey) into overlayArray
   --
   put word 1 to 2 of hKey into shortHkey
   display_Array overlayArray, shortHkey
end menu_HandlerOverlayArray

on _
end _

on menu_HandlerFolder hObject
   put LocalArray ["hKey"] into hKey
   --
   put hkey_Folder (hKey) into someFolder
   -- put the handler_Folder [hKey] of hObject into someFolder
   finder_Reveal someFolder
end menu_HandlerFolder

on menu_HandlerMetadataFolder hObject
   put LocalArray ["hKey"] into hKey
   --
   put the metadata_Folder [hKey] of hObject into someFolder
   finder_Reveal someFolder
end menu_HandlerMetadataFolder

on menu_ObjectMetadataFolder hObject
   put LocalArray ["hKey"] into hKey
   --
   put the metadata_Folder of hObject into someFolder
   finder_Reveal someFolder
end menu_ObjectMetadataFolder
