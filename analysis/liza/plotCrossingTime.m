function plotCrossingTime(subj)
if ~exist('subj','var') || isempty(subj)
    subj = 'test';
end

%for some reason, compiling these records is failing
%once this is solved we'll load in a single compiled file from ...\ballData\CompiledTrialRecords\
recordPath = 'C:\Users\nlab\Desktop\ballData\PermanentTrialRecordStore\';
recordPath = [recordPath subj filesep];

files = dir([recordPath 'trialRecords_*.mat']);

bnds = cell2mat(cellfun(@(x)textscan(x,'trialRecords_%u-%u_%*s.mat','CollectOutput',true),{files.name}'));
[~,ord] = sort(bnds(:,1));
files = files(ord);

recNum = 0;
for i=1:length(files)
    if bnds(ord(i),1) ~= recNum+1
        error('record file names indicate ordering problem')
    end
    
    fullRecs(i) = load([recordPath files(i).name]);
    newRecNum = recNum + length(fullRecs(i).trialRecords);
    records(recNum+1:newRecNum) = fullRecs(i).trialRecords; %extending this struct array is slow, that's why we normally use compiled records
    recNum = newRecNum;
    
    if bnds(ord(i),2) ~= recNum
        error('record file names indicate ordering problem')
    end
    
    fprintf('done with %d of %d\n',i,length(files));
end

if ~all(diff([records.trialNumber]) == 1)
    error('records don''t show incrementing trial numbers')
end

startTimes = datenum(cell2mat({records.date}'));
d = diff(startTimes);
sessions = find(d > .02); %.5
if ~all(d > 0)
    error('records don''t show increasing start times')
end

if ~all(diff([records.sessionNumber]) >= 0)
    error('records don''t show increasing session numbers')
end

r = [records.reinforcementManager];
r = [r.rewardSizeULorMS];

s = [records.stimDetails];
timeout = [s.nFrames];
targetLocation = [s.target];

result = {records.result};
u = unique(result);
[~,loc] = ismember(result,u);

if ~all(cellfun(@isempty,{records.correct}))
    error('weird -- records.correct should always be empty (for now we''re not using this field)')
end

manualRewards = [records.containedForcedRewards];

t = [records.trialDetails];
res = cellfun(@(x)f(x),{t.correct});
    function out=f(x)
        if isempty(x)
            out = 2;
        elseif isscalar(x) && islogical(x)
            out = double(x);
        else
            error('unexpected value')                
        end
    end

if ~all((res == 2) == (loc == 1))
    error('manual kills didn''t line up with empty corrects')
end

[actualRewards nFrames times targ track] = cellfun(@(x)g(x),{records.phaseRecords},'UniformOutput',false);
    function [a n t targ track]=g(x)
        if length(x)~=2
            error('expected 2 phases')
        end
        
        a = x(2).actualRewardDurationMSorUL;
        n = x(1).dynamicDetails.nFrames;
        t = x(1).dynamicDetails.times;
        targ = x(1).dynamicDetails.target;
        track = x(1).dynamicDetails.track;
    end

if ~all(cell2mat(nFrames)==timeout)
    error('nFrames didn''t match timeout')
end

if ~all(cellfun(@(x,y)length(x)==size(y,2),times,track))
    error('times and track didn''t have same dimension')
end

if ~all(cell2mat(targ)==targetLocation)
    error('targetLocation and targ didn''t match')
end

close all

n = 2;
subplot(n,1,1)
plot([records.trialNumber],[cell2mat(actualRewards); r]')
ylims = [0 max(r)*1.5];
ylim(ylims)
ylabel('reward size (ms)')
title(subj)
standardPlot;

    function standardPlot
        xlabel('trial number')
        xlim([1 length(records)])
        
        hold on
        grey = .75*ones(1,3);
        for i=1:length(sessions)
            plot(sessions(i)*ones(1,2),ylims,'Color',grey)
        end
    end

len = cellfun(@length,times);
subplot(n,1,2)
plot([records.trialNumber],[len; timeout]')
ylims = [0 max(len)*1.5];
ylim(ylims)
ylabel('frames to crossing')
standardPlot;
end