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


--> Deps
-
