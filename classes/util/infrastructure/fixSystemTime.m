function fixSystemTime
if IsWin
            [a b]=dos('w32tm /resync /nowait');
            if a~=0
                b
                'seems that on windows 7, windows time service must be started manually (right click computer->manage->services)'
                'or, from dos prompt with admin privledges, ''net start w32time'''
                'also, w32tm has to be runin a dos prompt started by right click->run as administrator -- not sure how to do that from matlab'
                error('system time sync failed')
            end
else
    warning('system time sync only works for windows')
end