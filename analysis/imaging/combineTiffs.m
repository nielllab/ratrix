function combineTiffs
dbstop if error

addpath('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;

if ~ispc
    error('win only for now')
end

behaviorPath = '\\lee\Users\nlab\Desktop\ballData';
imagingPath = 'C:\Users\nlab\Desktop\data'; %\\landis (accessing local via network path is slow)
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
    
    {'wg02' {
            {[1    511],[     ],'9-24-12\wg2','wg2r1' } % 28631 (47.7183 mins)
            {[512  815],[1 270],'9-25-12\wg2','wg2r1' } % 26261 (43.7683 mins)
            {[816 1223],[1 325],'9-26-12\wg2','wg2run'} % 37047 (61.745 mins)
        }
    }
};

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

ids = dir([iPath '_*.tif']);
bds = dir(bPath);

if ~isscalar(bds)
    error('hmmm...')
end

maxGB = 1;

bytesPerPix = 2;
pixPerFrame = maxGB*1000*1000*1000/length(ids)/bytesPerPix;
sz = size(imread([iPath '_0001.tif']));
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
    
    clear f
else
    fprintf('reading from scratch\n')
    % fprintf('requesting %g GB memory\n',length(ids)*prod(sz)*bytesPerPix/1000/1000/1000)
    
    data = zeros(sz(1),sz(2),length(ids),'uint16');
    stamps = zeros(stampHeight,300,length(ids),'uint16');
    
    [d,base] = fileparts(iPath);
    tic
    for i=1:length(ids) %something in this loop is leaking
        if rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,length(ids),100*i/length(ids))
        end
        fn = sprintf('%s_%04d.tif',base,i);
        if ~ismember(fn,{ids.name})
            error('hmmm')
        end
        frame = imread(fullfile(d,fn));
        data(:,:,i) = imresize(frame((stampHeight+1):end,:),sz); %is imresize smart about unity?
        stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
    end
    toc
    
    t = readStamps(stamps);
    
    f = load(fullfile(fileparts(bPath),bds.name));
    trialRecs = f.trialRecords;
    
    fprintf('saving...\n')
    tic
    save(mfn,'data','t','trialRecs','-v7.3') %7.3 required for >2GB vars
    toc
    
    clear stamps
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

bRecs = getTrigTimes({trialRecs.pco});
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

tol = .05*frameDur;

reqs = diff([bRecs{:}]);
fixed = nan(1,length(reqs)+1);

current = 1;
for i=1:length(d)
    if current <= length(reqs)
        fixer = 0;
        while i>1 && abs(d(i)-sum(reqs(current+(0:fixer)))) > tol
            fixer = fixer + 1;
            if current + fixer > length(reqs)
                error('bad')
            end
        end
        current = current + fixer;
        fixed(current) = d(i);
        current = current + 1;
    end
end


figure
hold on
v = .01;

d = {};
bFrames = {};
for i = 1:length(bRecs)
    reqs = diff(bRecs{i});
    plot(reqs+v*i,'r','LineWidth',3);
    
    d{i} = fixed(length([bRecs{1:i-1}]) + (1:length(bRecs{i})));
    
    plot(d{i}(1:end-1)+v*i)
    
    if ~isempty(find([abs(reqs-d{i}(1:end-1))>tol false] & ~isnan(d{i}) & ~isnan([nan d{i}(1:end-1)]),1,'first'))
        error('bad')
    end
    
    bFrames{i} = bRecs{i}(~isnan(d{i}));
end
% ylim([frameDur v*200])
% xlim([0 200])

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

pts = [-.8 2];
pts = linspace(pts(1),pts(2),1+round(diff(pts)/frameDur));
ptLs = numNice(pts,.01);

if isempty(goodTrials) || true %heh
    trials = [1 length(onsets)];
else
    trials = goodTrials;
end

trials = trials(1):trials(2);

stoppedWithin = 5; %2
respondedWithin = 3; %1
onlyCorrect = true;
noAfterErrors = true;
worstFactor = 1; %.1

