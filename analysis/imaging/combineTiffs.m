function data = combineTiffs
dbstop if error

addpath('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;

if ~ispc
    error('win only for now')
end

behaviorPath = 'C:\Users\nlab\Desktop\jbw01\ballData';
imagingPath = 'C:\Users\nlab\Desktop\jbw01\';

% {{subj,{{trials,imDir,imBase}
%         {trials,imDir,imBase}
%         {trials,imDir,imBase}}},
%  {subj,{...}},
%  {subj,{...}}};

% \\landis\Users\nlab\Desktop\data\9-21-12\jbw01 go to grating run 1\
recs = {{'jbw01',{{[1 192],'jbw01 go to grating run 1','jbw01r1'}}}};

%%%%%%%%%%%%%%%%%%%%% new way (\\landis\Users\nlab\Desktop\data\)
if false
date = '9-24-12';
recs = {{'jbw01',{{[213 982],'.','jbw01r1'}}}}; % 54690 (91.15 mins)
% recs = {{'jbw03',{{[1 665]  ,'.','jbw03r1'}}}}; % 63882 (106.47 mins)
% recs = {{'wg2'  ,{{[1 511]  ,'.','wg2r1'  }}}}; % 28631 (47.7183 mins)
% 
% date = '9-25-12';
% recs = {{'jbw01',{{[983 1463],'.','jbw01run1'}}}}; % 51296 (85.4933 mins)
% recs = {{'jbw03',{{[667 962] ,'.','jbw03r1'  }}}}; % 30610 (51.0167 mins)
% recs = {{'wg2'  ,{{[512 815] ,'.','wg2r1'    }}}}; % 26261 (43.7683 mins)
% 
% date = '9-26-12';
% recs = {{'jbw01',{{[1464 2205],'.','jbw01r1'}}}}; % 32136 (53.56 mins)
% recs = {{'wg2'  ,{{[816 1223] ,'.','wg2run' }}}}; % 37047 (61.745 mins)

behaviorPath = '\\lee\Users\nlab\Desktop\ballData';
imagingPath = fullfile('C:\Users\nlab\Desktop\data',date,recs{1}{1});
end

cellfun(@(x)cellfun(@(y)f(x{1},y),x{2},'UniformOutput',false),recs,'UniformOutput',false);
    function f(x,y)
        rng = sprintf('%d-%d',y{1}(1),y{1}(2));
        biAnalysis(...
            fullfile(behaviorPath,'PermanentTrialRecordStore',x,['trialRecords_' rng '_*.mat']),...
            fullfile(imagingPath,y{2},y{3}),...
            [x '.' rng]...
            );
    end
end

function biAnalysis(bPath,iPath,pre)
ids = dir([iPath '_*.tif']);
bds = dir(bPath);

if ~isscalar(bds)
    error('hmmm...')
end

maxGB = 4;

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
bRecs = getTrigTimes({trialRecs.pco});
if any(cellfun(@isempty,bRecs))
    error('bad recs')
end

hold on
arrayfun(@(x)plot(x*ones(1,2),[0 boundary],'b'),trials)
plot(diff([bRecs{:}]),'r','LineWidth',3)
plot(d)
ylim([0 boundary])

s = [trialRecs.stimDetails];
targ = sign([s.target]);

% trialRecs.stimDetails should have phase/orientation, (orientedGabors saves it)
% but trail (the ball stimManager) doesn't save details from the stimManager it uses...

s = [trialRecs.trialDetails];
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

trials = [36 172];

fig = figure;
hold on
arrayfun(@(x)plot(x*ones(1,1+diff(trials)),trials(1):trials(end),'o','Color',[.5*ones(1,2) 0]),pts); %'y' ,'LineWidth',3 [.75 .25 0]
for i=1:length(onsets)
    if i<=length(bRecs)
        plot(bRecs{i}-onsets(i),i,'w+')
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

trials = trials(1):trials(2);
pts = repmat(pts,length(trials),1)+repmat(onsets(trials)',1,length(pts));
im = nan([size(pts,1) size(pts,2) size(data,1) size(data,2)]); %trials * t * h * w
fprintf('interpolating...\n')
tic
for i=1:length(trials)
    frames = length([bRecs{1:trials(i)-1}]) + (1:length(bRecs{trials(i)}));
    im(i,:,:,:) = interp1(bRecs{trials(i)},double(permute(data(:,:,frames),[3 1 2])),pts(i,:));
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

keyboard
end

function saveFig(f,fn,pos)
set(f,'PaperPositionMode','auto'); %causes print/saveas to respect figure size
set(f,'InvertHardCopy','off'); %preserves black background when colordef black
set(f,'Position',pos) % [left, bottom, width, height]
saveas(f,fullfile('C:\Users\nlab\Desktop\analysis',[fn '.png']));

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
writeAVI(m,fullfile('C:\Users\nlab\Desktop\analysis',[s '.avi']));%,fps)
end

function out = phaseStarts(rec)
r = [rec.responseDetails];
out = [r.startTime];
% rec.dynamicDetails %contains tracks

%almost same as phaseLabel - just has 'reinforcement' instead of 'reinforced'
labels = {rec.phaseType};
goods = cellfun(@strcmp,labels,{'pre-request', 'discrim', 'reinforced'});
if ~all(goods)
    e = cellfun(@isempty,labels);
    f = find(e,1,'first');
    if all(e(f:end))
        out = [out nan(1,length(labels)-f+1)];
    else
        rec.phaseType
        error('bad phases')
    end
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