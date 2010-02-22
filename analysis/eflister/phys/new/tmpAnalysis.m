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

data.mins=(stimTimes(2)-stimTimes(1))/60;

if data.mins>=5 && ismember(stimType,{'gaussian','gaussgrass','rpt/unq'}) && ismember(rec.date,datenum({'04.15.09'},'mm.dd.yy')) %,'hateren'}) % && ...
    %        (...
    %        ismember(rec.date,datenum({'04.15.09','04.24.09'},'mm.dd.yy')) ...
    %        || ...
    %        false ... %all(stimTimes==[1670 3144.317]) ...
    %        )
    % test examples:
    % statey -> 22	43.3 mins	164-04.15.09-z47.34-chunk1-code1-acf4f35b54186cd6055697b58718da28e7b2bf80/gaussian-t2042.385-4641
    % great  -> 17	24.6 mins	164-03.25.09-z19.2-chunk1-code1-9d10d71ac6e4d1de0f7a8d88ca27b72790f9553d/gaussian-t1670-3144.317
    % inter? -> 27	55.7 mins	188-04.24.09-z52.48-chunk1-code1-9196f9c63cf78cac462dac2cedd55306961b7fd0/gaussian-t5554.8235-8895.053
    
    data.spks=load(fileNames.spikesFile);
    data.spks=data.spks(data.spks>=stimTimes(1) & data.spks<=stimTimes(2));
    rate=length(data.spks)/(stimTimes(2)-stimTimes(1));
    
    fprintf('%s\n\t%05.1f mins   spk rate: %04.1f hz\n',[data.ratID ' ' data.date ' ' data.uID],data.mins,rate);
    
    [data.stim,data.phys,data.frames,data.rptStarts]=extractData(fileNames,stimTimes,rec);
    
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
    
    data=findBursts(data);
    
    doAnalysis(data,'stationarity');
    
    % doAnalysis(data,'raster');
    
    % doAnalysis(data,'STA');
    % doAnalysis(data,'stimCheck');
    
    % doAnalysis(data,'field');
    % doAnalysis(data,'autocorr');
    % doAnalysis(data,'burstDetail');
    % doAnalysis(data,'waveforms');
    % doAnalysis(data,'ISI');
    % doAnalysis(data,'spectrogram');
    
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
else
    fprintf('\nskipping %g mins %s\n',data.mins,stimType)
end
end

function doAnalysis(data,type)
fprintf('\tdoing %s: ',type)
preName=fullfile(data.figureBase,[data.ratID '-' data.date '-z' num2str(data.z) '-chunk' data.chunkNum '-code' num2str(data.rec.chunks.spkCode) '-' data.hash],[data.stimType '-t' num2str(data.stimTimes(1)) '-' num2str(data.stimTimes(2))]);
[status,message,messageid]=mkdir(preName);
if ~status
    message
    messageid
    error('mkdir error')
end

name=fullfile(preName,type);
if ~(exist([name '.png'],'file')) % && exist([name '.fig'],'file')) %one flaw of this design is that if data were regenerated but old figs were still in this location, we'd not update the figs
    %also, only the first presence of the first fig determines whether we
    %generate -- cuz we'd have to actually call the generator to find out
    %how many to expect, which is the expense we're trying to avoid.
    switch type
        case 'spectrogram'
            savefigs(name,spectro(data),data.stimType,data.mins);
        case 'ISI'
            savefigs(name,isi(data),data.stimType,data.mins);
            saveLockoutVios(preName,data);
        case 'waveforms'
            savefigs(name,waveforms(data),data.stimType,data.mins);
        case 'burstDetail'
            savefigs(name,burstDetail(data),data.stimType,data.mins);
        case 'STA'
            savefigs(name,sta(data),data.stimType,data.mins);
        case 'stimCheck'
            savefigs(name,stimCheck(data),data.stimType,data.mins);
        case 'raster'
            savefigs(name,raster(data),data.stimType,data.mins);
        case 'stationarity'
            savefigs(name,stationarity(data),data.stimType,data.mins);
        case 'autocorr'
            savefigs(name,autocorr(data),data.stimType,data.mins);
        case 'field'
            savefigs(name,field(data),data.stimType,data.mins);
        otherwise
            error('unrecognized type')
    end
else
    fprintf('already present\n')
end
fprintf('\n')
end

function saveLockoutVios(name,data)
if ~isempty(data.lockoutVios)
    [fid, message]=fopen(fullfile(name,'lockout violations.txt'),'wt');
    if ismember(fid,-1:2)
        message
        error('couldn''t open file')
    end
    for i=1:length(data.lockoutVios)
        fprintf(fid,'%g\n',data.lockoutVios(i));
    end
    if 0~=fclose(fid);
        error('fclose error')
    end
end
end

function savefigs(oname,fs,stimType,mins)
fprintf('saving %d figs',length(fs))

pieces={};
tName=oname;
while ~isempty(tName)
    [pieces{end+1} tName]=strtok(tName,filesep);
end

summaryLoc=[];
for j=1:length(pieces)-3
    summaryLoc=fullfile(summaryLoc,pieces{j});
end

if ismac
    summaryLoc=[filesep summaryLoc];
end

summaryLoc=fullfile(summaryLoc,'summaries',stimType);

[status,message,messageid]=mkdir(summaryLoc);
if ~status
    message
    messageid
    error('mkdir error')
end

fprintf('\nsummarizing: %s\n',summaryLoc)

[fid, message]=fopen(fullfile(summaryLoc,[sanitize(stimType) ' summary.txt']),'at+');
if ismember(fid,-1:2)
    message
    error('couldn''t open file')
end
frewind(fid);
lines={};
while ~feof(fid)
    lines{end+1}=fgetl(fid);
end
if length(lines)==1 && isscalar(lines{end}) && isnumeric(lines{end}) && lines{end}==-1
    lines={};
end

pth=fullfile(pieces{end-2},pieces{end-1});

if isempty(lines) || isempty(findstr(lines{end},pth))
    status=fseek(fid,0,'eof');
    if status~=0
        [message,errnum]=ferror(fid)
    end
    lines{end+1}=sprintf('%d\t%3.1f mins\t%s\n',length(lines)+1,mins,pth);
    fprintf(fid,lines{end});
    fprintf('\tadding summary line\n')
else
    fprintf('\tmatch!\n')
end
if 0~=fclose(fid);
    error('fclose error')
end

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
    
    fullName=[name '.png'];
    figName=[name '.fig'];
    [a b c]=movefile(fn,fullName);
    if ~a
        b
        c
        error('couldn''t move fig')
    end
    
    figSaves={'raster','stationarity'};
    if false || ismember(pieces{end},figSaves)
        saveas(f,figName)
    end
    if ismember(pieces{end},{'ISI','waveforms','STA','raster','stationarity','stimCheck'}) && ismember(i,[1 length(fs)])
        [garbage n]=fileparts(name);
        [a b c]=copyfile(fullName,fullfile(summaryLoc,[num2str(length(lines)) '-' n '.png']));
        if a~=1
            b
            c
            error('couldn''t copy fig')
        end
        
        if ismember(pieces{end},figSaves)
            [a b c]=copyfile(figName,fullfile(summaryLoc,[num2str(length(lines)) '-' n '.fig']));
            if a~=1
                b
                c
                error('couldn''t copy fig')
            end
        end
        
    end
    
    close(f)
end
end

function g=spectro(data)
if data.mins>=.5
    g=figure;
    [f t p]=getSpec(data);
    displayspectrogram(t,f,p,false,'yaxis');
else
    g=[];
end
end

function [f t p stft]=getSpec(data)
pHz=1/median(diff(data.phys(2,:)));
fprintf('spectroing from %g hz... ',pHz)
freqs=1:50;
[stft f t p]=spectrogram(data.phys(1,:)-mean(data.phys(1,:)),round(pHz),[],freqs,pHz); %1 sec res w/50% overlap?
end

%stolen from matlab's spectrogram.m
function displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc)

% Cell array of the standard frequency units strings
frequnitstrs = getfrequnitstrs;
if isFsnormalized,
    idx = 1;
    f = f/pi; % Normalize the freq axis
else
    idx = 2;
end

newplot;
if strcmpi(faxisloc,'yaxis'),
    if length(t)==1
        % surf requires a matrix for the third input.
        args = {[0 t],f,10*log10(abs([Pxx Pxx])+eps)};
    else
        args = {t,f,10*log10(abs(Pxx)+eps)};
    end
    
    % Axis labels
    xlbl = 'Time';
    ylbl = frequnitstrs{idx};
