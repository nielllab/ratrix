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
data.fileNames=fileNames;

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

fprintf('\tloading waveforms for code %d, chan %d, file %s...\n',rec.chunks.spkCode, rec.chunks.spkChan, rec.file)
wm=load(fileNames.wavemarkFile);
recTimes=[wm.recs.time];
wm.recs=wm.recs(recTimes>=stimTimes(1) & recTimes<=stimTimes(2));

data.theseWaveforms=wm.recs(rec.chunks.spkCode==[wm.recs.code]);
theseRecTimes=[data.theseWaveforms.time];
if ~isempty(setdiff(data.spks,theseRecTimes)) || ~isempty(setdiff(theseRecTimes,data.spks))
    error('recs and spks don''t match')
end

data.otherWaveforms=wm.recs(rec.chunks.spkCode~=[wm.recs.code]);
data.lockout=double(wm.totalPoints)*wm.rate;
data.waveformTimes=wm.tms;
data.numPts=wm.totalPoints;

data.waveformPeakTime=double(wm.prePoints)*wm.rate*1000;
if ~almostEqual(data.waveformPeakTime,data.waveformTimes(wm.prePoints+1))
    error('waveform peak time error')
end

doAnalysis(data,'burstDetail');
doAnalysis(data,'waveforms');
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
name=fullfile(data.figureBase,[data.ratID '-' data.date '-z' num2str(data.z) '-chunk' data.chunkNum '-code' num2str(data.rec.chunks.spkCode) '-' data.hash],[data.stimType '-t' num2str(data.stimTimes(1)) '-' num2str(data.stimTimes(2))]);
[status,message,messageid]=mkdir(name);
if ~status
    message
    messageid
    error('mkdir error')
end

name=fullfile(name,type);
if ~(exist([name '.png'],'file') && exist([name '.fig'],'file')) %one flaw of this design is that if data were regenerated but old figs were still in this location, we'd not update the figs
    %also, only the first presence of the first fig determines whether we
    %generate -- cuz we'd have to actually call the generator to find out
    %how many to expect, which is the expense we're trying to avoid.
    switch type
        case 'spectrogram'
            savefigs(name,spectro(data));
        case 'ISI'
            savefigs(name,isi(data));
        case 'waveforms'
            savefigs(name,waveforms(data));
        case 'burstDetail'
            savefigs(name,burstDetail(data));
        otherwise
            error('unrecognized type')
    end
else
    fprintf('already present\n')
end
fprintf('\n')
end

function savefigs(oname,fs)
fprintf('saving %d figs',length(fs))

for i=1:length(fs)
    f=fs(i);
    if i>1
        name=[oname '-' num2str(i)];
    else
        name=oname;
    end
    
    % saveas(f,[name '.png']) %resolution not controllable
    
    % print() seems to pick a size independent of the figure size (how?), so the following is unnecessary.
    if false
        left=0;
        bottom=0;
        width=1600;
        height=1200;
        set(f,'OuterPosition',[left, bottom, width, height]);
    end
    
    %"When you print to a file, the file name must have fewer than 128 characters, including path name."
    %http://www.mathworks.com/access/helpdesk/help/techdoc/ref/print.html#f30-534567
    
    fn='tmp.png';
    dpi=300;
    print(f,'-dpng',['-r' num2str(dpi)],fn);
    
    [a b c]=movefile(fn,[name '.png']);
    if ~a
        b
        c
        error('couldn''t move fig')
    end
    
    saveas(f,[name '.fig'])
    close(f)
end
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
rng=[min([data.ref data.inter]/2) 2]*1000;
rng(1)=.5;

n=4;
f=figure;
subplot(n,2,1:2)
plot(b(1:end-1),a(1:end-1),'k');
hold on
m = max(a(1:end-1));
plot(data.lockout*ones(1,2)*1000,[0 m],'k')
plot(1000*data.ref*ones(1,2),[0 m],'b');
plot(1000*data.inter*ones(1,2),[0 m],'r');
xlabel('ms')
ylabel('count')
title('isi')
set(gca,'XTick',[0:ms]);
ylim([0 m]);
xlim([0 ms]);
legend({'isi distribution','lockout','refractory criterion','burst isi criterion'})

