function out=texsCorrespondToThisWindow(s,w)
%method to determine if tex is cached appropriate in this window, 
%PTB expert mode

out=false;

if ismember({'textures'},fields(s.cache))

    allWindows=Screen('Windows');
    texIDsThere=allWindows(find(Screen(allWindows,'WindowKind')==-1))

    allTexsRequired=unique(s.cache.textures);
    allTexsRequired=allTexsRequired(~isnan(allTexsRequired));
    
    if all(ismember(allTexsRequired,texIDsThere));
        out=true;
    end
else
    error('can''t find texture field!')
end
