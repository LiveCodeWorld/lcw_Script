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

command launch_MenuControllerHelp mController, pDisplayView
   put the menu_GlobalTitle of mController into gMenuTitle
   if gMenuTitle is empty then return "Error, no menu_GlobalTitle for:" && mController
   
   -- put the help_Url [true] of mController into helpURL
   put help_ConstructMenuUrl (gMenuTitle, true) into helpURL
   if helpURL is not empty then
      launch url helpURL
      return helpURL
   end if
   
   ask_CreateMenuPage mController, pDisplayView
   put the result into helpURL
   return helpURL
end launch_MenuControllerHelp

command ask_CreateMenuPage mController, pDisplayView
   put the name of mController into oName
   if pDisplayView is empty then
      put rev_ScriptEditorStack () into pDisplayView
   end if
   get "Are you sure you wish to create the wiki help page for the script of [[oName]]? This will overwrite any existing page."
   lcw_Answer it, pDisplayView, oName
   
   help_CreateMenuPage mController
   put the result into helpURL
   return helpURL
end ask_CreateMenuPage

command help_CreateMenuPage mController
   put the menu_GlobalTitle of mController into gMenuTitle
   if gMenuTitle is empty then return "Error, no menu_GlobalTitle for:" && mController
   
   ask_PushGithub mController
   help_CreateMenuPage gMenuTitle, mController
   --
   put help_ConstructMenuUrl (gMenuTitle, true) into helpURL
   launch url helpURL
   return helpURL
end help_CreateMenuPage


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

-- on menu_UpdateCodeSection sObject
help_UpdateObjectCodeSection sObject
launch_ObjectHelp sObject
end menu_UpdateCodeSection

-- on menu_UpdateObjectHelp sObject
   help_UpdateFromObject sObject
   launch_ObjectHelp sObject
end menu_UpdateObjectHelp

-- on menu_UploadGraph sObject, sGraph
   breakPoint
end menu_UploadGraph
