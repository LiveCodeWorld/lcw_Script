script "Global | ScriptEditor | Tabs | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Tabs | Menu
type: controller
target: scriptObject
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target


--> Global | ScriptEditor | Tabs | Menu
-
on menu_SaveScriptTabs scriptObject
   put empty into pPrefKey
   --
   put scriptEditor_ListEditingObjects() into historyObjects
   pref_SaveValue "historyObjects", historyObjects, pPrefKey
   
   put scriptEditor_ListTabScriptObjects() into tabScriptObjects
   pref_SaveValue "tabScriptObjects", tabScriptObjects, pPrefKey
   
   put line 1 of tabScriptObjects into scriptObject
   save scriptObject
   repeat with lineNum = 2 to the number of lines of tabScriptObjects
      put line lineNum of tabScriptObjects into scriptObject
      save scriptObject
      scriptEditor_CloseTab scriptObject
   end repeat
end menu_SaveScriptTabs

on menu_RestoreScriptTabs
   put empty into pPrefKey
   --
   put pref_FetchValue ("tabScriptObjects", pPrefKey)into tabScriptObjects
   repeat for each line scriptObject in tabScriptObjects
      -- scriptEditor_CreateNewTab scriptObject
      edit the script of scriptObject
   end repeat
end menu_RestoreScriptTabs

on menu_GatherStacks
   screen_GatherStacks
end menu_GatherStacks

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
