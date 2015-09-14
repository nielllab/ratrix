function plotCrossingTime(subj,drive,force)
%addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'bootstrap'));
%setupEnvironment;

dbstop if error
close all

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

if ispc
    compiledDir = '\\reichardt\figures';
    compiledFile = getCompiledFile(compiledDir,subj);
    
    doCompile = true;
    if doCompile
        try
            compiledFile = compileBall(subj,drive,force,compiledDir);
        catch ex
            getReport(ex)
            warning('bailing on compiling %s',subj)
        end
    end
    
    doPlot = true;
    if ~isempty(compiledFile) && doPlot
        try
            makePlots(subj,compiledFile);
        catch ex
            getReport(ex)
            warning('bailing on plotting %s',subj)
        end
    end
else
    error('only win so far')
end
end

function [compiledFile, lastTrial]=getCompiledFile(compiledDir,subj)
compiledFile = '';
lastTrial = 0;

d = dir(fullfile(compiledDir,subj,'compiled*.mat'));
if ~isempty(d)
    vals = cell2mat(cellfun(@(x)textscan(x,'compiled_1-%u_%uT%u.mat','CollectOutput',true),{d.name}'));
    trials = vals(:,1);
    [~, ord]=sortrows(vals(:,[2 3]));
    %compiledFile = fullfile(compiledDir,subj,d(max(ord)).name);
    compiledFile = fullfile(compiledDir,subj,d(ord(end)).name);
    %lastTrial = trials(max(ord));
    lastTrial = trials(ord(end));
end
end

function subj = fixSubj(subj)
wf = '-widefield';
if strcmp(subj,[subj(1:end-length(wf)) wf])
    subj = subj(1:end-length(wf));
end
end

function compiledFile = compileBall(subj,drive,force,compiledDir)
if ispc
    recordPath = fullfile(drive,'Users','nlab');
elseif ismac && local
    recordPath = [filesep fullfile('Users','eflister')];
else
    error('unsupported')
end

%compiledFile = '';
[compiledFile,lastTrial] = getCompiledFile(compiledDir,subj);

%for some reason, compiling these records is failing
%once this is solved we'll load in a single compiled file from ...\ballData\CompiledTrialRecords\
%most of the work in this file does what CompileTrialRecords does

%get trial records in the right order
tmp = recordPath;
recordPath = fullfile(recordPath,'Desktop','ballData','PermanentTrialRecordStore',fixSubj(subj))

d=dir(fileparts(recordPath));

if false
    fprintf('available subjects:\n');
    {d([d.isdir] & ~ismember({d.name},{'.','..'})).name}
end

files = dir(fullfile(recordPath,'trialRecords_*.mat'));

if isempty(files)

    % edf added 07.03.15 to address mtrix6 db.mat kerfufle that points to wrong data directory
    recordPath = fullfile(tmp,'Desktop','ratrixData','PermanentTrialRecordStore',fixSubj(subj))
    files = dir(fullfile(recordPath,'trialRecords_*.mat'));
    
    if isempty(files)
        error('no records for that subject')
    end
end

bounds = cell2mat(cellfun(@(x)textscan(x,'trialRecords_%u-%u_%uT%u-%uT%u.mat','CollectOutput',true),{files.name}'));
[~,ord] = sort(bounds(:,1));
bounds = bounds(ord,:);
files = files(ord);

if ~force && ispc
    fd = ['\\reichardt\figures\' subj];
    d=dir([fd '\*.300.png']);
    d=sort({d.name});
    try %d may be empty
        d=textscan(strtok(d{end},'.'),'%uT%u','CollectOutput',true);
        d=d{1};
        d = double(d) - double(bounds(end,5:6));
        if d(1)>0 || (d(1)==0 && d(2)>0)
            fprintf('skipping - latest figures already generated (%s)\n',fd)
            compiledFile = [];
            return
        end
    end
    
    if bounds(end,2)<=lastTrial
        fprintf('skipping - latest trials already compiled (%s)\n',fd)
        return
    end
end

lcf = [];
if ~isempty(compiledFile)
    fprintf('loading %s\n',compiledFile)
    lcf = load(compiledFile);
    lcf = lcf.data;
end

recNum = 0;
theseRecs = 0;
for i=1:length(files)
    if bounds(i,1) ~= recNum+1
        error('record file names indicate ordering problem')
    end
    
    if recNum >= lastTrial
        fullRecs(i) = load(fullfile(recordPath,files(i).name)); %loading files in this format is slow, that's why we normally use compiled records
        newRecNum = theseRecs + length(fullRecs(i).trialRecords);        
        
        if exist('records','var')
            try
                f1 = fields(records);
                f2 = fields(fullRecs(i).trialRecords);
                f12 = setdiff(f1,f2);
                f21 = setdiff(f2,f1);
                for fi = 1:length(f12)
                    [fullRecs(i).trialRecords.(f12{fi})] = deal([]);
                    'old not in new'
                    f12{fi}
                    recordPath
                end
                for fi = 1:length(f21)
                    [records.(f21{fi})] = deal([]);
                    'new not in old'
                    f21{fi}
                    recordPath
                end
            catch ex
                getReport(ex)
                keyboard
            end            
        elseif theseRecs~=0
            error('huh?')
        end
        
        try
            records(theseRecs+1:newRecNum) = fullRecs(i).trialRecords; %extending this struct array is slow, another reason we normally use compiled records
        catch ex            
                getReport(ex)
                keyboard
        end
        fullRecs(i).trialRecords = []; %prevent oom
        theseRecs = newRecNum;
        recNum = newRecNum + lastTrial;
        fprintf('done with %d of %d\n',i,length(files));
        
        if bounds(i,2) ~= recNum
            error('record file names indicate ordering problem')
        end
        
    else
        recNum = bounds(i,2);
    end
end

if ispc && false %takes too long (95sec local) to save (.25GB on disk, 1.8GB in memory), loading slow (73sec local) too
    tic
    save([fd '\latest.mat'],'fullRecs','records');
    toc
    keyboard
end

%keyboard
if ~exist('records','var')
    fprintf('no new records\n')
    return
end

trialNums = [records.trialNumber];
if ~all(diff(trialNums) == 1)
    recordPath
    warning('records don''t show incrementing trial numbers')
    keyboard
    error('records don''t show incrementing trial numbers')
end

startTimes = datenum(cell2mat({records.date}'));
if ~all(diff(startTimes) > 0)
    r = find(diff(startTimes)<=0);
    for i=1:length(r)
        inds = r(i)+[0:2]
        records(inds).date
    end
    
    if false
        figure
        plot(startTimes)
        xlim([r(1) r(end)]+100*[-1 1])
        ylim(startTimes(r(1))+.02*[-1 1])
        keyboard
    end
    
    %ok to soften from error to warning?  seems windows time service has
    %hiccups (see //mtrix6 ly13 on 09.09.12)
    warning('records don''t show increasing start times')
end

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
try
    s = [records.stimDetails];
catch ex
    sd = arrayfun(@(x)isfield(x.stimDetails,'subDetails'),records);
    if ~isscalar(unique(sd))
        warning('some records.stimDetails have field subDetails, some don''t -- throwing away for now')
        % ...\ratrix\classes\protocols\stimManagers\@trail\extractDetailFields.m
        %probably need to be using stimManager's extractDetailFields ala compileDetailedRecords, why aren't we?
        for rn = 1:length(records) % way to do with arrayfun?
            if isfield(records(rn).stimDetails,'subDetails')
                records(rn).stimDetails.subDetails
                records(rn).stimDetails = rmfield(records(rn).stimDetails,'subDetails');
            end
        end
        s = [records.stimDetails];
    else
        ex
        keyboard
    end
end
timeout = [s.nFrames];
targetLocation = [s.target];

%TODO: flag correction trials (different marker on plot?)
correctionTrial = [s.correctionTrial];

    function out = extract(f,d,m,trans,e)
        out = cellfun(@(x)doField(x,f,d),{records.stimManager},'UniformOutput',false);
        if trans
            out = out';
        end
        if exist('e','var')
            out(cellfun(@isempty,out))={e};
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

dmsNan.targetLatency = nan;
dmsNan.cueLatency    = nan;
dmsNan.cueDuration   = nan;
dms           = extract('dms'           ,dmsNan  ,true ,false,dmsNan);

for i=1:size(bounds,1)
    if ismember('stimManager.stim',fullRecs(i).fieldsInLUT)
        if ~ismember(subj,{'ly15' 'ly11'})
            warning('weird, thought only ly11/ly15 have this (but don''t know why we don''t see lots of LUTed stims), was never debugged')
        end
        for x = (bounds(i,1):bounds(i,2)) - (bounds(end,2) - length(stim)) %blech!  haven't verified all the assumptions for this
            try
                if isscalar(stim{x}) && isreal(stim{x}) && stim{x}>0 && stim{x}<=length(fullRecs(i).sessionLUT) && mod(stim{x},1)==0 % mod(.,1)==0 checks for float integers
                    %all(cellfun(@(f)f(stim{x}),{@isscalar @isreal})) %too slow
                    stim{x}=fullRecs(i).sessionLUT{stim{x}};
                    if ~strcmp(stim{x},'rand')
                        stim{x}
                        warning('weird, have only ever seen this for rand on ly11/ly15 -- why aren''t other values LUTed?')
                    end
                else
                    stim{x}
                    class(stim{x})
                    fullRecs(i).sessionLUT
                    error('LUT problem')
                end
            catch ex
                getReport(ex)
                keyboard
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

if any(~ismember(results,{'incorrect','correct','timedout','tooEarly',''}))
    error('unexpected dynamicDetails.result')
end
if any( strcmp(results,'')~=(res==2) | ismember(results,{'incorrect','timedout','tooEarly'})~=(res==0) | strcmp(results,'correct')~=(res==1) )
    error('dynamicDetails.result didn''t line up with trialDetails.correct')
end
results(res==2)={'quit'};

targRight = sign(targetLocation)>0;
choiceRight = (targRight & strcmp(results,'correct')) | (~targRight & strcmp(results,'incorrect'));

%dig out the reward size we intended to give
r = [records.reinforcementManager];
intendedRewards = [r.rewardSizeULorMS];

%interframe intervals (in secs, should be 1/60 for 60Hz)
try
    s = [records.station];
    ifis = [s.ifi];
catch %later stations added a field 'laserPins'
    ifis = cellfun(@(x)x.ifi,{records.station});
end

data=struct(...
    'trialNum'       , num2cell(uint32(trialNums)      ), ...
    'startTime'      , num2cell(       startTimes'     ), ...
    'result'         ,                 results          , ...
    'choiceRight'    , num2cell(       choiceRight     ), ...
    'targRight'      , num2cell(       targRight       ), ...
    'flip'           , num2cell(       flip            ), ...
    'rnd'            , num2cell(       rnd             ), ...
    'gain'           , num2cell(       gain         , 1), ...
    'stoppingTime'   , num2cell(       stoppingTime    ), ...
    'stoppingSpeed'  , num2cell(       stoppingSpeed, 1), ...
    'intendedReward' , num2cell(       intendedRewards ), ...
    'actualReward'   , num2cell(       actualRewards   ), ...
    'actualReqReward', num2cell(       actualReqRewards), ...
    'manualReward'   , num2cell(       manualRewards   ), ...
    'initP'          , num2cell(       initP        , 1), ...
    'wallDist'       , num2cell(       wallDist'    , 1), ...
    'slowTrack'      ,                 slowTrack        , ...
    'track'          ,                 track              ...
    );

cellfun(@(f)combineStructs(dms,f),fields(dmsNan));

    function combineStructs(in,f)
        [data.(f)] = in.(f);
    end

if ~isempty(lcf) && (lcf(end).trialNum +1 ~= data(1).trialNum || lcf(end).startTime > data(1).startTime)
    error('new rec nums don''t match up with end of old ones')
end

data = [lcf data];

d = fullfile(compiledDir,subj);
[status,message,messageid] = mkdir(d);
if status ~= 1
    status
    message
    messageid
    error('couldn''t mkdir')
end

compiledFile = fullfile(d,sprintf('compiled_%d-%d_%s.mat',data(1).trialNum,data(end).trialNum,datestr(now,30)));
tic
save(compiledFile,'data');
toc

%existing compiled records have these fields in compiledTrialRecords (all 1 x n double)
% trialNumber
% date
% correct                 %all in [0 1 nan]
% result                  %all in [0 1]
% containedManualPokes    %all 0
% didHumanResponse        %all in [0 1]
% containedForcedRewards  %all in [0 1]
% correctionTrial         %all nans?
% actualRewardDuration
% proposedRewardDuration
% proposedPenaltyDuration
% response                %all in [-1 1], almost always -1
end

function makePlots(subj,compiledFile)
close all

data = load(compiledFile);
data = data.data;

trialNums        = [data.trialNum       ];
startTimes       = [data.startTime      ];
results          = {data.result         };
choiceRight      = [data.choiceRight    ];
targRight        = [data.targRight      ];
flip             = [data.flip           ];
rnd              = [data.rnd            ];
gain             = [data.gain           ];
stoppingTime     = [data.stoppingTime   ];
stoppingSpeed    = [data.stoppingSpeed  ];
intendedRewards  = [data.intendedReward ];
actualRewards    = [data.actualReward   ];
actualReqRewards = [data.actualReqReward];
manualRewards    = [data.manualReward   ];
initP            = [data.initP          ];
wallDist         = [data.wallDist       ];
slowTrack        = {data.slowTrack      };
track            = {data.track          };
targetLatency    = [data.targetLatency  ];
cueLatency       = [data.cueLatency     ];
cueDuration      = [data.cueDuration    ];

clear data;

d = diff(startTimes)';
sessions = find(d > .5/24); %this gives us session boundaries whenever there was a half hour gap in the trial start times
gaps = d(sessions);

minPerChunk=50;
chunkHrs=36;

chunks=sessions-minPerChunk;
try
    chunks=sessions(diff(startTimes([[ones(sum(chunks<=0),1) chunks(chunks>0)] sessions+1]),[],2)>chunkHrs/24);
catch
    warning('bad chunks, but i think it doesn''t matter anymore')
end

[goodResults,classes] = ismember(results,{'incorrect','correct','timedout','tooEarly'});

cm = [...
    1  0 0;... % red    for incorrects
    0  1 0;... % green  for corrects
    1  1 0;... % yellow for timeouts
    1 .5 0 ... % orange for tooEarlies
    ];
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

sps = 4;
h = [];

h(end+1) = subplot(sps,1,1);
hold on
ylims = [-1 max([actualRewards actualReqRewards])*head];
standardPlot(@plot,[],false,true);
correctPlot(actualRewards);
plot(trialNums,intendedRewards,bw)
plot(trialNums,actualReqRewards,'m.','MarkerSize',dotSize)
ylabel('reward size (ms)')
title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])

    function standardPlot(f,ticks,lines,dates,xticks)
        if length(ylims)>2
            yvals=ylims;
            ylims=[1 length(ylims)];
        end
        
        arrayfun(@(x,y)f(x*ones(1,2),ylims,'Color',grey,'LineWidth',.5+2*y),sessions,gaps);
        %arrayfun(@(x)f(x*ones(1,2),ylims,'Color',[1 0 0]),chunks  );
        
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
        xlim([1 length(trialNums)])
        
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
        if length(x)>1
            fill([x fliplr(x)],[y(1,:) fliplr(y(2,:))],c,'FaceAlpha',t,'LineStyle','none');
        end
    end

    function semilogyEF(x,y,varargin)
        %using semilogy causes transparency in this AND next plot to fail!  using plot resolves it.  set(gca,'YScale','log') doesn't
        plot(x,log(y),varargin{:});
    end

    function x=fix0(x)
        x=min(x(x~=0))/2;
    end

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

dur     = cellfun(@getDurFromT,track    );
stopDur = cellfun(@getDurFromT,slowTrack);
    function d = getDurFromT(t)
        if isempty(t)
            d=0;
        else
            d=diff(t(1,[1 end]));
        end
    end

h(end+1) = subplot(sps,1,2);
hold on
doLog = true;
eps2 = min(stopDur(stopDur>0));
n = 50;

stopType = 'ptile';
switch stopType
    case 'density'
        k=100;
        bins = logspace(log10(eps2),log10(max(stopDur(:))),k);
        s = histc(window(pad(stopDur,n,@nan),n),bins);
    case 'ptile'
        cmj = colormap('jet');
        cmj = [cmj;flipud(cmj)];
        k = size(cmj,1);
        s = prctile(window(pad(stopDur,n,@nan),n),linspace(0,100,k));
        
        eps2=eps2/head; %min(s(s>0))/head;
        %s(s<=0)=eps2;
end
switch stopType
    case 'density'
        ylims = bins;
        plotter = @plot;
        ytop = ylims(end);
    otherwise
        ylims = [eps2 max(stopDur)*head];
        plotter = @semilogyEF;
        ytop = log(ylims(end));
end
standardPlot(plotter,[.1 .3 1 3 10 30],true);
scatter(trialNums,.9*ytop*ones(size(trialNums)),dotSize,hsv2rgb([mod(-.25-startTimes',1) ones(length(trialNums),2)]),'+');
switch stopType
    case 'density'
        imagesc(log(s))
        axis xy
    case 'ptile'
        if false %patch
            for i=1:size(s,1)-1
                rangePlot(trialNums,s(i+[0 1],:),cmj(ceil(size(cmj,1)*i/(size(s,1)-1)),:),1);
            end
        else %contour
            for i=ceil(linspace(1,size(s,1),11))
                semilogyEF(trialNums,s(i,:),'Color',cmj(ceil(size(cmj,1)*i/size(s,1)),:));
            end
        end
    otherwise
        semilogyEF(trialNums(stopDur>0),stopDur(stopDur>0),'.','MarkerSize',dotSize)
end
ylabel('stop time (s)')

for i=1:max(classes)
    pTiles{i} = prctile(window(pad(dur(classes==i),n,@nan),n),25*[-1 0 1]+50);
end

h(end+1) = subplot(sps,1,3);
hold on
eps2=fix0(dur(goodResults));
ylims = [eps2 prctile(dur,99)*head];
standardPlot(@semilogyEF,[.01 .03 .1 .3 1 3 10],true);
correctPlot(dur);
for i=1:length(pTiles)
    pTiles{i}(pTiles{i}==0)=eps2;
    rangePlot(trialNums(i==classes),pTiles{i}([1 end],:),cm(i,:));
end
ylabel('response time (s)')
doLog = false;

    function [x pci] = binoConf(alpha,inds,res)
        [~, pci] = binofit(sum(window(res(inds),n)),n,alpha);
        x=trialNums(inds);
        x=x(~isnan(pad(zeros(1,size(pci,1)),n,@nan)));
    end

alpha=.05;
[perfX perfC] = binoConf(alpha,~(strcmp(results,'quit') | manualRewards),strcmp(results,'correct'));
[biasX biasC] = binoConf(alpha,~ismember(results,{'quit','timedout'})   ,choiceRight              );

h(end+1) = subplot(sps,1,4);
hold on
ylims = [0 1];
standardPlot(@plot,[],[],[],true);
rangePlot(perfX,perfC','r');
rangePlot(biasX,biasC',bw);
plot(trialNums,.5*ones(1,length(trialNums)),bw)
if any(flip)
    plot(trialNums(flip),.5,'b+')
end
if any(rnd)
    plot(trialNums(rnd),.5,'g+')
end
dms = any(~isnan([targetLatency;cueLatency;cueDuration]));
if any(dms)
    plot(trialNums(dms),.5,'+','Color',[1 .5 0]);
end

ylabel('% correct(r) rightward(w)')

xlabel('trial')
linkaxes(h,'x');
uploadFig(gcf,subj,max(trialNums)/10,sps*200);

    function out=interleave(in,p)
        out = cell2mat(cellfun(@(x,i)[x p],in,'UniformOutput',false));
    end

    function out = processTrack(t,i,f,v)
        if ~isempty(t)
            ts = double(i)+(t(1,:)-t(1,1))*f;
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

plotTracks = false;
if plotTracks
    
    slowFact = .1;
    trackFact = 1;
    
    these=1;
    justLast=true;
    if justLast
        try %might not be any sessions yet
            these=sessions(end-1);
        end
    end
    these=these:trialNums(end);
    
    stops = cellfun(@(x,i)processTrack(x,i,slowFact ,true ),slowTrack(these),num2cell(these),'UniformOutput',false);
    resps = cellfun(@(x,i)processTrack(x,i,trackFact,false),    track(these),num2cell(these),'UniformOutput',false);
    
    h=[];
    ylabels = {'stop x','stop y','left x','left y','right x','right y'};
    sps = length(ylabels);
    fig = figure;
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
                xs = cellfun(@(c){cellfun(@(x)x([1 i-j],:),resps(filt(these) & classes(these)==c),'UniformOutput',false) cm(c,:)},num2cell(unique(classes(goodResults))),'UniformOutput',false);
        end
        
        ylims = cell2mat(cellfun(@(x)cell2mat(cellfun(@(y)cell2mat(cellfun(@(f)f(y(2,:)),{@min @max}','UniformOutput',false)),x{1},'UniformOutput',false)),xs,'UniformOutput',false));
        ylims = arrayfun(@(p,i)prctile(ylims(i,:),p),[0 100]+5*[1 -1],1:2);
        xs = cellfun(@(x){interleave(x{1},nan(2,1)) x{2:end}},xs,'UniformOutput',false);
        plot(these,0,'Color',grey);
        hold on
        standardPlot(@plot,[],[],i==2,i==sps);
        
        cellfun(@(x)plot(x{1}(1,:),x{1}(2,:),'Color',x{2}),xs(~cellfun(@(x)isempty(x{1}),xs)));
        
        switch i
            case 1
                title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])
            case 2
                xlabel(sprintf('slow time %gs',1/slowFact));
        end
        
        ylabel(ylabels{i});
    end
    
    xlabel(sprintf('trial (track time %gs)',1/trackFact));
    linkaxes(h,'x');
    xlim(these([1 end]));
    uploadFig(fig,subj,range(these)*10,sps*200,'tracks');
end

    function out = getLims(in)
        out = (range(in(:))+.1)*(head-1)*[-1 1] + cellfun(@(f) f(in(:)),{@min @max}); %+.1 ugly for when in is constant so range is zero
    end

plotSettings = true;
if plotSettings
    fig=figure;
    d=3;
    
    plots = {
        gain         ,'gain'           ;
        stoppingSpeed,'stop speed'     ;
        stoppingTime ,'stop time (s)'  ;
        wallDist'    ,'target distance';
        [cueDuration; targetLatency],'cue dur / targ lat (s)';
        };
    
    n = size(plots,1);
    h = [];
    for i=1:n
        h(i) = subplot(n,1,i);
        hold on
        ylims = getLims(plots{i,1});
        if ~any(isnan(ylims))
            standardPlot(@plot,[],[],i==1,i==n); %(f,ticks,lines,dates,xticks)
            x=plot(trialNums,plots{i,1}');
            arrayfun(@(x,y) set(x,'LineWidth',y),x,(d-1)+(d*(length(x)-1):-d:0)');
        end
        ylabel(plots{i,2})
        if i==1
            title([subj ' -- ' datestr(now,'ddd, mmm dd HH:MM PM')])
        end
    end
    
    xlabel('trial')
    linkaxes(h,'x');
    uploadFig(fig,subj,max(trialNums)/10,n*200,'params');
end
end