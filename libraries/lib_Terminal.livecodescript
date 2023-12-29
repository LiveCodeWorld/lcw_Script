script "lib_Terminal"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Terminal
type: library
version: 0.1

/*
In this library we develop handlers that allow us to interact with the terminal.
Our aim is to provide interactive documentation for terminal commands that are made avialable in Livecode and the browser.
We experiment writing this documentation in wiki.
*/


--> Working on
-


--> Diff
-
command diff_Files thisFile, lastFile
   -- this fixed upgrade error -- https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error
   -- can we open in background
   -- put "sdiff" into someShell
   
   -- try to run in the background
   -- put "(" & someShell && "&)" into someShell -- makes no difference
   -- put "screen" && someShell into someShell -- does not work (needs to attach screen)
   
   put "opendiff" into someShell
   put space & kwote(thisFile, "'") && kwote(lastFile, "'") after someShell
   put shell (someShell) into shellResult
   return shellResult
end diff_Files

command diff_CreateTempFile someText, shortFile
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & shortFile into someFile
   -- put someText into url ("binfile:" & someFile)
   text_Set someFile, someText
   return someFile
end diff_CreateTempFile


--> Terminal | Diff
-
command terminal_Diff thisText, lastText, pThisShortFile, pLastShortFile
   if pThisShortFile is empty then put "this.txt" into pThisShortFile
   if pLastShortFile is empty then put "last.txt" into pLastShortFile
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & pThisShortFile into thisFile
   put compareFolder & pLastShortFile into lastFile
   
   diff_CreateTempFile thisText, pThisShortFile
   put the result into thisFile
   
   diff_CreateTempFile lastText, pLastShortFile
   put the result into lastFile
   
   if the shiftkey is "Down" then
      put "opendiff" into someShell
      put space & kwote(thisFile, "'") && kwote(lastFile, "'") after someShell
      terminal_PasteScript someShell
      put the result into shellResult
   else
      set the defaultfolder to compareFolder
      put "opendiff" && kwote(pThisShortFile) && kwote(pLastShortFile) into someShell
      put shell (someShell) into shellResult
   end if
   return shellResult
end terminal_Diff

command terminal_KillOpenDiff
   put LocalArray ["opendiffProcessName"] into opendiffProcessName
   put the openProcesses into oNames
   put the openProcessIDs into oIDs
   --
   close process opendiffProcessName
   delete variable LocalArray ["opendiffProcessName"]
end terminal_KillOpenDiff


--> Terminal
-
command terminal_PasteScript shellScript, pDelayTime
   if pDelayTime is empty then put 0.25 into pDelayTime
   --
   put "tell application 'Terminal'" into tScript
   put CR & "activate" after tScript
   put CR & "delay [[pDelayTime]]" after tScript
   put CR & "tell application 'System Events'" after tScript
   put CR & "keystroke '[[shellScript]]'" after tScript
   put CR & "end tell" after tScript
   put CR & "end tell" after tScript
   --
   put merge (tScript) into  mScript
   replace "'" with quote in mScript
   --
   do mScript as AppleScript
   put the result into someError
   --
   switch someError
      case "execution error"
         return someError & CR&CR & mScript
         break
      default
         return mScript
   end switch
end terminal_PasteScript

command terminal_PasteInNewTab shellScript, pDelayTime
   if pDelayTime is empty then put 0.25 into pDelayTime
   --
   put "tell application 'Terminal'" into tScript
   put CR & "activate" after tScript
   put CR & "delay [[pDelayTime]]" after tScript
   --
   put CR & "tell application 'System Events'" after tScript
   put CR & "keystroke 't' using {command down}" after tScript
   --
   put CR & "keystroke '[[shellScript]]'" after tScript
   put CR & "end tell" after tScript
   put CR & "end tell" after tScript
   --
   put merge (tScript) into  mScript
   replace "'" with quote in mScript
   --
   do mScript as AppleScript
   put the result into someText
   --
   return mScript
end terminal_PasteInNewTab
