function fixSystemTime(wait)
if ~exist('wait','var') || isempty(wait)
    wait = true;
end

if ispc
    cmd = 'w32tm /resync';
    if ~wait
        cmd = [cmd ' /nowait'];
        warning('not waiting will cause you to miss the potential error: The computer did not resync because the required time change was too big.')
    end
    
    [a b] = dos('net start w32time');
    if a~=0
        if isempty(strfind(b,'has already been started'))
            a
            b
            'if access is denied, run matlab as admin'
            error('couldn''t start w32time')
        end
    end
    
    [a b]=dos(cmd);
    if a~=0
        b
        'seems that on windows 7, windows time service must be started manually (right click computer->manage->services)'
        'or, from dos prompt with admin privledges, ''net start w32time'''
        'also, w32tm has to be run in a dos prompt started by right click->run as administrator -- not sure how to do that from matlab'
        'seems running matlab as admin is enough, or disabling uac as we do for porttalk anyway...'
        'if you get The following error occurred: The specified module could not be found. (0x8007007E)'
        'get hotfix at http://support.microsoft.com/kb/978714 (some kind of 32/64 bit dll confusion)'
        error('system time sync failed')
    else
        if ~strcmp(b,sprintf('Sending resync command to local computer\nThe command completed successfully.\n'))
            a
            b
            if ~isempty(strfind(b,'The computer did not resync because no time data was available.'))
                warning('this happened once, but i don''t know how to fix it -- even manually hitting "update now" under "internet time settings" doesn''t help')
            else
                'if you got: The computer did not resync because the required time change was too big.'
                'see http://www.smattie.com/2012/03/13/how-to-fix-clock-drift-in-cloud-environments-not-joined-to-ad-domain/'
                error('system time sync failed')
            end
        end
    end
else
    warning('system time sync only works for windows')
end