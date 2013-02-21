function collectInfo
clc
fprintf('\nBEGIN OUTPUT\n')

%if ispc
% linux required apt-get install libpam-winbind
    stations = {   ...
        'mtrix1'   ...
        'mtrix2'   ...
        'mtrix3'   ...
        'mtrix4'   ...
        'mtrix5'   ...
        'mtrix6'   ...
        'jarmusch' ...
        'lee'      ...
        };
% elseif isunix % can't figure out how to get cifs to mount using host names
%     stations = {        ...
%         '184.171.85.60' ... % mtrix1 
%         };
% else
%     error('no osx yet')
% end

dirs = {                                               ...
    fullfile('Users','nlab','Desktop','mouseData')     ...
    fullfile('Users','nlab','Desktop','mouseData0512') ...
    fullfile('Users','nlab','Desktop','wehrData')      ...
    fullfile('Users','nlab','Desktop','ballData')      ...
    };

cellfun(@(s) cellfun(@(d) collect(s,d),dirs),stations);
end

function collect(s,d)

h  = fullfile('ServerData','db.mat');

if ispc
    p = fullfile(['\\' s], d, h);    
elseif isunix
    mntpt = [filesep fullfile('mnt','tmp')];
    % on ubuntu, had to run 'sudo visudo' and comment out the path resetting stuff, and run yesod as sudo
    system (['sudo mkdir -p ' mntpt]);
    system (['sudo umount ' mntpt]);
    stat = 1;
    while stat~=0
    stat = system (['sudo mount.cifs //' fullfile(s,'Users') ' ' mntpt ' -o username=workgroup/nlab,password=huestis238']);
    if stat~=0
        'mount gave status: (retrying)'
        stat
        pause(1)
    end
    end
    [~,g] = fileparts(d);     
    p = fullfile(mntpt,'nlab','Desktop',g,h);
end

f = dir(p);
if isscalar(f)
    r = ratrix(fileparts(p),0);
    cellfun(@(i) report(r,s,d,i),getSubjectIDs(r));
else
    fprintf('none for %s %s\n',s,d)
end

if isunix
system (['sudo umount ' mntpt]);
system (['sudo rmdir ' mntpt]);
end
end

    function report(r,s,d,i)
        if isempty(strfind(i,'test'))
            sub = getSubjectFromID(r,i);
            [ptcl t]=getProtocolAndStep(sub);
            if ~isempty(ptcl)
                tm=getTrialManager(getTrainingStep(ptcl,t));                
                
                [~, rewardSizeULorMS, requestRewardSizeULorMS, msPenalty] = calcReinforcement(getReinforcementManager(tm),[]);
                fprintf('%s ',[s ' "' d '" ' i]);
                fprintf('reward:%g pnlty:%g\n',rewardSizeULorMS,msPenalty)
            end
        end
    end
