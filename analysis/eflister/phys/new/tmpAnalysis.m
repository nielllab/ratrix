function tmpAnalysis(fileNames,stimTimes,pulseTimes,rec,stimType,binsPerSec,force,figureBase)

if false
    excludes={};
    
    %targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/2.gaussian.z.38.26.t.30.292-449.144.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.15.09/acf4f35b54186cd6055697b58718da28e7b2bf80/3.gaussian.z.47.34.t.2042.38-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.17.09/89493235e157403e6bad4b39b63b1c6234ea45dd/5.gaussian.z.47.88.t.3891.4-4941.chunk.2.89493235e157403e6bad4b39b63b1c6234ea45dd';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/4b45921ce9ef4421aa984128a39f2203b8f9a381/6.gaussian.z.38.885.t.3683.44-4944.05.chunk.3.4b45921ce9ef4421aa984128a39f2203b8f9a381';
    
    %these died cuz the code needs to be fixed to be safe for the
    %case of zero bursts -- i didn't save the figs yet
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/2.gaussian.z.38.26.t.30.292-449.144.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/6.gaussian.z.38.26.t.1269.03-2739.63.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
end

if false
    [pth name]=fileparts([fileparts(fileNames.targetFile) '.blah']);
    prefix=fullfile(pth,name);
    
    info=prefix;
    infos={};
    while ~isempty(info)
        [infos{end+1} info]=strtok(info,filesep);
    end
    data.ratID=infos{end-3};
    data.datest=infos{end-2};
    data.uID=infos{end};
end

if length(stimTimes)~=2 || stimTimes(2)<=stimTimes(1)
    error('stimTimes error')
end

[data.ratID data.date type data.uID data.hash data.z data.chunkNum]=parseFileName(fileNames.targetFile,stimType,rec,stimTimes);

mins=(stimTimes(2)-stimTimes(1))/60;

data.spks=load(fileNames.spikesFile);
data.spks=data.spks(data.spks>=stimTimes(1) & data.spks<=stimTimes(2));
rate=length(data.spks)/(stimTimes(2)-stimTimes(1));

fprintf('%s\n\t%05.1f mins   spk rate: %04.1f hz\n',[data.ratID ' ' data.date ' ' data.uID],mins,rate);

[data.stim,data.phys,data.rptStarts]=extractData(fileNames,stimTimes,rec);

data=findBursts(data);

data.stimTimes=stimTimes;
data.figureBase=figureBase;
data.stimType=stimType;
data.rec=rec;

%[data.waveforms data.lockout]=doWaveforms(fileNames.wavemarkFile,rec.chunks.spkChan,rec.chunks.spkCode);

%doAnalysis(data,'waveforms');
doAnalysis(data,'ISI');
%doAnalysis(data,'spectrogram');

switch stimType
    case 'gaussian'
        % doAnalysis(fileNames,stimTimes,rec,spks,stimType,rate)
    case 'hateren'
    case {'sinusoid','sinusoid(new)'}
    case 'gaussgrass'
    case 'squarefreqs'
    case 'rpt/unq'
    case {'junk','off'}
    otherwise
        error('unknown type: %s\n',stimType)
end
end

function doAnalysis(data,type)
fprintf('\tdoing %s: ',type)
name=fullfile(data.figureBase,[data.ratID '-' data.date '-z' num2str(data.z) '-wf' data.chunkNum '-' num2str(data.rec.chunks.spkCode) '-t' num2str(data.stimTimes(1)) '-' num2str(data.stimTimes(2)) '-' data.hash],data.stimType);
[status,message,messageid]=mkdir(name);
if ~status
    message
    messageid
    error('mkdir error')
end

name=fullfile(name,type);
if ~(exist([name '.png'],'file') && exist([name '.fig'],'file')) %one flaw of this design is that if data were regenerated but old figs were still in this location, we'd not update the figs
    switch type
        case 'spectrogram'
            savefig(name,spectro(data));
        case 'ISI'
            savefig(name,isi(data));
        case 'waveforms'
            savefig(name,waveforms(data));
        otherwise
            error('unrecognized type')
    end
