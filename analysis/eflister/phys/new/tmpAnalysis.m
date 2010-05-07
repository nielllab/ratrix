function tmpAnalysis(fileNames,stimTimes,pulseTimes,rec,stimType,binsPerSec,force,figureBase)

if false
    excludes={};
    
    %targs{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/a7e4526229bb5cd78d91e543fc4a0125360ea849/2.gaussian.z.38.26.t.30.292-449.144.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.15.09/acf4f35b54186cd6055697b58718da28e7b2bf80/3.gaussian.z.47.34.t.2042.38-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/164/04.17.09/89493235e157403e6bad4b39b63b1c6234ea45dd/5.gaussian.z.47.88.t.3891.4-4941.chunk.2.89493235e157403e6bad4b39b63b1c6234ea45dd';
    excludes{end+1}='/Volumes/Maxtor One Touch II/eflister phys/phys analysis/188/04.23.09/4b45921ce9ef4421aa984128a39f2203b8f9a381/6.gaussian.z.38.885.t.3683.44-4944.05.chunk.3.4b45921ce9ef4421aa984128a39f2203b8f9a381';
    
    %these died cuz the code needs to be fixed to be safe for the case of zero bursts -- i didn't save the figs yet
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

if ... % selectRecordings('gauss',stimType,data) %
        data.mins>=3 && ismember(stimType,{'sinusoid','sinusoid(new)','squarefreqs'}) ... % && ismember(rec.date,datenum({'03.13.09'},'mm.dd.yy'))
        && (ismember(rec.date,datenum({'03.17.09'},'mm.dd.yy')) && rec.chunks.cell_Z==9.255) % || ... %not 8.58 %15 mins
   %     ismember(rec.date,datenum({'03.19.09'},'mm.dd.yy'))) %5 mins works
   
    % && ismember(stimType,{'gaussian','gaussgrass','rpt/unq'}) && ismember(rec.date,datenum({'04.15.09'},'mm.dd.yy')) %'hateren'
    
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
    
    fprintf('\n%s\n',[data.ratID ' ' data.date ' ' data.uID]);
    
    data.spks=data.spks(data.spks>=stimTimes(1) & data.spks<=stimTimes(2));
    rate=length(data.spks)/(stimTimes(2)-stimTimes(1));
    
    [data.stim,data.phys,data.frames,data.rptStarts,data.offsets]=extractData(fileNames,stimTimes,rec);
    
    data.stimTimes=stimTimes;
    data.figureBase=figureBase;
    data.stimType=stimType;
    data.rec=rec;
    
    tic
    fprintf('\tloading waveforms for code %d, chan %d, file %s...',rec.chunks.spkCode, rec.chunks.spkChan, rec.file)
    wm=load(fileNames.wavemarkFile);
    toc
    
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
    
    [entropy.bitsPerSpk entropy.bitsPerSec]=spkEntropy(data.spks);
    entropy.spkRate=rate;
    entropy.burstRate=length(data.bsts)/(stimTimes(2)-stimTimes(1));
    entropy.tonicRate=length(data.tonics)/(stimTimes(2)-stimTimes(1));
    entropy.stimType=stimType;
    entropy.minsDuration=data.mins;
    aggregate(data,'entropy',entropy);
    
    fprintf('\t%05.1f mins   spk rate: %04.1f hz (%04.1f bits/spk, %04.1f bits/sec)\n',data.mins,rate,entropy.bitsPerSpk,entropy.bitsPerSec);
    
    % doAnalysis(data,'fanoFactor');
    
    % doAnalysis(data,'stationarity');
    
    doAnalysis(data,'raster');
    
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

function aggregate(data,name,val)
z=load(data.fileNames.tmpFile,'z');
if ~isempty(fields(z))
    z=z.z;
end
z(end+1).(name)={data.uID val}; %now can dig these out with {z.(name)} and toss the emtpies.
save(data.fileNames.tmpFile,'z','-append')
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
        case 'fanoFactor'
            savefigs(name,fano(data),data.stimType,data.mins);
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
    %lines{end}
    fprintf(fid,restoreControls(lines{end})); %without restoreControls, windows, but not osx, says 'Warning: Invalid escape sequence appears in format string.' and then fails to actually add the \n to the file.
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
    if true || ismember(pieces{end},figSaves)
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
tic

data.pre=.1;
data.inter=.004;
data.ref=.002;

fprintf('\tfinding bursts...')

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
toc
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
numBins=round(durMS/10);

subplot(3,1,1)
tAC=doAC(data.tonics,durMS,numBins);
title('tonic autocorr')
set(gca,'ytick',[])

subplot(3,1,2)
bAC=doAC(data.bsts,durMS,numBins);
title('burst autocorr')
set(gca,'ytick',[])

subplot(3,1,3)



