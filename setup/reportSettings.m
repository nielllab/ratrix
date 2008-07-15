function reportSettings
clc
%p=pwd;
%addpath(fullfile(p,'..','bootstrap'))


warning('off','MATLAB:dispatcher:nameConflict')
addpath(RemoveSVNPaths(removeSecretBackups(genpath(getRatrixPath))));
addpath('\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\');
warning('on','MATLAB:dispatcher:nameConflict')

%dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
dataPath=fullfile('C:\Documents and Settings\rlab\Desktop\','ratrixData');
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

ids=getSubjectIDs(r);

if ~isempty(ids)
    
    [heats stations subjects]=getRatLayout();
    maxLen=0;
    for i=1:length(heats)
        if length(heats{i})>maxLen
            maxLen=length(heats{i});
        end
    end
    for rowNum=1:size(stations,1)
        for colNum=1:size(stations,2)
            fprintf('\n station: %s\n',stations{rowNum,colNum})
            for h=1:length(heats)
                fprintf('\theat: %s',[heats{h} repmat(' ',1,maxLen-length(heats{h}))])
                sub=subjects{rowNum,colNum,h};

                fprintf('\tsubject: %s',sub)

                found=false;
                for i=1:length(ids)
                    ratID=ids{i};
                    if strcmp(ratID,sub)
                        if found
                            error('found multiple subj')
                        end
                        found=true;
                        
                        s = getSubjectFromID(r,ratID);
                        [p t]=getProtocolAndStep(s);
                        if ~isempty(p)
                            tm=getTrialManager(getTrainingStep(p,t));
                            fprintf('\tstep: %d\treinforcement: %s\tclass:%s\n',t,shortDisp(getReinforcementManager(tm)),class(tm));
                        else
                            fprintf('\t has no protocol\n',ratID);
                        end

                    end
                end
                if ~found
                    fprintf('none\n');
                    %error('no subj found')
                end
                
                
            end
        end
    end
    

else
    'no subjects defined'
end