else
    fprintf('already present\n')
end
fprintf('\n')
end

function savefig(name,f)
fprintf('saving fig')
left=0;
bottom=0;
width=1600;
height=1200;
set(f,'OuterPosition',[left, bottom, width, height]);

saveas(f,[name '.png'])
saveas(f,[name '.fig'])
close(f)
end

function f=spectro(data)
f=figure;
plot(rand(10))
fprintf('spectroing... ')
end

function isiSub(sub,sup,d,code)
[tf loc]=ismember(sub,sup);
if ~all(tf)
    error('huh?')
else
    loc=loc(loc>1 & loc<length(sup));
end
plot(d(loc-1),d(loc),code)
end

function f=isi(data)
ms=25;
d=diff(data.spks)*1000;
[a,b]=hist(d,0:.1:ms);
rng=[min(d) max(d)];

n=4;
f=figure;
subplot(n,1,1)
plot(b(1:end-1),a(1:end-1),'k');
hold on
plot(ones(1,2)*data.lockout*1000,[0 max(a(1:end-1))],'k')'
xlabel('ms')
ylabel('count')
title('isi')
set(gca,'XTick',[0:ms]);

subplot(n,1,2:n)
loglog(d(1:end-1),d(2:end),'k.')
hold on
plot(data.ref*ones(1,2)*1000,rng,'k')
plot(data.pre*ones(1,2)*1000,rng,'k')
plot(rng,data.inter*ones(1,2)*1000,'k')
plot(data.inter*ones(1,2)*1000,rng,'k')

isiSub(data.bsts,data.spks,d,'rx');
isiSub(data.bstNotFst,data.spks,d,'r.');
isiSub(data.refVios,data.spks,d,'bo');

rng=[min([rng(1) [data.ref data.inter]*1000/2]) rng(2)];
xlim(rng)
ylim(rng)
xlabel('pre isi (ms)')
ylabel('post isi (ms)')
axis square
end

function f=waveforms(data)
keyboard
f=figure;
end

function [data]=findBursts(data)
data.pre=.1;
data.inter=.004;
data.ref=.002;

fprintf('\tfinding bursts...\n')

data.bsts=data.spks([false ; (diff(data.spks)>=data.pre & [data.inter>=diff(data.spks(2:end)) ; false])  ]);
data.refVios=data.spks([false ; diff(data.spks)<data.ref]);

data.bstNotFst=nan(1,5*length(data.bsts));
count=0;
data.bstLens=nan(1,length(data.bsts));
tmp=sort(data.spks);
for i=1:length(data.bsts) %find a vectorized way (actually this is fast enough)
    done=false;
    data.bstLens(i)=1;
    start=data.bsts(i);
    tmp=tmp(tmp>start);
    while ~done && ~isempty(tmp)
        if tmp(1)-start<=data.inter
            count=count+1;
            data.bstNotFst(count)=tmp(1);
            data.bstLens(i)=data.bstLens(i)+1;
            tmp=tmp(2:end); %this is empty safe!?
        else
            done=true;
            if rand>.95 && false
                fprintf('\t%.1f%% through bursts\n',100*i/length(bsts))
            end
        end
    end
end
if any(isnan(data.bstLens)) || any(data.bstLens<2)
    error('bst error')
end
if any(isnan(data.bstNotFst(1:count))) || any(~isnan(data.bstNotFst(count+1:end)))
    error('bstNotFst error')