subplot(n,2,2*[1:(n-1)]+1)
loglog(d(1:end-1),d(2:end),'k.')

    function markup(doLog)
        scalePts = [.5 1 2 3 4 10 100 500 1000 2000];
        scale=scalePts;
        stretch=ones(1,2)*1000;
        r=rng;
        ref=data.ref*stretch;
        pre=data.pre*stretch;
        inter=data.inter*stretch;
        lockout=data.lockout*stretch;
        
        if doLog
            r=logTransform(r);
            ref=logTransform(ref);
            pre=logTransform(pre);
            inter=logTransform(inter);
            scale=logTransform(scalePts);
            lockout=logTransform(lockout);
        end
        
        hold on
        plot(ref,r,'b')
        plot(pre,r,'r')
        plot(r,inter,'r')
        plot(inter,r,'r')
        plot(lockout,r,'k')
        plot(r,lockout,'k')
        xlim(r)
        ylim(r)
        xlabel('pre isi (ms)')
        ylabel('post isi (ms)')
        axis square
        
        set(gca,'XTickLabel',scalePts);
        set(gca,'XTick',scale);
        set(gca,'YTickLabel',scalePts);
        set(gca,'YTick',scale);
        set(gca,'FontSize',6);
    end

markup(false);
isiSub(data.bsts,data.spks,d,'rx');
isiSub(data.bstNotFst,data.spks,d,'r.');
isiSub(data.refVios,data.spks,d,'bo');

res=20;
offset=min(log(d));

    function out=logTransform(in)
        out=round(res*(log(in)-offset)+1);
    end

log_spk_diffs = logTransform(d);

twoDisi = sparse([],[],[],max(log_spk_diffs),max(log_spk_diffs),length(data.spks)-2);
for i=3:length(data.spks)
    x=log_spk_diffs(i-1);
    y=log_spk_diffs(i-2);
    twoDisi(x,y)=twoDisi(x,y)+1;
end

subplot(n,2,2*[2:n])

imagesc(twoDisi);
c=colormap(jet);
c(1,:)=[1,1,1];
colormap(c)
colorbar('EastOutside')

markup(true);
axis xy
end

function f=waveforms(data)

maxToShow=2000;

%times indicated for spikes and waveforms are start times, not peak times.  that means they are offset consistently within file but not across files

mTheseTraces=cat(1,data.theseWaveforms.points)';
mNoiseTraces=cat(1,data.otherWaveforms.points)';

t=[data.theseWaveforms.time];
tn=[data.otherWaveforms.time];

if ~all(cellfun(@issorted,{t,tn}))
    error('waveform times not ascending monotonic')
end

