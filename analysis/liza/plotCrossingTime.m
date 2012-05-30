function plotCrossingTime(subj)
dbstop if error

if ~exist('subj','var') || isempty(subj)
    subj = 'test';
end

%for some reason, compiling these records is failing
%once this is solved we'll load in a single compiled file from ...\ballData\CompiledTrialRecords\
%most of the work in this file does what CompileTrialRecords does

%get trial records in the right order
if ismac
    recordPath = [filesep fullfile('Users','eflister')];
else
    local = false;
    if local
        drive='C:';
    else
        drive='\\mtrix5';  
        %drive = '\\jarmusch';
    end
    recordPath = fullfile(drive,'Users','nlab');
end

recordPath = fullfile(recordPath,'Desktop','ballData','PermanentTrialRecordStore',subj);

d=dir(fileparts(recordPath));
fprintf('available subjects:\n');
{d([d.isdir] & ~ismember({d.name},{'.','..'})).name}

files = dir(fullfile(recordPath,'trialRecords_*.mat'));

bounds = cell2mat(cellfun(@(x)textscan(x,'trialRecords_%u-%u_%*s.mat','CollectOutput',true),{files.name}'));
[~,ord] = sort(bounds(:,1));
bounds = bounds(ord,:);
files = files(ord);

recNum = 0;
for i=1:length(files)
    if bounds(i,1) ~= recNum+1
        error('record file names indicate ordering problem')
    end
    
    fullRecs(i) = load(fullfile(recordPath,files(i).name)); %loading files in this format is slow, that's why we normally use compiled records
    newRecNum = recNum + length(fullRecs(i).trialRecords);
    records(recNum+1:newRecNum) = fullRecs(i).trialRecords; %extending this struct array is slow, another reason we normally use compiled records
    recNum = newRecNum;
    
    if bounds(i,2) ~= recNum
        error('record file names indicate ordering problem')
    end
    
    fprintf('done with %d of %d\n',i,length(files));
end

trialNums = [records.trialNumber];
if ~all(diff(trialNums) == 1)
    error('records don''t show incrementing trial numbers')
end

startTimes = datenum(cell2mat({records.date}'));
d = diff(startTimes);
sessions = find(d > .02); %this gives us session boundaries whenever there was a half hour gap in the trial start times
if ~all(d > 0)
    error('records don''t show increasing start times')
end

minPerChunk=50;
chunkHrs=36;

chunks=sessions-minPerChunk;
chunks=sessions(diff(startTimes([[ones(sum(chunks<=0),1) chunks(chunks>0)] sessions+1]),[],2)>chunkHrs/24);

%these session boundaries aren't useful, cuz you may have stopped and started right away again
if ~all(diff([records.sessionNumber]) >= 0)
    error('records don''t show increasing session numbers')
end

%just verify these are empty (not having set this is probably why compiling fails)
if ~all(cellfun(@isempty,{records.correct}))
    error('weird -- records.correct should always be empty (for now we''re not using this field)')
end

%should just be one of two strings -- 'nominal' for most trials, 'manual kill' on the trial where you hit k-q
result = {records.result};
[~,loc] = ismember(result,unique(result));

%this is a record of correct (true) or incorrect (false), but should be empty on 'manual kill' trials
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
    %hmm, test's trial 2257 (last one in file 23) is set to manual kill, but got a 0 for correct, instead of an empty.  how?
    inds = find((res == 2) ~= (loc == 1))
    res(inds)
    loc(inds)
    u=unique(result);
    u(loc(inds))
    t(inds).correct
    warning('manual kills didn''t line up with empty corrects')
end

%these trials each have 2-3 phases -- a possible "slow" phase, a discrimination phase, and a reinforcement phase
%we take the actual measured reward duration from the reinforcement phase (currently quantized to frame boundaries)
%from the discrimination phase, we take the x,y,t track location measurements
%entries in 'times' are in seconds, corresponding to x,y entries in 'track'
%we also pull out some other info just to do some consistency checking later
[actualRewards nFrames times targ track results stopTimes] = cellfun(@(x)g(x),{records.phaseRecords},'UniformOutput',false);
    function [a n t targ track r slowT]=g(x)
        if ~any(length(x)==[2 3])
            error('expected 2 or 3 phases')
        end
        
        phasesDone = false(1,3);
        slowT=[]; %%% 
        
        for i=1:length(x)
            if ~all(phasesDone(2:i-1))
                error('phases out of order')
            end
            
            if isempty(x(i).phaseType) %k-q'd before got to this phase?
                if any(phasesDone)
                    switch find(phasesDone,1,'last')
                        case 1
                            x(i).phaseType='discrim';
                        case 2
                            x(i).phaseType='reinforced';
                        otherwise
                            error('huh')
                    end
                else
                    error('huh')
                end
            end
            
            switch x(i).phaseType
                case 'pre-request'
                    setPhase(1);
                    track = doField(x(i).dynamicDetails,'slowTrack');
                    if ~isempty(track)
                        slowT = track(1,:);
                    else
                        slowT=[];
                    end
                    % TODO: here's where you should add analysis of the "slow" track
                    % load in the track from this phase following example from the discrim phase below
                case 'discrim'
                    setPhase(2);
                    
                    n     = doField(x(i).dynamicDetails,'nFrames');
                    t     = doField(x(i).dynamicDetails,'times');
                    targ  = doField(x(i).dynamicDetails,'target');
                    track = doField(x(i).dynamicDetails,'track');
                    r     = doField(x(i).dynamicDetails,'result');
                    
                    if ~all(diff(t(~isnan(t)))>0)
                        error('track timestamps aren''t increasing')
                    end
                    
                    if ~isempty(r)
                        if any(cellfun(@(x)any(isnan(x)),{t track(:)}))
                            error('should only happen when there is no result (manual kills)')
                        end
                    else
                        r = '';
                        test=repmat(isnan(t),2,1) == isnan(track);
                        if ~all(test(:))
                            error('test and track didn''t have matching nans')
                        end
                        if length(find(diff(isnan(t)))) > 1
                            error('should be at most one transition from non-nans to nans')
                        end
                        t=t(~isnan(t));
                        track=track(:,~isnan(t));
                    end
                case 'reinforced'
                    setPhase(3);
                    
                    a = x(i).actualRewardDurationMSorUL;
                otherwise
                    x(i).phaseType
                    error('huh')
            end
        end
        if ~all(phasesDone(2:end))
            error('missing phases')
        end
        
        function setPhase(sp)
            if ~phasesDone(sp)
                phasesDone(sp)=true;
            else
                error('duplicate phase!')
            end
        end
        
        function out = doField(x,f)
            if isfield(x,f)
                out = x.(f);
            else
                out = [];
            end
        end
    end
actualRewards = cell2mat(actualRewards);

if ~all(cellfun(@(x,y)length(x)==size(y,2),times,track))
    error('times and track didn''t have same dimension')
end

    function d = getDurFromT(t)
        %no entry was made if there was no motion (and there were missed frames), so the raw number of entries slightly distorts actual duration
        len = cellfun(@length,t);
         t = cellfun(@fixTimes,t,'UniformOutput',false);
        function x=fixTimes(x)
            if isempty(x)
                x=[0 0]; %diff(0) is [];
            end
        end
        d = cellfun(@(x)1000*diff(x([1 end])),t);
    end

dur = getDurFromT(times);

stopDur = getDurFromT(stopTimes);

% i'm seeing a lot of trials (12%) that have only one timestamp
if false %this shows that position really is past the wall on the first timestamp
    fprintf('%g%% trials have only one timestamp (%g%% of these were correct)\n',100*sum(len==1)/length(len),100*sum(len==1 & res==1)/sum(len==1));
    x=[track{len==1}];
    plot(x(1,:),x(2,:),'.')
end


%hack oom
clear fullRecs
records=rmfield(records,'phaseRecords');

% clear t
% clear fullRecs
% d=fields(records);
% for i=1:length(d)
%     fullRecs={records.(d{i})};
%     fullRecs=whos('fullRecs');
%     t(i,1:2)={d{i},fullRecs.bytes};
% end
% clear fullRecs
% for i=1:size(t,1)
%     fullRecs(i) = t{i,2};
% end
% [~,d]=sort(fullRecs);
% t = t(d,:)

records = arrayfun(@fixStimDetails,records);
    function x=fixStimDetails(x)
        if ~isfield(x.stimDetails,'correctionTrial')
            x.stimDetails.correctionTrial = [];
        end
    end

%verify the following info matches consistently
s = [records.stimDetails];
timeout = [s.nFrames];
targetLocation = [s.target];

if ~all(cellfun(@(x,y)isempty(x) || x==y,nFrames,mat2cell(timeout,1,ones(1,length(timeout))))) % this was the limit on the trial length -- the # of position changes
    error('nFrames didn''t match timeout')
end

if ~all(cellfun(@(x,y)isempty(x) || x==y,targ,mat2cell(targetLocation,1,ones(1,length(targetLocation)))))
    error('targetLocation and targ didn''t match')
end

if ~all(cellfun(@isempty,results) == (res == 2))
    error('empty results didn''t line up with manual kills')
end

if ~all(cellfun(@checkCorrect,results,mat2cell(res,1,ones(1,length(res)))))
    error('correct/incorrect/timedout results didn''t line up with correctness')
end

    function out=checkCorrect(x,y)
        switch x
            case ''
                out = y==2;
            case 'correct'
                out = y==1;
            case {'incorrect','timedout'}
                out = y==0;
            otherwise
                error('unexpected result')
        end
    end

%this is set whenever you hit k-ctrl-# to manually open valve
manualRewards = [records.containedForcedRewards];

classes = nan(size(manualRewards));
classes(res==0 & strcmp('incorrect',results) & ~manualRewards) = 1;
classes(res==1 & strcmp('correct'  ,results) & ~manualRewards) = 2;
classes(res==0 & strcmp('timedout' ,results) & ~manualRewards) = 3;

choiceSide = (sign(targetLocation).*sign(classes-1.5) +1)/2;  %%% flip target side if you got it wrong, then 0 = left, 1=right
choiceSide(classes==3)=NaN;

cs = 1:3; % unique(classes(~isnan(classes))); %bug when you have no exemplars of one of the categories

n = 50;
    function out = nanmeanMW(x) %my nanmean function shadows the stats toolbox one and is incompatible
        % out = builtin('nanmean',x); %fails cuz toolboxes don't count as builtin
        
        fs = which('nanmean','-all');
        ind = find(~cellfun(@isempty,strfind(fs,'stats')));
        if ~isscalar(ind)
            error('couldn''t find unique stats toolbox nanmean')
        end
        % out = feval(fs{ind},x); %fails cuz exceeds MATLAB's maximum name length of 63 characters
        % f = str2func(fs{ind}); %paths aren't valid function names?
        oldDir = cd(fileparts(fs{ind}));
        out = nanmean(x);
        cd(oldDir);
    end

    function out = savg(x,n)
        out = nanmeanMW(window(pad(x,n,@nan),n));
    end

    function out = pad(x,n,p)
        n = (n-1)/2;
        out = [p(1,ceil(n)) x p(1,floor(n))];
    end

    function out = window(x,n)
        out = x(repmat((1:n)',1,length(x)-n+1)+repmat(0:length(x)-n,n,1));
    end

for i=1:length(cs)
    tDur{i} = classes==cs(i);
    slidingAvg{i} = savg(dur(tDur{i}),n);
    pTiles{i} = prctile(window(pad(dur(tDur{i}),n,@nan),n),25*[-1 0 1]+50);
end

    function [x pci] = getPCI(alpha,inds,res)        
        [~, pci] = binofit(sum(window(res(inds),n)),n,alpha);
        x=trialNums(inds);
        x=x(~isnan(pad(zeros(1,size(pci,1)),n,@nan)));
    end


rInds = res~=2 & ~manualRewards;
[x pci] =getPCI(0.05,rInds,res);
        
sideInds = ~isnan(choiceSide);
[sidex sidepci] = getPCI(0.05,sideInds,choiceSide);

%dig out the reward size we intended to give
r = [records.reinforcementManager];
intendedRewards = [r.rewardSizeULorMS];

%interframe intervals (in secs, should be 1/60 for 60Hz)
s = [records.station];
ifis = [s.ifi];


%plot some stuff!
close all
n = 5;

dotSize=20;
cm = [1 0 0;0 1 0;.9 .9 0]; %red for incorrects, green for corrects, yellow for timeouts
grey = .85*ones(1,3);
transparency = .2;
head = 1.1;

subplot(n,1,1)
correctPlot(actualRewards);
hold on
plot(trialNums,intendedRewards,'k')
ylims = [0 max(actualRewards)*head];
ylabel('reward size (ms)')
title(subj)
standardPlot(@plot,[],false,true);

    function standardPlot(f,ticks,lines,dates)
        arrayfun(@(x)f(x*ones(1,2),ylims,'Color',grey   ),sessions);        
        arrayfun(@(x)f(x*ones(1,2),ylims,'Color',[1 0 0]),chunks  );
        
        
        datestr(startTimes(sessions+1))
        if exist('dates','var') && dates
            for sess = 1:length(sessions)    
            text(sessions(sess)+50,0.1*ylims(2),datestr(startTimes(sessions(sess)+1),2),'FontSize',8,'Rotation',90,'FontName','FixedWidth');
            end  
        end 
        if isequal(f,@semilogyEF) %they couldn't overload == ?
            ylims = log(ylims);
        end
        
        ylim(ylims)
        xlim([1 length(records)])
        
        if exist('ticks','var') && ~isempty(ticks)
            set(gca,'YTick',log(ticks),'YTickLabel',ticks);
            if exist('lines','var') && lines
                f(trialNums,repmat(ticks,length(trialNums),1),'Color',grey);
            end
        end
    end

    function correctPlot(x)
        mask = ~isnan(classes);
        
        x = x(mask);
        tns = trialNums(mask);
        good = classes(mask);
        
        if exist('doLog','var') && doLog
            z = log(fix0(x));
            nzInds = x~=0;
            x = log(x);
        else
            nzInds = true(size(x));
        end
        scatter(tns(nzInds),x(nzInds),dotSize,cm(good(nzInds),:),'.');
        if ~all(nzInds)
            hold on
            scatter(tns(~nzInds),z*ones(1,sum(~nzInds)),dotSize,cm(good(~nzInds),:),'+');
        end
    end

    function rangePlot(x,y,c)
        if exist('doLog','var') && doLog
            y=log(y);
        end
        if ~exist('c','var') || isempty(c)
            c=zeros(1,3);
        end
        fill([x fliplr(x)],[y(1,:) fliplr(y(2,:))],c,'FaceAlpha',transparency,'LineStyle','none');
    end

    function semilogyEF(x,y,varargin)
        %using semilogy causes transparency in this AND next plot to fail!  using plot resolves it.  set(gca,'YScale','log') doesn't
        
        plot(x,log(y),varargin{:});
    end

    function x=fix0(x)
        x=min(x(x~=0))/10;
    end
% 
% subplot(n,1,2)
% doLog = true;
% correctPlot(len); % k-q's res=2 often have len < timeout
% hold on
% semilogyEF(trialNums,timeout,'k') %why does this seem to be under the scatter?
% ylims = [fix0(len) max(len)*head];
% ylabel('num positions')
% standardPlot(@semilogyEF,[1 3 10 30 100 300]);

doLog=true;
subplot(n,1,2)
eps2 = min(stopDur(stopDur>0))
hold off
scatter(trialNums(stopDur>0),log(stopDur(stopDur>0)),dotSize,'.')
ylims = [eps2 max(stopDur)*head];
hold on
ylabel('stopping time')
standardPlot(@semilogyEF,[100 1000 10000 30000],false,true);

subplot(n,1,3)
eps2=fix0(dur(~isnan(classes)));
correctPlot(dur);
hold on
for i=1:length(cs)
    xd=trialNums(classes==cs(i));
    pTiles{i}(pTiles{i}==0)=eps2;
    rangePlot(xd,pTiles{i}([1 end],:),cm(i,:));
end
ylims = [eps2 max(dur)*head];
ylabel('ms')
standardPlot(@semilogyEF,[.01 .03 .1 .3 1 3 10]*1000,true);
doLog = false;

subplot(n,1,4)
rangePlot(x,pci');
hold on
plot(x,.5*ones(1,length(x)),'k')
ylims = [0 1];
ylabel('% correct')
standardPlot(@plot);
xlabel('trial')

subplot(n,1,5)
rangePlot(sidex,sidepci');
hold on
plot(x,.5*ones(1,length(x)),'k')
ylims = [0 1];
ylabel('% to right')
standardPlot(@plot);

xlabel('trial')
end