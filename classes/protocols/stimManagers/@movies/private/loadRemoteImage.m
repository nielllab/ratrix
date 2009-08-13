function [im m alpha]=loadRemoteImage(s,name,ext)
    completed=false;
    nAttempts=0;
    maxAttempts=5;
    while ~completed
        nAttempts = nAttempts+1;
        try
            [im m alpha]=imread(fullfile(s.directory,[name ext]));  %,'BackgroundColor',zeros(1,3)); this would composite against black and return empty alpha
            completed=true;
        catch ex
            %expect remote reads to fail cuz of windows networking/file sharing bug
            pauseDur = rand+nAttempts-1; %linearly increase, but be nondeterministic
            fprintf('attempt %d: failed to read %s, trying again in %g secs\n',nAttempts,fullfile(s.directory,[name ext]),pauseDur)
            disp(['CAUGHT ERROR: ' getReport(ex,'extended')])

            if nAttempts>maxAttempts
                [nAttempts maxAttempts]
                error('exceeded maxAttempts')
            end

            beep %feedback when ptb screen is up -- ratrix can appear to be dead for long periods without this -- better would be screen output, but that requries some rearchitecting
            pause(pauseDur);
        end

    end