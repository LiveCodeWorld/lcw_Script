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

--> Menu | Name
-
/*
The menu_Name is the name value of the script metadata of the controller
It "should"" be the saem as the stack name
*/

getprop menu_Name
   put the long id of the target into tObject
   --
   put the script_MetaData of tObject into scriptMetaData
   put scriptMetaData ["type"] into scriptType
   if scriptType is not "controller" then return empty
   put scriptMetaData ["name"] into mName
   return mName
end menu_Name

setprop menu_Name mName
   put the long id of the target into tObject
   --
   put the script_MetaData of tObject into scriptMetaData
   
   put scriptMetaData ["type"] into scriptType
   if scriptType is not "controller" then return empty
   put scriptMetaData ["name"] into oldName
   if oldName = mName then return mName -- no need to reset
   
   put mName into scriptMetaData ["name"]
   --
   set the script_MetaData of tObject to scriptMetaData
   --
   return scriptMetaData
end menu_Name


--> Working on
-
getprop script_MenuTitles
   put the long id of the target into tObject
   
   -- put the script_MenuTitleTableArray of tObject into mTitleTableArray (not in order)
   -- put menu_ListCustomPropertyTitles (tObject) into mTitles -- not using custom props
   put the script of tObject into someScript
   put script_ExtractMenuSuiteTitles (someScript) into scriptMenuTitles
   --
   return scriptMenuTitles
end script_MenuTitles

getprop script_GlobalMenuTitles
   put the script_MenuTitles of the target into mTitles
   filter mTitles with "Global |*"
   return mTitles
end script_GlobalMenuTitles
   
getprop script_GlobalTitles [suiteType]
   put the script of the target into someScript
   put script_ExtractGlobalTitles (someScript, suiteType) into globalMenuTitles
   return globalMenuTitles
end script_GlobalTitles

getprop script_MenuTitleTableArray
   -- this is what constructs the mTitleTableArray from a script
   local mTitleTableArray
   
   put the long id of the target into mController
   put the script of mController into someScript
   put the revAvailableHandlers of mController into hTable
   
   -- put script_OrderedMenuTitles (someScript) into mTitles
   put someScript into mTitleLines
   filter mTitleLines with "--> * Menu"
   
   menu_ClearRecursionCheck
   repeat for each line mTitleLine in mTitleLines
      put word 2 to -1 of mTitleLine into mTitle
      put menu_ExtractTableFromScript (mTitle, someScript, hTable, mController) into mTable
      put mTable into mTitleTableArray [mTitle]
   end repeat
   return mTitleTableArray
end script_MenuTitleTableArray

getprop menu_DataArray
   -- the problem with this is if the target has been cloned or copied
   -- the menu_Controller will have changed
   put the customproperties ["menu_Table"] of the target into mTitleTableArray
   return mTitleTableArray
end menu_DataArray

setprop menu_DataArray mTitleTableArray
   set the customproperties ["menu_Table"] of the target to mTitleTableArray
end menu_DataArray


--> Script | MenuTitles
-
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