n=ceil(size(mTheseTraces,2)/maxToShow);
m=ceil(size(mTheseTraces,2)/n);

    function tracePlot(xs,cs,p)
        for i=1:size(cs,1)
            plot(xs,cs{i,1},'Color',(cs{i,2}+ones(1,3))/2) % argh no alpha for lines :(
            hold on
        end
        for i=1:size(cs,1)
            ptiles=[0 1] + p*[1 -1]/2;
            s=sort(cs{i,1},2);
            plot(xs,s(:,ceil(ptiles*size(s,2))),'Color',cs{i,2})
        end
    end

    function x=removeMean(x)
        x=x-repmat(mean(x),size(x,1),1);
    end

f=[];
thisIndex=1;
for j=1:n
    inds=thisIndex:min(thisIndex+m,size(mTheseTraces,2));
    thisIndex=inds(end)+1;
    theseTraces=removeMean(mTheseTraces(:,inds));
    
    times=t(inds([1 end]));
    tnInds=tn>=times(1) & tn<=times(2);
    noiseTraces=removeMean(mNoiseTraces(:,tnInds));

    f(end+1)=figure;
    subplot(2,2,[1 3])
    tracePlot(data.waveformTimes,{theseTraces, [1 0 0]; noiseTraces, zeros(1,3)},.05);
    
    allTraces=[theseTraces(:) ; noiseTraces(:)];
    lims=cellfun(@(x) x(allTraces), {@min,@max});
    plot(ones(1,2)*data.waveformPeakTime,lims,'k')
    ylim(lims)
    xlim([0 data.waveformTimes(end)])
    xlabel('ms')
    ylabel('volts')
    title(sprintf('%d of %d waveforms (%d noise waveforms)',length(inds),size(mTheseTraces,2),sum(tnInds)))
    
    subplot(2,2,2)
    
    bits=12;%16;
    vLims=5*[-1 1]*2; %the *2 is because we subtract the mean, so in the worst case, this makes the range twice as big
    if any(allTraces<vLims(1) | allTraces>vLims(2))
        error('volt error')
    end
    allTraces=[theseTraces noiseTraces];
    im = sparse([],[],[],length(data.waveformTimes),2^bits,length(data.waveformTimes)*(size(noiseTraces,2)+size(theseTraces,2)));
    for i=1:size(allTraces,2)
        for x=1:length(data.waveformTimes)
            y= 1+round((2^bits) * (allTraces(x,i)-vLims(1))/(vLims(2)-vLims(1)));
            im(x,y)=im(x,y)+1;
        end
        if rand>.99
            fprintf('%g done\n',100*i/size(allTraces,2))
        end
    end
    imagesc(im')
    
    z=sum(im)==0;
    
    ylim([find(z~=1,1,'first') length(z)-find(fliplr(z)~=1,1,'first')-1])
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    c=colormap(jet);
    % c(1,:)=[1,1,1];
    colormap(c)
    % colorbar('EastOutside')
    axis xy
    
    subplot(2,2,4)
    allTraces=allTraces';
    [u s v]=svd(allTraces);
    s=diag(s);
    ms=2;
    svdPlot(theseTraces','r.',ms);
    hold on
    svdPlot(noiseTraces','k.',ms);
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    
    plotSpecials(data.bsts,'ro')
    plotSpecials(data.bstNotFst,'mo')
    plotSpecials(data.refVios,'bo')
end

    function plotSpecials(x,code)
        [matches locs]=ismember(x,t(inds));
        items=removeMean(mTheseTraces(:,inds(1)+locs(matches)-1))'; %this transpose shouldn't be necessary?
        if ~all(ismember(items,theseTraces','rows'))
            error('match error')
        end
        svdPlot(items,code,5) 
    end

    function svdPlot(items,code,sz)
       plot(items*v(:,1)/s(1),items*v(:,2)/s(2),code,'MarkerSize',sz) 
    end

if false
    plot(tms,normalizeByDim(traces,2),'Color',col)
end
end

function f=burstDetail(data)
preBstMS=60;
bstDurMS=60;

maxToPlot=150;
offset=.4;

times=[];
inds=[];
totals=[];
for i=1:length(data.bstRecs)
    if ~isempty(data.bstRecs{i})
        new=data.bstRecs{i}(:,i)*1000-preBstMS;
        times=[times ; new];
        inds(end+1:end+length(new))=i;
        totals(i)=length(new);
    end
end

if isempty(data.bstRecs)
    data.bstRecs{1}=[];
end

if ~isempty(data.bstRecs{1}) || any(inds==1)
    error('bstRecs has nonempty record for single spike bursts')
end

times=[times ; data.refVios*1000-preBstMS]; %doing refVios as single spike bursts so that we don't pay to load the raw phys files twice -- should really fix so the fig filename isn't something to do with bursts, but then would need to output a structure of handle/name pairs...

inds(end+1:end+length(data.refVios))=1;

if length(totals)>2
    f=figure;
    bar(2:length(totals),totals(2:end),'k')
    ylabel('count')
    xlabel('spikes per burst')
else
    f=[];
end

fprintf('\n')
master=getRangeFromChunks(data.fileNames.physFile,times,bstDurMS+preBstMS);

for i=unique(inds)
    
    master2=master(inds==i,:,:);
    
    m=ceil(size(master2,1)/maxToPlot);
    n=ceil(size(master2,1)/m);
    
    thisInd=1;
    for j=1:m
        nextInd=min(thisInd+n-1,size(master2,1));
        theseInds=thisInd:nextInd;
        thisInd=nextInd+1;
        bstDetail=master2(theseInds,:,:);
        
        bstD=bstDetail(:,:,2)';
        bstD=bstD-repmat(min(bstD),size(bstD,1),1);
        bstD=bstD./repmat(max(bstD),size(bstD,1),1);
        bstD=bstD+repmat(offset*(1:size(bstD,2)),size(bstD,1),1);
        
        f(end+1)=figure;
        lims=cellfun(@(x) x(bstD(:)),{@min ; @max});
        if i==1
            plot([-data.ref*ones(2,1)*1000 zeros(2,1)],repmat(lims,1,2),'b')
        else
            plot([data.inter*[-1*ones(2,1) ones(2,1)]*1000 zeros(2,1)],repmat(lims,1,3),'r')
        end
        hold on
        xLocs=bstDetail(1,:,1)-bstDetail(1,1,1)-preBstMS;
        plot(xLocs,bstD,'Color',ones(1,3)*.75)
        
        subTraces(1000*data.bsts,'r',1);
        subTraces(1000*data.bstNotFst','m',i-1);
        subTraces(1000*data.tonics,'g');
        subTraces([data.otherWaveforms.time],'b');
        
        % legend({'raw traces','first spike of burst','subsequent spikes in bursts','tonic spikes','other threshold crossings (other spikes or noise)'}) %god legend sucks
        tit=sprintf('%d of %d',size(bstDetail,1),size(master2,1));
        if i==1
            title([tit ' refractory violoations']);
        else
            title(sprintf('%s raw burst traces with %d spks/bst',tit,i))
        end
        xlabel('ms')
        set(gca,'YTick',[]);
        if size(bstD,2)<maxToPlot/2
            ylim([0 offset*maxToPlot/2])
        else
            ylim(lims);
        end
    end
end

    function subTraces(times,c,perRow)
        tms=[];
        rows=[];
        for k=1:size(bstD,2)
            matches=times(times>=bstDetail(k,1,1) & times<=bstDetail(k,end,1));
            if exist('perRow','var')
                if length(matches)~=perRow && i~=1
                    error('didn''t find exactly right number matches')
                end
            end
            finds=[];
            for q=1:length(matches)
                finds(end+1)=find(matches(q)-bstDetail(k,:,1)<=0,1,'first'); %why aren't these exact?
            end
            if length(finds)~=length(matches)
                error('didn''t find all')
            end
            
            finds=finds(finds>data.numPts & finds<size(bstDetail,2)-data.numPts);
            numFinds=length(finds);
            
            if ~isempty(finds)
                finds=repmat(finds,data.numPts,1) + repmat([0:double(data.numPts)-1]',1,numFinds);
                
                tms=[tms reshape(xLocs(finds),size(finds,1),numFinds)];
                rows=[rows reshape(bstD(finds,k),size(finds,1),numFinds)];
            end
        end
        plot(tms,rows,c)
    end
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
if ~all(tmp==data.spks)
    error('spks didn''t start off monotonic ascending')
end
data.bstRecs={};
for i=1:length(data.bsts) %find a vectorized way (actually this is fast enough)
    done=false;
    data.bstLens(i)=1;
    start=data.bsts(i);
    tmp=tmp(tmp>start);
    bstRec=start;
    while ~done && ~isempty(tmp)
        if tmp(1)-bstRec(end)<=data.inter
            count=count+1;
            data.bstNotFst(count)=tmp(1);
            data.bstLens(i)=data.bstLens(i)+1;
            bstRec(end+1)=tmp(1);
            tmp=tmp(2:end); %this is empty safe!?
        else
            done=true;
            if length(data.bstRecs)<data.bstLens(i)
                data.bstRecs{data.bstLens(i)}=[];
            end
            data.bstRecs{data.bstLens(i)}(end+1,:)=bstRec; %note we miss the very last burst if no tonics follow it
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

if false
    plot(data.bstRecs{2}(:,1)-data.bsts(1:end-1)); %huh, why doesn't this make flat lines, with step offsets for each burst>2?
end
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