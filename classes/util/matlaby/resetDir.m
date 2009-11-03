function resetDir(d)
a=false;
tries=20;
tryn=0;
while ~a && tryn<tries %ah, windows...
    [a b c]=rmdir(d,'s');
    if ~a
        if ~strcmp(c,'MATLAB:RMDIR:NotADirectory')
            {b,c,d}
            %getting     'No directories were removed.'    'MATLAB:RMDIR:NoDirectoriesRemoved'
            %might be if someone is looking at dir remotely...
            WaitSecs(.3);
            tryn=tryn+1;
        else
            a=true;
        end
    end
end
if ~a
    error('couldn''t rmdir')
end
[a b c]=mkdir(d);
if ~a
    b
    c
    error('couldn''t mkdir')
end
end