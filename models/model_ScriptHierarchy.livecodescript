script "model_ScriptHierarchy"
--> MetaData
-
license: GPLv3
name: model_ScriptHierarchy
type: model
version: 0.2

/*
This library is simply here to work out the Livecode message path for any given object.
There is no native way to do this in Livecode, but we do have a lot of inforamtion about the context
So we can calculate a good guess. Even a bit of a hack is useful in terms of finding handlers and so forth.
*/


--> Working on
-

--> Props
-
getprop object_Hierarchy [pWhichBehaviors]
   -- this old handler return things the wrong way round
   -- see also "script_Hierarchy" 
   put the long id of the target into someObject
   if pWhichBehaviors is empty then put "no library deps" into pWhichBehaviors
   
   put revRuggedId (someObject) into objectHierarchy
   put the behavior of someObject into objectBehavior
   object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
   
   put someObject into objectOwner
   put empty into skipThisBackgroundID
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists(mainStackObject) then
               put mainStackObject & CR before objectHierarchy
               put the behavior of mainStackObject into objectBehavior
               object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            end if
            return objectHierarchy
            break
         case "card"
            -- previously added a card, so check for backgrounds
            
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               put revRuggedId (backgroundObject) & CR before objectHierarchy
               put the behavior of backgroundObject into objectBehavior
               object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            end repeat
            
            delete word 1 to 4 of objectOwner
            
            -- above a card must be a stack
            put name of objectOwner into stackObject
            put stackObject & CR before objectHierarchy
            put the behavior of stackObject into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then return objectHierarchy
            put revRuggedId (objectOwner) & CR before objectHierarchy
            put the behavior of objectOwner into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then return objectHierarchy
            put revRuggedId (objectOwner) & CR before objectHierarchy
            put the behavior of objectOwner into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
      end switch
   end repeat
   return "error" -- should never get here!
end object_Hierarchy

command object_MaybeAddBehavior @objectHierarchy, objectBehavior, pWhichBehaviors
   if exists (objectBehavior) then
      switch
         case pWhichBehaviors is "no deps"
            -- don't add
            break
         case pWhichBehaviors is "no library deps" and the uRIP ["type"] of objectBehavior is not "behavior/library"
            put revRuggedId (objectBehavior) & CR before objectHierarchy
            break
         default -- case "all"
            put revRuggedId (objectBehavior) & CR before objectHierarchy
            break
      end switch
   end if
end object_MaybeAddBehavior


--> Script| Hierarchy
-
getprop script_Hierarchy [pProjectName]
   -- surpisingly complex dependencies if we include pProjectName
   put the long id of the target into targetObject
   put the object_Hierarchy of targetObject into scriptHierarchy
   hkey_AddDevelopmentHierarchy scriptHierarchy, pProjectName
   return scriptHierarchy
end script_Hierarchy

getprop hkey_ScriptHierarchy [externalObjects]
   -- Good for straight libraries and the object itself
   -- Does not do behaviors of libs, or front and back scripts
   
   put the long id of the target into tObject
   put revRuggedID (tObject) into tObject
   if externalObjects is empty then
      put env_ScriptHierarchy (true) into externalObjects
      line_Delete tObject, externalObjects
   end if
   put the behavior_Objects of tObject into bObjects
   
   put tObject into scriptHierarchy
   if bObjects is not empty then put CR & bObjects after scriptHierarchy
   if externalObjects is not empty then put CR & externalObjects after scriptHierarchy
   --
   return scriptHierarchy
end hkey_ScriptHierarchy

getprop object_Hierarchy
   put the long id of the target into targetObject
   repeat
      put revRuggedID (targetObject) & CR after hObjects
      put targetObject into someObject
      repeat
         put the behavior of someObject  into bObject
         if exists (bObject) is false then exit repeat
         
         put revRuggedId (bObject) & CR after hObjects
         put bObject into someObject
      end repeat
      
      if word 4 of targetObject is not "of" then
         delete char -1 of hObjects
         return hObjects
      end if
      
      delete word 1 to 4 of targetObject
   end repeat
end object_Hierarchy


--> Script| Hierarchy | Development
-
command hkey_AddDevelopmentHierarchy @scriptHierarchy, pProjectName
   local frontObjects, usedStacks, backObjects
   
   switch pProjectName
      case empty
         put stack_PathsToObjects (the stacksinUse) into usedStacks
         put env_ListFrontScripts() into frontObjects
         put env_ListBackScripts() into backObjects
         break
      case "none"
         break
      default
         put project_ListUsedDeps (pProjectName) into usedStacks
         put project_ListFrontDeps (pProjectName) into frontObjects
         put project_ListBackScripts (pProjectName) into backObjects
   end switch
   
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   script_AddLibrariesToHierarchy scriptHierarchy, frontObjects, usedStacks, backObjects
end hkey_AddDevelopmentHierarchy

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

command script_AddLibrariesToHierarchy @objectIndex, frontObjects, usedStacks, backObjects 
   if usedStacks is not empty then put usedStacks & CR before objectIndex
   if backObjects is not empty then put backObjects & CR before objectIndex
   if frontObjects is not empty then put CR & frontObjects after objectIndex
end script_AddLibrariesToHierarchy


--> Deps
-
function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return word 1 to -1 of stackObjects
end stack_PathsToObjects

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

function rev_AppToolsFolder
   put rev_AppContentsFolder() & "Tools/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_AppToolsFolder

function rev_ToolsLibraryFolder
   put rev_AppContentsFolder() & "Tools/Toolset/libraries/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_ToolsLibraryFolder

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder
