function sortManager
%%%% set these params

spkDurMS=2;

pth='C:\Documents and Settings\rlab\Desktop\';
baseName='cell 2tmp';

%%%%% do not edit below here

close all
clc

fName=fullfile(pth,baseName,[baseName ' matted phys.mat']);
data=load(fName);

sampRate=1/data.step;
tOffset=data.first;
data=single(data.data);
[tr tc]=size(data);
if tr~=1 && tc==1
    data=data';
elseif ~tr==1
    error('bad data size')
end
secDur=length(data)/sampRate;

% sampRate=40000;
% secDur=30;
% 
% data=single(makeChunk(sampRate,secDur/60));

times=linspace(0,secDur,secDur*sampRate)+tOffset;
%data=randn(size(times));
data=data/max(abs(data));

fOrd=round(sampRate/200); %how choose filter orders?
loCut=100;
hiCut=10000;
loThresh=[];
hiThresh=[];

maxHz=150;

filt=[];
th=[];
filtV=[];
scores=[];
uScores=[];
spkTimes=[];
spks=[];
uSpks=[];
spkPts=[];

viewRate=7000;

bHeight=25;
bWidth=150;
gHeight=400;
gWidth=1500;
sWidth=20;
border=10;
hWidth=300;
saWidth=hWidth;

szs.sWidth=15;
szs.border=14;
szs.stWidth=50;
szs.stHeight=25;
szs.sHeight=gHeight-4*szs.border;

numCuts=2;
spHeight=4*szs.border+szs.sHeight;
spWidth=(4*numCuts+1)*szs.border+numCuts*(szs.stWidth+szs.sWidth);

fWidth=5*border+gWidth+sWidth+spWidth;
fHeight= 4*border+bHeight+2*gHeight;

f = figure('MenuBar','none','Toolbar','figure','Name','sortManager','NumberTitle','off','Resize','on','CloseRequestFcn',@cleanup,'Units','pixels','Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt) %#ok<INUSD>
        closereq;
    end

subjectM=uicontrol(f,'Style','popupmenu','String',{'subject'},'Units','pixels','Position',[border                 3*border+2*gHeight bWidth bHeight],'Callback',@subjectC); %#ok<NASGU>
dateM   =uicontrol(f,'Style','popupmenu','String',{'date'},   'Units','pixels','Position',[2*border+bWidth        3*border+2*gHeight bWidth bHeight],'Callback',@dateC); %#ok<NASGU>
cellM   =uicontrol(f,'Style','popupmenu','String',{'cell'},   'Units','pixels','Position',[3*border+2*bWidth      3*border+2*gHeight bWidth bHeight],'Callback',@cellC); %#ok<NASGU>
chunkM  =uicontrol(f,'Style','popupmenu','String',{'chunk'},  'Units','pixels','Position',[4*border+3*bWidth      3*border+2*gHeight bWidth bHeight],'Callback',@chunkC); %#ok<NASGU>
%displayB=uicontrol(f,'Style','pushbutton','String','display', 'Units','pixels','Position',[fWidth-(border+bWidth) 3*border+2*gHeight bWidth bHeight],'Callback',@applyC);

sph = uipanel(f,'title','bandpass','Units','pixels','Position',[border 2*border+gHeight spWidth spHeight]);

loCutS=sliderPanel(sph,{'title','lo cut (hz)','ind',1,'szs',szs},{'min',1,   'max',500,       'value',loCut,'callback',@bandC},[],[],'%0.0f');
hiCutS=sliderPanel(sph,{'title','hi cut (hz)','ind',2,'szs',szs},{'min',2500,'max',.99*sampRate/2,'value',hiCut,'callback',@bandC},[],[],'%0.0f'); %fir1 dies if given exactly the nyquist

threshHiS=uicontrol(f,'Style','slider','String','hiThresh','Min',0, 'Max',1,'SliderStep',[.001 .05],...
    'Units','pixels','Position',[3*border+spWidth+gWidth 3*border+gHeight*3/2 sWidth (gHeight-border)/2],'Callback',@threshC);
threshLoS=uicontrol(f,'Style','slider','String','loThresh','Min',-1,'Max',0,'SliderStep',[.001 .05],...
    'Units','pixels','Position',[3*border+spWidth+gWidth gHeight+2*border     sWidth (gHeight-border)/2],'Callback',@threshC);

    function bandC(src,evet) %#ok<INUSD>
        set(klustaB,'Enable','off');
        cla(usah)
        cla(upcah)
        cla(sah)
        cla(pcah)
        cla(hah)
        th=[];
        cla(ah)
        drawnow
        
        loCut=get(loCutS,'Value');
        hiCut=get(hiCutS,'Value');
        
        [b,a]=fir1(fOrd,2*[loCut hiCut]/sampRate);
        filt=filtfilt(b,a,data);
        filt=filt/max(abs(filt));
        
        filtV = interp1(times,filt,timesV,'linear');
        
        setHz=10;
        numSteps=50;

        
        for w=[1 -1]
            v=linspace(w,0,numSteps)';
            dRate=500; %this rate just sets granularity that we use to look for xings to make the hz/threshold plots and auto-pick the thresholds.  
                       %was originally 5000, had to set to 500 for real amounts of data...
                       %and if it's this low, it picks thresholds too low, says there are too many spikes, and we run out of memory when plotting them (see "temp -- remove!" lines below)
            dTimes=linspace(0,secDur,secDur*dRate)+tOffset;
            dFilt=interp1(times,filt,dTimes,'linear'); %without downsampling, the following line runs out of memory even for singles when > ~15s @40kHz
            crossHz=sum(diff((w*repmat(dFilt,numSteps,1))>(w*repmat(single(v),1,length(dFilt))),1,2)>0,2)/secDur;
            
            if w>0
                newMin=v(find(crossHz>maxHz,1,'first'));
                if isempty(newMin)
                    newMin=0;
                end
                set(threshHiS,'min',newMin);
                
                hiThresh=v(find(crossHz>setHz,1,'first'));
                if isempty(hiThresh)
                    hiThresh=0;
                end
                hiThresh=.9; %temp -- remove!
                set(threshHiS,'Value',hiThresh);
            else
                newMax=v(find(crossHz>maxHz,1,'first'));
                if isempty(newMax)
                    newMax=0;
                end
                set(threshLoS,'max',newMax);
                
                loThresh=v(find(crossHz>setHz,1,'first'));
                if isempty(loThresh)
                    loThresh=0;
                end
                loThresh=-.9; %temp -- remove!
                set(threshLoS,'Value',loThresh);
            end
            
            plot(hah,crossHz,v,'r');
            set(hah,'nextplot','add');
            
            change=[0 diff(crossHz)']; %change in rate per thresh
            change=maxHz*change/max(change); % normalize
            plot(hah,change,v,'g');
            
            xlabel(hah,'hz')
        end
        
        ylim(hah,[-1 1]);
        xlim(hah,[-.05 1]*maxHz);
        
        drawThresh;
    end

    function threshC(src,evt) %#ok<INUSD>
        drawThresh;
    end

    function drawThresh()
        loThresh=get(threshLoS,'Value');
        hiThresh=get(threshHiS,'Value');
        
        cla(ah)
        cla(sah)
        cla(pcah)
        cla(usah)
        cla(upcah)
        drawnow;
        
        tops=[false diff(filt>hiThresh)>0];
        topCrossings=   times(tops);
        bottoms=[false diff(filt<loThresh)>0];
        bottomCrossings=times(bottoms);
        set(topCrossingsT,   'String',sprintf('top crossings: %0.1f hz',   length(topCrossings)   /secDur));
        set(bottomCrossingsT,'String',sprintf('bottom crossings: %0.1f hz',length(bottomCrossings)/secDur));
        
        plot(ah,repmat(topCrossings,   2,1),[1 hiThresh]' *ones(1,length(topCrossings)),   'k');
        set(ah,'nextplot','add');
        plot(ah,repmat(bottomCrossings,2,1),[loThresh -1]'*ones(1,length(bottomCrossings)),'k');
        
        plot(ah,timesV,dataV,'b');
        plot(ah,timesV,filtV,'r');
        plot(ah,[0 secDur]+tOffset,[0 0],'k');
        plot(ah,[0 secDur]+tOffset,ones(2,1)*[loThresh hiThresh],'k');
        
        plot(hah,[0 0],[-1 1],'k');
        if ~isempty(th)
            delete(th)
        end
        th=plot(hah,[0 maxHz],ones(2,1)*[loThresh hiThresh],'k');
        
        spkLength=round(sampRate*spkDurMS/1000);
        spkPts=(1:spkLength)-ceil(spkLength/2);
        
        [tops    uTops    topTimes]   =extractPeakAligned(tops,1);
        [bottoms uBottoms bottomTimes]=extractPeakAligned(bottoms,-1);
        
        function [group uGroup groupPts]=extractPeakAligned(group,flip)
            maxMSforPeakAfterThreshCrossing=.5; %this is equivalent to a lockout, because all peaks closer than this will be called one peak, so you'd miss IFI's smaller than this. 
            % we should check for this by checking if we said there were multiple spikes at the same time.
            % but note this is ONLY a consequence of peak alignment!  if aligned on thresh crossings, no lockout necessary (tho high frequency noise riding on the spike can cause it 
            % to cross threshold multiple times, causing you to count it multiple times w/timeshift).
            % our remaining problem is if the decaying portion of the spike has high freq noise that causes it to recross thresh and get counted again, so need to look in past to see
            % if we are on the tail of a previous spk -- but this should get clustered away anyway because there's no spike-like peak in the immediate period following the crossing.
            % ie the peak is in the past, so it's a different shape, therefore a different cluster
            
            maxPeakSamps=round(sampRate*maxMSforPeakAfterThreshCrossing/1000);
            
            group=find(group)';
            groupPts=group((group+spkLength-1)<length(filt) & group-ceil(spkLength/2)>0);
            group=data(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!
            
            [junk loc]=max(flip*group,[],2);
            groupPts=((loc-1)+groupPts);
            groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));
            
            group= filt(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
            uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
            uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);
        end
        
        spkTimes=times([topTimes;bottomTimes]);
        spks=[tops;bottoms]';
        uSpks=[uTops;uBottoms]';
        
        spkPts=1000*spkPts/sampRate;
        if ~isempty(spks)
            plot(sah,spkPts,spks,'r')
        end
        set(sah,'nextplot','add');
        xlabel(sah,'ms')
        title(sah,sprintf('%d up spikes | %d down spikes',size(tops,1),size(bottoms,1)))
        plot(sah,[min(spkPts) max(spkPts)],ones(2,1)*[hiThresh loThresh],'k');
        
        if ~isempty(uSpks)
            plot(usah,spkPts,uSpks,'b')
        end
        set(usah,'nextplot','add');
        xlabel(usah,'ms')
        
        [coeff scores] = princomp(zscore(spks'));
        
        plot(sah,spkPts,coeff(:,1:3),'k','LineWidth',2); %need to remember to destandardize these!
        plot3(pcah,scores(:,1),scores(:,2),scores(:,3),'k.','MarkerSize',10);
        axis(pcah,'equal');
        
        [coeff uScores] = princomp(zscore(uSpks'));
        plot(usah,spkPts,coeff(:,1:3),'k','LineWidth',2);%need to remember to destandardize these!
        plot3(upcah,uScores(:,1),uScores(:,2),uScores(:,3),'k.','MarkerSize',10);
        axis(upcah,'equal');
        
        set(klustaB,'Enable','on');
    end

    function klusta(src, evt) %#ok<INUSD>
        set(klustaB,'Enable','off');
        
        cla(ksah)
        cla(kpcah)
        
        if ismac
            kPath='./KlustaKwik/macosx-i386/';
		else
			kPath=['"' fullfile(getRatrixPath,'analysis','spike sorting','KlustaKwik') '"']; %#ok<NASGU>
        end
        fileBase='eTest';
        numPCs=3;
        maxClusters=10;
        useUnfiltered=true;
        
        if useUnfiltered
            fs=uScores(:,1:numPCs);
        else
            fs=scores(:,1:numPCs); %#ok<UNRCH>
        end
        
        [fid msg]= fopen([fileBase '.fet.1'],'wt+');
        if fid>=0
            try
                fprintf(fid,[num2str(numPCs) '\n']);
                for k=1:size(fs,1)
                    fprintf(fid,'%s\n', num2str(fs(k,:)));
                end
            catch ex
                fclose(fid);
                getReport(ex)
            end
            fclose(fid);
        else
            msg %#ok<NOPRT>
            error('couldn''t open fet file')
        end
        
        allFeatures=num2str(ones(1,numPCs));
        allFeatures(allFeatures==' ')='';
        
        cmd=[fullfile(kPath,'KlustaKwik') ' ' fileBase ' 1 -UseFeatures ' allFeatures ' -MinClusters 1 -MaxClusters ' num2str(maxClusters)];
        fprintf('running: "%s"\n',cmd)
        [s r]=system(cmd);
        
        % Usage: KlustaKwik FileBase ElecNo [Arguments]
        % FileBase	tetrode
        % ElecNo	1
        % MinClusters	20
        % MaxClusters	30
        % MaxPossibleClusters	100
        % nStarts	1
        % RandomSeed	1
        % Debug	0
        % Verbose	1
        % UseFeatures	11111111111100001
        % DistDump	0
        % DistThresh	6.907755
        % FullStepEvery	20
        % ChangedThresh	0.050000
        % Log	1
        % Screen	1
        % MaxIter	500
        % StartCluFile
        % SplitEvery	40
        % PenaltyMix	1.000000
        % Subset	1
        % help	0
        
        if s
            r %#ok<NOPRT>
            error('klustakwik error')
        end
        
        cs=load([fileBase '.clu.1']);
        
        try %delete these so we don't confuse ourselves with out of date stuff in the future
            delete([fileBase '.fet.1'])
            delete([fileBase '.clu.1'])
        catch ex
            getReport(ex)
        end
        
        [ks inds]=sort(cs(2:end));
        [b m garbage]=unique(ks,'last'); %#ok<NASGU> %need to sort ks for m to be useful for counting; garbage and ks are the same
        
        counts=diff([0; m]);
        [garbage ord]=sort(counts,'descend');
        
        if sum(counts)~=length(spkTimes) || cs(1)~=length(counts)
            sum(counts)
            length(spkTimes)
            cs(1)
            length(counts)
            error('bad clu output')
        end
        
        colors=colormap(jet);
        colorInds=round(linspace(1,size(colors,1),length(counts)));
        
        for i=1:length(ord) %draw in descending cluster size so biggest are in background and don't cover up smallest
            c=colors(colorInds(i),:); %biggest always a consistent color (dark blue)
            
            spkInds=inds(ks==ord(i));
            
            [chks filtInds]=ismember(spkTimes(spkInds),times);
            if ~all(chks)
                error('couldn''t find some times back')
            end
            plot(ah,spkTimes(spkInds),filt(filtInds),'*','Color',c);
            plot(ksah,spkPts,uSpks(:,spkInds)+(i-1),'Color',c);
            plot3(kpcah,fs(spkInds,1),fs(spkInds,2),fs(spkInds,3),'.','MarkerSize',10,'Color',c)
            
            set(ksah,'nextplot','add');
            set(kpcah,'nextplot','add');
            
            plot(ksah,spkPts,i-1,'k')
        end
        xlabel(ksah,'ms')
        title(ksah,sprintf('%d clusters (%d max)',length(ord),maxClusters));
        ylim(ksah,[-1 length(ord)+1]);
        
        set(klustaB,'Enable','on');
    end


ah=   axes('Parent',f,'Units','pixels','Position',[3*border+spWidth               5*border+gHeight gWidth-2*border-hWidth gHeight-3*border]);
hah=  axes('Parent',f,'Units','pixels','Position',[4*border+spWidth+gWidth-hWidth 5*border+gHeight hWidth-2*border        gHeight-3*border]);
sah=  axes('Parent',f,'Units','pixels','Position',[border                         4*border         saWidth                gHeight-5*border]);
pcah= axes('Parent',f,'Units','pixels','Position',[border*2+saWidth               4*border         saWidth                gHeight-border]);
usah= axes('Parent',f,'Units','pixels','Position',[border*3+2*saWidth             4*border         saWidth                gHeight-5*border]);
upcah=axes('Parent',f,'Units','pixels','Position',[border*4+3*saWidth             4*border         saWidth                gHeight-border]);
ksah= axes('Parent',f,'Units','pixels','Position',[border*5+4*saWidth             4*border         saWidth                gHeight-5*border]);
kpcah=axes('Parent',f,'Units','pixels','Position',[border*6+5*saWidth             4*border         saWidth                gHeight-border]);

klustaB=uicontrol(f,'Style','pushbutton','String','klustakwik', 'Units','pixels','Position',[border*5+4.5*saWidth-.5*bWidth  border bWidth bHeight],'Enable','off','Callback',@klusta);

topCrossingsT=uicontrol(   f,'Style','text','HorizontalAlignment','right','Units','pixels','Position',[border+spWidth+gWidth-hWidth-bWidth 3*border+2*gHeight+bHeight/2 bWidth bHeight/2]);
bottomCrossingsT=uicontrol(f,'Style','text','HorizontalAlignment','right','Units','pixels','Position',[border+spWidth+gWidth-hWidth-bWidth 3*border+2*gHeight           bWidth bHeight/2]);

timesV=linspace(0,secDur,secDur*viewRate)+tOffset;
dataV = interp1(times,data,timesV,'linear');
plot(ah,timesV,dataV);
ylim(ah,[-1 1]);
xlabel(ah,'sec');
bandC;

%reset to current

% actions={'set starting now','recompute all'};
% actionM =uicontrol(f,'Style','popupmenu','String',actions,    'Units','pixels','Position',[4*border+bWidth border+bHeight bWidth bHeight],@actionC);
% applyB  =uicontrol(f,'Style','pushbutton','String','apply',   'Units','pixels','Position',[fWidth-(border+bWidth) border+bHeight bWidth bHeight],@applyC);
%
% 3dimPca/clustercolored waveforms/clustercolored

%checkbox

end