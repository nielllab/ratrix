function displayCumulativePhysAnalysis(sm,cumulativedata,parameters)
% allows for display without recomputation

% make sure data exists
if isempty(cumulativedata)
    warning('NOT DISPLAYING INFO FOR TRIAL %d BECAUSE CUMULATIVE DATA IS EMPTY',parameters.trialRange(end));
    return
end
analysisdata = cumulativedata.lastAnalysis;
analysisdata.singleChunkTemporalRecord(1,:)=...
    getTemporalSignal(analysisdata.STA,analysisdata.STV,analysisdata.numSpikes,'bright');

% stimulus info
stimulusDetails = parameters.stimRecords.stimulusDetails;
whiteVal=255;
spatialSmoothingOn=true;
doSTC=false;
xtraPlot={'spaceTimeContext'}; % eyes, spaceTimeContext, montage

% timeWindowMs
timeWindowMsStim=[300 50]; % parameter [300 50]
timeWindowMsLFP =[1000 1000];

% refreshRate - try to retrieve from neuralRecord (passed from stim computer)
if isfield(parameters, 'refreshRate')
    refreshRate = parameters.refreshRate;
else
    %error('dont use default refreshRate');
    refreshRate = 100;
end

% calculate the number of frames in the window for each spike
timeWindowFramesStim=ceil(timeWindowMsStim*(refreshRate/1000));

if spatialSmoothingOn
    filt=... a mini gaussian like fspecial('gaussian')
        [0.0113  0.0838  0.0113;
        0.0838  0.6193  0.0838;
        0.0113  0.0838  0.0113];
end

if isfield(stimulusDetails,'distribution')
    switch stimulusDetails.distribution.type
        case 'gaussian'
            std = stimulusDetails.distribution.std;
            meanLuminance = stimulusDetails.distribution.meanLuminance;
        case 'binary'
            p=stimulusDetails.distribution.probability;
            hiLoDiff=(stimulusDetails.distribution.hiVal-stimulusDetails.distribution.lowVal);
            std=hiLoDiff*p*(1-p);
            meanLuminance=(p*stimulusDetails.distribution.hiVal)+((1-p)*stimulusDetails.distribution.lowVal);
    end
else
    error('dont use old convention for whiteNoise');
    %old convention prior to april 17th, 2009
    %stimulusDetails.distribution.type='gaussian';
    %std = stimulusDetails.std;
    %meanLuminance = stimulusDetails.meanLuminance;
end
        
    

% cumulative
[brightSignal brightCI brightInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,'bright');
[darkSignal darkCI darkInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,'dark');

rng=[min(cumulativedata.cumulativeSTA(:)) max(cumulativedata.cumulativeSTA(:))];

% 11/25/08 - update GUI
% create the figure and name it
if length(parameters.trialRange)>1
    figureName = sprintf('%s on %s. trialRange :%d -> %d',parameters.stepName,parameters.trodeName,min(parameters.trialRange),max(parameters.trialRange));
else
    figureName = sprintf('%s on %s. trialRange :%d',parameters.stepName,parameters.trodeName,parameters.trialRange);
end
figure(parameters.figHandle)
set(gcf,'NumberTitle','off','Name',figureName,'Units','pixels','position',[100 100 800 700]);


% is it a spatial signal? or fullfield?
doSpatial=~(size(cumulativedata.cumulativeSTA,1)==1 & size(cumulativedata.cumulativeSTA,2)==1); % if spatial dimentions exist

