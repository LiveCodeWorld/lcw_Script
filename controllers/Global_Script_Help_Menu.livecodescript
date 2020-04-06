script "Global_Script_Help_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Help_Menu
type: controller
version: 0.2


--> Menu | Init
-
local LocalArray

on menu_Init
   put project_IsActive ("lcw_Wiki") into helpActive
   put helpActive into LocalArray ["helpActive"]
   
   if helpActive then
      put scriptEditor_Object() into sObject
      put the help_Url [true] of sObject into helpURL
      put helpURL into LocalArray ["helpURL"]
   end if
end menu_Init

getprop menu_Target [tObject]
   -- put scriptEditor_GetProjectNameTarget (tObject) into projectName
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target

getprop disabed_UpdateHelp
   switch
      case LocalArray ["helpURL"] is empty
      case LocalArray ["helpActive"] is false
         return "delete"
      default
         return false
   end switch
end disabed_UpdateHelp

getprop disabled_Help
   switch
      case LocalArray ["helpURL"] is empty
      case LocalArray ["helpActive"] is false
         return "delete"
      default
         return false
   end switch
end disabled_Help

getprop disabled_CreateHelp
   switch
      case LocalArray ["helpURL"] is not empty
      case LocalArray ["helpActive"] is false
         return "delete"
      default
         return false
   end switch
end disabled_CreateHelp


--> Global | Script | Help | Menu
-
on menu_Help sObject
   help_Launch sObject
end menu_Help

on menu_CreateHelp sObject
   lcw_CreateObjectHelp sObject
   help_Launch sObject
end menu_CreateHelp

on menu_UpdateHelp sObject
   lcw_UpdateObjectHelp sObject
   help_Launch sObject
end menu_UpdateHelp
