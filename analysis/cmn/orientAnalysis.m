function orientAnalysis
colordef white
%m=input('which box?');
m=4

mtrix=['mtrix' num2str(m)];%'mtrix4'; %box to use
if m==1 | m==2
    apath = ['\\',mtrix,'\Users\nlab\Desktop\mouseData0512\CompiledTrialRecords\']; %edf temp
else
    apath = ['\\',mtrix,'\Users\nlab\Desktop\mouseData\CompiledTrialRecords\']; %edf temp
end

%%% plot performance, reinforcement rate, or both
reinforcement=1;
performance=1;

subjs= {};
d=dir(apath);
for ind=1:length(d)
    [matches tokens] = regexpi(d(ind).name,'(.*)\.compiledTrialRecords\.\d+-\d+\.mat','match','tokens');
    if ~isempty(matches) && length(tokens{1})==1 && isempty(strfind(tokens{1}{:},'test'))
        % we found a compiledTrialRecord
        subjs{end+1}=tokens{1}{1};
    end
end

performanceFig = figure;
reinfFig = figure;

for s = 1:length(subjs);
    
    [stim records] = getRecords(apath,subjs{s});
    
    if performance
        sessionStarts = find(diff(records.date)>0.5)+1;
        sessionEnds = sessionStarts(2:end)-1;
        sessionEnds = [sessionEnds length(records.date)];
        totalSessions = length(sessionStarts);
        colorscale='bgrcmy'
        
        nback=5;
        for session = 1:nback+1;  %%% last "session" is all sessions
            if session<=nback
                trials = sessionStarts(totalSessions-session+1):sessionEnds(totalSessions-session+1);
            else
                trials = sessionStarts(totalSessions-nback+1):sessionEnds(totalSessions); %%% all sessions
            end
            [min(trials) max(trials)]
            [found usedTrials] = ismember(trials, stim.trialNums);
            if sum(found)~=length(found);
                sprintf('couldnt match trials')
            end
            
            orients = stim.records.orientations(1,usedTrials);
            orientList = unique(orients(~isnan(orients)))

            correct = records.correct(trials);
            
            for i = 1:length(orientList)
                paramCorrect = correct(orients==orientList(i));
                paramCorrect = paramCorrect(~isnan(paramCorrect));
                [pct(i) ci(i,:)] = binofit(sum(paramCorrect),length(paramCorrect));
            end
            
            figure(performanceFig);
            subplot(2,2,s)
            hold on
            if session<=nback
                errorbar(orientList*2*180/pi,pct,pct-ci(:,1)',ci(:,2)'-pct,colorscale(nback-session+1))
            else
                errorbar(orientList*2*180/pi,pct,pct-ci(:,1)',ci(:,2)'-pct,'g','LineWidth',4)  %%% all sessions
            end
            title(sprintf('%s',subjs{s}));
            axis([-10 100 0.4 1.1])
            set(gca,'XTick',0:30:90);
            plot([0 90],[0.5 0.5],'Linewidth',0.5)
            plot([0 90],[1 1],'Linewidth',0.5)
        end
    end
    if reinforcement
        figure(reinfFig);
        subplot(4,2,2*s-1);
        plot(records.actualRewardDuration(records.proposedRewardDuration>0));
        ylim([0 max(records.actualRewardDuration)*1.2])
        ylabel('reward');
        
        subplot(4,2,2*s);
        plot(records.proposedPenaltyDuration(records.proposedPenaltyDuration>0));
        ylim([0 max(records.proposedPenaltyDuration)*1.2])
        ylabel('penalty')
    end
end

end

function [stimDets records] =getRecords(compiledFileDir,subjectID)
compiledFile=fullfile(compiledFileDir,[subjectID '.compiledTrialRecords.*.mat']);
d=dir(compiledFile);
records=[];

for i=1:length(d)
    if ~d(i).isdir
        [rng num er]=sscanf(d(i).name,[subjectID '.compiledTrialRecords.%d-%d.mat'],2);
        if num~=2
            d(i).name
            er
        else
            fprintf('loading file')
            t=GetSecs();
            ctr=load(fullfile(compiledFileDir,d(i).name));
            fprintf('\ttime elapsed: %g\n',GetSecs-t)
            records=ctr.compiledTrialRecords;
            stimDets = ctr.compiledDetails;
            
        end
    end
end
end