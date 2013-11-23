function combineTiffs
dbstop if error

p = mfilename('fullpath');
addpath(fullfile(fileparts(fileparts(fileparts(p))),'bootstrap'))
setupEnvironment;

if ~ispc
    error('win only for now')
end

behaviorPath = '\\lee\Users\nlab\Desktop\ballData';
imagingPath = 'C:\Users\nlab\Desktop\data'; %\\landis (accessing local via network path is slow)
imagingPath = 'E:\widefield data';

%%% my understanding of record formt (cmn)
%%% record format - subject name (which suffices to find behavior data'
%%% followed by one cell for each imaging session
%%% {[trial numbers] ... find this from PermanentTrialRecordStore
%%% [trials within this sesion to use]
%%% [imaging path]
%%% [ imaging filenames]

recs = {
    {'jbw01' {
            {[1     192],[36 172],'9-21-12\jbw01 go to grating run 1','jbw01r1'  }
            {[213   982],[10 670],'9-24-12\jbw01'                    ,'jbw01r1'  } % 54690 (91.15 mins) %timing screws up around 4300th frame/50th trial
            {[983  1463],[ 1 165],'9-25-12\jbw01'                    ,'jbw01run1'} % 51296 (85.4933 mins) %timing screws up early
            {[1464 2205],[20 720],'9-26-12\jbw01'                    ,'jbw01r1'  } % 32136 (53.56 mins) %timing screws up around 4270
        }
    }
    
    {'jbw03' {
            {[1   665],[],'9-24-12\jbw03','jbw03r1'} % 63882 (106.47 mins)
            {[667 962],[],'9-25-12\jbw03','jbw03r1'} % 30610 (51.0167 mins)
        }
    }
    
    {'wg02'  {
            {[1    511],[     ],'9-24-12\wg2','wg2r1' } % 28631 (47.7183 mins)
            {[512  815],[1 270],'9-25-12\wg2','wg2r1' } % 26261 (43.7683 mins)
            {[816 1223],[1 325],'9-26-12\wg2','wg2run'} % 37047 (61.745 mins)
        }
    }
};

imagingPath = 'E:\widefield data';
recs = {
     {'GCam13LN' {     
%             {[2   194],[],'112012\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data   
             {[204 474],[],'112112\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data  
             {[510 577],[],'112212\GCam13LN\r2','GCam13LN'} %originally in landis E:\data  
%             {[579 785],[],'112312\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data  
%     
%             {[786   848],[],'112512\GCam13LN'   ,'GCam13LN'}
%             {[850   983],[],'112512\GCam13LN\r2','GCam13LN'}            
%              {[984  1190],[],'112612\GCam13LN'   ,'GCam13LN'}
%              {[1191 1405],[],'112712\GCam13LN'   ,'GCam13LN'}            
%             {[1406 1652],[],'112812\GCam13LN'   ,'GCam13LN'}
%             {[1664 1874],[],'113012\GCam13LN\r3','GCam13LN'}
%             {[1875 2159],[],'120112\GCam13LN'   ,'GCam13LN'}
%             {[2160 2423],[],'120212\GCam13LN'   ,'GCam13LN'}
%             {[2424 2743],[],'120312\GCam13LN'   ,'GCam13LN'}
%             {[2744 2960],[],'120412\GCam13LN'   ,'GCam13LN'}
         }
     }
    
    {'GCam13TT' {         
%             {[8   257],[],'112012\GCam13TT','GCam13TT'} %originally in landis E:\data  
             {[258 353],[],'112112\GCam13TT','GCam13TT'} %originally in landis E:\data  
              {[354 496],[],'112212\GCam13TT','GCam13TT'} %originally in landis E:\data  
%             {[498 621],[],'112312\GCam13TT','GCam13TT'} %originally in landis E:\data  
%     
%             {[644   855],[],'112512\GCam13TT'   ,'GCam13TT'} 
%              {[858  1085],[],'112612\GCam13TT'   ,'GCam13TT'} 
%              {[1116 1321],[],'112712\GCam13TT\r2','GCam13TT'}
%             {[1322 1710],[],'112812\GCam13TT\'  ,'GCam13TT'}
%             {[1712 1816],[],'113012\GCam13TT\'  ,'GCam13TT'}
%              {[1817 2005],[],'120112\GCam13TT\'  ,'GCam13TT'}
%             {[2007 2276],[],'120212\GCam13TT\'  ,'GCam13TT'}
%             {[2277 2584],[],'120312\GCam13TT\'  ,'GCam13TT'}
%             {[2585 2939],[],'120412\GCam13TT\'  ,'GCam13TT'}
        }
    }    
};

imagingPath = 'D:\Widefield (12-10-12+)';
recs = {
    {'GCam13LN' {      
            {[3314 3766],[],'022213\gcam13ln\gcam13ln_r1\gcam13ln_r1_e','gcam13ln_r1'}    % expanded from pcoraw          
        }
    }
    
    {'GCam13TT' {         
             {[3070 3215],[],'022213\gcam13tt_r1','gcam13tt.r1'}
             {[3216 3566],[],'022213\gcam13tt_r2\gcam13tt_r2g','gcam13tt_r2'}     % expanded from pcoraw   -- should be first to have long reward stim
        }
    }    
};


recs = {
    {'Gcam25RT' {
    {[117 315],[],'043013\Gcam25-RT_behavior'                   ,'Gcam25-RT_behavior_GTS'}
    {[319 523],[],'050313\Gcam25-RT_behavior\Gcam25-RT_behavior','Gcam25-RT_behavior_GTS'}
    }
    }
    
    {'Gcam32LN' {
    {[1   203],[],'043013\Gcam32-LN_behavior','Gcam32_LN_behavior_GTS'}
    %             {[204 419],[],'050313\Gcam32-LN_behavior','Gcam32-LN_behavior_GTS'}       %tight filter
    }
    }
    
    {'Gcam32TT' {
    %            {[1  61 ],[],'043013\Gcam32-TT_behavior'               ,'Gcam32-TT_behavior_GTS'}
   % {[62  274],[],'043013\Gcam32-TT_behavior\','Gcam32-TT_behavior_GTS'}
    {[275 515],[],'050313\Gcam32-TT_behavior\'              ,'Gcam32-TT_behavior_GTS'}
    }
    }
    
%         {'Gcam17RN' {
%                 {[1    95],[],'050113\Gcam17-RN_behavior','Gcam17-RN_behavior_HVV'}
%                 {[102 293],[],'050213\Gcam17-RN_behavior','Gcam17-RN_behavior_HVV'}
%             }
%         }
%     
        {'Gcam20TT' {
                {[1 176],[],'050113\Gcam20-TT_behavior','Gcam20-TT_behavior_HvV'}
            }
        }
    
        {'Gcam21RT' {
              %  {[19  155],[],'050113\Gcam21-RT_behavior','Gcam21-RT_behavior_HvV'} % hmm, last trial too few yellow frames
                {[156 372],[],'050213\Gcam21-RT_behavior','Gcam21-RT_behavior_HVV'}
            }
        }
    
        {'Gcam30LT' {
                {[1   216],[],'050113\Gcam30-LT_behavior','Gcam30-LT_behavior_HVV'}  % really bad performance
                {[217 429],[],'050213\Gcam30-LT_behavior','Gcam30-LT_behavior_HVV'}
            }
        }
    
        {'Gcam33LT' {
                {[1 137],[],'050113\Gcam33-LT_behavior\Gcam33-LT_behavior_HVV','Gcam33-LT_behavior_HVV_2'}
            }
        }
    };


imagingPath = 'C:\data\imaging';
recs = {
    {'gcam51LN' {
    {[36 222],[],'090613 GTS Behavior\G51-LN_r2_behavior_setProtocolGTS_4x4bin_53ms_vertical','G51-LN_r2_behavior_setProtocolGTS_4x4bin_53ms_vertical'}    
    }
    }
    %%% go to stimulus (top=right, bottom=left)
    
    {'g625ln' {
    {[61 237],[],'092013 DOI\G62-5-LN_DOI and behavior\G625_LN_Behavior_GoToBlack_DOI_at_start','G625_LN_Behavior_GoToBlack_DOI_at_start'}
   
    }
    }
    }; %%% black on top = go right, black on bottom = go left

% dirOverview(imagingPath)

%%% apply function biAnalysis to each
cellfun(@(r)cellfun(@(s)f(r{1},s),r{2},'UniformOutput',false),recs,'UniformOutput',false);
    function f(subj,r)
        close all
        rng = sprintf('%d-%d',r{1}(1),r{1}(2));
        biAnalysis(...
            fullfile(behaviorPath,'PermanentTrialRecordStore',subj,['trialRecords_' rng '_*.mat']),...
            fullfile(imagingPath,r{3},r{4}),...
            [subj '.' rng],...
            r{2}...
            );
    end
end

function biAnalysis(bPath,iPath,pre,goodTrials)
fprintf('doing %s\n',bPath)
dirOverview(fileparts(iPath))
%keyboard
if exist(fullfile('C:\Users\nlab\Desktop\analysis',[pre '.sync.png']),'file')
    fprintf('skipping, already done\n')
    return
end

if verLessThan('matlab', '8.1') %2013a
    warning('use 2013a, or else loading tiffs is slow/can''t read bigtiffs (2012b?)')
end

%%% read image data
pr = [iPath '.pcoraw'];
% pr = 'D:\Widefield (12-10-12+)\022213\gcam13ln\gcam13ln_r1\gcam13ln_r1.pcoraw'; %31GB %timestamps screwed up around frame 9600+?
% pr = 'D:\Widefield (12-10-12+)\022213\gcam13tt_r2\gcam13tt_r2.pcoraw'; %12GB %timestamps screwed up after frame ~10k?
doPcoraw = isscalar(dir(pr));
if doPcoraw
    fprintf('imfinfo on pcoraw\n')
    tic
    ids = imfinfo(pr);
    toc
    
    cds = nan(1,length(ids));
    
    sz = cellfun(@(x)unique([ids.(x)]),{'Height','Width'});
    if numel(sz)~=2
        error('bad unique')
    end
    %     sz = cellfun(@(x)t.getTag(x),{'ImageLength' 'ImageWidth'});
else
    warning('pcoraw preferred')
    
    ids = dir([iPath '_*.tif']);
    if isempty(ids)
        keyboard
        dest = fileparts(iPath);
        b = dest;
        [~,b] = strtok(b,filesep);
        [~,b] = strtok(b,filesep);
        src = ['\\landis\data' b];
        fprintf('copying %s to %s (takes forever)\n',src,dest);
        dirOverview(src);
        [status,message,messageid] = copyfile(src,dest,'f'); %f shouldn't be necessary, but i get a read-only error w/o it
        if status~=1
            status
            message
            messageid
            error('copy fail')
        end
        ids = dir([iPath '_*.tif']);
    end
    
    try
        sz = size(imread([iPath '_0001.tif']));
    catch
        sz = size(imread([iPath '_000001.tif']));
        sz = sz(1:2);
    end
end

bds = dir(bPath);

if ~isscalar(bds)
    error('hmmm...')
end

maxGB = 1;

bytesPerPix = 2;
pixPerFrame = maxGB*1000*1000*1000/length(ids)/bytesPerPix;

stampHeight = 20;
sz(1) = sz(1)-stampHeight;
scale = pixPerFrame/prod(sz);
if scale<1
    sz = round(sqrt(scale)*sz);
end

mfn = [iPath '_' sprintf('%d_%d_%d',sz(1),sz(2),length(ids)) '.mat'];
if exist(mfn,'file')
    fprintf('loading preshrunk\n')
    tic
    f = load(mfn);
    toc
    
    data = f.data;
    t = f.t;
    trialRecs = f.trialRecs;
    stamps = f.stamps;
    drops = f.drops;
    
    clear f
else
    fprintf('reading from scratch\n')
    % fprintf('requesting %g GB memory\n',length(ids)*prod(sz)*bytesPerPix/1000/1000/1000)
    
    data = zeros(sz(1),sz(2),length(ids),'uint16');
    stamps = zeros(stampHeight,300,length(ids),'uint16');
    
    if doPcoraw
        warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
        t = Tiff(pr,'r');
    else
        if ~any(iPath=='.')
            [d,base] = fileparts(iPath);
        else
            [d,base,tmp] = fileparts(iPath);
            base = [base tmp];
        end
    end
    tic
    for i=1:length(ids) %something in this loop is leaking
        if rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,length(ids),100*i/length(ids))
        end
        if doPcoraw
            frame = t.read();
            % have to use Tiff object (faster anyway) -- imread dies on bigtiffs at high frame numbers with:
            % Error using rtifc
            % TIFF library error - 'TIFFFetchDirectory:  Sanity check on directory count failed, this is probably not a valid IFD offset.'
            
            if i < length(ids)
                cds(i) = t.currentDirectory; %wraps around as a uint16
                t.nextDirectory();
            end
        else
            fn = sprintf('%s_%04d.tif',base,i);
            if ~ismember(fn,{ids.name})
                fn = sprintf('%s_%06d.tif',base,i);
                if ~ismember(fn,{ids.name})
                    error('hmmm')
                end
            end
            frame = imread(fullfile(d,fn));
        end
        switch ndims(frame)
            case 3 %converting pcoraw to rgb tiff, but r,g,b all slightly different?
                if i==1
                    warning('need to fix: why aren''t r,g,b all same?')
                end
                %frame = frame(:,:,1);
                frame = sum(double(frame),3); %documented to sum rgb anywhere?  only thing that makes timestamps work...
                if any(frame(:)>intmax('uint16'))
                    error('hmmm')
                else
                    frame = uint16(frame);
                end
            case 2
                %pass
            otherwise
                error('hmmm')
        end
        data(:,:,i) = imresize(frame((stampHeight+1):end,:),sz); %is imresize smart about unity?  how do our data depend on method?  (we use default 'bicubic' -- "weighted average of local 4x4" (w/antialiasing) -- we can specify kernel if desired)
        stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
    end
    toc
    
    %     figure
    %     plot(diff(cds))
    
    if doPcoraw
        if false
            t.close(); %on huge pcoraw this crashes matlab!
        end
        warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
    end
    
    [t,drops] = readStamps(stamps);
    
    f = load(fullfile(fileparts(bPath),bds.name));
    trialRecs = f.trialRecords;
    
    fprintf('saving...\n')
    tic
    save(mfn,'data','t','trialRecs','stamps','drops','-v7.3') %7.3 required for >2GB vars
    toc
end

fig = figure;
plot(diff(drops)-1)
xlabel('frame')
numDrops = drops(end)-length(ids);
lab = sprintf('%d dropped frames',numDrops);
title(lab)
saveFig(fig,[pre '.drops'],[0 0 500 200]); % [left, bottom, width, height]

if ~all(drops' == 1:length(ids))
    warning(lab)
end

clear ids

d = diff(t');

frameDur = median(d);

%very ad hoc -- is this right?
%takes care of when imaging starts before behavior
%but why do we get that first image then -- shouldn't be triggered til behavior starts?
%eg, jbw03 667-962 and wg02 1-511 have d(1)~70
if d(1)>1.5*frameDur
    d = d(2:end);
    t = t(2:end);
    data = data(:,:,2:end);
end

[bRecs, ledInds] = getTrigTimes({trialRecs.pco});
if any(cellfun(@isempty,bRecs))
    error('bad recs')
end

if false %this method no good
    boundary = 5*frameDur;
    trials = [1 1+find(d>boundary)];
    
    figure
    subplot(2,1,1)
    bins = linspace(0,2,200);
    n = hist(d,bins);
    n = log(n);
    n(isinf(n)) = 0;
    plot(bins,n)
    hold on
    plot(boundary*ones(1,2),[0 max(n)],'r')
    plot(frameDur*ones(1,2),[0 max(n)],'b')
    title(sprintf('%d (imaging) vs. %d (behavior)',length(trials),length(trialRecs)))
    xlabel('secs')
    set(gca,'YTick',[])
    
    subplot(2,1,2)
    hold on
    arrayfun(@(x)plot(x*ones(1,2),[0 boundary],'b'),trials)
    plot(diff([bRecs{:}]),'r','LineWidth',3)
    plot(d)
    ylim([0 boundary])
end


% align the times:  apparently some of the requested exposures recorded in
% the trial records don't wind up getting actually saved as tiffs, so d is
% missing some of what bRecs has...

tol = .15*frameDur; %was .05, but 112612\GCam13TT 858-1085 needs more

reqs = diff([bRecs{:}]);
fixed = nan(1,length(reqs)+1);

bad = false;
current = 1;
for i=1:length(d)
    if current <= length(reqs)
        fixer = 0;
        errRec = [];
        while i>1 && abs(d(i)-sum(reqs(current+(0:fixer)))) > tol
            errRec(end+1) = d(i)-sum(reqs(current+(0:fixer)));
            
            fixer = fixer + 1;
            if current + fixer > length(reqs) || errRec(end) < -tol
                warning('bad')
                
                figure
                plot([errRec' tol*repmat([1 -1],length(errRec),1)])
                
                bad = true;
                break
            end
        end
        if bad
            break
        end
        current = current + fixer;
        fixed(current) = d(i);
        current = current + 1;
    end
end


fig = figure;
hold on
v = .01;

d = {};
bFrames = {};
frameLeds = {};
for i = 1:length(bRecs)
    reqs = diff(bRecs{i});
    plot(reqs+v*i,'r','LineWidth',3);
    
    d{i} = fixed(length([bRecs{1:i-1}]) + (1:length(bRecs{i})));
    
    plot(d{i}(1:end-1)+v*i)
    
    if ~isempty(find([abs(reqs-d{i}(1:end-1))>tol false] & ~isnan(d{i}) & ~isnan([nan d{i}(1:end-1)]),1,'first'))
        error('bad')
    end
    
    bFrames{i} =   bRecs{i}(~isnan(d{i}));
    frameLeds{i} = ledInds{i}(~isnan(d{i}));
end
ylim(frameDur + [0 v*1.05*length(bRecs)]);
xlim([0 max([cellfun(@length,bRecs) cellfun(@length,d)])]);
saveFig(fig,[pre '.align'],[0 0 1600 800]); % [left, bottom, width, height]

if bad
    keyboard
end

if length([bFrames{:}]) > size(data,3) %we probably miss the last one
    error('bad')
end

figure
tmp = [bFrames{:}];
len = min(cellfun(@length,{tmp t}));
plot(diff(tmp(1:len))-diff(t(1:len)')) %no one should be off  by more than .5ms (3 for first), but we get a couple dozen per trial, something about correction/alignment above is wrong?
hold on
plot(find(~ismember([bRecs{:}],tmp)),0,'o','Color',[1 .5 0]) %not quite right -- lines them up by bRecs rather than the smaller bFrames, but shows that the errors are always by camera drops

s = [trialRecs.stimDetails];
f = find(arrayfun(@(x)isempty(x.target),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad targets')
end
targ = sign([s.target]);

% trialRecs.stimDetails should have phase/orientation, (orientedGabors saves it)
% but trail (the ball stimManager) doesn't save details from the stimManager it uses...

s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct];

starts = cell2mat(cellfun(@phaseStarts,{trialRecs.phaseRecords}','UniformOutput',false))';
onsets = starts(2,:);

clear trialRecs

f = find(any(isnan(starts)),1,'first');
if ~isempty(f)
    if f~=length(onsets)
        error('bad nans')
    else
        onsets = onsets(1:end-1);
    end
end

if isempty(goodTrials) || true %heh
    trials = [1 length(onsets)];
else
    trials = goodTrials;
end

trials = trials(1):trials(2);

stoppedWithin = 4; %2
respondedWithin = [.3 1]; %[.5 2]; %1
onlyCorrect = true;
noAfterErrors = true;
worstFactor = .7; %.1  %%%???

afterErrors = [false ~correct(1:end-1)];

misses = cellfun(@setdiff,bRecs,bFrames,'UniformOutput',false);

if length([misses{:}]) ~= 1+numDrops %we gurantee one drop at the end? -- verify this...
    error('drop calculation error')
    %    warning('drop calculation error')
    % Gcam21RT [19 155] 050113 has lots of drops at the end that screw this up -- switch to warning seemed ok but i didn't check carefully
end

worsts = cellfun(@(x)max(diff(x)),bFrames,'UniformOutput',false);
d = diff(cellfun(@isempty,worsts));
f = find(d,1);
if ~isempty(f) && any(d(f+1:end)~=0)
    error('bad bFrames')
end
worsts = cell2mat(worsts);

trials = trials(trials<=length(worsts));

d = diff(starts);
trials = trials( ...
    d(1,trials)<=stoppedWithin              & ...
    d(2,trials)<=respondedWithin(2)         & ...
    d(2,trials)>=respondedWithin(1)         & ...
    (~onlyCorrect | correct(trials))        & ...
    (~noAfterErrors | ~afterErrors(trials)) & ...
    cellfun(@isempty,misses(trials))        & ...
    ...% targ(trials)>0                          & ...
    worsts(trials)<=frameDur*(1+worstFactor)  ...
    );

c = getUniformSpectrum(normalize(onsets));

pts = [-.8 respondedWithin(1)]; %-1.5*frameDur]; %last frame suspect -- if reinforcement phase ends before exposure does, probably turns led off prematurely
pts = linspace(pts(1),pts(2),1+round(diff(pts)/frameDur));

fig = figure;
hold on
for i = 1:length(trials)
    if any(pts<=bFrames{trials(i)}(end)-onsets(trials(i)))
        plot(pts(pts<=bFrames{trials(i)}(end)-onsets(trials(i))),trials(i),'y+')
    end
end

for i=1:length(onsets)
    if i<=length(bRecs)
        plot(bRecs{i}(ledInds{i} == 1)-onsets(i),i,'g.','MarkerSize',1)
        plot(bRecs{i}(ledInds{i} == 2)-onsets(i),i,'b.','MarkerSize',1)
        if ~isempty(misses{i})
            plot(misses{i}-onsets(i),i,'o','Color',[1 .5 0])
        end
    end
    
    s = starts(:,i)-onsets(i);
    plot(s(1),i,'+','Color',c(i,:))
    
    if targ(i)>0
        cm = 'b';
    else
        cm = 'm';
    end
    plot(s(2),i,[cm '+'])
    
    if correct(i)
        cm = 'g';
    else
        cm = 'r';
    end
    plot(s(3),i,[cm '+'])
end
xlims = [-2 3];
xlim(xlims)
ylabel('trial')
xlabel('secs since discrim onset')
saveFig(fig,[pre '.sync'],[0 0 diff(xlims)*200 length(onsets)*5]); % [left, bottom, width, height]

bFrames   =   bFrames(  1:length(correct));
frameLeds = frameLeds(  1:length(correct));
misses    =    misses(  1:length(correct));
targ      =      targ(  1:length(correct));
starts    =    starts(:,1:length(correct));

%last frame suspect -- if reinforcement phase ends before exposure does, turns led off prematurely
if true
    bad = cumsum(cellfun(@length,bFrames));
    
    bFrames   = cellfun(@(x)x(1:end-1),  bFrames,'UniformOutput',false);
    frameLeds = cellfun(@(x)x(1:end-1),frameLeds,'UniformOutput',false);
    
    data(:,:,bad) = [];
    t(bad) = [];
    
    bad = length([bFrames{:}]);
    data(:,:,bad+1:end) = [];
    t(       bad+1:end) = [];
    
    misses; %ok?
    
    if ~isempty(trials)
        pts(pts > min(cellfun(@(x,y)x(end)-y,bFrames(trials),num2cell(onsets(trials))))) = [];
    end
end

leds = {'green' 'blue'};

fprintf('clustering leds...\n')
tic
[ledC, fig] = ledCluster(data);
toc
saveFig(fig,[pre '.led'],[0 0 1000 1000]); % [left, bottom, width, height]

flatLEDs = [frameLeds{:}];
problem = flatLEDs ~= ledC;
if any(problem)
    fig = figure;
    plot(find(problem),ledC(problem),'cx')
    hold on
    plot(find(problem),flatLEDs(problem),'rx')
    title('led problems')
    legend({'cluster','record'})
    xlabel('frame')
    set(gca,'YTick',1:length(leds))
    set(gca,'YTickLabel',leds)
    saveFig(fig,[pre '.led.problems'],[0 0 1000 300]); % [left, bottom, width, height]
end


for ind = 1:length(leds)
  lab=leds{ind}; 
    thisBFrames = cellfun(@(x,y)x(y == ind),bFrames,frameLeds,'UniformOutput',false);
    these = flatLEDs == ind;
    thisData = data(:,:,these);
    thisT = t(these);
    [im{ind} dfof{ind}] = widefieldAnalysis(trials,pts,onsets,thisData,thisT,thisBFrames,[pre '.' lab],c,targ,stoppedWithin,respondedWithin,misses,starts,correct);
end

bg = dfof{2}-dfof{1};
bg_med = squeeze(nanmedianMW(bg));
figure
for tpts = 1:size(bg_med,1)
    subplot(3,4,tpts)
    imagesc(squeeze(bg_med(tpts,:,:)),[-0.02 0.02]);
    axis off
end
title([pre 'bg dfof'])
keyboard

if true && ~isempty(trials)
    i=1;
    frames = length([bFrames{1:trials(i)-1}]) + (1:length(bFrames{trials(i)}));
    ledInds = [frameLeds{:}];
    these = double(squeeze(data(:,:,frames)));
    lims = prctile(these(:),[1 99]); % cellfun(@(f) f(data(:)),{@min @max});
    figure
    k = ceil(length(frames)/4);
    for i=1:length(frames)
        subplot(k,4,i)
        imagesc(double(squeeze(data(:,:,frames(i)))));%,lims)
        title(leds{ledInds(frames(i))})
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis equal
        axis tight
    end
    
    
    inds = frames(ledInds(frames) == 2);
    theseT = t(inds);
    these = double(squeeze(data(:,:,inds)));
    m = nanmedianMW(these,3);
    m = repmat(m,[1 1 size(these,3)]);
    dfof = (these-m)./m;
    figure
    k = ceil(sqrt(size(dfof,3)));
    for i=1:size(dfof,3)
        subplot(k,k,i)
        
        imagesc(dfof(:,:,i));
        
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis equal
        axis tight
        
        if i==1
            title('dfof')
        end
    end
    
    figure
    for i=1:size(these,3)
        subplot(k,k,i)
        
        imagesc(these(:,:,i),[0 2^16]);
        
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis equal
        axis tight
        
        if i==1
            title('raw (same scale)')
        end
    end
    
    figure
    d = diff(these,[],3);
    lims = prctile(d(:),[1 99]);
    for i=1:size(d,3)
        subplot(k,k,i)
        
        imagesc(d(:,:,i),lims);
        
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis equal
        axis tight
        
        if i==1
            title('diff (same scale)')
        end
    end
    
    figure
    traces = reshape(these,[size(these,1)*size(these,2) size(these,3)]);
    plot(theseT-theseT(1),traces)
    
    figure
    plot(theseT-theseT(1),traces(rand(size(traces,1),1)>.99,:))
    
    %keyboard
end
end

function [im dfof]= widefieldAnalysis(trials,pts,onsets,data,t,bFrames,pre,c,targ,stoppedWithin,respondedWithin,misses,starts,correct)
%%% my understanding of parameters (cmn)
%%% trials = trial numbers to use, pts = timepts relatvie to stim onset,
%%% onsets = onset time for stim, data = all image frames, t= frametime
%%% bframes=frametimes for each trial, pre = file prefix, c= colormap,
%%% targ = target side(-1 1),

ptLs = numNice(pts,.01);
pts = repmat(pts,length(trials),1)+repmat(onsets(trials)',1,length(pts));
im = nan([size(pts,1) size(pts,2) size(data,1) size(data,2)]); %trials * t * h * w

b = whos('im');
fprintf('target is %gGB\n',b.bytes/1000/1000/1000)

figure
hold on
plot(t-t(1),'r','LineWidth',3)
bs = [bFrames{:}];
plot(bs-bs(1))

fig = figure;
h = [];
numPix = 50;
pix = reshape(data,[size(data,1)*size(data,2) size(data,3)]);
[~, ord] = sort(rand(1,size(pix,1)));
h(end+1) = subplot(2,1,1);
hold on
alpha = .1;
ms = [misses{:}];
behaviorKey;

    function behaviorKey
        arrayfun(@plotPhases,1:length(bFrames))
        arrayfun(@plotMisses,ms)
    end

    function plotPhases(tNum)
        fillPhase(starts(1,tNum),starts(2,tNum),[1 1 1]);
        fillPhase(starts(2,tNum),starts(3,tNum),[1 1 0]);
        if correct(tNum)
            tc = [0 1 0];
        else
            tc = [1 0 0];
        end
        fillPhase(starts(3,tNum),bFrames{tNum}(end),tc);
    end

    function fillPhase(start,stop,col)
        if stop>start %drops may cause bFrames to not contain frames after a phase start
            fill(([start start stop stop]-bs(1))/60,2^16*[0 1 1 0],col,'FaceAlpha',alpha)
        end
    end

    function plotMisses(in)
        plot((in-bs(1))*ones(1,2)/60,[0 2^16],'Color',[1 .5 0])
        % can't have alpha on line, and dominates otherwise
        % fillPhase(in,in+.05,[1 .5 0]);
    end

% plot((bs-bs(1))/60,pix(ord(1:numPix),:)) % this line dies sometimes on 2011b?
% xlabel('mins')
% ylabel('pixel values')
% title('raw')

h(end+1) = subplot(2,1,2);
hold on
behaviorKey;
title('after drops and error stim removed') %both cause spikes
bads = false(size(bs));
for i=1:length(ms)
    bads(find((bs-ms(i))>0,1,'first')) = true;
end
for i=1:length(correct)
    if ~correct(i)
        bads(bs >= starts(3,i) & bs <= bFrames{i}(end)) = true;
    end
end

pix = double(pix(ord(1:numPix),:));
pix(:,bads) = nan;
plot((bs-bs(1))/60,pix)
ylim([0 max(pix(:))])

linkaxes(h,'x');

if false
    subplot(3,1,2)
    title('fit')
    
    subplot(3,1,3)
    title('detrended + scaled')
    saveFig(fig,[pre '.detrend'],[0 0 500 1000]); % [left, bottom, width, height]
else
    saveFig(fig,[pre '.detrend'],[0 0 2000 500]); % [left, bottom, width, height]
end

fprintf('permuting...\n')
tic
data = permute(data,[3 1 2]); %possible oom
toc

fig = figure;
bins = linspace(0,double(intmax('uint16')),1000);
for i=1:length(onsets)
    semilogy(bins,hist(reshape(double(data(i,:,:)),[1 size(data,2)*size(data,3)]),bins),'Color',c(i,:))
    hold on %kills log axis if issued earlier
end
xlim([0 max(bins)])
title('pixel values')

x = .92;
h = .8;
% [left, bottom, width, height]
a = axes('Position',[x (1-h)/2 (1-x)/2 h],'Units','normalized');

hold on
for i=1:length(onsets)
    plot([-1 1],(onsets(i)*ones(1,2)-onsets(1))/60,'Color',c(i,:))
end
title('mins')
ylim([0 (onsets(end)-onsets(1))/60])
set(a,'XTickLabel',[])
set(a,'Box','off')
set(a,'YAxisLocation','right')

saveFig(fig,[pre '.pix'],[0 0 500 500]); % [left, bottom, width, height]

fprintf('interpolating...\n')
tic
for i=1:length(trials)
    frames = length([bFrames{1:trials(i)-1}]) + (1:length(bFrames{trials(i)}));
    if ~isempty(frames)
        im(i,:,:,:) = interp1(bFrames{trials(i)},double(data(frames,:,:)),pts(i,:));
    elseif i~=length(trials)
        error('huh?')
    end
    fprintf('%g%% done\n',100*i/length(trials));
end
toc

if ~isempty(trials)
    % clear data
    
    %need nanmean from fullfile(matlabroot,'toolbox','stats','stats')
    %but \ratrix\analysis\eflister\phys\new\helpers\ is shadowing it...
    
    show(nanmedianMW(im),ptLs,[pre '.all trials (raw)'],[50 99],@cb);
    show(nanmedianMW(im(targ(trials)>0,:,:,:)) - nanmedianMW(im(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (raw)'],[1 99],@cb);
    
    m = squeeze(nanmedianMW(squeeze(nanmedianMW(im)))); %does this order matter?
    m = permute(repmat(m,[1 1 size(im,1) size(im,2)]),[3 4 1 2]);
    dfof = (im-m)./m;
    

    
    clear m
    %clear im
    
    show(nanmedianMW(dfof),ptLs,[pre '.all trials (dF/F)'],[1 99],@cb);
    show(nanmedianMW(dfof(targ(trials)>0,:,:,:)) - nanmedianMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (dF/F)'],[1 99],@cb);
    
        for tr = 1:size(im,1);
        baseline = squeeze(nanmedianMW(im(tr,ptLs<0,:,:),2));
        for fr = 1:size(im,2)
            dfof(tr,fr,:,:) = (squeeze(im(tr,fr,:,:))-baseline)./baseline;
        end
        end
    
            show(nanmedianMW(dfof),ptLs,[pre '.all trials baseline(dF/F)'],[1 99],@cb);
    show(nanmedianMW(dfof(targ(trials)>0,:,:,:)) - nanmedianMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right baseline(dF/F)'],[1 99],@cb);
    
    
%     for i = 1:length(trials)
%         figure
%         for a=1:size(im,2)
%             subplot(3,4,a)
%             imagesc(squeeze(dfof(i,a,:,:)),[-0.02 0.02])
%         end
%     end
%     
%     keyboard
    
end

    function cb(in)
        figure
        
        xb = [max(ptLs(1),-stoppedWithin) min(ptLs(end),respondedWithin(1))];
        
        n = 5;
        subplot(n,1,1)
        plotPix(1:length(onsets),'all');
        
        subplot(n,1,2)
        plotPix(trials,'good',true);
        
        subplot(n,1,3)
        al = plotPix(trials(targ(trials)>0),'good lefts',true); %haven't checkec parity of targ
        
        subplot(n,1,4)
        ar = plotPix(trials(targ(trials)<0),'good rights',true); %haven't checkec parity of targ
        
        subplot(n,1,5)
        hold on
        plot(ptLs,[ar-nanmedianMW(ar,2); al-nanmedianMW(ar,2)]','w','LineWidth',2)
        plot(ptLs,al-ar,'r','LineWidth',2)
        plot(ptLs,zeros(1,length(ptLs)),'Color',.5*ones(1,3),'LineWidth',2)
        xlim(xb)
        
        xlabel('seconds since discrim onset')
        
        function avg = plotPix(which,lab,doAvg)
            hold on
            arrayfun(@(i)plot(bFrames{i}-onsets(i),data(length([bFrames{1:i-1}])+(1:length(bFrames{i})),in(1,2),in(1,1)),'Color',c(i,:)),which);
            xlim(xb)
            
            if exist('doAvg','var') && doAvg
                avg = nanmedianMW(im(ismember(trials,which),:,in(1,2),in(1,1)));
                plot(ptLs,avg,'w','LineWidth',2)
            end
            
            title(lab)
        end
    end
end

function in = normalize(in)
in = in-min(in);
in = in/max(in);
end

function saveFig(f,fn,pos)
targ = 'C:\Users\nlab\Desktop\analysis';
[status,message,messageid] = mkdir(targ);
if status~=1
    error('bad mkdir')
end

set(f,'PaperPositionMode','auto'); %causes print/saveas to respect figure size
set(f,'InvertHardCopy','off'); %preserves black background when colordef black
set(f,'Position',pos) % [left, bottom, width, height]
saveas(f,fullfile(targ,[fn '.png']));

if false
    dpi=300;
    latest = [fn '.' num2str(dpi) '.' sfx];
    % "When you print to a file, the file name must have fewer than 128 characters, including path name."
    % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/print.html#f30-534567
    print(f,'-dpng',['-r' num2str(dpi)],'-opengl',latest); %opengl for transparency -- probably unnecessary cuz seems to be automatically set when needed
end

if isempty(strfind(fn,'trials')) % these take up half a gig each
    saveas(f,fullfile(targ,[fn '.fig']));
end
end

function out = numNice(in,t)
out = round(in/t)*t;
end

function show(m,pts,s,c,cb)
m = permute(m,[3 4 2 1]);
lims = prctile(m(:),c);
if ~any(isnan(lims))
    d = ceil(sqrt(size(m,3)));
    fig = figure;
    for i=1:size(m,3)
        subplot(ceil(size(m,3)/d),d,i)
        x = imagesc(m(:,:,i),lims);
        
        set(x,'ButtonDownFcn',@(x,y)cb(round(get(get(x,'Parent'),'CurrentPoint'))))
        
        xlabel(['t = ' num2str(pts(i)) ' s'])
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        axis equal
        axis tight
    end
    %colormap
    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Visible','off','Units','normalized'); %'Box','off','clipping','off'
    text(0.5, .98, ['\bf ' s], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
    
    s = s(~ismember(s,'|\/<>*?":'));
    saveFig(fig,s,[0 0 1920 1200]); % [left, bottom, width, height]
    
    m(m<lims(1))=lims(1);
    m(m>lims(2))=lims(2);
    m = (m-lims(1))./diff(lims);
    writeAVI(m,fullfile('C:\Users\nlab\Desktop\analysis',s));%,fps)
else
    fprintf('bailing on %s, tight trial filter?\n',s)
    keyboard
end
end

function out = phaseStarts(rec)
try
    r = [rec.responseDetails];
    out = [r.startTime];
catch %only some have totalFrames?  why?
    for i=1:length(rec)
        s =  rec(i).responseDetails.startTime;
        if isempty(s)
            s = nan;
        end
        out(i) = s;
    end
end

% rec.dynamicDetails %contains tracks

%almost same as phaseLabel - just has 'reinforcement' instead of 'reinforced'
labels = {rec.phaseType};
expected = {'pre-request', 'discrim', 'reinforced'};
goods = cellfun(@strcmp,labels,expected);
if ~all(goods)
    e = cellfun(@isempty,labels);
    f = find(e,1,'first');
    if all(e(f:end))
        if length(out)>=f
            if all(isnan(out(f:end)))
                out = out(1:f-1);
            else
                error('bad')
            end
        end
        out = [out nan(1,length(labels)-f+1)];
    else
        rec.phaseType
        error('bad phases')
    end
end

if length(out)~=length(expected)
    error('bad')
end
end

function [a,b] = getTrigTimes(pcos)
out = cellfun(@check,cellfun(@get,pcos,'UniformOutput',false),'UniformOutput',false);

[a, b] = cellfun(@split,out,'UniformOutput',false);

    function [a,b]=split(in)
        a = in(1,:);
        b = in(2,:);
    end

    function out=check(in)
        %[timeWanted busySpins timeTrig ackSpins timeAck ledInd]' x n
        want = [3 6];
        spins = in([2 4],:);
        
        if ~any(isnan(spins(:)))
            out = in(want,:);
        else
            ind = find(any(diff(isnan(spins),[],2)));
            if isscalar(ind) && ~any(any(isnan(spins(:,1:ind)))) && all(all(isnan(spins(:,ind+1:end))))
                out = in(want,1:ind);
            else
                error('bad spins')
            end
        end
    end
end