else
    if length(t)==1
        args = {f,[0 t],10*log10(abs([Pxx' Pxx'])+eps)};
    else
        args = {f,t,10*log10(abs(Pxx')+eps)};
    end
    xlbl = frequnitstrs{idx};
    ylbl = 'Time';
end
hndl = surf(args{:},'EdgeColor','none');

axis xy; axis tight;
colormap(jet);

% AZ = 0, EL = 90 is directly overhead and the default 2-D view.
view(0,90);

ylabel(ylbl);
xlabel(xlbl);
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
if m>0
    ylim([0 m]);
end
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

function tracePlot(xs,cs,p)
for i=1:size(cs,1)
    if isempty(cs{i,1})
        cs{i,1}=zeros(length(xs),1);
    end
    plot(xs,cs{i,1},'Color',(cs{i,2}+ones(1,3))/2) % argh no alpha for lines :(
    hold on
end
for i=1:size(cs,1)
    if size(cs{i,1},2)>1
        ptiles=[0 1] + p*[1 -1]/2;
        s=sort(cs{i,1},2);
        plot(xs,s(:,ceil(ptiles*size(s,2))),'Color',cs{i,2})
    end
end
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

    function x=removeMean(x)
        if ~isempty(x)
            x=x-repmat(mean(x),size(x,1),1);
        end
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
    
    vLims=5*[-1 1]*2; %the *2 is because we subtract the mean, so in the worst case, this makes the range twice as big
    if any(allTraces<vLims(1) | allTraces>vLims(2))
        error('volt error')
    end
    allTraces=[theseTraces noiseTraces];
    
    traceDensity(data.waveformTimes,allTraces,vLims);
    
    subplot(2,2,4)
    allTraces=allTraces';
    
    try
        [u s v]=svd(allTraces);
    catch
        warning('too many waveforms for svd -- choosing dims based on half of waveforms')
        fprintf('verify: using %d not %d\n',size(allTraces,1),size(allTraces,2))
        [u s v]=svd(allTraces(rand(1,size(allTraces,1))>.5,:));
    end
    
    s=diag(s);
    ms=2;
    svdPlot(theseTraces','r.',ms,s,v);
    hold on
    svdPlot(noiseTraces','k.',ms,s,v);
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    
    plotSpecials(data.bsts,'ro')
    plotSpecials(data.bstNotFst,'mo')
    plotSpecials(data.refVios,'bo')
    
    if length(f)>15 && n-j>3 %runs out of memory, ugh, how fix?
        
        dpi=300;
        print(f(end),'-dpng',['-r' num2str(dpi)],[sanitize(datestr(now)) '.png']);
        
        close(f(end))
        f=f(1:end-1);
    end
end

    function plotSpecials(x,code)
        [matches locs]=ismember(x,t(inds));
        items=removeMean(mTheseTraces(:,inds(1)+locs(matches)-1))'; %this transpose shouldn't be necessary?
        if ~all(ismember(items,theseTraces','rows'))
            error('match error')
        end
        svdPlot(items,code,5,s,v)
    end

if false
    plot(tms,normalizeByDim(traces,2),'Color',col)
end
end

function X=svdPlot(items,code,sz,s,v,cs)
X=[];

if ~isempty(items)
    X=items*v(:,1)/s(1);
    Y=items*v(:,2)/s(2);
    
    if false
        X=squish(X);
        Y=squish(Y);
    end
    
    if ~exist('cs','var')
        plot(X,Y,code,'MarkerSize',sz)
    else
        scatter(X,Y,sz,cs,code)
    end
    
    axis square
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    
    X=X-min(X);
    X=X/max(X);
end

    function in=squish(in)
        in(in>0)=log(in(in>0));
        in(in<0)=-log(abs(in(in<0)));
        
        if any(~isreal(in))
            error('how possible?')
        end
    end

end

function traceDensity(times,traces,lims,bits,doLog)
if ~exist('bits','var') || isempty(bits)
    bits=12;%16;
end

n=10000;
if false && size(traces,2)>n
    traces=traces(:,rand(1,size(traces,2))<n/size(traces,2));
end

im = sparse([],[],[],length(times),1+2^bits,length(times)*size(traces,2));
for i=1:size(traces,2)
    for x=1:length(times)
        if traces(x,i)<=lims(2) && traces(x,i)>=lims(1)
            y= 1+round((2^bits) * (traces(x,i)-lims(1))/(lims(2)-lims(1)));
            im(x,y)=im(x,y)+1;
        end
    end
    if true && rand>.99
        fprintf('%g done\n',100*i/size(traces,2))
    end
end

if ~exist('doLog','var') || isempty(doLog) || doLog
    imagesc(log(im'))
else
    imagesc(im')
end

z=sum(im)==0;

ylim([find(z~=1,1,'first') length(z)-find(fliplr(z)~=1,1,'first')-1])
set(gca,'YTick',[])
set(gca,'XTick',[])
c=colormap(jet);
% c(1,:)=[1,1,1];
colormap(c)
% colorbar('EastOutside')
axis xy
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

maxVios=1000;
if length(data.refVios)>maxVios %TODO: hanle this better
    data.refVios=data.refVios(1:maxVios);
    size(data.refVios)
    warning('ignorming some refVios so we don''t run out of memory')
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

data.lockoutVios=data.spks(diff(data.spks)<data.lockout);

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

function f=autocorr(data)
f=figure;

switch data.date
    case '04.15.09'
        physDetailTimes=[4180 4300];
    otherwise
        physDetailTimes=[];
end

if ~isempty(physDetailTimes)
    physDetailTimes=physDetailTimes*1000;
    
    z=getRangeFromChunks(data.fileNames.physFile,physDetailTimes(1),diff(physDetailTimes));
    
    nyquist=1/(2*median(diff(z(1,:,1)/1000)));
    cutoff=250;
    
    b=fir1(300,cutoff/nyquist,'high');
    filted=filtfilt(b,1,z(1,:,2));
    
    subplot(3,1,3)
    plot((z(1,:,1)-physDetailTimes(1))/1000,filted);
    hold on
    
    bs=data.bsts(data.bsts>=physDetailTimes(1)/1000 & data.bsts<=physDetailTimes(2)/1000)-physDetailTimes(1)/1000;
    plot(bs,ones(1,length(bs))*max(filted),'x')
    title('example bursts')
    xlabel('secs')
    xlim([0 diff(physDetailTimes)/1000])
end

durMS=1000;

subplot(3,1,1)
doAC(data.tonics,durMS,durMS);
title('tonic autocorr')

subplot(3,1,2)
doAC(data.bsts,durMS,round(durMS/10));
title('burst autocorr')
end

function out=doAC(ts,durMS,numBins,opt)
    function counts=locAC(times,c,times2)
        if ~exist('times2','var') || isempty(times2)
            times2=times;
            killCenter=true;
        else
            killCenter=false;
        end
        counts=zeros(size(bins));
        for i=1:length(times)
            t=times2-times(i);
            counts=counts+hist(1000*t(abs(t)<=durMS/1000),bins);
            if rand>.999
                fprintf('%g%% done\n',100*i/length(times))
            end
        end
        if killCenter
            counts(numBins+1)=0;
        else
            counts=normalize(counts);
        end
        plot(bins,counts,c)
    end

if true
    bins=linspace(-durMS,0,numBins+1);
    bins=[bins -1*fliplr(bins(1:end-1))];
    
    if ~exist('opt','var') || isempty(opt)
        locAC(ts,'b')
        hold on
        locAC(rand(size(ts))*range(ts),'k') %note the shuffle corrector doesn't work for nonstationary data
    else
        for r=1:size(opt,1)
            out(r,:)=locAC(ts,opt{r,2},opt{r,1});
            hold on
        end
    end
else
    bins=linspace(0,durMS,numBins);
    h=hist(diff(1000*ts),bins);
    plot(bins(1:end-1),h(1:end-1))
end

ylabel('count')
xlabel('ms')
end

function f=field(data)
physMS=500;
n=3;
f=doST(getEvenFrames(data.phys'),data.tonics,data.bsts,physMS,physMS,n,'field');
end

function f=doST(frames,tonics,bsts,stimPreMS,stimPostMS,n,t,preISIs)
f=figure;

color=zeros(1,3);
c=.95;

[tSTF vals corrected pres]=calcSTA(tonics,frames,stimPreMS,stimPostMS,c,preISIs);
staPlot(tSTF,color,vals,c,n,1,['spike triggered average ' t],frames(1,:),[],corrected,pres);

[bSTF vals corrected pres]=calcSTA(bsts,frames,stimPreMS,stimPostMS,c,preISIs);
staPlot(bSTF,color,vals,c,n,3,['burst triggered average ' t],frames(1,:),[],corrected,pres);

info=compareTriggeredDistributions(tonics,bsts,frames,stimPreMS,stimPostMS);
staPlot(info,color,[],c,n,2,['spike vs. burst triggered ' t],nan);
end

function frames=getEvenFrames(data)
frames=data(1,2) : median(diff(data(:,2))) : data(end,2);
frames=[interp1(data(:,2),data(:,1),frames,'nearest'); frames];
end

function f=sta(data)
stimPreMS =300;%1000;
stimPostMS=75;%200;

preISIs=[0 10 50 100 200 300];

n=4;

if ~isempty(data.frames)
    f=doST(getEvenFrames(data.frames),data.tonics,data.bsts,stimPreMS,stimPostMS,n,'frame',preISIs);
else
    f=figure;
end

if false %note this will overwrite the spk vs. bst comparison -- where should we put that?
    [tSTS vals]=calcSTA(data.tonics,data.stim,stimPreMS,stimPostMS,c);
    staPlot(tSTS,color,vals,c,n,2,'spike triggered average filtered photodiode',data.stim(1,:));
    
    [bSTS vals]=calcSTA(data.bsts,data.stim,stimPreMS,stimPostMS,c);
    staPlot(bSTS,color,vals,c,n,4,'burst triggered average filtered photodiode',data.stim(1,:),true);
end
end

function staPlot(info,color,vals,c,n,r,t,dist,doLegendXLab,corrected,pres)
    function rg=getExtremes(rs)
        rg=cellfun(@(x) x(rs(:)),{@min,@max});
    end

if ~exist('dist','var')
    numCols=2;
    lims=getExtremes(vals);
    mu=[];
    sigma=[];
elseif isvector(dist)
    numCols=3;
    
    if ~isnan(dist)
        lims=[-1 1]*3;
        subplot(n,numCols,numCols*r-2)
        
        [mu,sigma] = normfit(dist);
        
        [counts bins]=hist((dist-mu)/sigma,100);
        actual=-log(counts);
        
        plot(actual,bins)
        
        hold on
        fit=-log(normpdf(bins)); % ,mu,sigma));
        fit=fit-min(fit)+min(actual);
        plot(fit,bins,'Color',.5*ones(1,3))
        
        ylim(lims)
        xlim(getExtremes(actual(~isinf(actual))))
        set(gca,'XTick',[])
        ylabel('stim z-score')
    end
else
    error('dist error')
end

subplot(n,numCols,numCols*r-1)

% fill([info(2,:) fliplr(info(2,:))],[info(3,:) fliplr(info(4,:))],mean([ones(1,3);color]))
if false
    tracePlot(info(2,:),{vals' color},1-c);
    hold on
end

if ~isempty(vals) && false  %haven't scaled these example traces correctly yet...
    rows=rand(1,size(vals,1))>.999;
    rows([1 end])=true;
    plot(info(2,:),vals(rows,:)','r')
end

scaled=info(1,:);
if any(~isnan(dist)) && ~all(info(1,:)==0) && ~all(isnan(info(1,:)))
    scaled=(scaled-mu)/sigma;
    theseLims=getExtremes(scaled(:));
    if ~isempty(vals)
        % consier version with stim vals normalized prior to averaging?
        noMeans=mean(vals-repmat(mean(vals')',1,size(vals,2)))/sigma;
        try
        diffs=mean(diff(vals')')/sigma; %since diff and avg both linear, order probably doesn't matter
        catch ex %OOM
            warning('warning: shortening due to OOM')
            diffs=mean(diff(vals(rand(size(vals,1),1)>.5,:)')')/sigma;
        end
        theseLims=getExtremes([scaled(:); noMeans(:); diffs(:)]);
    end
else
    theseLims=[0 1];
end

pCol=.7*ones(1,3);
[AX,H2,H1] = plotyy(info(2,:),info(end,:),info(2,:),scaled);
AX=fliplr(AX);

set(H1,'Color',color);
set(H2,'Color',pCol);
hold(AX(1),'on')
hold(AX(2),'on')
set(AX(1),'YColor','k')
set(AX(2),'YColor','k')

plot(AX(1),zeros(2,1),theseLims,'k');
plot(AX(1),info(2,[1 end]),zeros(1,2),'k')
plot(AX(2),info(2,[1 end]),.05*ones(1,2),'Color',pCol)

if false
    H3=plot(AX(1),median(diff(info(2,1:end)))/2+info(2,1:end-1),diffs,'b');
    H4=plot(AX(1),info(2,:)                                    ,noMeans,'r');
    
    if exist('doLegendXLab','var') && ~isempty(doLegendXLab) && doLegendXLab
        legend([H1 H4 H3 H2],{'STA','no means','STA diff','p-value'});
    end
end

if ~isnan(dist)
    ylabel(AX(1),'stim z-score')
end
ylabel(AX(2),'p-value')
xlabel(AX(1),'ms')

ylim(AX(1),theseLims)
ylim(AX(2),[0 1])
set(AX(1),'YTickMode','auto')
set(AX(2),'YTickMode','auto')

xlim(AX(1),info(2,[1 end]))
xlim(AX(2),get(AX(1),'XLim'))
title(t)

subplot(n,numCols,numCols*r)
if ~isempty(vals) && false
    traceDensity(info(2,:),(vals'-mu)/sigma,lims,12,true)
elseif ~(isscalar(dist) && isnan(dist))
    
    if false
        %power spectrum of the STA, to see if there is 10Hz resonance, etc
        plotSpec(scaled,1000/median(diff(info(2,:))),.95,true); %[pow c w]=pmtm(scaled-mean(scaled),[],f,1000/median(diff(info(2,:))),p);
        %originally had this (i think it's wrong):
        % [pow c w]=pmtm(scaled,[],f,median(diff(info(2,:)))*1000,p); %maybe should subtract mean from scaled?
    else
        if exist('pres','var') && ~all(0==pres(:))
            cm=colormap;
            for i=1:size(pres,1)
                plot(info(2,:),pres(i,:),'Color',cm(round(((i-1)/(size(pres,1)-1))*(size(cm,1)-1))+1,:))
                hold on
            end
            xlabel('ms')
            set(gca,'YTick',[])
            xlim(info(2,[1 end]))
            ylim([min(pres(:)) max(pres(:))])
        end
    end
end

if exist('corrected','var') && ~isempty(corrected) %&& false
    if length(scaled)~=size(corrected,2)
        error('wrong corrected length (probably off by one cuz of xcorr returning 2N+1')
    end
    plot(AX(1),info(2,:),cNorm(corrected(1,:)),'r')
    plot(AX(1),info(2,:),cNorm(corrected(2,:)),'g')
    
    set(H1,'LineWidth',2)
    
elseif exist('pres','var')
    cm=colormap;
    for i=1:size(pres,1)
        plot(AX(1),info(2,:),cNorm(pres(i,:)),'Color',cm(round(((i-1)/(size(pres,1)-1))*(size(cm,1)-1))+1,:)) %MUST FIX: this cNorm is NOT kosher
    end
end

    function in=cNorm(in)
        in=in-min(in);
        in=in/max(in);
        in=in*range(scaled);
        in=in+min(scaled);
    end
end

function f=stimCheck(data)
f=figure;

if ~isempty(data.frames)
    dist=getEvenFrames(data.frames);
    
    frames=dist(1,:);
    times=dist(2,:);
    
    if ~(isscalar(frames) && isnan(frames))
        
        if false %how flat is flat?
            n=30;
            hz=100;
            r=50;
            d=(randn(1,n*hz));
            subplot(2,1,1)
            plotSpec(d,hz,.95,true,true);
            
            subplot(2,1,2)
            d=repmat(d,1,r);
            plotSpec(d,hz,.95,true,true);
        end
        
        clf
        
        subplot(2,1,1)
        fs=1/median(diff(times));
        
        plotSpec(frames,fs,.95,true,true);
        
        subplot(2,1,2)
        
        acMS=100;
        [ac lags]=xcorr(frames,ceil(fs*acMS/1000));
        plot(1000*lags/fs,ac)
        xlabel('ms')
        xlim(acMS*[-1 1])
    else
        warning('dist is scalar nan')
    end
end

end

function plotSpec(sig,t,p,removeMean,shuffle)

if removeMean
    sig=sig-mean(sig);
end

maxf=ceil(t/2);
f=0:maxf;

[pow c w]=pmtm(sig,[],f,t,p);

if ~all(w==f)
    error('w not f')
end

plot(w,log(pow),'b')
hold on
plot(w,log(c),'Color',.5*[0 0 1])
xlabel('hz')
ylabel('log power')
xlim([0 maxf])

if exist('shuffle','var') && ~isempty(shuffle)
    sig=sig(randperm(length(sig)));
    [pow c w]=pmtm(sig,[],f,t,p);
    plot(w,log(pow),'k')
    plot(w,log(c),'Color',.5*ones(1,3))
end

end

function f=stationarity(data)
if ~isempty(data.rptStarts)
    start=data.rptStarts(1);
else
    start=min(data.tonics);
end

f=[];

pts=200;
secs=max([data.bsts ; data.tonics])-start;
dt=secs/pts;
step=dt/2;
ts=start+(0:step:secs);



if false %i don't think i know how to make phaseograms
n=10000000;
x.phys=[rand(1,n);linspace(0,n/1000,n)];
[a b c d]=getSpec(x);
gram(angle(d),b,a,'lin');
keyboard
end



tmpName='/Users/eflister/Desktop/22spec.mat';
if false
    [fq t p stft]=getSpec(data);
    %save(tmpName,'fq','t','p','stft');
else
    tmp=load(tmpName);
    fq=tmp.fq;
    t=tmp.t;
    p=tmp.p;
    stft=tmp.stft;
    clear tmp
end

if false
    %sucked out of spectrogram.m -- do i need to do anything (like correct for windowing) to stft to make a phaseogram?
    %pretty sure answer is no...
    % [garbage,garbage,garbage,garbage,garbage,win] = welchparse(data,'psd',varargin{:});
    % U = win'*win;     % Compensates for the power of the window.
    % Sxx = y.*conj(y)/U; % Auto spectrum.
        
    f=[figure f];
    gram(angle(stft),t,fq,'lin'); %wrap() doesn't seem to be a good idea here...
    title('phaseogram')
end

p=p'-mean(p(:));

if false
    try
        [u s v]=svd(p);
    catch
        warning('too much spectro for svd -- choosing dims based on half')
        [u s v]=svd(p(rand(1,size(p,1))>.5,:));
    end
    s=diag(s);
    
    save(['/Users/eflister/Desktop/classifiers/' data.uID '.mat'],'v');
    
else
    v=load('/Users/eflister/Desktop/classifier.mat');
    v=v.v;
    s=ones(1,size(v,1)); %fix so s's normalize the variances
end

%     function out=myFind(M,DIM)
%         switch DIM
%             case 1
%             case 2
%                 M=M';
%             otherwise
%                 error('only works for 1 or 2 (hack)')
%         end
%         out=nan(1,size(M,1));
%         for i=1:size(M,1)
%             possible=find(M(i,:),1,'first');
%             if isscalar(possible)
%                 out(i)=possible;
%             elseif ~isempty(possible)
%                 error('huh?')
%             end
%         end
%     end

f=[figure f];

if true
    
    X=p*v(:,1)/s(1);
    Y=p*v(:,2)/s(2);
    
    if true
        
        cut=.05;
        order=1000;
        
        orderFactor=5; %hmm, 3 should work but sometimes fails
        if orderFactor*order>length(X)
            order=floor(length(X)/orderFactor);
        end
        b=fir1(order,cut);
        pHz=1/median(diff(t));
        
        %this dim actually shifts mean
        x=filtfilt(b,1,X);
        
        if false
            [junk junk tx px]=spectrogram(X-mean(X),round(pHz),[],[],pHz);
            x=log(sum(px))';
            x=filtfilt(b,1,x);
            x(end+1)=mean(x);
        end
        
        %this dim only shifts variance
        
        [junk junk ty py]=spectrogram(Y-mean(Y),round(pHz),[],[],pHz);
        y=log(sum(py))';
        y=filtfilt(b,1,y);
        y(end+1)=mean(y);
        
    else
        x=X;
        y=Y;
    end
    
    x=normalize(x);
    y=normalize(y);
    
    n=3;
    
    subplot(n,1,1)
    specShow=p';
    specShow=specShow-min(specShow(:));
    % specShow=specShow/max(specShow(:));
    specShow=log(specShow); %log brings out low power details (but states a little more obvious without it) -- note can add a constant inside the log to change severity of compression
    if false
        specShow=specShow./repmat(mean(specShow')',1,size(specShow,2)); %nothing interesting added by normalization
    end
    imagesc(specShow)
    axis xy
    ylabel('hz')
    
    xLabMins=5;
    xlabs=0:xLabMins:max(t)/60;
    
    %xrows=myFind((repmat(t/60,length(xlabs),1)-repmat(xlabs',1,length(t))) >=0,1); %gah!
    xrows=floor(interp1(t/60,1:length(t),xlabs,'nearest'));
    set(gca,'XTick',xrows,'XTickLabel',xlabs);
    ylabs=0:5:max(fq);
    %yrows=myFind((repmat(fq,1,length(ylabs))-repmat(ylabs,length(fq),1)) >=0,2); %gah!
    yrows=floor(interp1(fq,1:length(fq),ylabs,'nearest'));
    set(gca,'YTick',yrows,'YTickLabel',ylabs);
    
    subplot(n,1,2)
    idx = kmeans(x(:),2); %why are we kmeansing only on x, not y?
    
    if mean(x(idx==1))>mean(x(idx==2))
        sync=idx==1;
        idx(sync)=2;
        idx(~sync)=1;
        % assuming we loaded the PC's, the alpha band is negative, and x should be more negative during the sync state.  we want sync state==1
    end
    
    plot(idx)
    ylim([.9 2.1])
    ylabel('state')
    set(gca,'XTick',xrows,'XTickLabel',xlabs);
    xlim([1 length(idx)])
    if ~all(unique(idx)==[1 2]')
        unique(idx)
        warning('unique(idx) not [1 2]')
    end
    set(gca,'YTick',[1 2],'YTickLabel',{'sync','desync'})
    
    subplot(n,1,3)
    ratePlot(data.bsts,'r')
    hold on
    ratePlot(data.tonics,'k')
    ylabel('normalized rate')
    set(gca,'YTick',[])
    %set(gca,'XTick',[])
    
    
    
    
    idxTimes=t+data.phys(2,1);
    currState=idx(1);
    u=unique(idx);
    for i=1:length(u)
        boundaries{u(i)}=[];
    end
    boundaries{currState}=idxTimes(1);
    for i=1:length(idx)
        if idx(i)~=currState
            boundaries{currState}(end,2)=idxTimes(i-1);
            currState=idx(i);
            boundaries{currState}(end+1,1)=idxTimes(i);
        end
    end
    boundaries{currState}(end,2)=idxTimes(end);
    

    
    [burstyS tonicyS]=segregate(data.spks);
    [burstyB tonicyB]=segregate(data.bsts);
    
    hi = .75;
    lo = .25;
    
    statePlot(burstyS,hi,'kx')
    statePlot(burstyB,hi,'rx')
    statePlot(tonicyS,lo,'kx')
    statePlot(tonicyB,lo,'rx')
    
    f=[f figure];
    n=4;
    
    subplot(n,1,1)
    plot(v(:,[2 1]))
    title('pc''s')
    xlabel('hz')
    set(gca,'YTick',[])
    xlim([1 size(v,1)])
    
    subplot(n,1,2)
    plot([Y X])
    xlim([1 length(Y)])
    ylim([min([Y(:);X(:)]) max([Y(:);X(:)])])
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    
    subplot(n,1,3)
    plot([y x])
    xlim([1 length(y)])
    set(gca,'XTick',[])
    ylabel('normalized score')
    
    if false
        subplot(n,1,4)
        d=100;
        %plot([hist(x,d);hist(y,d)]')
        
        q=cellfun(@(z) normalize(hist(z,d)),[{x} {y}],'UniformOutput',false);
        plot(log(cell2mat(q')'))
        set(gca,'YTick',[])
        set(gca,'XTick',[])
        xlabel('score')
        ylabel('pc dist')
    end
    
    %if this isn't last, it gets erased cuz of the repositioning
    subplot(n,1,4)
    ms=23; %50
    scatter(x,y,ms,t,'.')
    axis square
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    pos=get(gca,'Position');
    left=pos(1);
    bottom=pos(2);
    width=pos(3);
    height=pos(4);
    change=.1;
    set(gca,'Position',[left bottom-change/2  width  height+change]);
    %%%% set(gca,'Position',[0.13 0.365118-.05 0.775 0.0747626+.1]);
    xlabel('green')
    ylabel('blue')
    
    if ~isempty(data.frames)
        frames=getEvenFrames(data.frames);
        
        if false
            f=[f figure];
            
            stimPreMS =200;%300;
            stimPostMS=100;% 30;
            
            stimPreMS =400;
            stimPostMS=400;
            
            color=zeros(1,3);
            c=.95;
            
            n=4;
            
            [tSTF vals]=calcSTA(tonicyS,frames,stimPreMS,stimPostMS,c);
            staPlot(tSTF,color,vals,c,n,1,'spike triggered average frame (desync)',frames(1,:));
            
            [tSTFb vals]=calcSTA(burstyS,frames,stimPreMS,stimPostMS,c);
            staPlot(tSTFb,color,vals,c,n,2,'spike triggered average frame (sync)',frames(1,:));
            
            [bSTF vals]=calcSTA(tonicyB,frames,stimPreMS,stimPostMS,c);
            staPlot(bSTF,color,vals,c,n,3,'burst triggered average frame (desync)',frames(1,:));
            
            [bSTFb vals]=calcSTA(burstyB,frames,stimPreMS,stimPostMS,c);
            staPlot(bSTFb,color,vals,c,n,4,'burst triggered average frame (sync)',frames(1,:));
            
            %subplot(n,2,2*n-1)
            %xlabel('ms')
            
            ns=[50 100 200 500 1000 2000 5000 10000 20000 50000];
            resamps=20; %4
            stimPreMS=300;
            stimPostMS=300;
            
            if false
                ns=[500 1000 5000];
                resamps=4;
                stimPreMS=50;
                stimPostMS=50;
            end
            
            if false
                ns=[100 500 2000 10000];
                resamps=5;
            end
            
            f=[f figure];
            
            subplot(3,1,1)
            ts=staResampSig(tonicyS,[0 0 0]);
            tb=staResampSig(tonicyB,[1 0 0]);
            title('desync')
            xlim([0 max(length(tonicyS), length(tonicyB))])
            
            subplot(3,1,2)
            bs=staResampSig(burstyS,[0 0 0]);
            bb=staResampSig(burstyB,[1 0 0]);
            title('sync')
            xlim([0 max(length(burstyS), length(burstyB))])
            
            subplot(3,1,3)
            rands=[data.spks; data.bsts];
            randrng=[min(rands) max(rands)];
            rands=rand(length(rands),1) * (randrng(2)-randrng(1)) + randrng(1);
            staResampSig(rands,[0 0 0]);
            title('rand')
            
        end
        
        if true
            if false
                ms=150; %500 causes calcSTA to OOM on doTrigger
                fs=1000; %10k OOM's
            else
                ms=15;
                fs=2500;
                
                ms=25;
                fs=3000;
            end
                            
            color=zeros(1,3);
            c=.95;
            n=3;
            
            if strcmp(data.rec.display_type,'led')
                %note it currently looks like LED has artificial 1ms frame times -- consider adding frame pulses to this protocol
                %for now we trigger off the largest transitions
                d=abs(diff(data.frames(:,1)));
                [dist bins]=hist(d,100);
                f=[f figure];
                subplot(2,1,1)
                plot(bins,dist)
                dist=cumsum(dist)/sum(dist);
                thresh=bins(find(dist>.9,1))/2;
                hold on
                plot(thresh*ones(1,2),[0 max(dist)])
                title('led diffs')
                frameTimes=data.frames([0 d>thresh],2);
                subplot(2,1,2)
                hist(diff(frameTimes),100)
                str=sprintf('orig was %g, new is %g', median(diff(data.frames(:,2))),median(diff(frameTimes)));
                title(sprintf('frame lengths (%s)',str))
                fprintf('doing an led: %s\n',str)
            else
                frameTimes=data.frames(:,2);
            end
            
            names{1}='sync';
            names{2}='desync';
            [frameTransitions{1} frameTransitions{2}]=segregate(frameTimes);
            
            for state=unique(idx')
                f=[f figure];
                
                [stf vals]=calcSTA(frameTransitions{state},frames,ms,ms,c);
                staPlot(stf,color,vals,c,n,1,sprintf('%s state (%s): frame triggered frames',names{state},data.rec.display_type),frames(1,:));
                
                try
                [stf vals]=calcSTA(frameTransitions{state},getEvenFrames(data.phys'),ms,ms,c,[],false); %if we doKS here, we OOM on ks line 81 on short files, but not 22, why?  sampling rate is 1000hz...
                catch ex %OOM on doTrig -> shorten ms
                    msTmp=ms/4;
                    warning('hack: shortening due to OOM')
                    [stf vals]=calcSTA(frameTransitions{state},getEvenFrames(data.phys'),msTmp,msTmp,c,[],false); 
                end
                
                staPlot(stf,color,vals,c,n,2,'frame triggered field',data.phys(1,:));
                
                subplot(3,2,5)
                %cmp=doAC(frameTransitions{state},ms,ms,{data.tonics,'b'; data.bsts,'g'});

                xc=doXC(frameTransitions{state},ms,fs,{data.tonics,'k'; data.bsts,'r'});
                title('frame triggered spks/bursts')
                
                doLog=false;
                if doLog
                    ff=@log;
                else
                    ff=@(x) x;
                end
                
                subplot(3,2,6)
                [Pxx,Pxxc,freqs] = pmtm(removeMean(xc(1,:)),[],[],fs,c);
                plot(freqs,ff(Pxx),'k')
                hold on
                [Pxx,Pxxc,freqs] = pmtm(removeMean(xc(2,:)),[],[],fs,c);
                plot(freqs,ff(Pxx),'r')
                xlabel('hz')
                
                %                 [Pxx,Pxxc,freqs] = pmtm(removeMean(cmp(1,:)),[],[],fs,c);
                %                 plot(freqs,Pxx,'b')
                %                 hold on
                %                 [Pxx,Pxxc,freqs] = pmtm(removeMean(cmp(2,:)),[],[],fs,c);
                %                 plot(freqs,Pxx,'g')
                
                f=[f figure];
                                
                [stf vals]=calcSTA(scramble(frameTransitions{state},boundaries{state}),frames,ms,ms,c);
                staPlot(stf,color,vals,c,n,1,sprintf('%s state (%s): scramble triggered frames',names{state},data.rec.display_type),frames(1,:));
                
                subplot(3,2,5)
                xc=doXC(frameTransitions{state},ms,fs,{scramble(data.tonics,boundaries{state}),'k'; scramble(data.bsts,boundaries{state}),'r'}); %strong frame rate harmonics gt through unless we also scramble frameTransitions -- why?
                title(sprintf ('frame triggered scrambled spks/bursts (%s)',names{state}))
                
                subplot(3,2,6)
                [Pxx,Pxxc,freqs] = pmtm(removeMean(xc(1,:)),[],[],fs,c);
                plot(freqs,ff(Pxx),'k')
                hold on
                [Pxx,Pxxc,freqs] = pmtm(removeMean(xc(2,:)),[],[],fs,c);
                plot(freqs,ff(Pxx),'r')
                xlabel('hz')
            end
        end
        
        keyboard
        %coherenceAnalysis(frames,{tonicyS,burstyS,tonicyB,burstyB});
        coherenceAnalysis(data.stim,{tonicyS,burstyS,tonicyB,burstyB});
    end
else
    n=5;
    
    subplot(n,1,1)
    displayspectrogram(t,fq,p,false,'yaxis');
    
    subplot(n,1,2)
    
    ms=50;
    score=svdPlot(p,'.',ms,s,v,t);
    
    subplot(n,1,3)
    plot(fq,v(:,1:2))
    xlabel('hz')
    title('lfp dims')
    
    subplot(n,1,4)
    plot(t,score,'b')
    hold on
    ratePlot(data.bsts,'r')
    ratePlot(data.tonics,'k')
    
    ylabel('normalized rate or score')
    xlabel('secs')
    xlim([0 secs]);
    
    legend({'burst','tonic','LFP state'})
    
    rptPts=data.rptStarts-start;
    rptLabMask=true(size(rptPts));
    scale=0;
    if length(rptPts)>100
        scale=floor(log10(length(rptPts)))-1+log10(2);
    elseif length(rptPts)>20
        scale=log10(5);
    end
    
    if scale~=0
        rptLabMask=mod(1:length(rptPts),round(10^scale))==0;
        rptLabMask([1 end])=true;
    end
    
    xlabs={};
    for i=1:length(data.rptStarts)
        xlabs{end+1}=sprintf('%d',i);
    end
    
    if true
        %this thing makes zooming suck.  also no way to get rid of ticks from bottom x axes
        ax2 = axes('Position',get(gca,'Position'),...
            'XAxisLocation','top',...
            'Color','none',... %supposed to be default, but without this the original axes are obscured
            'XTick',rptPts(rptLabMask),...
            'XTickLabel',xlabs(rptLabMask),...
            'XLim',get(gca,'XLim'));
        %            'YAxisLocation','right',...
        %            'XColor','k','YColor','k');
        
        xlabel(ax2,'repeat num');
    end
    
    state=doNormRate(data.tonics)./doNormRate(data.bsts);
    
    [burstyS tonicyS]=segregate(data.spks);
    [burstyB tonicyB]=segregate(data.bsts);
    
    subplot(n,1,5)
    
    state=log(state);
    state(isinf(state))=nan;
    plot(ts-start,state);
    hold on
    plot(ts-start,zeros(1,length(ts)),'k')
    xlabel('secs')
    title('state')
    xlim([0 secs])
    
    hi = max(state)/2;
    lo = min(state)/2;
    
    statePlot(burstyS,lo,'kx')
    statePlot(burstyB,lo,'rx')
    statePlot(tonicyS,hi,'kx')
    statePlot(tonicyB,hi,'rx')
    
    f=[f figure];
    
    stimPreMS =200;%300;
    stimPostMS=100;% 30;
    
    color=zeros(1,3);
    c=.95;
    
    n=4;
    
    if ~isempty(data.frames)
        frames=data.frames(1,2) : median(diff(data.frames(:,2))) : data.frames(end,2);
        frames=[interp1(data.frames(:,2),data.frames(:,1),frames,'nearest'); frames];
        
        [tSTF vals]=calcSTA(tonicyS,frames,stimPreMS,stimPostMS,c);
        staPlot(tSTF,color,vals,c,n,1,'spike triggered average frame (tonic state)');
        
        [tSTFb vals]=calcSTA(burstyS,frames,stimPreMS,stimPostMS,c);
        staPlot(tSTFb,color,vals,c,n,2,'spike triggered average frame (bursty state)');
        
        [bSTF vals]=calcSTA(tonicyB,frames,stimPreMS,stimPostMS,c);
        staPlot(bSTF,color,vals,c,n,3,'burst triggered average frame (tonic state)');
        
        [bSTFb vals]=calcSTA(burstyB,frames,stimPreMS,stimPostMS,c);
        staPlot(bSTFb,color,vals,c,n,4,'burst triggered average frame (bursty state)');
    end
    
    subplot(n,2,2*n-1)
    xlabel('ms')
end

    function xc=doXC(x,ms,fs,ys)
        if ~exist('ys','var') || isempty(ys)
            ys={x,'k'};
        end
        x=fix(x);
        function in=fix(in)
            if ~all(in>0)
                error('must be all positive')
            end
            in=sparse(ones(1,length(in)),ceil(in*fs),ones(1,length(in)));
        end
        function in=chop(in)
            in=full(in(min(bounds(:,1)):min(length(in),max(bounds(:,2)))));
        end
        for i=1:size(ys,1)
            y=fix(ys{i,1});

            bounds=cell2mat(cellfun(@(it) cellfun(@(f) f(it),{@min @max}),cellfun(@find,{x; y},'UniformOutput',false),'UniformOutput',false));
            
            [xc(i,:) lags]=xcorr(chop(y),chop(x),ceil(fs*ms/1000),'none'); %undoc'ed? must be 'none' for different length vectors -- why?  also no xcorr on sparse?  and xcorr has OOM problems...
            lags=lags/fs;
            xc(i,:)=normalize(xc(i,:));
            if abs(median(diff(lags)) - 1/fs) > 10^-9
                error('fs error')
            end
            plot(1000*lags,xc(i,:),ys{i,2})
            hold on
        end
        xlim([-1 1]*ms);
        xlabel('ms')
    end

    function in=removeMean(in)
        in=in-mean(in);
    end

    function out=staResampSig(evts,color)
        doKS=false;
        
        theseNs=[ns length(evts)];
        
        semilogx(theseNs,(1-c)*ones(1,length(theseNs)),'k')
        hold on
        
        faded=color;
        faded(faded==0)=.5;
        
        out=nan(length(theseNs),resamps,2);
        scram=out;
        
        for i=1:length(theseNs)
            if length(evts)>theseNs(i)
                theseResamps=resamps;
                sym='x';
            elseif length(evts)==theseNs(i)
                theseResamps=1;
                sym='o';
            else
                theseResamps=0;
            end
            
            for j=1:theseResamps
                theseEvts=evts(randperm(length(evts)));
                theseEvts=sort(theseEvts(1:theseNs(i)));
                fprintf('doing %d %d\n',theseNs(i),j)
                
                info=calcSTA(theseEvts,frames,stimPreMS,stimPostMS,c,[],doKS);
                
                if doKS
                    sigs=info(3,:) <= 1-c;
                else
                    rands=sort(rand(length(theseEvts),1)*(frames(2,end)-frames(2,1))+frames(2,1));
                    randDist=calcSTA(rands,frames,stimPreMS,stimPostMS,c,[],doKS);
                    samp=sort(randDist(1,:));
                    
                    %samp=sort(frames(ceil(rand(1,length(theseEvts))*size(frames,2))));
                    lims=samp(round(length(samp)*([0 1]+((1-c)/2)*[1 -1])));
                    sigs=info(1,:)<=lims(1) | info(1,:)>=lims(2);
                end
                
                
                
                out(i,j,:)=[sum(sigs(info(2,:)<0)) sum(sigs(info(2,:)>=0))]./[sum(info(2,:)<0) sum(info(2,:)>=0)];
                semilogx(theseNs(i),out(i,j,1),sym,'Color',color)
                semilogx(theseNs(i),out(i,j,2),sym,'Color',faded) %this one is not showing up -- why?
                % keyboard
                
                scramFrames=frames(1,:);
                scramFrames=scramFrames(randperm(length(scramFrames)));
                scramFrames=[scramFrames;frames(2,:)];
                %frames(:,randperm(size(frames,2)))
                
                %ugh get rid of this repeated code
                info=calcSTA(theseEvts,scramFrames,stimPreMS,stimPostMS,c,[],doKS);
                
                
                if doKS
                    sigs=info(3,:) <= 1-c;
                else
                    rands=sort(rand(length(theseEvts),1)*(frames(2,end)-frames(2,1))+frames(2,1));
                    randDist=calcSTA(rands,scramFrames,stimPreMS,stimPostMS,c,[],doKS);
                    samp=sort(randDist(1,:));
                    
                    
                    %samp=sort(scramFrames(ceil(rand(1,length(theseEvts))*size(scramFrames,2))));
                    lims=samp(round(length(samp)*([0 1]+((1-c)/2)*[1 -1])));
                    sigs=info(1,:)<=lims(1) | info(1,:)>=lims(2);
                end
                
                scram(i,j,:)=[sum(sigs(info(2,:)<0)) sum(sigs(info(2,:)>=0))]./[sum(info(2,:)<0) sum(info(2,:)>=0)];
                semilogx(theseNs(i),scram(i,j,1),sym,'Color',[0 0 1])
                semilogx(theseNs(i),scram(i,j,2),sym,'Color',[.5 .5 1])
            end
        end
        avgs=mean(out(1:end-1,:,1)');
        semilogx(ns(1:length(avgs)),avgs,'Color',color)
        avgs=mean(out(1:end-1,:,2)');
        semilogx(ns(1:length(avgs)),avgs,'Color',faded)
        
        %ugh get rid of this repeated code
        avgs=mean(scram(1:end-1,:,1)');
        semilogx(ns(1:length(avgs)),avgs,'Color',[0 0 1])
        avgs=mean(scram(1:end-1,:,2)');
        semilogx(ns(1:length(avgs)),avgs,'Color',[.5 .5 1])
        
        ylim([0 1])
        xlim([min(theseNs) max(theseNs)])
    end

    function statePlot(in,val,code)
        plot(in-start,val*ones(1,length(in)),code)
    end

    function [lo hi]=segregate(in)
        if true
            ids=interp1(t+data.phys(2,1),idx,in,'nearest'); %note that this corrected t is probably wrong by half a bin used in the LFP spec analysis, could be ~order secs
            if ~all(isnan(ids) | ismember(ids,[1 2])) %nans occur where times are outside the range analyzed by the LFP analysis -- how can this happen?
                error('state error')
            end
            nanAnalysis=diff(isnan(ids));
            nanDinds=find(nanAnalysis);
            if length(nanDinds)>2 || ~all(nanAnalysis(nanDinds)==sort(nanAnalysis(nanDinds))) % nans should only be at beginning and end: [-1 1]
                error('nan error')
            end
            lo=in(ids==1);
            hi=in(ids==2);
        else
            lo=[]; %could prealloc w/nans if nec
            hi=[];
            in=in(in>=ts(1)-step/2);
            
            for i=1:length(ts)
                while ~isempty(in) && in(1)<=ts(i)+step/2
                    if in(1)<ts(i)-step/2
                        error('step err')
                    end
                    if state(i)>1
                        hi=[hi ; in(1)];
                    else
                        lo=[lo ; in(1)];
                    end
                    in=in(2:end);
                end
                if rand>.99 && true
                    fprintf('%g%% done\n',100*i/length(ts))
                end
            end
            if ~isempty(in)
                warning('in not empty')
            end
        end
    end

    function out=doNormRate(in)
        out=nan(size(ts)); %TODO: do this with a filter instead
        for i=1:length(ts)
            out(i)=sum(in>ts(i)-dt/2 & in<ts(i)+dt/2)/dt;
        end
        if any(isnan(out))
            error('nan err')
        end
        out=out/max(out);
    end

    function ratePlot(in,code)
        %ts=min(in):step:max(in);
        %         out=nan(size(ts)); %TODO: do this with a filter instead
        %         for i=1:length(ts)
        %             out(i)=sum(in>ts(i)-dt/2 & in<ts(i)+dt/2)/dt;
        %         end
        %         if any(isnan(out))
        %             error('nan err')
        %         end
        %         out=out/max(out);
        
        out=doNormRate(in);
        if isempty(in)
            xs=[0 secs];
            plot(xs,zeros(1,2),code);
        else
            xs=ts-start;
            plot(xs,out,code);
        end
        xlim([min(xs) max(xs)])
        xlabel('mins')
        xtl=0:5:max(xs/60);
        xt=floor(interp1(xs/60,1:length(xs),xtl,'nearest'));
        if length(xt)<=length(xs)
            set(gca,'XTick',xs(xt),'XTickLabel',xtl);
        else
            % set(gca,'XTick',xs,'XTickLabel',xs/60)
        end
    end

end

    function out=scramble(in,r)
        match=nan(size(in));
        for i=1:length(in)
            match(i)=isWithin(in(i),r);
        end
        fprintf('\n%g%% match\n',100*sum(match>0)/length(match))
        
        d=cumsum([0 diff(r')]);
        out=sort(rand(size(in(match>0)))*d(end));
        
        new=nan(size(r));
        for i=1:size(r,1)
            new(i,:)=[d(i) d(i+1)];
        end
        
        match=nan(size(out));
        for i=1:length(out)
            match(i)=isWithin(out(i),new);
        end
        
        for i=1:length(out)
            out(i)=out(i)+r(match(i),1)-new(match(i),1);
        end
        
        if false
        blah=figure;
        plot(in, zeros(1,length(in)),'rx');
        hold on
        plot(out, zeros(1,length(out)),'bo')
        keyboard
        close blah
        end

        %out=sort(rand(size(in))*diff(r)+r(1));
    end

    function out=isWithin(in,r)
        out=nan(1,size(r,1));
        for i=1:size(r,1)
            if in>=r(i,1) && in<=r(i,2)
                out(i)=1;
            else
                out(i)=0;
            end
        end
        switch sum(out)
            case 0
                out=0;
            case 1
                out=find(out);
            otherwise
                error('multiple')
        end
    end

function f=raster(data)
f=figure;

if ~isempty(data.rptStarts) && length(data.rptStarts)>1
    missed=.01 < abs(1 - diff(data.rptStarts)/median(diff(data.rptStarts)));
    if any(missed)
        warning('%d index pulses missed',sum(missed))
    end
    
    minLength=inf;
    maxLength=0;
    for i=1:length(data.rptStarts)
        if i==length(data.rptStarts)
            endT=data.rptStarts(i)+median(diff(data.rptStarts)); %TODO: figure out better way
        else
            endT=data.rptStarts(i+1);
        end
        
        %this introduces a few ms of jitter because of the jitter of the
        %index pulse wrt the crt, plus crt jitter/frame drops accumulates through each
        %trial
        inds{i}=find(data.stim(2,:)>=data.rptStarts(i) & data.stim(2,:)<endT); %or data.frames, but that doesn't necessarily have equal dt's
        if length(inds{i})<minLength && i~=length(data.rptStarts)
            minLength=length(inds{i});
        end
        if length(inds{i})>maxLength
            maxLength=length(inds{i});
        end
        
        rasters{i}=separate(data.tonics,data.rptStarts(i),endT);
        bursts{i}=separate(data.bsts,data.rptStarts(i),endT);
        inBursts{i}=separate(data.bstNotFst,data.rptStarts(i),endT);
        violations{i}=separate(data.refVios,data.rptStarts(i),endT);
    end
    
    useMinLength=false;
    
    if useMinLength
        len=minLength;
    else
        len=maxLength;
    end
    
    block=nan(length(data.rptStarts),len);
    for i=1:length(inds)
        if useMinLength
            block(i,:)=data.stim(1,inds{i}(1:len));
        else
            block(i,1:length(inds{i}))=data.stim(1,inds{i});
        end
    end
    
    if useMinLength
        tmp=block(1:end-1,:);
        if any(isnan(tmp(:)))
            error('nan error')
        end
    end
    
    timestep=median(diff(data.stim(2,:)));
    maxTime=len*timestep;
    bins=0:timestep:(len-1)*timestep;
    
    psth=0;
    bpsth=0;
    %pbins=0:.01:maxTime;
    pbins=0:.05:maxTime;
    
    for i=1:length(rasters)
        psth=psth+hist(rasters{i}(rasters{i}<=maxTime),pbins);
        bpsth=bpsth+hist(bursts{i}(bursts{i}<=maxTime),pbins);
    end
    
    if false
        block=mean(block);
    end
    
    block=block'-min(block(:));
    block=block/max(block(:));
    
    if false %the old way makes too many graphics objects and overwhelms gfx memory
        
        if false %lab meeting hack
            plot(bins,repmat(.01*(0:size(block,2)-1),size(block,1),1)+block+1)
        else
            %plot(bins,zeros(size(bins)));
            hold on
        end
        
        %xlabel('secs')
        %title(sprintf('%d gaussian repeats (%.1f hz, %.1f%% bursts, %d violations)',length(data.rptStarts),length(data.spks)/(data.stimTimes(2)-data.stimTimes(1)),100*length(data.bsts)/length(data.spks),length(data.refVios)))
        hold on
        
        plot(pbins,psth/max(psth),'k')
        plot(pbins,bpsth/max(bpsth),'r')
        
        for i=1:length(rasters)
            cellfun(@(c) plotRaster(c{1}{i},c{2},i+1,maxTime),{ {rasters,'k.'} {bursts,'ro'} {inBursts,'r.'} {violations,'bo'} })
        end
        xlim([0 maxTime])
        
    else
        % clf
        
        cellfun(@(c) doRaster(c{1},c{2},maxTime),{ {rasters,'k.'} {bursts,'ro'} {inBursts,'r.'} {violations,'bo'} })
        
        if false
            granMS=1;
            
            info=[]; %[cols rows vals]
            
            for i=1:length(rasters)
                cellfun(@(c) imRaster(c{1}{i},i,c{2},maxTime),{ {rasters,1} {bursts,2} {inBursts,3} {violations,4} });
            end
            
            inds=sub2ind(arrayfun(@(x) max(info(:,x)),[2 1]),info(:,2),info(:,1));
            if length(inds)~=length(unique(inds))
                error('got duplicate inds') %we can't have dupes cuz sparse() adds the entries
            end
            
            im=sparse(info(:,2),info(:,1),info(:,3));
            
            cs=([0 0 0; 1 0 0; 1 0 1; 0 0 1]);
            
            vals=unique(im(:));
            vals=vals(vals~=0);
            for v=1:length(vals)
                [i j]=find(im==vals(v));
                plot(j,i,'+','Color',cs(v,:))
                hold on
            end
            xlim([1 size(im,2)])
            ylim([1 size(im,1)])
        end
        
        axis ij
        
        dpi=3*72; %size of 1-pt dots (pts are 1/72", and dots are 1/3 requested pt size) http://www.mathworks.com/access/helpdesk/help/techdoc/ref/lineseriesproperties.html#MarkerSize
        heightInches=8; %assumption -- doesn't seem to be specifiable
        fudge=3;
        
        frac=length(rasters)/(dpi*heightInches);
        
        ylim([0 length(rasters)/min(fudge*frac,1)])
        % xlim([0 30]) %temp hack
    end
    
    ylabel('repeat')
    xlabel('secs')
    title(sprintf('%d %s repeats (%.1f hz, %.1f%% bursts (%d total), %d violations)',length(data.rptStarts),data.stimType,length(data.spks)/(data.stimTimes(2)-data.stimTimes(1)),100*length(data.bsts)/length(data.spks),length(data.bsts),length(data.refVios)))
    
else
    warning('skipping raster cuz no rpts id''d')
end

    function doRaster(data,code,lim)
        info=[];
        for i=1:length(data)
            info=[info [i*ones(1,length(data{i}));data{i}(:)']];
        end
        if any(code=='.')
            m=1;
        else
            m=2;
        end
        plot(info(2,:),info(1,:),code,'MarkerSize',m)
        hold on
    end

    function imRaster(times,trial,val,lim)
        times=unique(round(times(times<lim)*1000/granMS)+1); %unique is necessary to avoid putting more than one event in a bin, cuz sparse() will then add them
        
        if ~isempty(info)
            matches=info(:,2)==trial & ismember(info(:,1),times);
            if any(matches)
                if val~=4
                    error('only violations should overlap other events')
                else
                    fprintf('replacing %d violations\n',sum(matches))
                    info=info(~matches,:);
                end
            end
        end
        
        info=[info;times(:) repmat([trial val],length(times),1)];
    end
end

function [sta vals corrected pres]=calcSTA(trigTs,stim,preMS,postMS,c,preISIs,doKS)

if ~exist('doKS','var') || isempty(doKS)
    doKS=true;
end

if ~exist('preISIs','var') || isempty(preISIs)
    preISIs=0;
elseif preISIs(1)~=0
    error('first preISI not 0')
end

[vals times corrected]=doTrigger(trigTs,stim,preMS,postMS,preISIs);

for i=1:length(preISIs)
    if ~isempty(vals{i})
        pres(i,:)=mean(vals{i},1); %need to specify dim in case there's only one trig
    else
        pres(i,:)=zeros(size(times));
    end
end

vals=vals{1};

if ~isempty(trigTs)
    sta=pres(1,:);
    if doKS
        ps = ks(vals,stim(1,:));
    else
        ps=nan(size(sta));
    end
    if isscalar(ps)
        if ps==1 && numel(vals)<=1
            ps=ones(size(sta));
        else
            error('unexpected')
        end
    end
else
    sta=zeros(size(times));
    ps=ones(size(sta));
end
sta=[sta; times];

if false
    svals=sort(vals);
    sta=[sta; svals(ceil(size(svals,1)*([0 1]+[1 -1]*(1-c)/2)),:)];
end

sta=[sta; ps];
end

function [vals times corrected]=doTrigger(trigTs,stim,preMS,postMS,preISIs)
allTrigs=trigTs(trigTs>stim(2,1)+preMS/1000 & trigTs<stim(2,end)-postMS/1000);
diffs=[0 ; diff(allTrigs)]; %always throw out first spike (has unknown ISI ahead of it)

if ~exist('preISIs','var') || isempty(preISIs)
    preISIs=0;
end

timestep=median(diff(stim(2,:)));

preBin=floor(preMS/1000/timestep);
postBin=floor(postMS/1000/timestep);
tinds=-preBin:postBin;
times=tinds*timestep*1000;

for i=1:length(preISIs)
    trigs=allTrigs(diffs>preISIs(i)/1000);
    
    trigs=1+floor((trigs-stim(2,1))/timestep);
    
    if ~isempty(trigs) %used to test trigTs, why?
        inds=repmat(tinds,length(trigs),1)+repmat(trigs,1,length(tinds));
    else
        inds=[];
    end
    
    vals{i}=stim(1,:);
    vals{i}=vals{i}(inds);
end

allTrigs=1+floor((allTrigs-stim(2,1))/timestep); %revision 2743 screwed up by omitting this!

train=hist(allTrigs,1:length(stim(1,:))); 
%train=hist(allTrigs,stim(2,:)); %this fix messes up the bin timing a little

if all(train==0)
    warning('no triggers -- probably cuz no bursts')
    corrected=[];
else
    
    % dayan and abbott have derivations of the autocorrealation corrections
    %
    % note stim -> rate kernel (for predicting spiketrain from stim) does NOT depend on SPIKETRAIN autocorrelation:
    % 2.6 - white noise stim
    % 2.57 - correlated noise stim
    %
    % and spiketrain -> stim kernel (for predicting stim from spiketrain) does NOT depend on STIM autocorrelation (this is what we're doing here)
    % 3.60/3.79
    %
    % all use the xcorr between spike *rate* (not trains) and stim (to compute a thing proportional to STA) -- valid to use trains?
    
    N=max(preBin,postBin);
    
    [sta lags1]=xcorr(stim(1,:),train,N);
    [staR lags2]=xcorr(train,stim(1,:),N); %pam uses this version, but it's reversed for me?
    [auto lags3]=xcorr(train,N);
    
    corrected=fftshift(ifft(fft(sta)./fft(auto))); %i didn't expect fftshift to be necessary here, but it is -- why?
    
    if ~isreal(corrected) %pam's code thinks real() may be required, i don't think it should be necessary
        error('imaginary components found')
    end
    
    if false
        close all
        n=4;
        subplot(n,1,1)
        plot(lags1,sta)
        subplot(n,1,2)
        plot(lags2,staR)
        subplot(n,1,3)
        plot(lags3,auto)
        subplot(n,1,4)
        plot(corrected)
        
        keyboard
    end
    
    corrected=[corrected;sta];
    corrected=corrected(:,max(0,(postBin-preBin))+(1:length(tinds)));
end
end

function info=compareTriggeredDistributions(trigs1,trigs2,stim,preMS,postMS);
[vals1 times]=doTrigger(trigs1,stim,preMS,postMS);
[vals2 times]=doTrigger(trigs2,stim,preMS,postMS);

vals1=vals1{1};
vals2=vals2{1};

info=nan(3,length(times));
info(2,:)=times;
if all(cellfun(@(x) size(x,1)>1,{vals1 vals2}))
    info(3,:)=ks(vals1,vals2);
end
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
if ~strcmp(type,sanitize(exType))
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
    possiblyHasLeadingZeros=e{1};
    [m e]=scan(e,'%d');
    if isnumeric(m) && ~isempty(m)
        n=[n possiblyHasLeadingZeros '.'];
    else
        error('bad parse')
    end
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

function [stim,phys,frames,rptStarts]=extractData(fileNames,stimTimes,rec)
fprintf('\textracting...\n')
data=load(fileNames.targetFile);

try
    rptStarts=data.stimBreaks; %TODO: checks below for this case (this is the index pulse case)
catch
    if ~isempty(data.repeatTimes)
        rptStarts=data.repeatTimes(1,:);
        if ~all(cellfun(@iscell,{data.phys data.physT data.binnedVals data.binnedT}))
            error('hypothesis violated')
        end
    else
        rptStarts=[];
        if any(cellfun(@iscell,{data.phys data.physT data.binnedVals data.binnedT}))
            error('hypothesis violated')
        end
    end
    numRpts=length(rptStarts);
    
    if any(numRpts~=[size(data.repeatStimVals,2) size(data.repeatTimes,2) length(data.repeatColInds)]) ...
            || (iscell(data.phys) && any(numRpts~=[length(data.phys) length(data.physT)])) ...
            || (iscell(data.binnedVals) && any(numRpts~=[length(data.binnedVals) length(data.binnedT)]))
        error('num rpt err')
    end
    
    if ~isempty(data.bestBinOffsets) && length(data.bestBinOffsets)~=numRpts
        error('bestBinOffsets err')
    end
    
    if numRpts==0
        if ~isempty(data.repeatColInds)
            error('repeat col inds err')
        end
    else
        if any(data.repeatColInds~=1:numRpts)
            error('repeat col inds err')
        end
    end
    
    if false %TODO: flesh out this check -- make sure physT and binnedT boundaries straddle the rptStarts
        for i=1:numRpts
            if any(rptStarts(i)~=[data.physT{i}(1) data.binnedT{i}(1)])
                warning('repeat start times not unique')
            end
        end
    end
end
rptStarts=rptStarts(rptStarts>=stimTimes(1) & rptStarts<=stimTimes(2));

if length(data.physT)~=length(data.phys)
    error('phys length error')
end

if length(data.binnedT)~=length(data.binnedVals)
    if iscell(data.binnedT)
        error('binned stim length error')
    else
        length(data.binnedT)-length(data.binnedVals)
        warning('binned stim length difference')
        %TODO: find out why this is happening
        ml=min(length(data.binnedT),length(data.binnedVals));
        data.binnedT=data.binnedT(1:ml);
        data.binnedVals=data.binnedVals(1:ml);
    end
end

phys=extract(data.phys,data.physT,stimTimes);
stim=extract(data.binnedVals,data.binnedT,stimTimes);

if any(cellfun(@isempty,{data.repeatStimVals data.repeatTimes}))
    warning('no repeats id''d')
end

frames=[data.repeatStimVals(:) data.repeatTimes(:)];
frames=frames(frames(:,2)>=stimTimes(1) & frames(:,2)<=stimTimes(2),:);
if any(isnan(frames(:)))
    error('got a nan')
end
if isempty(frames)
    %NEXT UP -- this cooccurs with 'binned stim length difference' warning above on id 3
    %TODO: figure out why this happens -- i think it's when we can't ID repeats -- but we shouldn't let this stop us from doing the frame calc
    warning('got empty frames')
end
end

function out=extract(binnedVals,binnedT,stimTimes)
if iscell(binnedT)
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
else
    stim=binnedVals;
    stimT=binnedT;
end

if ~all(cellfun(@(x) isvector(x) && size(x,1)==1,{stim,stimT}))
    if all(cellfun(@isempty,{stim,stimT}))
        %pass TODO: check that this is a junk or off (there was no stim)
    elseif all(cellfun(@(x) isvector(x),{stim,stimT})) && size(stimT,1)==1 && size(stim,2)==1
        stim=stim'; %TODO: find out why this happens
    else
        error('stim/stimT size error')
    end
end

if any(isnan(stim) | isnan(stimT))
    error('nan error')
end
if any(.01 < abs(1 - diff(stimT)/median(diff(stimT))))
    error('time error')
end

out=[stim;stimT];
if ~isempty(out)
    out=out(:, out(2,:)>=stimTimes(1) & out(2,:)<=stimTimes(2));
end
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

function coherenceAnalysis(stim,evts)

figure
hist(diff(stim(2,:)),500)

spks=struct('times',evts);

spks=arrayfun(@(x) struct('times',x.times-stim(2,1)),spks);

if ~all(arrayfun(@(x) all(x.times)>=0 && size(x.times,2)==1,spks))
    error('negative times or not columns')
end

spks=spks(1); %TODO: fix below to deal with multiple conditions (~trials/channels)

p=.95;
winDur = 1;%.5;

hz=1/median(diff(stim(2,:)));
data=stim(1,:)';
data=data-mean(data);

params.Fs=hz;
params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
[garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
params

movingwin=[winDur winDur]; %[window winstep] (in secs)

if true
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
    
    figure
    subplot(2,1,1)
    gram(S1',t,f,'lin');
    title('stim power')
    subplot(2,1,2)
    gram(S2',t,f,'lin');
    title('spks power')
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
    plotSpecGram(S',t,f,'log');
    title('chronux w/err')
end

if false
    params.err=0;
    
    fprintf('chronux w/o err:')
    tic
    [S,t,f]=mtspecgramc(data,movingwin,params); %takes ? sec for 5 mins @ 40kHz
    toc
    t2=t;
    
	figure
    plotSpecGram(S',t,f,'log');
    title('chronux w/o err')
end

if false
    fprintf('spectrogram: \t')
    tic
    [stft,f2,t,S] = spectrogram(data,round(movingwin(1)*hz),round(hz*(movingwin(1)-movingwin(2))),f,hz); % takes ? sec for 5 mins @ 40kHz
    toc
    
    if ~all(f2(:)==f(:))
        error('f error')
    end
    
    figure
    plotSpecGram(S,t,f,'log');
    title('spectrogram')
    
    %sucked out of spectrogram.m -- do i need to do anything (like correct for windowing) to stft to make a phaseogram?
    %pretty sure answer is no...
    % [garbage,garbage,garbage,garbage,garbage,win] = welchparse(data,'psd',varargin{:});
    % U = win'*win;     % Compensates for the power of the window.
    % Sxx = y.*conj(y)/U; % Auto spectrum.
    
    if ~all(size(stft)==size(S))
        error('size problem')
    end
    
    figure
    gram(angle(stft),t,f,'lin');
    title('phaseogram')
end

keyboard
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

function gram(S,t,f,type)
imagesc(t,f,S);
axis xy;
xlabel('time (s)');
ylabel('freq (hz)');
colorbar;
end