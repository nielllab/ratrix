function reportSettings
clc

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

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

                fprintf('\tsub: %s',sub)

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
                            sm=getStimManager(getTrainingStep(p,t));
                                fprintf('\t%s(%d/%d)\ttrlMgr:%s\t',getName(p),t,getNumTrainingSteps(p),class(tm));
                            fprintf('pnlty:%g\n',getMsPenalty(getReinforcementManager(tm)))
                        else
                            fprintf('\t\t\t%s has no protocol\n',ratID);
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