end
data.bstNotFst=data.bstNotFst(~isnan(data.bstNotFst));
data.tonics=setdiff(data.spks,[data.bsts ; data.bstNotFst']);
end

function ex(fileNames,stimTimes,rec,spks,stimType,hz)

% spectralAnalysis(phys(1,:),phys(2,:));

pHz=1/median(diff(phys(2,:)));
freqs=1:50;
spectrogram(phys(1,:),round(pHz),[],freqs,pHz,'yaxis');
q=gcf;



physPreMS=300;
stimPreMS=300;
stimPostMS=30;

tSTL=calcSTA(tonics,phys,physPreMS,physPreMS);
tSTS=calcSTA(tonics,stim,stimPreMS,stimPostMS);
bSTL=calcSTA(bsts,phys,physPreMS,physPreMS);
bSTS=calcSTA(bsts,stim,stimPreMS,stimPostMS);

j=figure;
subplot(2,1,1)
plot(tSTS(2,:),tSTS(1,:),'k')
hold on
plot(bSTS(2,:),bSTS(1,:),'r')
xlabel('ms')
title('triggered stim')

subplot(2,1,2)
plot(tSTL(2,:),tSTL(1,:),'k')
hold on
plot(bSTL(2,:),bSTL(1,:),'r')
xlabel('ms')
title('triggered LFP')

preBstMS=20;
bstDurMS=40;
bstDetail=getRangeFromChunks(fileNames.physFile,bsts*1000-preBstMS,bstDurMS+preBstMS);

g=figure;
hist(bstLens,0:15)
title('spikes per burst')

h=figure;
bstD=bstDetail(:,:,2)';
bstD=bstD-repmat(min(bstD),size(bstD,1),1);
bstD=bstD./repmat(max(bstD),size(bstD,1),1);
bstD=bstD+repmat(.4*(1:size(bstD,2)),size(bstD,1),1);
plot(bstDetail(1,:,1)-bstDetail(1,1,1)-preBstMS,bstD(:,1:min(150,size(bstD,2))),'k')
title(sprintf('%d raw burst traces',size(bstDetail,1)))
xlabel('ms')

if ~isempty(rptStarts)
    missed=.01 < abs(1 - diff(rptStarts)/median(diff(rptStarts)));
    if any(missed)
        warning('%d index pulses missed',sum(missed))
    end
    
    minLength=inf;
    for i=1:length(rptStarts)-1
        %this introduces a few ms of jitter because of the jitter of the
        %index pulse wrt the crt, plus crt jitter/frame drops accumulates through each
        %trial
        inds{i}=find(stim(2,:)>=rptStarts(i) & stim(2,:)<rptStarts(i+1));
        if length(inds{i})<minLength
            minLength=length(inds{i});
        end
        rasters{i}=separate(tonics,rptStarts(i),rptStarts(i+1));
        bursts{i}=separate(bsts,rptStarts(i),rptStarts(i+1));
        inBursts{i}=separate(bstNotFst,rptStarts(i),rptStarts(i+1));
        violations{i}=separate(refVios,rptStarts(i),rptStarts(i+1));
    end
    block=nan(length(rptStarts)-1,minLength);
    for i=1:length(inds)
        block(i,:)=stim(1,inds{i}(1:minLength));
    end
    if any(isnan(block(:)))
        error('nan error')
    end
    meanStim=mean(block);
    meanStim=meanStim-min(meanStim);
    meanStim=meanStim/max(meanStim);
    timestep=median(diff(stim(2,:)));
    maxTime=minLength*timestep;
    bins=0:timestep:(minLength-1)*timestep;
    
    psth=0;
    bpsth=0;
    pbins=0:.01:maxTime;
    for i=1:length(rasters)
        psth=psth+hist(rasters{i}(rasters{i}<=maxTime),pbins);
        bpsth=bpsth+hist(bursts{i}(bursts{i}<=maxTime),pbins);
    end
    
    f=figure;
    plot(bins,meanStim+1)
    xlabel('secs')
    title(sprintf('%d gaussian repeats (%.1f hz, %.1f%% bursts, %d violations)',size(block,1),hz,100*length(bsts)/length(spks),length(refVios)))
    hold on
    
    plot(pbins,psth/max(psth),'k')
    plot(pbins,bpsth/max(psth),'r')
    
    for i=1:length(rasters)
        cellfun(@(c) plotRaster(c{1}{i},c{2},i,maxTime),{ {rasters,'kx'} {bursts,'ro'} {inBursts,'rx'} {violations,'bo'} })
    end
    xlim([0 maxTime])
    
    if true
        [ratID date type uid hash]=parseFileName(fileNames.targetFile,stimType);
        outDir='/Users/eflister/Desktop/committee';
        
        imName=fullfile(outDir,[type '.' num2str(size(block,1)) 'rpts.' ratID '.' date '.raster.']); %will clash if same stim recorded on same date with same rat or if another cell recorded at same time
        fprintf('\tsaving raster png\n')
        saveas(f,[imName 'png'])
        fprintf('\tsaving raster fig\n')
        saveas(f,[imName 'fig'])
        close(f)
        
        imName=fullfile(outDir,[type '.' sprintf('%.1f',(stimTimes(2)-stimTimes(1))/60) 'mins.' ratID '.' date '.spec.']); %will clash if same stim recorded on same date with same rat or if another cell recorded at same time
        fprintf('\tsaving spec png\n')
        saveas(q,[imName 'png'])
        fprintf('\tsaving spec fig\n')
        saveas(q,[imName 'fig'])
        close(q)
        
        imName=fullfile(outDir,[type '.' ratID '.' date '.STA.']); %will clash if same stim recorded on same date with same rat or if another cell recorded at same time
        fprintf('\tsaving sta png\n')
        saveas(j,[imName 'png'])
        fprintf('\tsaving sta fig\n')
        saveas(j,[imName 'fig'])
        close(j)
        
        imName=fullfile(outDir,[type '.' ratID '.' date '.bst dur hist.']); %will clash if same stim recorded on same date with same rat or if another cell recorded at same time
        fprintf('\tsaving bst dur hist png\n')
        saveas(g,[imName 'png'])
        fprintf('\tsaving bst dur hist fig\n')
        saveas(g,[imName 'fig'])
        close(g)
        
        imName=fullfile(outDir,[type '.' ratID '.' date '.raw burst traces.']); %will clash if same stim recorded on same date with same rat or if another cell recorded at same time
        fprintf('\tsaving raw burst png\n')
        saveas(h,[imName 'png'])
        fprintf('\tsaving raw burst fig\n')
        saveas(h,[imName 'fig'])
        close(h)
    else
        keyboard
    end
end
end

function sta=calcSTA(trigTs,stim,preMS,postMS)
trigs=trigTs(trigTs>stim(2,1)+preMS/1000 & trigTs<stim(2,end)-postMS/1000);

timestep=median(diff(stim(2,:)));

trigs=1+floor((trigs-stim(2,1))/timestep);

preBin=floor(preMS/1000/timestep);
postBin=floor(postMS/1000/timestep);
tinds=-preBin:postBin;

inds=repmat(tinds,length(trigs),1)+repmat(trigs,1,length(tinds));

vals=stim(1,:);
vals=vals(inds);
vals=vals-repmat(mean(vals')',1,length(tinds)); %legit?

sta=mean(vals);
sta=[sta;tinds*timestep*1000];
end

function [ratID date type uid h z chunkNum]=parseFileName(f,exType,rec,stimTimes)
a={};
while ~isempty(f)
    [a{end+1} f]=strtok(f,filesep);
end
if length(a)<5
    error('bad parse')
end

ratID=a{end-4};
if ~ismember(ratID,{'164','188'}) || ~strcmp(ratID,rec.rat_id)
    error('bad parse')
end

date=a{end-3};
datenum(date,'mm.dd.yy'); %just to check formatted right -- though datenum accepts '04.32.09'!

if ~strcmp(date,datestr(rec.date,'mm.dd.yy'))
    error('bad parse')
end

f=a{end-1};

if false;
    [c d]=textscan(f,'%u8%[^.].z.%f%*[.]t.%f-%fchunk.%u8%s'); %expect problems if last f *has* decimal portion (period before chunk will fail)
    if d~=length(f)
        c{:}
        f
        f(d:end)
        textscan(f,'%u8%[^.].z.%f%*[.]t.%f-%f%*[.]chunk.%u8%s')
        error('bad parse')
    end
end

uid=f;
e={};
while ~isempty(f)
    [e{end+1} f]=strtok(f,'.');
end

[n e]=scan(e,'%d');

type=e{1};
if ~strcmp(type,exType)
    error('bad parse')
end

if e{2}~='z'
    error('bad parse')
end

[z e]=scanNum(e(3:end),'t');

if rec.chunks.cell_Z ~= z
    error('bad parse')
end

h=e{end};

if ~strcmp(hash(rec.file,'SHA1'),h)
    error('bad parse')
end

chunkNum=e{end-1};

if ~strcmp(e{end-2},'chunk')
    error('bad parse')
end

e=e(2:end-3);

done=false;
i=1;
n='';
while ~done
    inds=find('-'==e{i});
    if isempty(inds)
        n=[n e{i} '.'];
        i=i+1;
    elseif isscalar(inds) && sum(n=='.')<2
        done=true;
        n=[n e{i}(1:inds-1)];
        m=[e{i}(inds+1:end) '.'];
        for j=i+1:length(e)
            m=[m e{j} '.'];
        end
    else
        error('bad parse')
    end
end

m=m(1:end-1);
if sum(m=='.')>1
    error('parse error')
end

n=str2num(n);

if floor(n)~=floor(stimTimes(1)) || isempty(n)
    error('bad parse')
end

n=str2num(m);

if floor(n)~=floor(stimTimes(2)) || isempty(n)
    error('bad parse')
end
end

function [n e]=scanNum(e,test)
n='';
count=0;
while ~strcmp(e{1},test)
    [m e]=scan(e,'%d');
    n=[n num2str(m) '.'];
    count=count+1;
    if count>2
        error('bad parse')
    end
end
n=str2num(n(1:end-1));
if isempty(n)
    error('bad parse')
end
end

function [a out] = scan(e,pat)
[a b c d]=sscanf(e{1},pat);
if d== length(e{1})+1 && isempty(c) && b==1
    out=e(2:end);
else
    error('bad parse')
end
end

function plotRaster(vals,code,i,lim) %made non-anonymous cuz no functional if
k=-.01;
vals=vals(vals<=lim);
if ~isempty(vals)
    plot(vals,k*i,code)
end
end

function out=separate(vals,start,stop)
out=vals(vals>=start & vals<stop)-start;
end

function [stim,phys,rptStarts]=extractData(fileNames,stimTimes,rec)
fprintf('\textracting...\n')
data=load(fileNames.targetFile);

rptStarts=data.stimBreaks;

if length(data.physT)~=length(data.phys) || length(data.binnedT)~=length(data.binnedVals)
    error('length error')
end

phys=extract(data.phys,data.physT);
stim=extract(data.binnedVals,data.binnedT);
end

function out=extract(binnedVals,binnedT)
totalStim=0;
for i=1:length(binnedT)
    totalStim=totalStim+length(binnedT{i});
    if length(binnedVals{i})~=length(binnedT{i})
        error('length error')
    end
end
stim=nan(1,totalStim);
stimT=stim;
stimInd=1;
for i=1:length(binnedT)
    stimIndE=stimInd+length(binnedT{i})-1;
    if stimIndE>totalStim
        error('total error')
    end
    stim(stimInd:stimIndE)=binnedVals{i};
    stimT(stimInd:stimIndE)=binnedT{i};
    stimInd=stimIndE+1;
end
if any(isnan(stim) | isnan(stimT))
    error('nan error')
end
if any(.01 < abs(1 - diff(stimT)/median(diff(stimT))))
    error('time error')
end

out=[stim;stimT];
end

% totalPhys=0;
% for i=1:length(data.physT)
%     totalPhys=totalPhys+length(data.physT{i});
%     if length(data.phys{i})~=length(data.physT{i})
%         error('phys length error')
%     end
% end
% phys=nan(1,totalPhys);
% physT=phys;
% physInd=1;
% for i=1:length(data.physT)
%     physIndE=physInd+length(data.physT{i})-1;
%     if physIndE>totalPhys
%         error('total phys error')
%     end
%     phys(physInd:physIndE)=data.phys{i};
%     physT(physInd:physIndE)=data.physT{i};
%     physInd=physIndE+1;
% end
% if any(isnan(phys) | isnan(physT))
%     error('phys nan error')
% end
% if any(.01 < abs(1 - diff(physT)/median(diff(physT))))
%     error('physT error')
% end
% phys=[phys;physT];
%
% totalStim=0;
% for i=1:length(data.binnedT)
%     totalStim=totalStim+length(data.binnedT{i});
%     if length(data.binnedVals{i})~=length(data.binnedT{i})
%         error('stim length error')
%     end
% end
% stim=nan(1,totalStim);
% stimT=stim;
% stimInd=1;
% for i=1:length(data.binnedT)
%     stimIndE=stimInd+length(data.binnedT{i})-1;
%     if stimIndE>totalStim
%         error('total stim error')
%     end
%     stim(stimInd:stimIndE)=data.binnedVals{i};
%     stimT(stimInd:stimIndE)=data.binnedT{i};
%     stimInd=stimIndE+1;
% end
% if any(isnan(stim) | isnan(stimT))
%     error('stim nan error')
% end
% if any(.01 < abs(1 - diff(stimT)/median(diff(stimT))))
%     error('stimT error')
% end

function spectralAnalysis(data,t)
if true
    
    p=.95;
    winDur = .1;
    
    hz=1/median(diff(t));
    
    figure
    params.Fs=hz;
    params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
    [garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
    params
    
    movingwin=[winDur winDur]; %[window winstep] (in secs)
    
    if false
        figure
        subplot(4,1,1)
        fprintf('chronux coh w/err:')
        tic
        [C,phi,S12,S1,S2,t,f,zerosp,confC,phistd,Cerr]=cohgramcpt(data,spks,movingwin,params,0);
        toc
        
        C(repmat(logical(zerosp),1,size(C,2)))=0;
        gram(C',t,f,'lin');
        title('coherence')
        
        subplot(4,1,2)
        gram(squeeze(Cerr(1,:,:))',t,f,'lin');
        title('chronux bottom err')
        subplot(4,1,3)
        gram(squeeze(Cerr(2,:,:))',t,f,'lin');
        title('chronux top err')
        
        subplot(4,1,4)
        gram(phi',t,f,'lin');
        title('chronux phase')
    end
    
    if false
        fprintf('chronux w/err: \t')
        tic
        [S,t,f,Serr]=mtspecgramc(data,movingwin,params); %takes 180 sec for 5 mins @ 40kHz
        toc
        
        figure
        subplot(2,1,1)
        plotSpecGram(squeeze(Serr(1,:,:))',t,f,'log');
        title('chronux bottom err')
        subplot(2,1,2)
        plotSpecGram(squeeze(Serr(2,:,:))',t,f,'log');
        title('chronux top err')
        
        figure
        subplot(3,1,1)
        plotSpecGram(S',t,f,'log');
        title('chronux w/err')
    else
        figure
    end
    
    params.err=0;
    
    fprintf('chronux w/o err:')
    tic
    [S,t,f]=mtspecgramc(data,movingwin,params); %takes ? sec for 5 mins @ 40kHz
    toc
    t2=t;
    
    subplot(3,1,2)
    plotSpecGram(S',t,f,'log');
    title('chronux w/o err')
    
    
    fprintf('spectrogram: \t')
    tic
    [stft,f2,t,S] = spectrogram(data,round(movingwin(1)*hz),round(hz*(movingwin(1)-movingwin(2))),f,hz); % takes ? sec for 5 mins @ 40kHz
    toc
    
    if ~all(f2(:)==f(:))
        error('f error')
    end
    
    subplot(3,1,3)
    plotSpecGram(S,t,f,'log');
    title('spectrogram')
    keyboard
end
end

function plotSpecGram(S,t,f,type)
if any(S(:)<0)
    error('not expecting negative S')
end
gram(10*log10(abs(S)+eps),t,f,type); %this code for plotting log psd is from matlab's spectrogram, chronux's plot_matrix uses similar, but without abs or eps

%    set(gca,'XTick',-pi:pi/2:pi)
%    set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})

%    ytick
end