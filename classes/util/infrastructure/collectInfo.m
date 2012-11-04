function collectInfo
fprintf('\nBEGIN OUTPUT\n')

if ispc
    stations = { ...
        'mtrix1' ...
        'mtrix2' ...
        'mtrix3' ...
        'mtrix4' ...
        };
elseif isunix % can't figure out how to get cifs to mount using host names
    stations = {        ...
        '184.171.85.60' ... % mtrix1 
        };
else
    error('no osx yet')
end

dirs = {                                ...
    '\Users\nlab\Desktop\mouseData'     ...
    '\Users\nlab\Desktop\mouseData0512' ...
    '\Users\nlab\Desktop\wehrData'      ...
    };

cellfun(@(s) cellfun(@(d) collect(s,d),dirs),stations);
end

function collect(s,d)

h  = fullfile('ServerData','db.mat');

if ispc
    p = fullfile(['\\' s d], h);    
elseif isunix
    mntpt = [filesep fullfile('mnt','tmp')];
	system ['sudo mkdir ' mntpt];
    system ['sudo mount.cifs //' fullfile(s,'Users') ' mntpt ' -o username=workgroup/nlab,password=huestis238'];
    [~,g] = fileparts(d);          
    p = fullfile(mntpt,'nlab','Desktop',g,h);
end

f = dir(p);
if isscalar(f)
    r = ratrix(fileparts(p),0);
    cellfun(@report,getSubjectIDs(r));
end

    function report(i)
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

if isunix
    system ['sudo umount ' mntpt];
    system ['sudo rmdir ' mntpt];
end
end