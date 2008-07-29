function fixSystemTime
if IsWin
            [a b]=dos('w32tm /resync /nowait');
            if a~=0
                b
                error('system time sync failed')
            end
else
    warning('system time sync only works for windows')
end