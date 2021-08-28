script "Global | Handler | Calls | Menu"
--> MetaData
-
license: GPLv3
name: Global | Handler | Calls | Menu
type: controller
version: 0.2


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put scriptEditor_GetHkey() into hKey
   return hKey
end menu_Target

getprop disabled_ExportHandlerCalls [hKey]
   put hkey_FetchHandler (hKey) into exportedHandler
   --  if exportedHandler is empty then return false
   
   put handler_Get (hKey) into objectHandler
   if objectHandler = exportedHandler then
      return true
   else
      return false
   end if
end disabled_ExportHandlerCalls
   
getprop disabled_EditHandlerCalls [hKey]
   return _callFileExists (hKey)
end disabled_EditHandlerCalls

getprop disabled_ListHandlerCalls [hKey]
   return _callFileExists (hKey)
end disabled_ListHandlerCalls

private function _callFileExists hKey
   put hkey_CallsFile (hKey) into callsFile
   if there is a file callsFile then
      return false
   else
      return true
   end if
end _callFileExists


--> Global | Handler | Calls | Menu
-
on submenu_Dependency
   return "Global | Hkey | Dependency | Menu"
end submenu_Dependency

on menu_EditHandlerCalls hKey
   put hkey_CallsFile (hKey) into callsFile
   atom_DisplayFile callsFile
end menu_EditHandlerCalls

on menu_ExportHandlerCalls hKey
   hkey_ExportHandler hKey, true
   display_HandlerCalls hKey
end menu_ExportHandlerCalls

on menu_ListHandlerCalls hKey
  display_HandlerCalls hKey
end menu_ListHandlerCalls

on menu_CollectDependencies hKey
   
end menu_CollectDependencies

on _
end _

on menu_RevealHandlerFolder hKey
   put hkey_Folder (hKey) into handlerFolder
   finder_Reveal handlerFolder
end menu_RevealHandlerFolder
