script "Global | Help | Controller | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Help | Controller | Menu
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
   return scriptEditor_Object()
   
   put menu_GetTarget ("Global | Help | Object | Menu") into mController
   if exists (mController) is false then put scriptEditor_Object() into mController
   _Init mController
   return mController
end menu_Target

getprop uploadGraph_Params [sObject]
   return empty
end uploadGraph_Params

private command _Init mController
   put env_ProjectIsActive ("lcw_Wiki") into helpActive   
   if helpActive then
      put the help_Url [true] of mController into helpURL
      put helpURL into LocalArray ["helpURL"]
      put scriptType into LocalArray ["scriptType"]
   end if
   put helpActive into LocalArray ["helpActive"]
end _Init


--> Global | Help | Controller | Menu
-
on menu_Help mController
   launch_MenuControllerHelp mController
end menu_Help

on menu_ProjectHelp mController
   put the project_Name of mController into projectName
   launch_OrCreateProject projectName
end menu_ProjectHelp

on _
end _

on menu_CreateMenuHelp mController
   ask_CreateMenuPage mController, pDisplayView
end menu_CreateMenuHelp

getprop disabled_CreateHelpWiki [mController]
   put the help_Domain of mController into wikiDomain
   put wiki_GetFolder(wikiDomain) is not empty into wikiExists
   return wikiExists
end disabled_CreateHelpWiki

on menu_CreateHelpWiki mController
   put the help_Domain of mController into wikiDomain
   put lcw_Ask ("Create new wiki...", wikiDomain, "New Wiki") into wikiDomain
   --
   wikiServer_Create wikiDomain
   display_LocalWikis "", "", "*livecode.world"
end menu_CreateHelpWiki