afterErrors = [false ~correct(1:end-1)];

misses = cellfun(@setdiff,bRecs,bFrames,'UniformOutput',false);
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
    d(2,trials)<=respondedWithin            & ... 
    (~onlyCorrect | correct(trials))        & ...
    (~noAfterErrors | ~afterErrors(trials)) & ...
    cellfun(@isempty,misses(trials))        & ...
    worsts(trials)<=frameDur*(1+worstFactor)  ...
    );

fig = figure;
hold on
for i = 1:length(trials)
plot(pts(pts<=bFrames{trials(i)}(end)-onsets(trials(i))),trials(i),'y+')
end

for i=1:length(onsets)
    if i<=length(bRecs)
        plot(bRecs{i}-onsets(i),i,'w.','MarkerSize',1)
        if ~isempty(misses{i})
            plot(misses{i}-onsets(i),i,'o','Color',[1 .5 0])
        end
    end
    
    s = starts(:,i)-onsets(i);
    plot(s(1),i,'c+')
    
    if targ(i)>0
        c = 'b';
    else
        c = 'm';
    end
    plot(s(2),i,[c '+'])
    
    if correct(i)
        c = 'g';
    else
        c = 'r';
    end
    plot(s(3),i,[c '+'])
end
xlims = [-2 3];
xlim(xlims)
ylabel('trial')
xlabel('secs since discrim onset')
saveFig(fig,[pre '.sync'],[0 0 diff(xlims)*200 length(onsets)*5]); % [left, bottom, width, height]

pts = repmat(pts,length(trials),1)+repmat(onsets(trials)',1,length(pts));
im = nan([size(pts,1) size(pts,2) size(data,1) size(data,2)]); %trials * t * h * w

b = whos('im');
fprintf('target is %gGB\n',b.bytes/1000/1000/1000)

fprintf('permuting...\n')
tic
data = permute(data,[3 1 2]); %possible oom
toc

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

clear data

%need nanmean from fullfile(matlabroot,'toolbox','stats','stats')
%but \ratrix\analysis\eflister\phys\new\helpers\ is shadowing it...

show(nanmeanMW(im),ptLs,[pre '.all trials (raw)'],[50 99]);
show(nanmeanMW(im(targ(trials)>0,:,:,:)) - nanmeanMW(im(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (raw)'],[1 99]);

m = squeeze(nanmeanMW(squeeze(nanmeanMW(im)))); %does this order matter?
m = permute(repmat(m,[1 1 size(im,1) size(im,2)]),[3 4 1 2]);
dfof = (im-m)./m;

clear m im

show(nanmeanMW(dfof),ptLs,[pre '.all trials (dF/F)'],[1 99]);
show(nanmeanMW(dfof(targ(trials)>0,:,:,:)) - nanmeanMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (dF/F)'],[1 99]);
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
end

function out = numNice(in,t)
out = round(in/t)*t;
end

function show(m,pts,s,c)
m = permute(m,[3 4 2 1]);
lims = prctile(m(:),c);
d = ceil(sqrt(size(m,3)));
fig = figure;
for i=1:size(m,3)
    subplot(ceil(size(m,3)/d),d,i)
    imagesc(m(:,:,i),lims)
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

function out = getTrigTimes(pcos)
out = cellfun(@check,cellfun(@get,pcos,'UniformOutput',false),'UniformOutput',false);

    function out=check(in)
        %[timeWanted busySpins timeTrig ackSpins timeAck]' x n
        spins = in([2 4],:);
        
        if  ~any(isnan(spins(:)))
            out = in(3,:);
        else
            ind = find(any(diff(isnan(spins),[],2)));
            if isscalar(ind) && ~any(any(isnan(spins(:,1:ind)))) && all(all(isnan(spins(:,ind+1:end))))
                out = in(3,1:ind);
            else
                error('bad spins')
            end
        end
    end
end