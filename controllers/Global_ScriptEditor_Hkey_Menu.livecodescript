script "Global_ScriptEditor_Hkey_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Hkey_Menu
type: controller
version: 0.7


--> Variables
-
local LocalArray


--> Global | ScriptEditor | Hkey | Menu
-
on insert_SendHkey
   return "Global | Hkey | Send | Menu"
end insert_SendHkey

on _
end _

on insert_HelpMenu
   return "Global | Hkey | Help | Menu"
end insert_HelpMenu

on _
end _

on menu_DisplayHkeySvg hKey
   put hkey_SvgFile (hKey) into svgFile
   if scriptEditor_PaneExists ("Deps") then
      display_ScriptEditorSvg svgFile
   end if
   
   put hkey into stackLabel
   display_SVG svgFile, stackLabel
end menu_DisplayHkeySvg

on _
end _

on submenu_HandlerFiles
   return "Global | Handler | Calls | Menu"
end submenu_HandlerFiles

on submenu_HandlerLibrary
   return "Global | Handler | Library | Menu"
end submenu_HandlerLibrary

on submenu_HandlerCalls
   return "Global | Handler | Calls | Menu"
end submenu_HandlerCalls

on submenu_HandlerWalk
   return "Global | Hkey | Walk | Menu"
end submenu_HandlerWalk

on submenu_HandlerTest
   return "Global | Handler | Menu"
end submenu_HandlerTest

on submenu_Panes
   return "Global | ScriptEditor | Panes | Menu"
end submenu_Panes

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Hkey | Menu | Props
-


--> Global | ScriptEditor | Hkey | Menu | Disabled
-
getprop disabled_DisplayHkeySvg [hKey]
   put hkey_SvgFile (hKey) into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_DisplayHkeySvg


--> Dev | Menu
-
on menu_FindHandlerWithSpotlight hkeyLine
   display_SpotlightHandler hkeyLine
end menu_FindHandlerWithSpotlight

on menu_UpdateSpotlightFolder
   answer folder "Choose a folder to re-index..."
   if it is empty then exit to top
   put it into inFolder
   
   spotlight_ForceUpdate inFolder
   put the result
end menu_UpdateSpotlightFolder


--> Menu | Props
-
on menu_Init targetObject, mPath, mTitlePath
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   switch hType
      case "M"
         put "c" into hType
         break
      default
   end switch
   put word 2 of hInfo into hName
   put word 3 of hInfo into startLineNum
   put word 4 of hInfo into endLineNum
   put scriptEditor_Object() into hObject
   put hName,hType,hObject,1 into hKey
   
   put hKey into LocalArray ["hKey"]
   put hObject into LocalArray ["scriptObject"]
   put startLineNum into LocalArray ["startLineNum"]
   put endLineNum into LocalArray ["endLineNum"]
   put line startLineNum to endLineNum of the script of hObject into LocalArray ["someHandler"]
   
   -- put library_HandlerFile (hKey, empty, true) into LocalArray ["hkeyFolder"]
   
   /*
   put hArray_ListHkeyObjects (hKey) into otherObjects
   line_Delete hObject, otherObjects
   put word 1 to -1 of otherObjects into LocalArray ["other objects"]
   */
end menu_Init

getprop menu_Target [mTitlePath]
   return LocalArray ["hKey"]
end menu_Target


--> Handlers
-
command launchFile treeWidget, shortPath
   put the search_Folder of treeWidget into findInsideFolder
   put the search_Text of treeWidget into textToFind
   
   text_AddTrailing findInsideFolder
   put findInsideFolder & shortPath into somePath
   set the itemdelimiter to "/"
   put item 1 of shortPath into shortHandlerFolder
   -- put hkey_FromShortFolder (shortHandlerFolder)
   put somePath
end launchFile


/*
--> Deps | menu_Init
-
command line_Delete someLines, @fromContainer, partLine, skipLines
   set the wholematches to (partLine is empty)
   repeat with ii = 1 to the number of lines of someLines
      put line ii of someLines into someLine
      get lineoffset(someLine, fromContainer, skipLines)
      if it is not 0 then
         put it + skipLines into lineNum
         delete line lineNum of fromContainer
      end if 
   end repeat
   return the number of lines of someIndex
end line_Delete

function library_HandlerFile hKey, pShortFileBit, pDontCreate
   -- returns empty if there is no folder, but the filename if there is
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   if there is not a folder hkeyFolder then return empty
   put pShortFileBit after hkeyFolder
   return hkeyFolder
end library_HandlerFile

function library_HkeyFolder hKey, pDontCreate
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   put hkey_FolderName (shortHkey) into folderName
   put library_HandlerFolder (folderName, pDontCreate) into hkeyFolder
   if folderName is not empty then put "/" after hkeyFolder
   
   if pDontCreate is false then folder_CreateNested hkeyFolder
   return hkeyFolder
end library_HkeyFolder

function library_HandlerFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/rev/handlers/", pDontCreate) & shortFileBit
end library_HandlerFolder

function library_PluginFolder pSubFolder, pDontCreate
   put revEnvironmentUserPluginsPath() & "/" into opnRootFolder
   put opnRootFolder & "opn_Plugins/" into someFolder
   
   if pSubFolder is not empty then
      folder_Format pSubFolder
      put pSubFolder after someFolder
   end if
   
   if pDontCreate is not true then folder_CreateNested someFolder
   return someFolder
end library_PluginFolder

command folder_Format @someFolder
   -- should be renamed "folder_Normalize"
   if someFolder is empty then return empty
   repeat while last char of someFolder is "/"
      delete last char of someFolder
   end repeat
   put "/" after someFolder
end folder_Format

function hkey_FolderName hKey
   put item 1 of hKey into hName
   put item 2 of hKey into hType
   if hType = "o" then put "c" into hType -- as "on" and "command" are functionally equivalent
   put hName & "_" & tolower (hType) into folderName
   return folderName
end hkey_FolderName

function library_HkeyToPublicShortHkey hKey
   -- change private handler to public one for library
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if char 1 of hType = "p" then delete char 1 of hType
   put hName,hType into shortHKey
   return shortHKey
end library_HkeyToPublicShortHkey

function rev_GetHandlerTreeSelectedInfo
   put rev_HandlerTreeField() into handlerField
   put the hilitedLine of handlerField into lineNum
   put line lineNum of the cHandlers of handlerField into tHandler
   return tHandler
end rev_GetHandlerTreeSelectedInfo

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return rev_TopScriptEditor()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
   end switch
end rev_ScriptEditorStack

function rev_TopScriptEditor
   put the stack_Name of the target into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else 
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      -- lcw_Notify stackNames, true
      if stackNames is empty then return empty
      put line 1 of stackNames into stackName
      if exists(stack stackName) is false then
         put the stack_Name of the target into stackName
      end if
      return the long id of stack stackName
   end if
end rev_TopScriptEditor

function scriptEditor_Object
   put rev_TopScriptEditor() into stackObject
   if exists(stackObject) is false then return empty
   dispatch "revSEGetCurrentObject" to stackObject
   put the result into someObject
   return someObject
end scriptEditor_Object
*/
