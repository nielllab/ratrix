function plotCrossingTime(subj,drive,force)
%addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'bootstrap'));
%setupEnvironment;

dbstop if error

if ~exist('force','var') || isempty(force)
    force = false;
end

if ~exist('subj','var') || isempty(subj)
    subj = 'test';
end

if ~exist('drive','var') || isempty(drive)
    local = false;
    if local
        drive='C:';
    else
        %drive='\\mtrix5';
        drive = '\\jarmusch';
    end
end

if IsWin
    recordPath = fullfile(drive,'Users','nlab');
elseif ismac && local
    recordPath = [filesep fullfile('Users','eflister')];
else
    error('unsupported')
end

%for some reason, compiling these records is failing
%once this is solved we'll load in a single compiled file from ...\ballData\CompiledTrialRecords\
%most of the work in this file does what CompileTrialRecords does

%get trial records in the right order
recordPath = fullfile(recordPath,'Desktop','ballData','PermanentTrialRecordStore',subj);

d=dir(fileparts(recordPath));
fprintf('available subjects:\n');
{d([d.isdir] & ~ismember({d.name},{'.','..'})).name}

files = dir(fullfile(recordPath,'trialRecords_*.mat'));

if isempty(files)
    error('no records for that subject')
end

bounds = cell2mat(cellfun(@(x)textscan(x,'trialRecords_%u-%u_%uT%u-%uT%u.mat','CollectOutput',true),{files.name}'));
[~,ord] = sort(bounds(:,1));
bounds = bounds(ord,:);
files = files(ord);

if ~force && IsWin
    fd = ['\\reichardt\figures\' subj];
    d=dir([fd '\*.300.png']);
    d=sort({d.name});
    try %d may be empty
        d=textscan(strtok(d{end},'.'),'%uT%u','CollectOutput',true);
        d=d{1};
        d = double(d) - double(bounds(end,5:6));
        if d(1)>0 || (d(1)==0 && d(2)>0)
            fprintf('skipping - latest figures already generated (%s)\n',fd)
            return
        end
    end
end

recNum = 0;
for i=1:length(files)
    if bounds(i,1) ~= recNum+1
        error('record file names indicate ordering problem')
    end
    
    fullRecs(i) = load(fullfile(recordPath,files(i).name)); %loading files in this format is slow, that's why we normally use compiled records
    newRecNum = recNum + length(fullRecs(i).trialRecords);
    records(recNum+1:newRecNum) = fullRecs(i).trialRecords; %extending this struct array is slow, another reason we normally use compiled records
    fullRecs(i).trialRecords = []; %prevent oom
    recNum = newRecNum;
    
    if bounds(i,2) ~= recNum
        error('record file names indicate ordering problem')
    end
    
    fprintf('done with %d of %d\n',i,length(files));
end

if IsWin && false %takes too long (95sec local) to save (.25GB on disk, 1.8GB in memory), loading slow (73sec local) too
    tic
    save([fd '\latest.mat'],'fullRecs','records');
    toc
    keyboard
end

trialNums = [records.trialNumber];
if ~all(diff(trialNums) == 1)
    error('records don''t show incrementing trial numbers')
end

startTimes = datenum(cell2mat({records.date}'));
d = diff(startTimes);
sessions = find(d > .5/24); %this gives us session boundaries whenever there was a half hour gap in the trial start times
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

%this is a record of correct (true) or incorrect (false), but may be empty on 'manual kill' trials (unless k-q during reinforcement phase)
t = [records.trialDetails];
res = cellfun(@f,{t.correct});
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
    %hmm, test's trial 2257 (last one in file 23) is set to manual kill,
    %but got a 0 for correct, instead of an empty.  maybe k-q during
    %penalty timeout?
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
%we also pull out some other info just to do some consistency checking later
[actualRewards nFrames targ track results slowTrack actualReqRewards] = cellfun(@g,{records.phaseRecords},'UniformOutput',false);
    function [a n targ track r slowT q]=g(x)
        if ~any(length(x)==[2 3])
            error('expected 2 or 3 phases')
        end
        
        phasesDone = false(1,3);
        slowT=[];
        
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
                    slowT = doField(x(i).dynamicDetails,'slowTrack');
                    if ~isempty(slowT)
                        if ~all(diff(slowT(1,:))>0) || any(isnan(slowT(:)))
                            error('slow timestamps not increasing or has nans')
                        end
                    end
                case 'discrim'
                    setPhase(2);
                    
                    n     = doField(x(i).dynamicDetails,'nFrames');
                    t     = doField(x(i).dynamicDetails,'times');
                    targ  = doField(x(i).dynamicDetails,'target');
                    track = doField(x(i).dynamicDetails,'track');
                    r     = doField(x(i).dynamicDetails,'result');
                    q = x(i).responseDetails.requestRewardDurationActual;
                    if isempty(q)
                        q=nan;
                    elseif isscalar(q)
                        q=q{1};
                    else
                        error('expected empty or scalar cell')
                    end
                    
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
                    end
                    track=[t(~isnan(t));track(:,~isnan(t))];
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
    end
actualRewards    = cell2mat(actualRewards   );
actualReqRewards = cell2mat(actualReqRewards);

    function out = doField(x,f,d)
        if ~exist('d','var')
            d = [];
        end
        if isfield(x,f)
            out = x.(f);
        else
            out = d;
        end
    end

dur     = cellfun(@getDurFromT,track    );
stopDur = cellfun(@getDurFromT,slowTrack);
    function d = getDurFromT(t)
        if isempty(t)
            d=0;
        else
            d=diff(t(1,[1 end]));
        end
    end

% i'm seeing a lot of trials (12%) that have only one timestamp
if false %this shows that position really is past the wall on the first timestamp
    fprintf('%g%% trials have only one timestamp (%g%% of these were correct)\n',100*sum(len==1)/length(len),100*sum(len==1 & res==1)/sum(len==1));
    x=[track{len==1}];
    plot(x(1,:),x(2,:),'.')
end

%hack oom
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
            x.stimDetails.correctionTrial = nan; %earlier version didn't have correction trials
        end
    end

%verify the following info matches consistently
s = [records.stimDetails];
timeout = [s.nFrames];
targetLocation = [s.target];

%TODO: flag correction trials (different marker on plot?)
correctionTrial = [s.correctionTrial];

    function out = extract(f,d,m,trans)
        out = cellfun(@(x)doField(x,f,d),{records.stimManager},'UniformOutput',false);
        if trans
            out = out';
        end
        if m
            out = cell2mat(out);
        end
    end

gain          = extract('gain'          ,nan(2,1),true ,false);
stoppingSpeed = extract('slow'          ,nan(2,1),true ,false);
stoppingTime  = extract('slowSecs'      ,nan     ,true ,false);
wallDist      = extract('targetDistance',nan(1,2),true ,true ); %apparently we never had single entries here?
stim          = extract('stim'          ,nan     ,false,false);
initP         = extract('initialPos'    ,nan(2,1),true ,false);

for i=1:size(bounds,1)
    if ismember('stimManager.stim',fullRecs(i).fieldsInLUT)
        for x=bounds(i,1):bounds(i,2)
            if isscalar(stim{x}) && isreal(stim{x}) && stim{x}>0 && stim{x}<=length(fullRecs(i).sessionLUT) && mod(stim{x},1)==0 % mod(.,1)==0 checks for float integers
                %all(cellfun(@(f)f(stim{x}),{@isscalar @isreal})) %too slow
                stim{x}=fullRecs(i).sessionLUT{stim{x}};
            else
                stim{x}
                class(stim{x})
                fullRecs(i).sessionLUT
                error('LUT problem')
            end
        end
    end
end
flip = strcmp(stim,'flip');
rnd  = strcmp(stim,'rand');

if ~all(cellfun(@(x,y)isempty(x) || x==y,nFrames,num2cell(timeout))) % this was the limit on the trial length -- the # of position changes
    error('nFrames didn''t match timeout')
end

if ~all(cellfun(@(x,y)isempty(x) || x==y,targ,num2cell(targetLocation)))
    error('targetLocation and targ didn''t match')
end

%this is set whenever you hit k-ctrl-# to manually open valve
manualRewards = [records.containedForcedRewards];

if any(~ismember(results,{'incorrect','correct','timedout',''}))
    error('unexpected dynamicDetails.result')
end
if any( strcmp(results,'')~=(res==2) | ismember(results,{'incorrect','timedout'})~=(res==0) | strcmp(results,'correct')~=(res==1) )
    error('dynamicDetails.result didn''t line up with trialDetails.correct')
end

targRight = sign(targetLocation)>0;
choiceRight = (targRight & strcmp(results,'correct')) | (~targRight & strcmp(results,'incorrect'));

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

[goodResults,classes] = ismember(results,{'incorrect','correct','timedout'});
for i=1:max(classes)
    pTiles{i} = prctile(window(pad(dur(classes==i),n,@nan),n),25*[-1 0 1]+50);
end

    function [x pci] = binoConf(alpha,inds,res)
        [~, pci] = binofit(sum(window(res(inds),n)),n,alpha);
        x=trialNums(inds);
        x=x(~isnan(pad(zeros(1,size(pci,1)),n,@nan)));
    end

alpha=.05;
[perfX perfC] = binoConf(alpha,~(strcmp(results,'') | manualRewards),res        );
[biasX biasC] = binoConf(alpha,~ismember(results,{'','timedout'})   ,choiceRight);

%dig out the reward size we intended to give
r = [records.reinforcementManager];
intendedRewards = [r.rewardSizeULorMS];

%interframe intervals (in secs, should be 1/60 for 60Hz)
s = [records.station];
ifis = [s.ifi];

%plot some stuff!
close all
sps = 4;

h = [];

cm = [1 0 0;0 1 0;1 1 0]; %red for incorrects, green for corrects, yellow for timeouts
head = 1.1;
dotSize = 4;

doBlack = true;
if doBlack
    colordef black
    grey = .25*ones(1,3);
    
    transparency = .5;
    bw = 'w';
else
    colordef white
    grey = .85*ones(1,3);
    cm = .9*cm;
    transparency = .2;
    bw = 'k';
end

h(end+1) = subplot(sps,1,1);
correctPlot(actualRewards);
hold on
plot(trialNums,intendedRewards,bw)
plot(trialNums,actualReqRewards,'m.','MarkerSize',dotSize)
ylims = [-1 max([actualRewards actualReqRewards])*head];
ylabel('reward size (ms)')
title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])
standardPlot(@plot,[],false,true);

    function standardPlot(f,ticks,lines,dates,xticks)
        if length(ylims)>2
            yvals=ylims;
            ylims=[1 length(ylims)];
        end
        
        arrayfun(@(x)f(x*ones(1,2),ylims,'Color',grey   ),sessions);
        arrayfun(@(x)f(x*ones(1,2),ylims,'Color',[1 0 0]),chunks  );
        
        if exist('dates','var') && ~isempty(dates) && dates
            tn = [0; sessions]+1;
            ds = diff([tn-1; length(startTimes)]);
            ss = datevec(startTimes(tn));
            for sess = 1:length(ds)
                if ds(sess)>15
                    ref = startTimes(tn(sess));
                    dayStr=datestr(ref,'ddd');
                    if sess==1 || diff(ss(sess+[-1 0],2))
                        monthStr=[datestr(ref,'mmm') ' '];
                    else
                        monthStr='';
                    end
                    anno=sprintf('%s \\bf%s%d \\rm%d',dayStr,monthStr,ss(sess,3),ds(sess));
                    text(tn(sess)+.5*ds(sess),ylims(1)+.1*range(ylims),anno,'FontSize',9,'Rotation',90,'FontName','FixedWidth');
                end
            end
        end
        
        if isequal(f,@semilogyEF) %they couldn't overload == ?
            ylims = log(ylims);
        end
        
        ylim(ylims)
        xlim([1 length(records)])
        
        if exist('ticks','var') && ~isempty(ticks)
            if ~exist('yvals','var')
                if isequal(f,@semilogyEF) %they couldn't overload == ?
                    ltics = log(ticks);
                else
                    ltics = ticks;
                end
            else
                ltics=interp1(yvals,1:length(yvals),ticks);
            end
            set(gca,'YTick',ltics,'YTickLabel',ticks);
            
            if exist('lines','var') && ~isempty(lines) && lines
                if exist('yvals','var')
                    error('not implemented')
                end
                f(trialNums,repmat(ticks,length(trialNums),1),'Color',grey);
            end
        end
        
        if ~exist('xticks','var') || isempty(xticks) || ~xticks
            set(gca,'XTick',[])
            set(gca,'XTickLabel',[]) %otherwise, x10^4 can show up (see http://www.mathworks.com/matlabcentral/answers/4515-removing-ticks)
        end
    end

    function correctPlot(x)
        x = x(goodResults);
        tns = trialNums(goodResults);
        good = classes(goodResults);
        
        if exist('doLog','var') && doLog
            z = log(fix0(x));
            nzInds = x~=0;
            x = log(x);
        else
            nzInds = true(size(x));
        end
        
        u=unique(good);
        for i=1:length(u)
            inds = nzInds & good==u(i);
            plot(tns(inds),x(inds),'.','Color',cm(u(i),:),'MarkerSize',dotSize);
            hold on
            if ~all(nzInds)
                inds = ~nzInds & good==u(i);
                plot(tns(inds),z*ones(1,sum(inds)),'+','Color',cm(u(i),:),'MarkerSize',dotSize);
            end
        end
    end

    function rangePlot(x,y,c,t)
        if ~exist('t','var') || isempty(t)
            t=transparency;
        end
        if exist('doLog','var') && doLog
            y=log(y);
        end
        if ~exist('c','var') || isempty(c)
            c=zeros(1,3);
        end
        fill([x fliplr(x)],[y(1,:) fliplr(y(2,:))],c,'FaceAlpha',t,'LineStyle','none');
    end

    function semilogyEF(x,y,varargin)
        %using semilogy causes transparency in this AND next plot to fail!  using plot resolves it.  set(gca,'YScale','log') doesn't
        plot(x,log(y),varargin{:});
    end

    function x=fix0(x)
        x=min(x(x~=0))/2;
    end

h(end+1) = subplot(sps,1,2);
doLog = true;
eps2 = min(stopDur(stopDur>0));

stopType = 'ptile';
switch stopType
    case 'density'
        k=100;
        bins = logspace(log10(eps2),log10(max(stopDur(:))),k);
        s = histc(window(pad(stopDur,n,@nan),n),bins);
        imagesc(log(s))
        axis xy
    case 'ptile'
        cmj = colormap('jet');
        cmj = [cmj;flipud(cmj)];
        k = size(cmj,1);
        s = prctile(window(pad(stopDur,n,@nan),n),linspace(0,100,k));
        
        eps2=eps2/head; %min(s(s>0))/head;
        %s(s<=0)=eps2;
        
        if false %patch
            for i=1:size(s,1)-1
                rangePlot(trialNums,s(i+[0 1],:),cmj(ceil(size(cmj,1)*i/(size(s,1)-1)),:),1);
                hold on
            end
        else %contour
            for i=ceil(linspace(1,size(s,1),11))
                semilogyEF(trialNums,s(i,:),'Color',cmj(ceil(size(cmj,1)*i/size(s,1)),:));
                hold on
            end
        end
    otherwise
        semilogyEF(trialNums(stopDur>0),stopDur(stopDur>0),'.','MarkerSize',dotSize)
end
switch stopType
    case 'density'
        ylims = bins;
        plotter = @plot;
    otherwise
        ylims = [eps2 max(stopDur)*head];
        plotter = @semilogyEF;
end
hold on
standardPlot(plotter,[.1 .3 1 3 10 30],true);
ylabel('stop time (s)')

h(end+1) = subplot(sps,1,3);
eps2=fix0(dur(goodResults));
correctPlot(dur);
hold on
for i=1:length(pTiles)
    pTiles{i}(pTiles{i}==0)=eps2;
    rangePlot(trialNums(i==classes),pTiles{i}([1 end],:),cm(i,:));
end
ylims = [eps2 prctile(dur,99)*head];
ylabel('response time (s)')
standardPlot(@semilogyEF,[.01 .03 .1 .3 1 3 10],true);
doLog = false;

h(end+1) = subplot(sps,1,4);
rangePlot(perfX,perfC','r');
hold on
rangePlot(biasX,biasC',bw);
plot(trialNums,.5*ones(1,length(trialNums)),bw)
if any(flip)
    plot(trialNums(flip),.5,'b+')
end
if any(rnd)
    plot(trialNums(rnd),.5,'g+')
end
ylims = [0 1];
ylabel('% correct(r) rightward(w)')
standardPlot(@plot,[],[],[],true);

xlabel('trial')
linkaxes(h,'x');
uploadFig(gcf,subj,max(trialNums)/10,sps*200);

    function out=interleave(in,p)
        out = cell2mat(cellfun(@(x,i)[x p],in,'UniformOutput',false));
    end

    function out = processTrack(t,i,f,v)
        if ~isempty(t)
            ts = i+(t(1,:)-t(1,1))*f;
            xys = t(2:3,:)-repmat(initP(:,i),1,size(t,2));
            if v
                ts = ts-diff(ts([1 end]));
                xys = cumsum(xys,2); %this hides some bad noise and clipping -> investigate...
                xys = xys-repmat(xys(:,end),1,size(xys,2));
            end
            out = [ts;xys];
        else
            out = nan(3,1);
        end
    end

plotTracks = true;
if plotTracks
    fig=figure;
    sps = 3*2;
    slowFact = .1;
    trackFact = 1;
    
    stops = cellfun(@(x,i)processTrack(x,i,slowFact ,true ),slowTrack,num2cell(trialNums),'UniformOutput',false);
    resps = cellfun(@(x,i)processTrack(x,i,trackFact,false),    track,num2cell(trialNums),'UniformOutput',false);
    
    h=[];
    ylabels={'stop x','stop y','left x','left y','right x','right y'};
    for i=1:sps
        h(end+1)=subplot(sps,1,i);

        switch i
            case {1 2}
                xs = {{cellfun(@(x)x([1 i+1],:),stops,'UniformOutput',false),'m'}};
            case {3 4 5 6}
                switch i
                    case {3 4}
                        j=1;
                        filt = ~targRight;
                    case {5 6}
                        j=3;
                        filt = targRight;
                end
                xs = cellfun(@(c){cellfun(@(x)x([1 i-j],:),resps(filt & classes==c),'UniformOutput',false) cm(c,:)},num2cell(unique(classes(goodResults))),'UniformOutput',false);
        end
        
        xs = cellfun(@(x){interleave(x{1},nan(2,1)) x{2:end}},xs,'UniformOutput',false);
        plot(trialNums,0,'Color',grey);
        hold on
        cellfun(@(x)plot(x{1}(1,:),x{1}(2,:),'Color',x{2}),xs);

        switch i
            case 1
                title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])
            case 2
                xlabel(sprintf('slow time %gs',1/slowFact));
        end
        
        ylabel(ylabels{i});
        ylims = get(h(end),'YLim');
        standardPlot(@plot,[],[],[],i==sps);
    end
    
    xlabel(sprintf('trial (track time %gs)',1/trackFact));
    linkaxes(h,'x');
    uploadFig(fig,subj,max(trialNums)/10,sps*200,'tracks');
end

    function out = getLims(in)
        out = (range(in(:))+.1)*(head-1)*[-1 1] + cellfun(@(f) f(in(:)),{@min @max}); %+.1 ugly for when in is constant so range is zero
    end

plotSettings = true;
if plotSettings
    fig=figure;
    d=3;
    
    plots = {gain    ,'gain'           ;
        stoppingSpeed,'stop speed'     ;
        stoppingTime ,'stop time (s)'  ;
        wallDist'    ,'target distance'};
    
    n = size(plots,1);
    h = [];
    for i=1:n
        h(i) = subplot(n,1,i);
        x=plot(trialNums,plots{i,1}');
        arrayfun(@(x,y) set(x,'LineWidth',y),x,(d-1)+(d*(length(x)-1):-d:0)');
        hold on
        ylims = getLims(plots{i,1});
        ylabel(plots{i,2})
        standardPlot(@plot,[],[],i==1,i==n); %(f,ticks,lines,dates,xticks)
        if i==1
            title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])
        end
    end
    
    xlabel('trial')
    linkaxes(h,'x');
    uploadFig(fig,subj,max(trialNums)/10,sps*200,'params');
end
end