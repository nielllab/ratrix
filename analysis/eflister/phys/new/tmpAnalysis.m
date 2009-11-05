function tmpAnalysis(fileNames,stimTimes,pulseTimes,rec,stimType,binsPerSec,force)
if length(stimTimes)~=2 || stimTimes(2)<=stimTimes(1)
    error('stimTimes error')
end

switch stimType
    case 'gaussian'
        
        [pth name]=fileparts([fileparts(fileNames.targetFile) '.blah']);
        prefix=fullfile(pth,name);
        
        index=isnumeric(rec.indexPulseChan);
        mins=(stimTimes(2)-stimTimes(1))/60;
        
        spks=load(fileNames.spikesFile);
        spks=spks(spks>=stimTimes(1) & spks<=stimTimes(2));
        rate=length(spks)/(stimTimes(2)-stimTimes(1));
        
        fprintf('%05.1f mins   spk rate: %04.1f hz   indexed: %d   %s\n',mins,rate,index,prefix);
        targs={};
        
        %       targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/2.gaussian.z.38.26.t.30.292-449.144.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
        targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.15.09/acf4f35b54186cd6055697b58718da28e7b2bf80/3.gaussian.z.47.34.t.2042.38-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80';
        targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.17.09/89493235e157403e6bad4b39b63b1c6234ea45dd/5.gaussian.z.47.88.t.3891.4-4941.chunk.2.89493235e157403e6bad4b39b63b1c6234ea45dd';
        targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/4b45921ce9ef4421aa984128a39f2203b8f9a381/6.gaussian.z.38.885.t.3683.44-4944.05.chunk.3.4b45921ce9ef4421aa984128a39f2203b8f9a381';

        %these died cuz the code needs to be fixed to be safe for the
        %case of zero bursts -- i didn't save the figs yet
        targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/2.gaussian.z.38.26.t.30.292-449.144.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
        targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/6.gaussian.z.38.26.t.1269.03-2739.63.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
        
        if ~ismember(prefix,targs) && index
            doAnalysis(fileNames,stimTimes,rec,spks,stimType,rate)
        end
    case {'sinusoid','sinusoid(new)'}
    case 'hateren'
    case 'gaussgrass'
    case 'squarefreqs'
    case 'rpt/unq'
    case {'junk','off'}
    otherwise
        fprintf('unknown type: %s\n',stimType)
end
end

function doAnalysis(fileNames,stimTimes,rec,spks,stimType,hz)
[stim,phys,rptStarts]=extractData(fileNames,stimTimes,rec);

% spectralAnalysis(phys(1,:),phys(2,:));

pHz=1/median(diff(phys(2,:)));
freqs=1:50;
spectrogram(phys(1,:),round(pHz),[],freqs,pHz,'yaxis');
q=gcf;

pre=.1;
inter=.004;
ref=.002;

bsts=spks([false ; (diff(spks)>=pre & [inter>=diff(spks(2:end)) ; false])  ]);
refVios=spks([false ; diff(spks)<ref]);

bstNotFst=nan(1,5*length(bsts));
count=0;
bstLens=nan(1,length(bsts));
tmp=sort(spks);
for i=1:length(bsts) %find a vectorized way (actually this is fast enough)
    done=false;
    bstLens(i)=1;
    start=bsts(i);
    tmp=tmp(tmp>start);
    while ~done && ~isempty(tmp)
        if tmp(1)-start<=inter
            count=count+1;
            bstNotFst(count)=tmp(1);
            bstLens(i)=bstLens(i)+1;
            tmp=tmp(2:end); %this is empty safe!?
        else
            done=true;
            if rand>.95 && false
                fprintf('\t%.1f%% through bursts\n',100*i/length(bsts))
            end
        end
    end
end
if any(isnan(bstLens)) || any(bstLens<2)
    error('bst error')
end
if any(isnan(bstNotFst(1:count))) || any(~isnan(bstNotFst(count+1:end)))
    error('bstNotFst error')
end
bstNotFst=bstNotFst(~isnan(bstNotFst));
tonics=setdiff(spks,[bsts ; bstNotFst']);

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

function [ratID date type uid hash]=parseFileName(f,exType)
a={};
while ~isempty(f)
    [a{end+1} f]=strtok(f,filesep);
end
if length(a)<5
    error('bad parse')
end

ratID=a{end-4};
if ~ismember(ratID,{'164','188'})
    error('bad parse')
end

date=a{end-3};
datenum(date,'mm.dd.yy'); %just to check formatted right -- though datenum accepts '04.32.09'!

f=a{end-1};

[c d]=textscan(f,'%u8%[^.].z.%f%*[.]t.%f-%fchunk.%u8%s'); %expect problems if last f *has* decimal portion (period before chunk will fail)
if d~=length(f)
    c{:}
    f
    f(d:end)
    textscan(f,'%u8%[^.].z.%f%*[.]t.%f-%f%*[.]chunk.%u8%s')
    error('bad parse')
end

type=c{2}{1};
if ~strcmp(type,exType)
    error('bad parse')
end
uid=f;
hash=c{7}{1};
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