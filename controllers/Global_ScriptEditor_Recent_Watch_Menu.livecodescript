﻿script "Global | ScriptEditor | Recent | Watch | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Recent | Watch | Menu
type: controller
version: 1.0

/*
This is designed to be the main or the default menu for manipulating a script in an editor.
As such it is currently used in the Livecode IDE's script editor.
You can attach it anywhere you want. I personally add it to the Script Editors "watch" button on the top right bar of the editor.
*/


--> Variables
-
local LocalArray

--> Menu | Props
-

--> Global | ScriptEditor | Recent | Watch | Menu
-
on menu_RecentWatch seHistoryButton
   put the name of seHistoryButton
end menu_RecentWatch

on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

private on _
end _

on submenu_Card
   return "Global | Card | Menu"
end submenu_Card

on submenu_Script
   return "Global | ScriptEditor | Script | Menu"
end submenu_Script

private on __
end __

on menu_ScriptHelp seButton
   -- launch_MenuHelp
   put scriptEditor_Object() into sObject
   draft_ScriptHelp sObject
end menu_ScriptHelp