% %% spatial signal (best via bright)
if doSpatial
    oP = get(gcf,'OuterPosition');
    set(gcf,'OuterPosition',[oP(1) oP(2) 2*oP(3) oP(4)]);
    % change here for which context
    contextType = 'dark';%'bright'; 'dark';
    switch contextType
        case 'dark'
            contextInd = darkInd;
        case 'bright'
            contextInd = brightInd;
        otherwise
            error('unknown context type');
    end
    
    %fit model to best spatial
    stdThresh=1;
    [STAenvelope STAparams] =fitGaussianEnvelopeToImage(cumulativedata.cumulativeSTA(:,:,contextInd(3)),stdThresh,false,false,false);
    cx=STAparams(2)*size(STAenvelope,2)+1;
    cy=STAparams(3)*size(STAenvelope,1)+1;
    stdx=size(STAenvelope,2)*STAparams(5);
    stdy=size(STAenvelope,1)*STAparams(5);
    e1 = fncmb(fncmb(rsmak('circle'),[stdx*1 0;0 stdy*1]),[cx;cy]);
    e2 = fncmb(fncmb(rsmak('circle'),[stdx*2 0;0 stdy*2]),[cx;cy]);
    e3 = fncmb(fncmb(rsmak('circle'),[stdx*3 0;0 stdy*3]),[cx;cy]);
    
    
    %get significant pixels and denoised spots
    switch stimulusDetails.distribution.type
        case 'gaussian'
            stdStimulus = std*whiteVal;
        case 'binary'
            stdStimulus = std*whiteVal*100; % somthing very large to prevent false positives... need to figure it out analytically.. maybe use different function
            %std=hiLoDiff*p*(1-p);
    end
    meanLuminanceStimulus = meanLuminance*whiteVal;
    [bigSpots sigPixels]=getSignificantSTASpots(cumulativedata.cumulativeSTA(:,:,contextInd(3)),cumulativedata.cumulativeNumSpikes,meanLuminanceStimulus,stdStimulus,ones(3),3,0.05);
    [bigIndY bigIndX]=find(bigSpots~=0);
    [sigIndY sigIndX]=find(sigPixels~=0);
    
    % clear the figure and start anew
    clf(parameters.figHandle);
    
    % cumulative modulation
    cumuModAx = subplot(2,4,1);
    im=single(squeeze(cumulativedata.cumulativeSTA(:,:,contextInd(3))));
    if spatialSmoothingOn
        im=imfilter(im,filt,'replicate','same');
    end
    if rng(1)==rng(2)
        rng = [0 255];
    end
    imagesc(im,rng);
    %colorbar; %colormap(blueToRed(meanLuminanceStimulus,rng));
    hold on; plot(brightInd(2), brightInd(1),'y+')
    hold on; plot(darkInd(2)  , darkInd(1),  'y-')
    hold on; plot(bigIndX     , bigIndY,     'y.')
    hold on; plot(sigIndX     , sigIndY,     'y.','markerSize',1)
    minTrial=min(cumulativedata.cumulativeTrialNumbers);
    maxTrial=max(cumulativedata.cumulativeTrialNumbers);
    xlabel(sprintf('cumulative (%d.%d --> %d.%d)',...
        minTrial,min(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==minTrial))),...
        maxTrial,max(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==maxTrial)))));
    fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot ellipses
    
    % latest trial modulation
    singTrModAx = subplot(2,4,2);    
    %hold off; imagesc(squeeze(STA(:,:,contextInd(3))),[min(STA(:)) max(STA(:))]);
    if ~(min(analysisdata.STA(:))==max(analysisdata.STA(:)))
        hold off; imagesc(squeeze(analysisdata.STA(:,:,contextInd(3))),[min(analysisdata.STA(:)) max(analysisdata.STA(:))]);
    else
        warning('hard coding some stuff here...')
        hold off; imagesc(squeeze(analysisdata.STA(:,:,contextInd(3))),[0 255]);
    end
    hold on; plot(brightInd(2), brightInd(1),'y+')
    hold on; plot(darkInd(2)  , darkInd(1),'y-')
    %colorbar;
    colormap(gray);
    %colormap(blueToRed(meanLuminanceStimulus,rng,true));
    
    fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot elipses
    
    xlabel(sprintf('this trial/chunk (%d-%d)',analysisdata.trialNumber,analysisdata.chunkID))
    
    % draw the temporal for the relevant only
    relevantTempOnlyAx = subplot(2,4,5);
    timeMs=linspace(-timeWindowMsStim(1),timeWindowMsStim(2),size(cumulativedata.cumulativeSTA,3));
    ns=length(timeMs);
    hold off; plot(timeWindowFramesStim([1 1])+1, [0 whiteVal],'k');
    hold on;  plot([1 ns],meanLuminance([1 1])*whiteVal,'k')
    % try
    %     plot([1:ns], analysisdata.singleChunkTemporalRecord, 'color',[.8 .8 1])
    % catch
    %     keyboard
    % end
    fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'b'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
    fh=fill([1:ns fliplr([1:ns])]',[brightCI(:,1); flipud(brightCI(:,2))],'r'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
    plot([1:ns], darkSignal(:)','b')
    plot([1:ns], brightSignal(:)','r')
    
    peakFrame=find(brightSignal==max(brightSignal(:)));
    timeInds=[1 peakFrame(end) timeWindowFramesStim(1)+1 size(cumulativedata.cumulativeSTA,3)];
    set(gca,'XTickLabel',unique(timeMs(timeInds)),'XTick',unique(timeInds),'XLim',minmax(timeInds));
    set(gca,'YLim',[minmax([analysisdata.singleChunkTemporalRecord(:)' darkCI(:)' brightCI(:)'])+[-5 5]])
    ylabel('RGB(gunVal)')
    xlabel('msec')

    % xtraPlot
    xtraPlotax = subplot(2,4,[3 4 7 8]);
    switch xtraPlot{1}
        case 'montage'
            % montage(reshape(cumulativedata.cumulativeSTA,[size(cumulativedata.STA,1) size(cumulativedata.STA,2) 1 size(cumulativedata.STA,3) ] ), 'DisplayRange',rng)
            montage(reshape(cumulativedata.cumulativeSTA,[size(STA,1) size(STA,2) 1 size(STA,3) ] ),'DisplayRange',rng)
            colormap(blueToRed(meanLuminanceStimulus,rng,true));
            % %% spatial signal (all)
            % for i=1:
            % subplot(4,n,2*n+i)
            % imagesc(STA(:,:,i),'range',[min(STA(:)) min(STA(:))]);
            % end
            
            if max(parameters.trialNumber)==318
                keyboard
            end
        case 'eyes'
            
            figure(parameters.trialNumber)
            if exist('ellipses','var')
                plotEyeElipses(eyeSig,ellipses,within,true);
            else
                msg=sprintf('no good eyeData on trial %d\n will analyze all data',parameters.trialNumber)
                text(.5,.5, msg)
            end
        case 'spaceTimeContext'
            %uses defaults on phys monitor may 2009, might not be up to
            %date after changes in hardware
            
            %user controls these somehow... params?
            eyeToMonitorMm=330;
            contextSize=3;
            pixelPad=0.1; %fractional pad 0-->0.5
            
            
            %stimRect=[500 1000 800 1200]; %need to get this stuff!
            stimRect=[0 0 stimulusDetails.width stimulusDetails.height]; %need to get this! now forcing full screen
            stimRectFraction=stimRect./[stimulusDetails.width stimulusDetails.height stimulusDetails.width stimulusDetails.height];
            [vRes hRes]=getAngularResolutionFromGeometry(size(analysisdata.STA,2),size(analysisdata.STA,1),eyeToMonitorMm,stimRectFraction);
            contextResY=vRes(contextInd(1),contextInd(2));
            contextResX=hRes(contextInd(1),contextInd(2));
            
            
            contextOffset=-contextSize:1:contextSize;
            n=length(contextOffset); % 2*c+1
            contextIm=ones(n,n)*meanLuminanceStimulus;
            selection=nan(n,n);
            maxAmp=max(abs(meanLuminanceStimulus-rng))*2; %normalize to whatever lobe is larger: positive or negative
            hold off; plot(0,0,'.')
            hold on
            for i=1:n
                yInd=contextInd(1)+contextOffset(i);
                for j=1:n
                    xInd=contextInd(2)+contextOffset(j);
                    if xInd>0 && xInd<=size(analysisdata.STA,2) && yInd>0 && yInd<=size(analysisdata.STA,1)
                        %make the image
                        selection(i,j)=sub2ind(size(analysisdata.STA),yInd,xInd,contextInd(3));
                        contextIm(i,j)=cumulativedata.cumulativeSTA(selection(i,j));
                        %get temporal signal
                        [stixSig stixCI stixtInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,selection(i,j));
                        yVals{i,j}=((1-pixelPad*2)   *  (stixSig(:)-meanLuminanceStimulus)/maxAmp)  +  n-i+1; % pad, normalize, and then postion in grid
                        xVals{i,j}=linspace(j-.5+pixelPad,j+.5-pixelPad,length(stixSig(:)));
                        
                    end
                end
            end
            
            % plot the image
            imagesc(flipud(contextIm),rng)
            colormap(blueToRed(meanLuminanceStimulus,rng,true));
            
            %plot the temporal signal
            for i=1:n
                for j=1:n
                    if ~isnan(selection(i,j))
                        plot(xVals{i,j},yVals{i,j},'y')
                    end
                end
            end
            
            % we only take the degrees of the selected pixel.
            %neighbors may differ by a few % depending how big they are,
            %geometery, etc.
            
            
            axis([.5 n+.5 .5 n+.5])
            set(gca,'xTick',[]); set(gca,'yTick',[])
            xlabel(sprintf('%2.1f deg/pix',contextResX));
            ylabel(sprintf('%2.1f deg/pix',contextResY));
            
        otherwise
            error('bad xtra plot request')
    end
    
    waveFormAx = subplot(2,4,6);
    % now draw the spike waveforms
    plot(cumulativedata.cumulativeSpikeWaveforms','r')
    set(waveFormAx,'XTick',[],'Ytick',[]);
    axis tight
    
else
    % full field!
    clf(parameters.figHandle);
    temporalonlyAx = axes;
    timeMs=linspace(-timeWindowMsStim(1),timeWindowMsStim(2),size(cumulativedata.cumulativeSTA,3));
    ns=length(timeMs);
    hold off; plot(timeWindowFramesStim([1 1])+1, [0 whiteVal],'k');
    hold on;  plot([1 ns],meanLuminance([1 1])*whiteVal,'k')
    % try
    %     plot([1:ns], analysisdata.singleChunkTemporalRecord, 'color',[.8 .8 1])
    % catch
    %     keyboard
    % end
    fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'b'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
    fh=fill([1:ns fliplr([1:ns])]',[brightCI(:,1); flipud(brightCI(:,2))],'r'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
    plot([1:ns], darkSignal(:)','b')
    plot([1:ns], brightSignal(:)','r')
    
    peakFrame=find(brightSignal==max(brightSignal(:)));
    timeInds=[1 peakFrame(end) timeWindowFramesStim(1)+1 size(cumulativedata.cumulativeSTA,3)];
    set(gca,'XTickLabel',unique(timeMs(timeInds)),'XTick',unique(timeInds),'XLim',minmax(timeInds));
    set(gca,'YLim',[minmax([analysisdata.singleChunkTemporalRecord(:)' darkCI(:)' brightCI(:)'])+[-5 5]])
    ylabel('RGB(gunVal)')
    xlabel('msec')
    % now draw the spike waveforms
    waveAx = axes('Position',[0.91 0.91 0.08 0.08]);
    plot(cumulativedata.cumulativeSpikeWaveforms','r')
    set(waveAx,'XTick',[],'Ytick',[]);
    axis tight
end

end
function [sig CI ind]=getTemporalSignal(STA,STV,numSpikes,selection)
switch class(selection)
    case 'char'
        switch selection
            case 'bright'
                [ind]=find(STA==max(STA(:)));  %shortcut for a relavent region
            case 'dark'
                [ind]=find(STA==min(STA(:)));
            otherwise
                selection
                error('bad selection')
        end
        
    case 'double'
        temp=cumprod(size(STA));
        if iswholenumber(selection) && all(size(selection)==1) && selection<=temp(end)
            ind=selection;
        else
            error('bad selection as a double, which should be an index into STA')
        end
    otherwise
        error('bad class for selection')
        
end

try
    %if numSpikes==0 || all(isnan(STA(:)))
    %    ind=1; %to prevent downstream errors, just make one up  THIS DOES
    %    NOT FULLY WORK... need to be smarter... prob no spikes this trial
    %end
    if  numSpikes==0
        ind=1; %to prevent downstream errors, just make one up
    else
        ind=ind(1); %use the first one if there is a tie. (more common with low samples)
    end
catch
    keyboard
end

[X Y T]=ind2sub(size(STA),ind);
ind=[X Y T];
sig = STA(X,Y,:);
if nargout>1
    er95= sqrt(STV(X,Y,:)/numSpikes)*1.96; % b/c std error(=std/sqrt(N)) of mean * 1.96 = 95% confidence interval for gaussian, norminv(.975)
    CI=repmat(sig(:),1,2)+er95(:)*[-1 1];
end
end
