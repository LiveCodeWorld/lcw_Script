script "model_ScriptMenu"
--> MetaData
-
license: GPLv3
name: model_ScriptMenu
type: model
version: 0.9

/*
The menu model is in transition, and is still using the old "table" based data structure.
Currently in the process of moving over to the new array based structure which should be more readable, maintainable and faster.

A menu_Controller contains all the information needed to create a menu, and link each menu item to a handler.
Views are linked to menu_Controllers via the menu_Title and the menu_Controller of the view.
This combination of mTitle and mController uniquely identifies the menu model for that menu and it's associated script.
*/

--> Script | MenuTitles
-
getprop script_MenuTitles
   -- not used except "Global | Menu | Table | Menu" ?
   
   put the long id of the target into targetObject
   put the script of targetObject into someScript
   put script_ExtractMenuSuiteTitles (someScript) into mTitles
   return mTitles
end script_MenuTitles

getprop menu_GlobalTitle
   put the script_GlobalTitles ["Menu"] of the target into globalMenuTitles
   return globalMenuTitles
end menu_GlobalTitle

setprop menu_GlobalTitle globalMenuTitles
   put the long id of the target into scriptObject
   repeat for each line globalMenuTitle in globalMenuTitles
      menu_SetGlobalController globalMenuTitle, scriptObject
   end repeat
end menu_GlobalTitle

getprop menu_TableTitles
   -- direct property of mController
   put the long id of the target into mController
   put menu_GetTableTitles (mController) into tableTitles
   return tableTitles
end menu_TableTitles

setprop menu_Table [pMenuTitle] mTable
   if pMenuTitle is empty then put the menu_Title of the target into pMenuTitle
   if pMenuTitle is empty then return empty
   put the menu_Controller [pMenuTitle] of the target into mController
   
   menu_SetTable pMenuTitle, mController, mTable
   return the result
end menu_Table


--> Menu | List
-
function menu_ListGlobalNames
   global gLCW
   put gLCW ["Global Menus"] into menuArray
   return keys (menuArray)
end menu_ListGlobalNames

function menu_ListGlobalObjects
   global gLCW
   put gLCW ["Global Menus"] into menuArray
   repeat for each key mTitle in menuArray
      put menuArray [mTitle]["mController"] into mController
      put mController & CR after mControllers
   end repeat
   delete char -1 of mControllers
   return mControllers
end menu_ListGlobalObjects

function script_ExtractMenuSuiteTitles someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   put script_MenuTitleArrayFromSuiteTitles (suiteTitles) into menuTitleArray
   return menuTitleArray ["OrderedMenuTitles"]
end script_ExtractMenuSuiteTitles

function script_MenuTitleArrayFromSuiteTitles suiteTitles
   -- not the best way ?
    local menuTitleArray
    set the itemdelimiter to "|"
    put "Menu \((.*)\)" into regularExpression
    put empty into menuTitles
    repeat for each line suiteTitle in suiteTitles
        put word 1 to -1 of last item of suiteTitle into lastMenuItem
        if lastMenuItem is "Menu" then
            put suiteTitle & CR after menuTitles
            put "" into menuTitleArray [suiteTitle]
        else if matchtext(lastMenuItem, regularExpression, toolMode) is true then
            put suiteTitle & CR after menuTitles
            put toolMode into menuTitleArray [suiteTitle]
        end if
    end repeat
    delete last char of menuTitles
    put menuTitles into menuTitleArray ["OrderedMenuTitles"]
    return menuTitleArray
end script_MenuTitleArrayFromSuiteTitles

