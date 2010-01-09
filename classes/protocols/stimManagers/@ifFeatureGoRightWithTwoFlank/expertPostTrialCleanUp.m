function expertPostTrialCleanUp(s)
%method to determine if it is cached

%1. first try leaving it all open
%this allows sm not to have to recache in expert mode
%this should evantually run out of memory for opening too many stims


%2. then try closing all the ones that stim does not track
allWindows=Screen('Windows');
texIDsThere=allWindows(find(Screen(allWindows,'WindowKind')==-1));
 
nonStimManagerTexs=setdiff(texIDsThere,s.cache.textures(:));
screen('close',nonStimManagerTexs);