if false % this OOM's
    
    maxf=50;
    
    params.Fs=2*maxf;
    params.fpass=[0 maxf];
    p=.05;
    
    params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
    [garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
    
    % if ~isvector(evts) || ~all(diff(evts)>=0)
    %     error('must be ascending vector')
    % end
    % s.times=evts(:);
    
    [S,f,R,Serr]=mtspectrumpt(data.tonics,params)
    
    k=plot(f,S,'k');
    hold on
    
    plot(f,Serr,.5*ones(1,3))
    
    [S,f,R,Serr]=mtspectrumpt(data.bsts,params);
    r=plot(f,S,'r');
    
    plot(f,Serr,[1 .5 .5]);
    
else
    
    fs=numBins/(durMS/1000);
    maxf=50;
    fbins=0:maxf;
    
    %bAC(ceil(length(bAC)/2))=0;
    %tAC(ceil(length(tAC)/2))=0;
    
    tAC=tAC-mean(tAC);
    bAC=bAC-mean(bAC);
    
    [pow c w]=pmtm(tAC,[],fbins,fs,.95);
    
    if ~all(w==fbins)
        error('w not f')
    end
    
    k=plot(w,normalize(pow),'k');
    hold on
    % plot(w,c,'Color',.5*ones(1,3))
    
    xlim([0 maxf])
    
    
    
    [pow c w]=pmtm(bAC,[],fbins,fs,.95);
    
    if ~all(w==fbins)
        error('w not f')
    end
    
    r=plot(w,normalize(pow),'r');
    
    % plot(w,c,'Color',[1 .5 .5])
    
    ylabel('normalized power');
    
end

legend([k r],{'tonics','bursts'});


xlabel('freq (hz)');
set(gca,'ytick',[])


end

%misnamed -- also does xc
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

if false
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
elseif false
    bins=linspace(0,durMS,numBins);
    h=hist(diff(1000*ts),bins);
    plot(bins(1:end-1),h(1:end-1))
else
    if ~exist('opt','var') || isempty(opt)
        fs=numBins/(durMS/1000);
        if ~isvector(ts) || ~all(diff(ts)>=0)
            error('must be ascending vector')
        end
        binned=hist(ts,ts(1):1/fs:ts(end));
        
        maxlags=fs*durMS/1000;
        [ac,lags]=xcorr(binned,maxlags);
        out=ac;
        ac(ceil(length(ac)/2))=0;
        plot(1000*lags/fs,ac)
        ylim([0 max(ac)])
    else
        error('only do this version without opt')
    end
end

ylabel('count')
xlabel('ms')
end

function f=field(data)
physMS=250;
n=3;
f=doST(getEvenFrames(data.phys'),data.tonics,data.bsts,physMS,physMS,n,'field',[]);
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

if false
    preISIs=[0 10 50 100 200 300];
else
    preISIs=[];
end

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
    
    if true
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

if exist('corrected','var') && ~isempty(corrected) && false
    if length(scaled)~=size(corrected,2)
        error('wrong corrected length (probably off by one cuz of xcorr returning 2N+1')
    end
    plot(AX(1),info(2,:),cNorm(corrected(1,:)),'r')
    plot(AX(1),info(2,:),cNorm(corrected(2,:)),'g')
    
    set(H1,'LineWidth',2)
    
elseif exist('pres','var') && false
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

[pow c w]=pmtm(double(sig),[],double(f),double(t),p);

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

function f=fano(data)
%break this out by state -- have to find blocks of time during the repeat that don't include different states, and also have consistent firing rate thru the chunk
%show 250ms and 30s
%coplot the psth ("whenever firing rate goes up, fano factor should go down", cuz pushing on refractoriness, but only when ff is below 1

%decision - go for whole repeats taht are in one state -- don't need too many to get good estimate.

%consider replacing bursts with single spikes, to ask if super poisson variability is due to burst occurances

if ~isempty(data.rptStarts)
    [out ff slidingMs f]=fanoFactor(data.spks,data.rptStarts,true);
else
    f=figure;
end

%f=save(data.tmpFile,,'-append');
%save(data.tmpFile,,'-append');
end

function f=stationarity(data)

states(data.phys(1,:),1/median(diff(data.phys(2,:))));
keyboard

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
if true
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
    
    n=4;
    cols=10;
    width=1;
    
    subplot(n,cols,[1+width:cols])
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
    
    %whoops, could skip this stuff cuz imagesc takes x,y args...
    
    %xrows=myFind((repmat(t/60,length(xlabs),1)-repmat(xlabs',1,length(t))) >=0,1); %gah!
    xrows=floor(interp1(t/60,1:length(t),xlabs,'nearest'));
    set(gca,'XTick',xrows,'XTickLabel',xlabs);
    ylabs=0:5:max(fq);
    %yrows=myFind((repmat(fq,1,length(ylabs))-repmat(ylabs,length(fq),1)) >=0,2); %gah!
    yrows=floor(interp1(fq,1:length(fq),ylabs,'nearest'));
    set(gca,'YTick',yrows,'YTickLabel',ylabs);
    
    idx = kmeans(x(:),2); %why are we kmeansing only on x, not y?
    
    if mean(x(idx==1))>mean(x(idx==2))
        sync=idx==1;
        idx(sync)=2;
        idx(~sync)=1;
        % assuming we loaded the PC's, the alpha band is negative, and x should be more negative during the sync state.  we want sync state==1
    end
    
    if false
        subplot(n,1,2)
        
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
    end
    
    subplot(n,cols,cols+(1+width:cols))
    
    currOn=false;
    for i=1:length(idx)
        if ~currOn && idx(i)==1
            currOn=true;
            fillX=t(i);
            %'starting one'
        elseif currOn && idx(i)~=1
            currOn=false;
            tmp=[fillX t(i)];
            fill([tmp fliplr(tmp)],[zeros(1,2) ones(1,2)],.75*ones(1,3),'linestyle','none');
            %'doing one'
            fillX=[];
            hold on
        end
    end
    
    ratePlot(data.bsts,'r')
    hold on
    ratePlot(data.tonics,'k')
    ylabel('normalized rate')
    set(gca,'YTick',[])
    %set(gca,'XTick',[])
    
    
    subplot(n,cols,1)
    plot(v(:,[2 1]),1:size(v,1),'linewidth',2)
    title('pc''s')
    ylabel('hz')
    set(gca,'XTick',[])
    ylim([1 size(v,1)])
    
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
    
    
    
    [burstyS tonicyS]=segregate(data.tonics); %fixed a serious error -- used to use data.spks, should have been data.tonics i'm pretty sure
    [burstyB tonicyB]=segregate(data.bsts);
    
    if false
        hi = .75;
        lo = .25;
        
        statePlot(burstyS,hi,'kx')
        statePlot(burstyB,hi,'rx')
        statePlot(tonicyS,lo,'kx')
        statePlot(tonicyB,lo,'rx')
    end
    
    %NOTE that the start and end times of these is goverend by the first/last event - need to fix!
    subplot(n,cols,2*cols+(1+width:cols))
    doEvtPower(data.tonics);
    title('tonic power')
    
    subplot(n,cols,3*cols+(1+width:cols))
    doEvtPower(data.bsts);
    title('burst power')
    
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
    subInds=1:30:length(x);
    scatter(x(subInds),y(subInds),ms,t(subInds),'.')
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
        
        if true
            f=[f figure];
            
            stimPreMS =200;%300;
            stimPostMS=100;% 30;
            
            stimPreMS =400;
            stimPostMS=400; %ks can OOM on unqiue->diff on last cell here
            
            stimPreMS =150;
            stimPostMS=50;
            
            stimPreMS =300;
            stimPostMS=100;
            
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
            
            if false
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
                rands=[data.tonics; data.bsts];
                randrng=[min(rands) max(rands)];
                rands=rand(length(rands),1) * (randrng(2)-randrng(1)) + randrng(1);
                staResampSig(rands,[0 0 0]);
                title('rand')
            end
            
        end
        
        if false
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
                frameTimes=data.frames([false; d>thresh],2); %changed , to ; for last cell -- other cells d isn't a column?
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
            
            bsts{1}=burstyB;
            bsts{2}=tonicyB;
            spks{1}=burstyS;
            spks{2}=tonicyS;
            
            if true
                if any(length(unique(idx'))~=cellfun(@length,{names,bsts,spks}))
                    error('numstates error')
                end
                
                frameTimes = {frameTransitions,'frame times'};
                lfp        = {data.phys       ,'lfp'        };
                rawStim    = {data.stim       ,'raw stim'   };
                stim       = {frames          ,'stim'       };
                evts       = {spks,'tonics';bsts,'bursts'};
                
                if false
                    %frametimes vs. spks
                    f=[f stateCoh(frameTimes,evts      ,'pt' ,names  ,data.rec.display_type)];
                    
                    %stim vs. spks
                    f=[f stateCoh(stim      ,evts      ,'hyb',names  ,data.rec.display_type)];
                    f=[f stateCoh(rawStim   ,evts      ,'hyb',names  ,data.rec.display_type)];
                    
                    %lfp vs. spks
                    f=[f stateCoh(lfp       ,evts      ,'hyb',names  ,data.rec.display_type)];
                    
                    %lfp vs. stim
                    f=[f stateCoh(lfp       ,stim      ,'con',{}     ,data.rec.display_type)];
                    f=[f stateCoh(lfp       ,rawStim   ,'con',{}     ,data.rec.display_type)];
                    
                    %lfp vs. frametimes
                    f=[f stateCoh(lfp       ,frameTimes,'hyb',names  ,data.rec.display_type)];
                else
                    
                    %lfp vs. spks
                    f=[f stateCoh(lfp       ,evts      ,'hyb',names  ,data.rec.display_type)];
                end
            else
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
        end
        
        %keyboard
        %coherenceAnalysis(frames,{tonicyS,burstyS,tonicyB,burstyB});
        %coherenceAnalysis(data.stim,{tonicyS,burstyS,tonicyB,burstyB});
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
    
    [burstyS tonicyS]=segregate(data.tonics); %used to be data.spks -- serious error i think
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
            plot(xs,zeros(1,2),code,'linewidth',2);
        else
            xs=ts-start;
            plot(xs,out,code,'linewidth',2);
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

function out=shift(in,amt)
inds=1:length(in);
out=interp1(inds,in,inds-amt);
end

function offsets=align(block,timestep,timeLimit,check)
xcs=xcorr(block',round(timeLimit/timestep)); % 1/timestep/2));  %HERE'S WHERE WE OOM (188 04.29.09 1.sinusoid.z.27.89.t.0.007-2338.31.chunk.1.eb9916e6e433e0599a743952acd19ec218eb83cb)

[junk minds]=max(xcs);

offsets=timestep*(minds-ceil(size(xcs,1)/2));

if any(abs(offsets(:))>.1)
    max(abs(offsets(:)))
    warning('offsets more than 100ms')
end

offsets=reshape(offsets,size(block,1),size(block,1)); %columns are list of offsets for each trial relative to every other trial

if exist('check','var') && check
    keyboard
    plot(repmat(timestep*(1:size(block,2))',1,size(block,1))+repmat(offsets(:,1)',size(block,2),1),block')
    
    junk=repmat(offsets(:,1)',size(block,2),1);
    plot(junk,'r')
end
end

function [out bins]=breakup(thisStim,starts,timestep,trialDur)

bins=0:timestep:(trialDur + timestep);

for i=1:length(starts)
    inds=thisStim(2,:)>=starts(i) & thisStim(2,:)<=starts(i)+trialDur;
    if false
        out(i,:)=interp1(thisStim(2,inds)-thisStim(2,find(inds,1)),thisStim(1,inds),bins,'pchip',nan); %losing low contrast high freq signals
    else
        original=thisStim(1,inds);
        if abs(1-median(diff(thisStim(2,inds)))/timestep)<.01
            d=length(bins)-length(original);
            if d>0
                original=[original nan(1,d)];
            elseif d<0
                original=original(1:length(bins));
            end
            out(i,:)=original;
        else
            error('bad timestep')
        end
    end
    firstNan=find(isnan(out(i,:)),1);
    if isempty(firstNan)
        nanStart(i)=size(out,2)+1;
    else
        nanStart(i)=firstNan;
    end
    out(i,:)=out(i,:)-mean(out(i,~isnan(out(i,:))));
end

lastGood=min(nanStart(1:end-1)); %last trial is probably partial (what about first trial?)
if lastGood/length(bins) < .95
    for i=1:length(starts)-1
        plot(i+thisStim(1,thisStim(2,:)>=starts(i) & thisStim(2,:)<=starts(i+1)))
        hold on
    end
    error('early nans')
end

if nanStart(end)<lastGood
    out=out(1:end-1,:);
end

out=out(:,1:lastGood-1);
bins=bins(1:lastGood-1);

if any(isnan(out(:)))
    error('nan error')
end

end

function [amp freq]=getSinParams(fitData,fitTs)
model=fittype('sin1');
options=fitoptions(model);
if ~all(cellfun(@strcmp,coeffnames(model),{'a1','b1','c1'}'))
    coeffnames(model)
    error('coeff name error')
end

cfun = fit(fitTs',fitData',model,options);

if false
    figure
    plot(cfun,'g',fitTs,fitData,'k')
end



[junk ampInd]=ismember('a1',coeffnames(cfun));
if ampInd~=1 || ~isscalar(ampInd)
    error('bad cfun output')
end
a1=coeffvalues(cfun);
amp=a1(ampInd);



[junk freqInd]=ismember('b1',coeffnames(cfun));
if freqInd~=2 || ~isscalar(freqInd)
    error('bad cfun output')
end
b1=coeffvalues(cfun);
freq=b1(freqInd)/(2*pi);
end

function f=raster(data)
f=figure;

if false
    thisStim=data.stim;
    error('not implmented')
else
    thisStim=data.frames'; % won't have equal dt's
    if isempty(thisStim)
        warning('empty data.frames?')
        return
    end
end

doSinusoidal=true;

if doSinusoidal
    timestep=median(diff(thisStim(2,:)));
    
    meanlessStim=thisStim(1,:)-mean(thisStim(1,:));
    windowDur=.25;
    windowTimes=min(thisStim(2,:)):windowDur:max(thisStim(2,:));
    windowFits=nan(2,length(windowTimes)-1);
    for windowNum=1:length(windowTimes)-1
        windowInds=thisStim(2,:)>=windowTimes(windowNum)&thisStim(2,:)<=windowTimes(windowNum+1);
        [windowFits(1,windowNum) windowFits(2,windowNum)]=getSinParams(meanlessStim(1,windowInds),thisStim(2,windowInds));
        if rand>.9
            fprintf('%g%% done\n',100*windowNum/(length(windowTimes)-1))
        end
    end
    subplot(3,1,1)
    plot(thisStim(2,:),normalize(meanlessStim),'r')
    hold on
    plot(windowTimes(1:end-1),normalize(windowFits(1,:)),'b')
    plot(windowTimes(1:end-1),windowFits(2,:)/50,'g')
    subplot(3,1,2)
    xc=diff(xcorr(windowFits(2,:)));
    exclude=5;
    excludeInds=round(exclude/windowDur);
    xc((-excludeInds:excludeInds)+length(xc)/2)=0;
    
    %need to fit to series of deltas instead, to get smallest possible repeat length.
    
    [junk v]=sort(xc,'descend');
    if false
        xDone=false;
        xInd=1;
        while ~xDone
            peaks=find(diff(xc>v(xInd)));
            if length(peaks)>2
                xDone=true;
            else
                xInd=xInd+1;
                if xInd>length(v)
                    error('no peaks')
                end
            end
        end
    end
    plot(xc);
    hold on
    if false
        for pNum=1:length(peaks)
            plot(ones(1,2)*peaks(pNum),minmax(xc),'k')
        end
    end
    plot(ones(1,2)*v(1),minmax(xc),'r')
    
    indsOffset=abs(v(1)-length(xc)/2); %use XCFit if necessary instead...
    
    subplot(3,1,3)
    for i=1:ceil(size(windowFits,2)/indsOffset)
        inds=(1:indsOffset)+(i-1)*indsOffset;
        inds=inds(inds<=size(windowFits,2));
        %plot(windowTimes(inds),normalize(windowFits(1,inds)),'b')
        plot(1+mod(inds-1,indsOffset),windowFits(2,inds)+(i-1)*max(windowFits(2,:)),'g')
        hold on
                plot([1 indsOffset],ones(1,2)*(i-1)*max(windowFits(2,:)),'k')
    end
    
    fracOffset=indsOffset/(length(xc)/2);
    windowFrac=.2;
    indsOffset=fitXCModel(diff(xcorr(thisStim(1,:))),round((1 + windowFrac*[-1 1])*fracOffset*size(thisStim,2)));
    
    f=[f figure];
    
    offsetIndsStarts=[];
    for i=1:ceil(size(thisStim,2)/indsOffset)
        inds=(1:indsOffset)+(i-1)*indsOffset;
        offsetIndsStarts(end+1)=inds(1);
        inds=inds(inds<=size(thisStim,2));
        plot(1+mod(inds-1,indsOffset),thisStim(1,inds)+(i-1)*max(thisStim(1,:)),'g')
        hold on
        plot([1 indsOffset],ones(1,2)*(i-1)+mean(thisStim(1,inds)),'k')
    end
    
    %hilbert instantaneous freq -- note is not considered best way to
    %get inst. freq -- senseitive to noise -- only works for low freqs
    %relative to sampling rate
    % plot(diff(unwrap(angle(hilbert(sin(24*2*pi*timestep*(1:1000))))))/(timestep*2*pi),'k')
    
    f=[f figure];
    
    trialStartTimes=thisStim(2,offsetIndsStarts);
    
else
    if size(data.rptStarts,1)>1
        if ~isvector(data.rptStarts)
            error('data.rptStarts not a vector')
        end
        data.rptStarts=data.rptStarts';
        warning('had to transpose data.rptStarts -- why?')
    end
    
    trialStartTimes=data.rptStarts;
end

%if ~isempty(data.rptStarts) && length(data.rptStarts)>1 % *2*  %skipping
%raster cuz no rpts id''d (now should be fixed with new rpt analysis -- see
%offsetIndsStarts above)

if ~isempty(trialStartTimes) && length(trialStartTimes>1)
    
    missed=.01 < abs(1 - diff(trialStartTimes)/median(diff(trialStartTimes)));
    if any(missed)
        warning('%d index pulses missed',sum(missed))
    end
    
    if doSinusoidal
        try
            trialDur=median(diff(trialStartTimes));
            [block bins]=breakup(thisStim,trialStartTimes,timestep,trialDur);
            
            offsets=align(block,timestep,1);
            ex=1; %consider picking a better one
            offsets=offsets(:,ex);
            
            if false %i think our new offsets are better in every case -- just ignore old data.offsets calculations...
                if ~isempty(data.offsets) && any(abs(data.offsets(1:length(offsets))'-offsets)>.01) % *1* can't do this if we use new trial detector -- num trials may differ
                    if true
                        data.offsets(1:length(offsets))'-offsets
                        warning('data.offsets disagrees with offsets, using offsets for now...')
                    else
                        plot(data.offsets)
                        hold on
                        plot(offsets,'r')
                        keyboard %what now?
                    end
                end
            end
            
            
            trialStarts=trialStartTimes(1:length(offsets))'-offsets;
            
            [block bins]=breakup(thisStim,trialStarts,timestep,trialDur); %how can block come back with fewer trials than trialStarts? 19 vs. 20, even though rptStarts has 21 for 04.15.09 1.sinusoid.z.47.34.t.2614.01-3169.56.chunk.1.8d2b23279f87853a7c63e4ab0ed38b8b150c317d
            
            subplot(5,1,1)
            plot(bins,block')
            xlim([0 trialDur])
            
            subplot(5,1,2)
            freqs=0:ceil(1/(2*timestep));
            rez=.5;
            
            p=.95;
            params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
            params.Fs=1/timestep;
            params.trialave=1;
            [garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
            params.err=0;
            
            movingwin=[rez rez]; %[window winstep] (in secs)
            
            movingwin=[.5 .05];
            
            
            [S,t,specf]=mtspecgramc(block',movingwin,params);
            
            S=log(S');
            imagesc(t,specf,S);
            
            numContrasts=5;
            knownFreqs=[1 5 10 25 50];%how get these?
            
            hold on
            fits=nan(2,size(S,2));
            for i=1:size(S,2)
                if false %this is wrong and was designed for S', fyi
                    samps=[];
                    for j=1:size(S,2)
                        samps=[samps specf(j)*ones(1,round(S(i,j)*10^4))];
                    end
                    plot(t(i),normfit(samps),'ko');
                end
                fits(:,i)=gaussMeanFit([specf; S(:,i)'],minmax(knownFreqs));
            end
            plot(t,fits(1,:),'ko');
            
            [hc hf]=hist(fits(1,:),200);
            knownFreqs=round(findFreqs([hf;hc],length(knownFreqs),minmax(knownFreqs)));
            
            tStep=median(diff(t));
            prenans=round((min(t)-min(bins))/tStep);
            postnans=round((max(bins)-max(t))/tStep);
            
            newT=[linspace(bins(1),t(1)-tStep,prenans) t linspace(t(end)+tStep,bins(end),postnans)];
            subplot(5,1,3)
            [fixFits hack sinAmps]=fitSinusoidal([nan(2,prenans) fits nan(2,postnans)],knownFreqs,numContrasts,specf,[nan(length(specf),prenans) S nan(length(specf),postnans)],newT);
            xlim(minmax(bins));
            
            subplot(5,1,5)
            plot(sinAmps)
            title('abs(fft)')
            
            subplot(5,1,2)
            plot(newT,fixFits(1,:),'k');
            xlim(minmax(bins));
            
            subplot(5,1,4)
            plot(newT,fixFits(2,:))
            xlim(minmax(bins));
            
            
            
            
            
            
            
            
            
            
            if false
                
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
                    %trial.  and if using data.frames, framedrops screw things up...
                    inds{i}=find(thisStim(2,:)>=data.rptStarts(i) & thisStim(2,:)<endT);
                    
                    
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
                
                timestep=median(diff(thisStim(2,:)));
                maxTime=len*timestep;
                %bins=0:timestep:(len-1)*timestep;
                thisDur=thisLen*timestep;
                
                
                
                %%%%%
                
                goodRefs=[];
                thisLen=median(cellfun(@length,inds));
                block=nan(length(data.rptStarts),len);
                for i=1:length(inds)
                    if useMinLength
                        block(i,:)=thisStim(1,inds{i}(1:len));
                        error('not implemented')
                    else
                        block(i,1:length(inds{i}))=interp1(thisStim(1,inds{i}),thisStim(2,inds{i})-thisStim(2,inds{i}(1)),bins,'pchip');
                    end
                    
                    if length(inds{i})==thisLen
                        goodRefs(end+1)=i;
                    end
                end
                
                if useMinLength
                    tmp=block(1:end-1,:);
                    if any(isnan(tmp(:)))
                        error('nan error')
                    end
                end
                
                if length(inds{end})/mean(cellfun(@(x)length(x),inds))<.95 %last trial is probably partial (what about first trial?)
                    block=block(1:end-1,:);
                    
                    rasters=rasters(1:end-1);
                    bursts=bursts(1:end-1);
                    inBursts=inBursts(1:end-1);
                    violations=violations(1:end-1);
                end
                
                
                
                if ~isempty(goodRefs)
                    
                    offsets=align(block,timestep,1);
                    
                    if false
                        subplot(2,1,1)
                        plot((offsets + repmat(timestep*.5*(1:size(block,1))',1,size(block,1)))')
                        subplot(2,1,2)
                        plot(data.offsets)
                    end
                else
                    error('no good refs')
                end
                
                if isempty(data.offsets)
                    ex = min(goodRefs);
                    
                    offsets=offsets(:,ex); %((1:size(block,1))+(ex-1)*size(block,1),:);
                    
                    subplot(2,1,1)
                    plot(block')
                    
                    for i=1:size(block,1)
                        
                        rasters{i}=rasters{i}+offsets(i);
                        bursts{i}= bursts{i}+offsets(i);
                        inBursts{i}=inBursts{i}+offsets(i);
                        violations{i}=violations{i}+offsets(i);
                        
                        % TODO: need to also fix block -- should cover all stim stuff
                        block(i,:)=shift(block(i,:),offsets(i)/timestep);
                    end
                    
                    subplot(2,1,2)
                    plot(block')
                else
                    error('haven''t written yet')
                end
                
                
                
                psth=0;
                bpsth=0;
                %pbins=0:.01:maxTime;
                %pbins=0:.05:maxTime;
                pbins=0:timestep:maxTime;
                
                if false
                    block=mean(block);
                end
                
                block=block'-min(block(:));
                block=block/max(block(:));
                
                for i=1:length(rasters)
                    psth=psth+hist(rasters{i}(rasters{i}<=maxTime),pbins);
                    bpsth=bpsth+hist(bursts{i}(bursts{i}<=maxTime),pbins);
                end
                
                n=5;
                
                avgStim=nanmean(block');
                
                subplot(n,1,1)
                allStims=repmat(.1*(0:size(block,2)-1),size(block,1),1)+block+1;
                plot(bins,allStims)
                xlim([0 thisDur])
                
                subplot(n,1,2)
                plot(0:timestep:timestep*(length(avgStim)-1),avgStim)
                xlim([0 thisDur])
                
                subplot(n,1,3)
                freqs=0:ceil(1/(2*timestep));
                rez=.5;
                
                if false
                    [stft fr t p]=spectrogram(avgStim-mean(avgStim),round(rez/timestep),[],freqs,1/timestep); %phase misalignments will cause bad cancellations here
                    imagesc(t,fr,log(p))
                else
                    
                    p=.95;
                    params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
                    params.Fs=1/timestep;
                    params.trialave=1;
                    [garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
                    params.err=0;
                    
                    movingwin=[rez rez]; %[window winstep] (in secs)
                    
                    movingwin=[.5 .05];
                    
                    for i=1:size(block,2)
                        block(:,i)=block(:,i)-mean(block(~isnan(block(:,i)),i));
                    end
                    
                    %trimBlock=block(1:end-1,:); %exclude last trial cuz it's probably partial (what about first trials...?)
                    blockNan=find(sum(isnan(block'))>0,1);
                    if ~isempty(blockNan)
                        if blockNan/size(block,1)<.95
                            error('early nans')
                        end
                        trimBlock=block(1:blockNan-1,:);
                    else
                        trimBlock=block;
                    end
                    
                    if false
                        blockNans=isnan(block);
                        blockNan=0;
                        for col=1:size(blockNans,1)
                            if blockNan<=0 && sum(blockNans(col,:))>0
                                blockNan=col;
                                if col/size(blockNans,1)<.95
                                    error('early nans')
                                end
                            end
                        end
                        trimBlock=block(:,1:blockNan-1);
                    end
                    
                    if sum(isnan(trimBlock(:)))>0
                        error('didn''t get rid of all nans')
                    end
                    
                    %block=block(:,sum(isnan(block))==0); %i don't think chronux can deal with nans
                    if isempty(trimBlock)
                        error('all trials had a nan')
                    end
                    
                    
                    [S,t,specf]=mtspecgramc(trimBlock,movingwin,params);
                    
                    S=log(S');
                    imagesc(t,specf,S);
                    
                    numContrasts=5;
                    knownFreqs=[1 5 10 25 50];%how get these?
                    
                    hold on
                    fits=nan(2,size(S,2));
                    for i=1:size(S,2)
                        if false %this is wrong and was designed for S', fyi
                            samps=[];
                            for j=1:size(S,2)
                                samps=[samps specf(j)*ones(1,round(S(i,j)*10^4))];
                            end
                            plot(t(i),normfit(samps),'ko');
                        end
                        fits(:,i)=gaussMeanFit([specf; S(:,i)'],minmax(knownFreqs));
                    end
                    plot(t,fits(1,:),'ko');
                    
                    [hc hf]=hist(fits(1,:),200);
                    knownFreqs=round(findFreqs([hf;hc],length(knownFreqs),minmax(knownFreqs)));
                    
                    tStep=median(diff(t));
                    prenans=round((min(t)-min(bins))/tStep);
                    postnans=round((max(bins)-max(t))/tStep);
                    
                    newT=[linspace(bins(1),t(1)-tStep,prenans) t linspace(t(end)+tStep,bins(end),postnans)];
                    subplot(n,1,4)
                    [fixFits hack]=fitSinusoidal([nan(2,prenans) fits nan(2,postnans)],knownFreqs,numContrasts,specf,[nan(length(specf),prenans) S nan(length(specf),postnans)],newT);
                    xlim(minmax(bins));
                    
                    subplot(n,1,3)
                    plot(newT,fixFits(1,:),'k');
                    xlim(minmax(bins));
                    
                    subplot(n,1,5)
                    plot(newT,fixFits(2,:))
                    xlim(minmax(bins));
                end
                
                doSinusoid=true;
                
                if doSinusoid
                end
                
            end
            
            %this is for 03.13 data
            %1 50 4 1 25  50 10 50 4 1  1 25 25 10 4  50 10 10 1 25  10 50 4 25 4
            %hackFreqs     = [0 50 5 0 25, 50 10 50 5 0, 0 25 25 10 5, 50 10 10 0 25, 10 50 5 25 5];
            
            %[4 2  2 1 2   1  1  5  3 2  5 3  5  5  5  3  2  3  3 4   4  4  4 1  1
            %hackContrasts = [4 2  2 1 2   4  1  5  3 2  5 3  5  5  5  3  2  3  3 4   4  1  4 1  1];
            
            hackFreqs    =hack(1,:);
            hackContrasts=hack(2,:);
            
            uFreqs=sort(unique(hackFreqs));
            uContrasts=sort(unique(hackContrasts));
            
            %chunkLen=ceil(length(bins)/length(hackFreqs));
            chunkDur= trialDur/length(hackFreqs);
            
            %allStims=allStims-repmat(nanMeanDown(allStims),size(allStims,1),1);
            %plot(allStims)
            
            n=5;
            
            thisFig=1;
            for i=1:length(uFreqs)
                f=[f figure];
                subplot(n,1,4)
                
                fInds=find(uFreqs(i)==hackFreqs);
                if length(fInds)~=length(uContrasts)
                    error('f error')
                end
                for j=1:length(uContrasts)
                    cInd=find(hackContrasts(fInds)==j);
                    if ~isscalar(cInd)
                        error('c error')
                    end
                    freqInds(i,j)=fInds(cInd);
                    
                    
                    
                    %theseInds=(freqInds(i,j)-1)*chunkLen+(1:chunkLen); %-1); %need chunkLen-1 cuz right now we have thisLen=2499 -- shouldn't be -- does pushing it to 2500 help alignment?
                    lims=[0 chunkDur]+(freqInds(i,j)-1)*chunkDur;
                    
                    cs=5;
                    
                    
                    
                    %theseInds=theseInds(theseInds<=size(block,2));
                    
                    chunk=block(:,feval(@(x) max(1,x(1)):min(size(block,2),x(2)), round(size(block,2)*(lims./trialDur))));
                    localOffsets=align(chunk,timestep,2/uFreqs(i));
                    localOffsets=localOffsets(:,ex);
                    
                    chunkStarts=lims(1)+trialStarts-localOffsets;
                    [chunkBlock chunkBins]=breakup(thisStim,chunkStarts,timestep,chunkDur); %not getting alignment... why?
                    
                    subplot(cs,length(uContrasts),j) % (j-1)*cs)
                    
                    if false
                        close all
                        
                        plot(allStims(theseInds(20:75),1:10))
                        cs=xcorr(allStims(theseInds(20:75),1:10));
                        plot(diff(cs(:,(1:48))))
                        figure
                        plot(cs(:,(1:48)+48*3))
                        plot(diff(cs(:,(1:48)+48*9)))
                    end
                    
                    
                    %plot(bins(theseInds),allStims(theseInds,:))
                    %plot((bins(repmat(theseInds,size(trimBlock,2),1))+repmat(localOffsets,1,length(theseInds)))',trimBlock(theseInds,:)+repmat(.1*(0:size(trimBlock,2)-1),length(theseInds),1))
                    %xlim(lims)
                    
                    %plot(chunkBins,chunkBlock'+repmat(.1*(0:size(chunkBlock,1)-1),size(chunkBlock,2),1))
                    dispChunk=chunk' + repmat(.1*(0:size(chunk,1)-1),size(chunk,2),1);
                    plot(repmat(((0:size(chunk,2)-1)*timestep)',1,size(chunk,1)) + repmat(localOffsets',size(chunk,2),1),dispChunk); %gah -- ok -- need to figure out how to use these offsets, why can't use breakup, and fix rasters
                    xlim([0 chunkDur])
                    ylim([min(dispChunk(:)) max(dispChunk(:))])
                    title(sprintf('f=%ghz c=%g',uFreqs(i),j))
                    
                    if j==4 && uFreqs(i)==25 && false
                        if false
                            subplot(cs,length(uContrasts),length(uContrasts)+j)  % (j-1)*cs+1)
                            plot(localOffsets)
                        end
                        localOffsets=align(block(:,feval(@(x) x(1):x(2), round(size(block,2)*(lims./trialDur)))),timestep,2/uFreqs(i),true);
                        keyboard
                    end
                    
                    
                    
                    
                    test=false;
                    
                    thisPsth=0;
                    thisBpsth=0;
                    for ind=1:size(chunkBlock,1)
                        if test
                            theseRasters   {ind}=makeSpikes([0 chunkDur],[ uFreqs(i)*[1 .5]],20,timestep);
                            theseBRasters  {ind}=makeSpikes([0 chunkDur],[ uFreqs(i)*[1 .5]],5 ,timestep);
                            theseInBursts  {ind}=makeSpikes([0 chunkDur],[ uFreqs(i)*[1 .5]],2 ,timestep);
                            theseViolations{ind}=makeSpikes([0 chunkDur],[ uFreqs(i)*[1 .5]],1 ,timestep);
                        else
                            chunkStart=chunkStarts(ind); %this is looking wrong -- check above how it didn't work for stim
                            theseRasters   {ind}=separate(data.tonics   ,chunkStart,chunkStart+chunkDur);
                            theseBRasters  {ind}=separate(data.bsts     ,chunkStart,chunkStart+chunkDur);
                            theseInBursts  {ind}=separate(data.bstNotFst,chunkStart,chunkStart+chunkDur);
                            theseViolations{ind}=separate(data.refVios  ,chunkStart,chunkStart+chunkDur);
                        end
                        thisPsth =thisPsth +hist(theseRasters {ind},chunkBins);
                        thisBpsth=thisBpsth+hist(theseBRasters{ind},chunkBins);
                    end
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    subplot(cs,length(uContrasts),length(uContrasts)+j)  % (j-1)*cs+1)
                    
                    if false
                        theseRasters   =cellfun(@(x,y) x+y, rasters   ,num2cell(localOffsets'),'UniformOutput',false);
                        theseBRasters  =cellfun(@(x,y) x+y, bursts    ,num2cell(localOffsets'),'UniformOutput',false);
                        theseInBursts  =cellfun(@(x,y) x+y, inBursts  ,num2cell(localOffsets'),'UniformOutput',false);
                        theseViolations=cellfun(@(x,y) x+y, violations,num2cell(localOffsets'),'UniformOutput',false);
                    end
                    
                    cellfun(@(c) doRaster( c{1} ,c{2},[0 chunkDur]),{ {theseRasters,'k.'} {theseBRasters,'ro'} {theseInBursts,'r.'} {theseViolations,'bo'} });
                    xlim([0 chunkDur])
                    
                    if false
                        
                        thisPsth=0;
                        thisBpsth=0;
                        for inc=1:length(rasters)
                            thisPsth=thisPsth+hist(theseRasters{inc},pbins);
                            thisBpsth=thisBpsth+hist(theseBRasters{inc},pbins);
                        end
                        
                    end
                    
                    subplot(cs,length(uContrasts),length(uContrasts)*2+j) %(j-1)*cs+2)
                    plot(chunkBins,thisPsth,'k')
                    hold on
                    plot(chunkBins,thisBpsth,'r')
                    xlim([0 chunkDur])
                    
                    
                    f0(i,j)=sum(thisPsth)/length(theseRasters);
                    
                    [Pxx,Pxxc,fr] = pmtm(thisPsth,[],freqs,1/timestep,.95);
                    if ~all(fr==freqs)
                        error('f error')
                    end
                    
                    mtmF1(i,j)=Pxx(uFreqs(i)+1);
                    mtmF0(i,j)=Pxx(1);
                    
                    subplot(cs,length(uContrasts),length(uContrasts)*3+j)
                    plot(freqs,normalize(Pxx),'b')
                    
                    
                    
                    
                    hold on
                    
                    %unclear what method psd uses
                    %the recommendation is pwelch, but that is at least different in that
                    %it normalizes freq to pi
                    warning('off','signal:psd:PSDisObsolete')
                    
                    
                    [S,psdF]=psd(thisPsth);
                    psdF=psdF/timestep/2;
                    plot(psdF,normalize(S),'g')
                    psdF1(i,j)=interp1(psdF,S,uFreqs(i),'pchip','extrap');
                    psdF0(i,j)=interp1(psdF,S,0);
                    
                    
                    
                    S=abs(fft(thisPsth));
                    S=S(1:ceil(length(S)/2));
                    fftF=linspace(0,1/timestep/2,length(S));
                    plot(fftF,normalize(S),'r')
                    fftF1(i,j)=interp1(fftF,S,uFreqs(i),'pchip','extrap');
                    fftF0(i,j)=S(1);
                    
                    title('psth power')
                    
                    
                    
                    
                    %'rate modulation' std of 1ms binned psth
                    %stim coherence
                    
                    
                    xcTime=.001;
                    forChronux=cell2struct(theseRasters,'times');
                    tinyTimes=chunkBins(1):xcTime:chunkBins(end);
                    tinyRast=[];
                    fftByTrial=[];
                    psdByTrial=[];
                    pmtmByTrial=[];
                    for ind=1:length(forChronux)
                        %spks=bound(forChronux(ind).times,lims);
                        %forChronux(ind).times=spks-lims(1);
                        
                        %tinyStim(ind,:)=; %needed for by-trial-coherence
                        tinyRast(ind,:)=hist(forChronux(ind).times,tinyTimes);
                        
                        x=xcorr(tinyRast(ind,:));
                        
                        fftX=abs(fft(x));
                        fftX=fftX(1:ceil(length(fftX)/2));
                        fftByTrial(ind,:)=interp1(linspace(0,1/xcTime/2,length(fftX)),fftX,fftF);
                        
                        [psdX,psdFprime]=psd(x);
                        psdByTrial(ind,:)=interp1(psdFprime/xcTime/2,psdX,psdF);
                        
                        pmtmByTrial(ind,:)=pmtm(x,[],freqs,1/timestep,.95);
                    end
                    
                    sd(i,j) = std(sum(tinyRast));%pam's "rate modulation" measure
                    va(i,j) = var(sum(tinyRast'));%for fano factor
                    mn(i,j)= mean(sum(tinyRast'));%TODO: divide by avg trial length (accounting for nans for partial trials);
                    
                    fftByTrial=mean(fftByTrial);
                    psdByTrial=mean(psdByTrial);
                    pmtmByTrial=mean(pmtmByTrial);
                    
                    %try
                    [S,specf]=mtspectrumpt(forChronux,params);
                    %                 catch ex
                    %                     if strcmp(ex.message,'Time-bandwidth product NW must be less than N/2.')
                    %                         S=
                    %                         f
                    %
                    %                     else
                    %                         error('mtspectrumpt error')
                    %                     end
                    %                 end
                    
                    
                    
                    
                    f1(i,j)=interp1(specf,S,uFreqs(i),'pchip','extrap');
                    compf0(i,j)=interp1(specf,S,0);
                    
                    
                    
                    subplot(cs,length(uContrasts),length(uContrasts)*4+j)
                    
                    
                    plot(specf,normalize(S),'k');
                    hold on
                    plot(fftF,normalize(fftByTrial),'r')
                    
                    plot(psdF,normalize(psdByTrial),'g')
                    plot(freqs,normalize(pmtmByTrial),'b')
                    title('by trial')
                    
                    
                    %stims4chronux=trimBlock(sub2ind(size(trimBlock),min(size(trimBlock,1),max(1,(repmat(theseInds,size(trimBlock,2),1)-repmat(round(localOffsets/timestep),1,length(theseInds)))')),repmat(1:size(trimBlock,2),length(theseInds),1)));
                    
                    paramsC=params;
                    paramsC.err=[2 .95]; %check if this .95 should be .05!
                    
                    [thisC,phi,S12,S1,S2,cfs,zerosp,confC,phistd,Cerr]=coherencycpt(chunkBlock',forChronux,paramsC); %chunkBlock needs alignment fixes here, see above...
                    if any(isnan(thisC))
                        error('this should be fixed now (see changes in mtfftpt)')
                        silentTrials=cellfun(@isempty,{forChronux.times});
                        warning('coherencycpt seems to not be able to handle trials with no spikes (throwing away %g of them)',sum(silentTrials))
                        [thisC,phi,S12,S1,S2,cfs,zerosp,confC,phistd,Cerr]=coherencycpt(chunkBlock(~silentTrials,:)',forChronux(~silentTrials),paramsC);
                    end
                    C(i,j)=interp1(cfs,thisC,uFreqs(i),'pchip','extrap'); %*3*                    
                    
                    sinAmps(i,j)=mean(std(chunkBlock'));
                    
                    fitAmps=[];
                    fitFreqs=[];
                    for trialNum=1:size(chunkBlock,1)
                        
                        %cfun=fitRectifiedFModel(2,chunkBlock(trialNum,1:round(.8*size(chunkBlock,2))),1/timestep,uFreqs(i)); %need to verify these figs look ok, also allow model to have zero offset and only one harmonic
                        
                        
                        fitData=chunkBlock(trialNum,1:round(.8*size(chunkBlock,2)));
                        fitTs=(0:(length(fitData)-1))/(1/timestep);
                        
                        [fitAmps(end+1) fitFreqs(end+1)] = getSinParams(fitData,fitTs);
                        
                    end
                    sinAmpsFit(i,j)=mean(fitAmps);
                    sinFreqsFit(i,j)=mean(fitFreqs);
                    
                    if false
                        oldFig=gcf;
                        thisFig=thisFig+1;
                        figure(100+thisFig)
                        plot(stims4chronux)
                        figure(oldFig);
                    end
                end
            end
            
            if false
                f=[f figure];
                
                subplot(4,1,1)
                c=colormap;
                cs=ceil(linspace(1,size(c,1),length(uContrasts)));
                for i=1:length(uContrasts)
                    plot(uFreqs,f0(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('f0')
                xlabel('freq (hz)')
                ylabel('spikes/s')
                
                subplot(4,1,2)
                for i=1:length(uContrasts)
                    plot(uFreqs,compf0(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('compf0')
                xlabel('freq (hz)')
                
                subplot(4,1,3)
                for i=1:length(uContrasts)
                    plot(uFreqs,f1(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('f1')
                xlabel('freq (hz)')
                
                subplot(4,1,4)
                for i=1:length(uContrasts)
                    plot(uFreqs,f1(:,i)./compf0(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('f1/f0')
                xlabel('freq (hz)')
                
                
                f=[f figure];
                subplot(4,1,1)
                for i=1:length(uContrasts)
                    plot(uFreqs,sd(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('std')
                xlabel('freq (hz)')
                
                
                subplot(4,1,2)
                for i=1:length(uContrasts)
                    plot(uFreqs,va(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('var')
                xlabel('freq (hz)')
                
                subplot(4,1,3)
                for i=1:length(uContrasts)
                    plot(uFreqs,mn(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('mean')
                xlabel('freq (hz)')
                
                
                subplot(4,1,4)
                for i=1:length(uContrasts)
                    plot(uFreqs,va(:,i)./mn(:,i),'Color',c(cs(i),:));
                    hold on
                end
                title('fano factor')
                xlabel('freq (hz)')
            end
            
                        n=3;
            c=colormap;
            ccs=ceil(linspace(1,size(c,1),length(uContrasts)));
            fcs=ceil(linspace(1,size(c,1),length(uFreqs)));
            
            uFreqs
            
                        doSummaryFig({'mean(std(stim))','amp fit','freq fit'});
            doSummaryFig({'mean','f1','f1/mean','coh','std','ff'});
            
            %save('C:\Documents and Settings\rlab\Desktop\for pam.mat','uFreqs','uContrasts','f0','sd','va','mn','f1','C'); % all are freqs x contrasts
            
        catch ex
            ex.message
            getReport(ex)
            if strcmp(ex.message,'Out of memory. Type HELP MEMORY for your options.')
                error('matlab needs to restart -- OOM');
            elseif strcmp(ex.message,'Matrix dimensions must agree.')
                error('what''s this about?')
            else
                error('catch everything')
            end
            
            warning('skipping sinusoidal due to error')
        end
    else
        if false %the old way makes too many graphics objects and overwhelms gfx memory
            
            if false %lab meeting hack
                plot(bins,repmat(.1*(0:size(block,2)-1),size(block,1),1)+block+1)
            else
                %plot(bins,zeros(size(bins)));
                hold on
            end
            
            %xlabel('secs')
            %title(sprintf('%d gaussian repeats (%.1f hz, %.1f%% bursts, %d violations)',length(data.rptStarts),length(data.spks)/(data.stimTimes(2)-data.stimTimes(1)),100*length(data.bsts)/(length(data.tonics)+length(data.bsts)),length(data.refVios)))
            hold on
            
            plot(pbins,psth/max(psth),'k')
            plot(pbins,bpsth/max(bpsth),'r')
            
            for i=1:length(rasters)
                cellfun(@(c) plotRaster(c{1}{i},c{2},i+1,maxTime),{ {rasters,'k.'} {bursts,'ro'} {inBursts,'r.'} {violations,'bo'} })
            end
            xlim([0 maxTime])
            
        else
            % clf
            
            figure(f(1));
            subplot(n,1,4)
            
            cellfun(@(c) doRaster(c{1},c{2},[0 maxTime]),{ {rasters,'k.'} {bursts,'ro'} {inBursts,'r.'} {violations,'bo'} })
            
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
            
            heightInches=heightInches/4;
            
            frac=length(rasters)/(dpi*heightInches);
            
            ylim([0 length(rasters)/min(fudge*frac,1)])
            xlim([0 thisDur]) %temp hack
        end
        
        ylabel('repeat')
        xlabel('secs')
        title(sprintf('%d %s repeats (%.1f hz, %.1f%% bursts (%d total), %d violations)',length(data.rptStarts),data.stimType,length(data.spks)/(data.stimTimes(2)-data.stimTimes(1)),100*length(data.bsts)/(length(data.tonics)+length(data.bsts)),length(data.bsts),length(data.refVios)))
    end
else
    error('should no longer happen on sinusoidals (see offsetIndsStarts)')
end

    function doSummaryFig(ps)
        f=[f figure];
        for pN=1:length(ps)
            
            switch ps{pN}
                case 'mean'
                    x=mn;
                case 'f1'
                    x=f1;
                case 'f1/mean'
                    x=f1./mn;
                case 'coh'
                    x=C;
                case 'std'
                    x=sd;
                case 'ff'
                    x=va./mn;
                case 'mean(std(stim))'
                    x=sinAmps;
                case 'amp fit'
                    x=sinAmpsFit;
                case 'freq fit'
                    x=sinFreqsFit;
                otherwise
                    error('unrecognized')
            end
            
            subplot(length(ps),n,n*(pN-1) + 1)
            for i=1:length(uContrasts)
                plot(uFreqs,x(:,i),'Color',c(ccs(i),:));
                hold on
            end
            title(ps{pN})
            if pN==length(ps)
                xlabel('freq (hz)')
            end
            xlim([min(uFreqs) max(uFreqs)])
            axis fill
            
            subplot(length(ps),n,n*(pN-1) + 2)
            for i=1:length(uFreqs)
                plot(uContrasts,x(i,:),'Color',c(fcs(i),:));
                hold on
            end
            if pN==length(ps)
                xlabel('contrast')
            end
            xlim([min(uContrasts) max(uContrasts)])
            axis fill
            
            subplot(length(ps),n,n*(pN-1) + 3)
            surfc(uContrasts,uFreqs,x) %i had this backwards -- x's rows are freqs, cols are contrasts...
            % but this agrees with surfc(1:10,100:200,rand(10,101)')
            ylabel('freq (hz)')
            xlabel('contrast')
            axis fill
        end
    end

    function doRaster(data,code,lims)
        info=[];
        for noClashI=1:length(data)
            these=data{noClashI}(data{noClashI}>=lims(1) & data{noClashI}<=lims(2));
            info=[info [noClashI*ones(1,length(these));these(:)']];
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

function out=makeSpikes(lims,fs,rate,res)
if false
    lims=[5 8];
    fs=3;
    rate=20;
    res=.01;
end

times=(0:res:diff(lims))';
out=[];
for i=1:length(fs)
    this=sin(fs(i)*2*pi*(times))/i ;
    if isempty(out)
        out=this;
    else
        out=out+this;
    end
end

out=normalize(out);

%out=lims(1)+times(find(out' * diff(lims)*rate/(timestep*sum(out)) > rand(length(out),1)));

new=rate*diff(lims)*out/sum(out);
if any(new>1)
    error('requested rate too high for res')
end

out=lims(1)+times(find(new>rand(length(out),1)));

if false
    out=[];
    for i=1:length(fs)
        out=[out linspace(lims(1),lims(2),diff(lims)*fs(i))];
    end
    out=unique(out)';
    if length(out)<3
        out=unique([out;rand(3,1)*diff(lims)+lims(1)]); %otherwise chronux scrwes up time bandwidth products and such
    end
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
        try
            inds=repmat(tinds,length(trigs),1)+repmat(trigs,1,length(tinds)); %OOM
        catch
            if all(trigs(:)>=intmin('int32')) && all(trigs(:)<=intmax('int32')) && all(tinds(:)>=intmin('int32')) && all(tinds(:)<=intmax('int32'))
                trigs=int32(trigs);
                tinds=int32(tinds);
                try
                    inds=repmat(tinds,length(trigs),1)+repmat(trigs,1,length(tinds)); % OOM
                catch
                    warning('doing only half the trigs')
                    trigs=trigs(rand(1,length(trigs))>.5);
                    inds=repmat(tinds,length(trigs),1)+repmat(trigs,1,length(tinds));
                end
            else
                error('bad trigs or tinds')
            end
        end
    else
        inds=[];
    end
    
    vals{i}=stim(1,:);
    try
        vals{i}=vals{i}(inds); %OOM
    catch
        if all(inds(:)>=0) && all(inds(:)<=intmax('uint32'))
            inds=uint32(inds);
            vals{i}=single(vals{i});
            vals{i}=vals{i}(inds);
        else
            error('bad inds')
        end
    end
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
    
    try
        [sta lags1]=xcorr(stim(1,:),train,N); %OOM
        
        % [staR lags2]=xcorr(train,stim(1,:),N); %pam uses this version, but it's reversed for me?
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
        
    catch
        warning('oom on xcorr, not doing STA in fourier space')
        corrected=[];%nan(2,length(tinds));
    end
    
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

function [stim,phys,frames,rptStarts,offsets]=extractData(fileNames,stimTimes,rec)
fprintf('\textracting stim, phys, frames...')
tic
data=load(fileNames.targetFile);
toc

try
    rptStarts=data.stimBreaks; %TODO: checks below for this case (this is the index pulse case)
    %this should fail on every dataset -- Reference to non-existent field 'stimBreaks'.
    
    offsets=data.bestBinOffsets;  %we're not going through the catch case below -- not sure this is ok or that this assignment to offsets is right...
    %only on windows does this?  haven't tried sinusoidals on osx...
    %need to add all the checks below, make sure offsets (and everything else) is right
    %size/orientation, etc.
    if all(cellfun(@(x) isempty(findstr( fileNames.targetFile,x)),{...
            '1.sinusoid.z.47.34.t.2614.01-3169.56.chunk.1.8d2b23279f87853a7c63e4ab0ed38b8b150c317d',...
            '1.sinusoid.z.47.88.t.496.35-1310.29.chunk.1.89493235e157403e6bad4b39b63b1c6234ea45dd',...
            '4.sinusoid.z.38.885.t.1576.86-1932.14.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381',...
            '4.sinusoid.z.38.885.t.1932.15-3328.chunk.2.4b45921ce9ef4421aa984128a39f2203b8f9a381',...
            '4.sinusoid.z.38.885.t.3328-3673.31.chunk.3.4b45921ce9ef4421aa984128a39f2203b8f9a381',...
            '4.sinusoid.z.38.26.t.456.372-1262.21.chunk.1.a7e4526229bb5cd78d91e543fc4a0125360ea849',...
            '1.sinusoid.z.52.48.t.4225-5549.31.chunk.1.9196f9c63cf78cac462dac2cedd55306961b7fd0',...
            '1.sinusoid.z.27.89.t.0.007-2338.31.chunk.1.eb9916e6e433e0599a743952acd19ec218eb83cb',...
            '6.sinusoid.z.27.83.t.1682.3-2938.3.chunk.1.c298e72f2ac2edbe8c043c41e72ebc6432394504',...
            '8.sinusoid(new).z.27.83.t.3060.85-4846.62.chunk.1.c298e72f2ac2edbe8c043c41e72ebc6432394504',...
            '1.sinusoid.z.28.04.t.226.44-1481.26.chunk.1.e8b33f5945b56d2bb55c8c098a1d72de73206822',...
            '1.squarefreqs.z.31.t.6123.74-6728.chunk.1.93213cc4a832b81a0ba1bf4e1e6afbfcf64b82fc',...
            '1.squarefreqs.z.31.t.6728-6980.42.chunk.2.93213cc4a832b81a0ba1bf4e1e6afbfcf64b82fc',...
            '1.squarefreqs.z.31.t.6980.45-7547.chunk.3.93213cc4a832b81a0ba1bf4e1e6afbfcf64b82fc'...
            }))
        fileNames.targetFile
        warning('not going through catch case for this file...  why?')
    end
    %isempty(findstr(fileNames.targetFile,'1.sinusoid.z.47.34.t.2614.01-3169.56.chunk.1.8d2b23279f87853a7c63e4ab0ed38b8b150c317d'))
    
    
    
catch ex
    %    ex.message
    %    fprintf('\ndoing catch case (every dataset should do this)\n')
    
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
    else
        offsets=data.bestBinOffsets;
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

function f = stateCoh(in1,in2,type,names,dispType)

if ~all(size(in1)==[1 2]) || size(in2,2)~=2
    error('bad input cells')
end

maxf=50;
f=figure;

if strcmp(type,'con')
    if ~isempty(names)
        error('we assume we''re not broken out by states when both signals continuous')
    elseif ~all(size(in2)==[1 2])
        error('bad input2 cell')
    else
        names={'all'};
    end
end

for state=1:length(names)
    for group=1:size(in2,1)
        
        switch type
            case 'pt'
                ref=in1{1}{state};
                snd=in2{group,1}{state};
            case {'hyb','con'}
                ref=in1{1};
                if strcmp(type,'con')
                    snd=in2{1};
                else
                    snd=in2{group,1}{state};
                end
            otherwise
                error('unknown type')
        end
        
        cronCoh(ref,snd,maxf,type,...
            sprintf('%s vs. %s (%s, %s)',in1{2},in2{group,2},names{state},dispType),...
            2*size(in2,1),...
            length(names),...
            state+2*(group-1)*length(names)...
            );
    end
end
end

function cronCoh(ref,evts,maxf,type,str,lx,ly,li)
check={};
doPointCheck=true;
cols={};

switch type
    case 'pt'
        fn=@cohgrampt;
        
        params.Fs=2*maxf;%600 takes about 3 mins for 30 mins data with 100Hz events and winur=1, 50 takes about 1 min.
        
        start=min([ref;evts]);
        ref=ref-start;
        evts=evts-start;
        
        %         tmp=cellfun(@(x) x-min([ref;evts]),{ref evts},'UniformOutput',false);
        %         ref=tmp{1};
        %         evts=tmp{2};
        
        ref=struct('times',ref);
        check{end+1}=ref;
        
    case 'hyb'
        fn=@cohgramcpt;
        
        params.Fs=1/median(diff(ref(2,:)));
        
        evts=evts-ref(2,1);
        
        ref=ref(1,:)';
        %ref=ref-mean(ref);
        
        cols={ref};
        
    case 'con'
        fn=@cohgramc;
        
        doPointCheck=false;
        both={ref,evts};
        
        dts=cellfun(@(x) median(diff(x(2,:))),both);
        
        params.Fs=min(1./dts);
        newNyquist=params.Fs/2;
        if maxf>newNyquist;
            maxf
            warning('had to lower frequency range')
            maxf=newNyquist
        end
        
        start=max(cellfun(@(x) x(2,1)  ,both));
        stop =min(cellfun(@(x) x(2,end),both));
        
        fprintf('resampling\n')
        tic
        cols=cellfun(@(x) interp1(x(2,:),x(1,:),start:1/params.Fs:stop,'linear')',both,'UniformOutput',false); %consider pchip or spline, if too slow try interp1q.  implications of not using resample?  high freqs will alias!  gah.
        toc
        
        ref=cols{1};
        evts=cols{2};
        
    otherwise
        error('unknown type')
end

if doPointCheck
    evts=struct('times',evts);
    check{end+1}=evts;
    
    if ~all(cellfun(@(x) all(x.times)>=0 && size(x.times,2)==1,check))
        error('negative times or not columns')
    end
end

if ~all(cellfun(@(x) size(x,2)==1,cols))
    error('we only work for single trials, which must be columns')
end

params.fpass=[0 maxf];
p=.05;

winDur = 10;%1;%.5;
params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
[garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);

movingwin=[winDur winDur]; %[window winstep] (in secs)

tic
fprintf('\ndoing coherence...')
if true
    switch type
        case {'pt','hyb'}
            [C,phi,S12,S1,S2,t,f,zerosp,confC,phistd,Cerr]=fn(ref,evts,movingwin,params,0);
        case 'con'
            [C,phi,S12,S1,S2,t,f,       confC,phistd,Cerr]=fn(ref,evts,movingwin,params); %no option for finite size correction or zerosp
            zerosp=[];
        otherwise
            error('unknown type')
    end
else
    %for fast testing
    t=1:10;
    f=1:100;
    C=rand(length(t),length(f));
    Cerr=rand(2,length(t),length(f));
    zerosp=[];
end
toc

if any(Cerr(:)<0)
    Cerr(Cerr<0)=0;
    %warning('chronux gave negative lower bound for coherence')
end

subplot(lx,ly,li)
imagesc(t,f,C');
%colorbar - this shrinks the main data badly
axis xy;
xlabel('time (s)');
ylabel('freq (hz)');
title(['coherence: ' str])

subplot(lx,ly,li+ly)
plot(f,mean(C(~zerosp,:))); %coherencypt runs out of memory even if you break into separate trials, so we do this
hold on
for i=1:size(Cerr,1)
    plot(f,squeeze(mean(Cerr(i,~zerosp,:))),'color',ones(1,3)*.5);
end
ylim([0 1])
ylabel('coherence')
xlabel('freq (hz)')
end

function doEvtPower(evts)
maxf=50;

params.Fs=2*maxf;
params.fpass=[0 maxf];
p=.05;
winDur = 10;%1;%.5;
params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
[garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);

movingwin=[winDur winDur]; %[window winstep] (in secs)


if ~isvector(evts) || ~all(diff(evts)>=0)
    error('must be ascending vector')
end
s.times=evts(:);

[S,t,f,R,Serr]=mtspecgrampt(s,movingwin,params,false);

if true
    if all(S(:)>=0)
        S=10*log10(abs(S)+eps);
    else
        error('S must be >=0')
    end
end

imagesc(t,f,S');

%colorbar - this shrinks the main data badly
axis xy;
xlabel('time (s)');
ylabel('freq (hz)');

end

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