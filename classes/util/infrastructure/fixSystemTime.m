function fixSystemTime(wait)
if ~exist('wait','var') || isempty(wait)
    wait = true;
end

if IsWin
    cmd = 'w32tm /resync';
    if ~wait
        cmd = [cmd ' /nowait'];
        warning('not waiting will cause you to miss the potential error: The computer did not resync because the required time change was too big.')
    end
    
    [a b] = dos('net start w32time');
    if a<0
        a
        b
        error('couldn''t start w32time')
    end
    
    [a b]=dos(cmd);
    if a~=0
        b
        'seems that on windows 7, windows time service must be started manually (right click computer->manage->services)'
        'or, from dos prompt with admin privledges, ''net start w32time'''
        'also, w32tm has to be run in a dos prompt started by right click->run as administrator -- not sure how to do that from matlab'
        'seems running matlab as admin is enough, or disabling uac as we do for porttalk anyway...'
        error('system time sync failed')
    else
        if ~strcmp(b,sprintf('Sending resync command to local computer\nThe command completed successfully.\n'))
            a
            b
            'if you got: The computer did not resync because the required time change was too big.'
            'see http://www.smattie.com/2012/03/13/how-to-fix-clock-drift-in-cloud-environments-not-joined-to-ad-domain/'
            error('system time sync failed')
        end
    end
else
    warning('system time sync only works for windows')
end