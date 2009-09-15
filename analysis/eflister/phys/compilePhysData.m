function compilePhysData(wd,fileNames,stimTimes,targetBinsPerSec,pulsesPerRepeat,numRepeats,uniquesEvery,drawSummary,drawStims,forceStimRecompile,forcePhysRecompile)

contents=what(wd);

for fileNum=1:length(fileNames)
    
    file=fileNames{fileNum};
    
    if isempty(stimTimes)
        stimTimes(:,:,fileNum)=[0 inf];
    end
    numStims=size(stimTimes(:,:,fileNum),1);
    
    name = sprintf('%s compiled stim.mat',file);
    
    fileGood = 0;
    if any(strcmp(contents.mat,name)) && ~forceStimRecompile && ~forcePhysRecompile
        load(fullfile(wd,name));
        if binsPerSec==targetBinsPerSec
            fileGood = 1;
        end
    end
    
    if ~fileGood
        [phys physTms]=checkForCompiledMat(wd,'phys',file,forcePhysRecompile,contents,targetBinsPerSec);
        
        [stim stimTms first(fileNum) step(fileNum)]=checkForCompiledMat(wd,'stim',file,forceStimRecompile,contents,[]);
        
        pFile=sprintf('%s pulse.txt',file);
        origPulses=load(fullfile(wd,pFile));
        
        C=doScan(fullfile(wd,pFile),'%% %[^%] %%',2);
        
        %pulses from ratrix changed over experiments:
        %if VRG:
        %pulses from vrg lag gun peaks by about 0.9ms  (may depend on curret photodiode location)
        %
        %if CRT:
        %1) original: 2 pulses at end of stim comp -> flip -> single pulse -> gun (corresponding to this frame) arrives at photodiode about .9ms later
        %2) improved: set bit -> flip -> unset bit
        %
        %if LED:
        %no pulses
        %
        %also later added repeat boundary pulses
        
        dispType='CRT';
        pulseProtocol='old';
        scheduledFrames=false;
        
        if scheduledFrames
            error('not implemented');
        end
        
        switch dispType
            case 'VRG'
                %note that the logic here would have to be carefully reworked
                %apparently vrg pulses lagged the gun peaks (verify this), whereas ratrix pulses precede them
                error('not implemented')
            case 'CRT'
                switch pulseProtocol
                    case 'old'
                        

% example pulse file:                        
% 1   %CHANNEL%	%2%
% 2   %Evt+-%
% 3   %%
% 4   %pulse%
% 5   
% 6   %HIGH%
% 7   1435.8024667
% ... ...

%above doScan w/2 header lines doesn't look right -- 4 or 5 works.
%also verify line 2: "%Evt+-%"

%note: consider exporting wavemarks as visual measure of sort quality
%with wavemarks as events, peaks are aligned, and times are peak times (i believe)
%if they are PRE times, they would be offset consistently within file but not across files
                        
                        if ~strcmp(C{1},'HIGH')
                            error('bad pulse parity')
                        end
                        
                        dPulses=diff(origPulses)<.0004; %major problems if flip or stim comp is ever this fast, or if double pulses take longer than this
                        stimComputed=[false; dPulses] & [false; false; dPulses(1:end-1)] & [false; false; false; dPulses(1:end-2)]; %pulses preceded by 3 quick events
                        
                        numFrames=length(stimComputed)/6;
                        check=reshape(stimComputed,6,numFrames)==repmat([0 0 0 1 0 0]',1,numFrames);
                        if numFrames~=round(numFrames) || ~all(check(:)) %can be quite confident if we pass this
                            error('bad pulses')
                        end
                        
                        pulses=origPulses([false; stimComputed(1:end-1)]); % take first down after the double to be the moment flip returns, gun will reach photodiode for this frame in about .9ms
                        pulseOffsetPct = .65; %pct of a nominal frame duration that the gun LAGS the pulse (depends on pdiode location!)
                    otherwise
                        error('unknown protocol')
                end
            case 'LED'
                error('not implemented')
            otherwise
                error('unknown dispType')
        end
        
        binsPerSec=targetBinsPerSec;
        
        for stimNum=1:numStims
            thesePulses = pulses(pulses>stimTimes(stimNum,1,fileNum) & pulses<stimTimes(stimNum,2,fileNum));
            
            nominalSecondsPerFrame = median(diff(thesePulses));
            if abs(1-nominalSecondsPerFrame/.01) > .1
                error('bad frame times')
            end
            
            tMask=stimTms>stimTimes(stimNum,1,fileNum) & stimTms<stimTimes(stimNum,2,fileNum);
            stimT=stimTms(tMask); % the photo sample times
            tStim=normalize(stim(tMask)'); %photodiode measurements should be considered linear but not calibrated
            
            boundaries=[thesePulses;thesePulses(end)+nominalSecondsPerFrame]+pulseOffsetPct*nominalSecondsPerFrame;
            [stimVals expandedStim]=markSample(boundaries,first(fileNum),step(fileNum),tStim,'frames');
            boundaries = boundaries(1:end-1);
            binT=boundaries(1): 1/binsPerSec : boundaries(end);
            [binVals expandedBins]=markSample(binT,first(fileNum),step(fileNum),tStim,'bins');
            binT = binT(1:end-1);
            
            f=figure;
            subplot(3,1,1)
            [pHist pBins]=hist(tStim,100);
            if pHist(end)>pHist(end-1)
                error('photodiode may have clipped')
            end
            semilogy(pBins,pHist)
            title('photo dist -- any clipping?')
            
            subplot(3,1,2)
            doHist(stimVals);
            title(sprintf('frame distribution (median hz: %g)',1/nominalSecondsPerFrame));
            
            subplot(3,1,3)
            doHist(binVals);
            title(sprintf('bins of %g ms',1000/binsPerSec))
            
            saveas(f,fullfile(wd,sprintf('%s stim dist.fig',file)))
            
            f=figure;
            contextFrames=25;
            contextSecs=contextFrames*nominalSecondsPerFrame;
            
            drops=[false; abs(1-diff(thesePulses)/nominalSecondsPerFrame)>.2];
            numDrops=sum(drops);
            drops([1 end])=1;
            dropTimes=thesePulses(drops);
            dropWins={};
            for dropNum=1:length(dropTimes)
                if isempty(dropWins) || dropTimes(dropNum)>dropWins{end}(1)+contextSecs
                    dropWins{end+1}=dropTimes(dropNum);
                else
                    dropWins{end}(end+1)=dropTimes(dropNum);
                end
            end
            dropTimes=dropTimes(2:end-1);
            
            for winNum=1:length(dropWins)
                subplot(length(dropWins),1,winNum)
                
                tRange=dropWins{winNum}(1)+contextSecs*[-1 1];
                tInds=stimT<tRange(2) & stimT>tRange(1);
                
                nPlot(stimT(tInds),expandedStim(tInds),'r');
                hold on
                nPlot(stimT(tInds),expandedBins(tInds),'g');
                nPlot(stimT(tInds),tStim(tInds),'b');
                plot(origPulses(origPulses<tRange(2) & origPulses>tRange(1)),.5,'kx');
                plot(dropTimes,.5,'ro')
                
                switch winNum
                    case 1
                        legend({'stim','bins','photo','pulse'})
                        title('first frame')
                    case length(dropWins)
                        title('last frame')
                    otherwise
                        title(sprintf('%g total drops',numDrops));
                end
                xlim(tRange)
                ylim([0 1.1])
            end
            
            saveas(f,fullfile(wd,sprintf('%s drop report.fig',file)))
            
            if all(cellfun(@isempty,{pulsesPerRepeat,numRepeats,uniquesEvery}))
                uniquesEvery(stimNum) = 0;
            else
                error('haven''t yet updated code to work with old protocol (with interleaved uniques)')
            end
            
            test=false;
            if test
                numrpts=10.3;
                framesPerRpt=509;
                stimVals=randn(framesPerRpt,1);
                noise=.5*randn(round(numrpts*framesPerRpt),1);
                stimVals=noise+[repmat(stimVals,floor(numrpts),1); stimVals(1:round((numrpts-floor(numrpts))*framesPerRpt))];
            end
            
            f=figure;
            [xc b]=xcorr(stimVals);
            xInd=(length(xc)+1)/2;
            
            rptStrength=[0; diff(xc(xInd:end))];
            thresh=.7;
            potentials=find(rptStrength>thresh*max(rptStrength));
            if length(potentials)~=1
                potentials=potentials-1;
                rptFrames=min(potentials);
                if ~all(nearInt(potentials/rptFrames))
                    plot(b(xInd:end),rptStrength)
                    hold on
                    plot(b(xInd:end),thresh*max(rptStrength)*ones(1,length(rptStrength)))
                    error('can''t find rpts')
                end
            else
                rptFrames=b(xInd+potentials-1);
            end
            repeatStimVals{stimNum} = wrap(stimVals,rptFrames,0,true);
            
            subplot(3,1,1)
            plot(repeatStimVals{stimNum});
            title(sprintf('repeats at %g frames (%g secs)',rptFrames,rptFrames*nominalSecondsPerFrame))
            xlabel('frame num')
            
            numRepeats(stimNum) = size(repeatStimVals{stimNum},2);
            repeatTimes{stimNum} = wrap(boundaries,rptFrames,0,false);
            
            repeatStarts=repeatTimes{stimNum}(1,:);
            binVals=normalize(binVals);
            for rNum = 1:numRepeats(stimNum)
                mask  = binT    >= repeatStarts(rNum);
                pmask = physTms >= repeatStarts(rNum);
                
                if rNum < numRepeats(stimNum)
                    mask  = mask  & binT    < repeatStarts(rNum+1);
                    pmask = pmask & physTms < repeatStarts(rNum+1);
                else
                    pmask = pmask & physTms < binT(end)+1/binsPerSec;
                end
                
                binnedVals{stimNum,rNum}=binVals(mask);
                binnedT{stimNum,rNum}=binT(mask);
                
                physVals{stimNum,rNum}=phys(pmask);
                physT{stimNum,rNum}=physTms(pmask);
            end
            
            maxLagSecs = .5;
            
            test=false;
            if test
                adj = .5;
                numRepeats = 15;
                template=rand(1,10*binsPerSec);
                for rNum=1:ceil(numRepeats)
                    binnedVals{stimNum,rNum}=[rand(1,round(rand*adj*maxLagSecs*binsPerSec)) template+.2*rand(1,length(template)) rand(1,round(rand*adj*maxLagSecs*binsPerSec))];
                    binnedVals{stimNum,rNum}=binnedVals{stimNum,rNum}(ceil(rand*adj*maxLagSecs*binsPerSec):end-round(rand*adj*maxLagSecs*binsPerSec));
                    binnedT{stimNum,rNum}=rand*binsPerSec*(adj*maxLagSecs)+(1:length(binnedVals{stimNum,rNum}))/binsPerSec;
                end
            end
            
            sigs = padToMatrix({binnedVals{stimNum,:}});
            
            %this will run out of memory if numRepats > ~15.  how fix?
            %could do 15 at a time...
            [xc b]=xcorr(sigs,maxLagSecs*binsPerSec); %must use ZERO padding, not nan padding!!!
            
            xc=normalizeCols(xc);
            
            % only want upper triangle w/o diagonal!  pick strongest one as reference
            
            xcinds=reshape(1:numRepeats^2,numRepeats,numRepeats);
            offsets = nan(numRepeats,numRepeats);
            strengths = offsets;
            constraints = offsets;
            violations = offsets;
            txcinds=[];
            for s1 = 1:numRepeats
                for s2 = 1:numRepeats
                    if s2 > s1
                        txcinds(end+1)=xcinds(s1,s2);
                        txc=xc(:,txcinds(end));
                        [sorted order]=sort(txc,'descend');
                        offsets(s1,s2)=b(order(1));
                        
                        foundContigPeak = false;
                        strInd=1;
                        strInds=[];
                        strengths(s1,s2)=0;
                        while ~foundContigPeak
                            iso=find(sorted==sorted(strInd));
                            strInd=max(iso)+1;
                            strInds=sort([strInds;order(iso)]);
                            if any(diff(strInds)~=1)
                                foundContigPeak=true;
                                fprintf('peakwidth: %g\n',length(strInds)-length(iso))
                                if strengths(s1,s2)<.1
                                    figure
                                    plot(txc)
                                    error('no unique contiguous peak -- probably because maxLagSecs too short')
                                end
                            else
                                strengths(s1,s2)=1-sorted(strInd);
                            end
                        end
                    end
                end
            end
            
            colors=colormap(jet);
            subplot(3,1,3)
            
            bestBinOffsets{stimNum}=nan(1,numRepeats);
            while any(~isnan(strengths(:)))
                best=max(strengths(:));
                [s1,s2]=find(strengths==best);
                if length(s1)~=1
                    strengths
                    warning('no unique max')
                    s1=s1(1);
                    s2=s2(1);
                end
                
                plot(b/binsPerSec,xc(:,xcinds(s1,s2)),'Color',colors(ceil((sum(~isnan(strengths(:)))/sum([1:numRepeats-1]))*size(colors,1)),:))
                hold on
                
                if isnan(bestBinOffsets{stimNum}(s1))
                    if isnan(bestBinOffsets{stimNum}(s2))
                        if all(isnan(bestBinOffsets{stimNum}))
                            bestBinOffsets{stimNum}(s1)=0;
                            bestBinOffsets{stimNum}(s2)=offsets(s1,s2);
                        else
                            if isnan(constraints(s1,s2))
                                constraints(s1,s2)=offsets(s1,s2);
                            else
                                error('shouldn''t get multiple constraints per pair')
                            end
                        end
                    else
                        bestBinOffsets{stimNum}(s1)=bestBinOffsets{stimNum}(s2)-offsets(s1,s2);
                    end
                else
                    if isnan(bestBinOffsets{stimNum}(s2))
                        bestBinOffsets{stimNum}(s2)=bestBinOffsets{stimNum}(s1)+offsets(s1,s2);
                    else
                        if isnan(constraints(s1,s2))
                            constraints(s1,s2)=offsets(s1,s2);
                        else
                            error('shouldn''t get multiple constraints per pair')
                        end
                    end
                end
                strengths(s1,s2)=nan;
            end
            
            title('xcorrs')
            xlabel('secs')
            
            while any(~isnan(constraints(:)))
                [s1,s2]=find(~isnan(constraints),1,'first');
                if (bestBinOffsets{stimNum}(s2)-bestBinOffsets{stimNum}(s1))~=constraints(s1,s2);
                    violations(s1,s2)=constraints(s1,s2)-(bestBinOffsets{stimNum}(s2)-bestBinOffsets{stimNum}(s1));
                end
                constraints(s1,s2)=nan;
            end
            
            if any(~isnan(violations(:)))
                warning('constraints violated')
                violations
            end
            
            bestBinOffsets{stimNum}=(bestBinOffsets{stimNum}-bestBinOffsets{stimNum}(1))/binsPerSec;
            
            subplot(3,1,2)
            for rNum = 1:numRepeats(stimNum)
                plot(binnedT{stimNum,rNum}-binnedT{stimNum,rNum}(1)-bestBinOffsets{stimNum}(rNum),(rNum*.05)+normalize(binnedVals{stimNum,rNum}),'Color',colors(round((rNum/numRepeats)*size(colors,1)),:))
                hold on
            end
            xlabel('secs')
            title(sprintf('binned at %g hz',binsPerSec))
            
            saveas(f,fullfile(wd,sprintf('%s overlayed repeats.fig',file)))
            
            figure
            for s1=1:numRepeats
                for s2=1:numRepeats
                    if s1==s2
                        offset(s1,s2)=0;
                    else
                        txc=xc(:,xcinds(s1,s2));
                        if s2>s1
                            %txc=xc(:,xcinds(s1,s2));
                            par=1;
                        else
                            %txc=xc(:,xcinds(s2,s1));
                            par=1;
                        end
                        offset(s1,s2)=par*(find(txc==max(txc),1,'first')-1-floor(length(txc)/2));
                    end
                end
                out=zeros(1,1+max(offset(s1,:))-min(offset(s1,:)));
                out(offset(s1,:)-min(offset(s1,:))+1)=1;
                plot(out+.05*s1)
                hold on
            end
            
            if uniquesEvery(stimNum) > 0
                uniqueColInds{stimNum}=[uniquesEvery(stimNum):uniquesEvery(stimNum):numRepeats(stimNum)];
                repeatColInds{stimNum}=setdiff(1:numRepeats(stimNum),uniqueColInds{stimNum});
                
                uniqueTimes{stimNum} = repeatTimes{stimNum}(:,uniqueColInds{stimNum});
                repeatTimes{stimNum} = repeatTimes{stimNum}(:,repeatColInds{stimNum});
                
                uniqueStimVals{stimNum} = repeatStimVals{stimNum}(:,uniqueColInds{stimNum});
                repeatStimVals{stimNum} = repeatStimVals{stimNum}(:,repeatColInds{stimNum});
            else
                uniqueTimes{stimNum}=[];
                uniqueStimVals{stimNum}=[];
                uniqueColInds{stimNum}=[];
                repeatColInds{stimNum}=1:numRepeats(stimNum);
            end
        end
        
        clear stim;
        
        save(fullfile(wd,name),'binsPerSec','uniqueStimVals','repeatStimVals','uniqueTimes','repeatTimes','uniqueColInds','repeatColInds','dropTimes','binnedVals','binnedT','bestBinOffsets','physVals','physT');
    end
    
    
    
    spks=load(fullfile(wd,sprintf('%s spks.txt',file)));
    
    requiredRefractory=.002;
    requiredPreBurst=.100;
    requiredPostBurst=.005;
    
    isis=diff(spks);
    violationInds=1+find(isis<=requiredRefractory);
    bstStartInds=intersect(1+find(isis>=requiredPreBurst), find(isis<=requiredPostBurst));
    bstInternalInds=[];
    bstViolationInds=[];
    for bInd=bstStartInds'
        candidateInd=bInd+1;
        while spks(candidateInd)-spks(candidateInd-1) <= requiredPostBurst
            bstInternalInds=[bstInternalInds candidateInd];
            if spks(candidateInd)-spks(candidateInd-1) <= requiredRefractory
                bstViolationInds=[bstViolationInds candidateInd];
            end
            candidateInd=candidateInd+1;
        end
    end
    
    disp(sprintf('%s has %d refractory violations, %d bursts, and %d bursts with refractory violations',file,length(violationInds),length(bstStartInds),length(bstViolationInds)))
    
    violationTimes=spks(violationInds);
    bstStartTimes=spks(bstStartInds);
    bstMemberTimes=spks(bstInternalInds);
    bstViolationTimes=spks(bstViolationInds);
    specials={violationTimes,bstStartTimes,bstMemberTimes,bstViolationTimes};
    
    [pks pkcodes]=textread(fullfile(wd,sprintf('%s pokes.txt',file)),'%n %*q %d 0 0 0','headerlines',2);
    pks=pks(pkcodes~=0);
    pkcodes=pkcodes(pkcodes~=0);
    
    for stimNum=1:numStims
        
        tRange=[repeatTimes{stimNum}(1,1) max(repeatTimes{stimNum}(:))+1/binsPerSec];
        
        numRptSpks = sum(spks>=tRange(1) & spks<tRange(2));
        numRptPks = sum(pks>=tRange(1) & pks<tRange(2));
        
        for specialNum=1:length(specials)
            rptNums(specialNum)=sum(specials{specialNum}>=tRange(1) & specials{specialNum}<tRange(2));
        end
        
        numUnqSpks = 0;
        numUnqPks = 0;
        unqNums(1:length(specials)) = 0;
        if ~isempty(uniqueTimes{stimNum})
            numUnqSpks = sum(spks>=uniqueTimes{stimNum}(1,1) & spks<uniqueTimes{stimNum}(end,end)+1/binsPerSec);
            numUnqPks = sum(pks>=uniqueTimes{stimNum}(1,1) & pks<uniqueTimes{stimNum}(end,end)+1/binsPerSec);
            
            for specialNum=1:length(specials)
                unqNums(specialNum)=sum(specials{specialNum}>=uniqueTimes{stimNum}(1,1) & specials{specialNum}<uniqueTimes{stimNum}(end,end)+1/binsPerSec);
            end
            
        end
        repeatSpikes{stimNum}=sparse([],[],[],size(repeatTimes{stimNum},1),size(repeatTimes{stimNum},2),numRptSpks);
        uniqueSpikes{stimNum}=sparse([],[],[],size(uniqueTimes{stimNum},1),size(uniqueTimes{stimNum},2),numUnqSpks);
        
        repeatPokes{stimNum}=sparse([],[],[],size(repeatTimes{stimNum},1),size(repeatTimes{stimNum},2),numRptPks);
        uniquePokes{stimNum}=sparse([],[],[],size(uniqueTimes{stimNum},1),size(uniqueTimes{stimNum},2),numUnqPks);
        
        for specialNum=1:length(specials)
            rptSpecials{stimNum,specialNum}=sparse([],[],[],size(repeatTimes{stimNum},1),size(repeatTimes{stimNum},2),rptNums(specialNum));
            unqSpecials{stimNum,specialNum}=sparse([],[],[],size(uniqueTimes{stimNum},1),size(uniqueTimes{stimNum},2),unqNums(specialNum));
        end
        
        for repeatNum=1:size(repeatTimes{stimNum},2)
            theseBins=repeatTimes{stimNum}(:,repeatNum);
            ns = isnan(theseBins);
            fs = find(diff(ns));
            if repeatNum == size(repeatTimes{stimNum},2)
                if length(fs)>1
                    error('found noncontiguous nans')
                elseif length(fs)==1
                    theseBins(fs+1:end)=theseBins(fs); %hist will set all the zero width bins to zero
                end
            else
                if any(ns) || ~isempty(fs)
                    error('got nans before last repeat')
                end
            end
            
            theseBins=[theseBins(1)-1/binsPerSec; theseBins; theseBins(end)+1/binsPerSec];
            
            newCol=hist(spks,theseBins);
            if ~isempty(fs) && any(newCol(fs+1:end-1))
                error('hist edge case didn''t hold -- found zero width bins with members')
            end
            
            %             rtRange=[repeatTimes{stimNum}(1,repeatNum) max(repeatTimes{stimNum}(:,repeatNum))+1/binsPerSec];
            %             theseSpks=spks(spks>=rtRange(1) & spks<rtRange(2));
            %             theseSpks=theseSpks-rtRange(1);
            %
            %             if floor(max(theseSpks)*binsPerSec) > size(repeatTimes{stimNum},1)
            %                 error('bad sizes')
            %             end
            %
            %             newCol=full(sparse(1+floor(theseSpks*binsPerSec),1,1));
            
            repeatSpikes{stimNum}(:,repeatNum)=newCol(2:end-1);
            
            for specialNum=1:length(specials)
                newCol=hist(specials{specialNum},theseBins);
                
                if ~isempty(fs) && any(newCol(fs+1:end-1))
                    error('hist edge case didn''t hold -- found zero width bins with members')
                end
                
                %                 theseSpecials=specials{specialNum}(specials{specialNum}>=rtRange(1) & specials{specialNum}<rtRange(2));
                %                 theseSpecials=theseSpecials-rtRange(1);
                %
                %                 if floor(max(theseSpecials)*binsPerSec) > size(repeatTimes{stimNum},1)
                %                     error('bad sizes')
                %                 end
                %
                %                 newCol=full(sparse(1+floor(theseSpecials*binsPerSec),1,1));
                rptSpecials{stimNum,specialNum}(:,repeatNum)=newCol(2:end-1);
            end
            
            if ~isempty(pks)
                error('poke code needs to be adjusted to match above repeat code')
                pkInds=find(pks>=rtRange(1) & pks<rtRange(2));
                pkTimes=pks(pkInds);
                pkTimes=pkTimes-rtRange(1);
                pkTimes=1+floor(pkTimes*binsPerSec);
                repeatPokes{stimNum}(pkTimes,repeatNum)=pkcodes(pkInds);
            end
            
            spectralAnalysis(physVals{stimNum,repeatNum},physT{stimNum,repeatNum});
            
        end
        for uniqueNum=1:size(uniqueTimes{stimNum},2)
            error('unique code needs to be adjusted to match above repeat code')
            
            theseSpks=spks(spks>=uniqueTimes{stimNum}(1,uniqueNum) & spks<uniqueTimes{stimNum}(end,uniqueNum)+1/binsPerSec);
            theseSpks=theseSpks-uniqueTimes{stimNum}(1,uniqueNum);
            newCol=full(sparse(1+floor(theseSpks*binsPerSec),1,1));
            uniqueSpikes{stimNum}(1:length(newCol),uniqueNum)=newCol;
            
            for specialNum=1:length(specials)
                theseSpecials=specials{specialNum}(specials{specialNum}>=uniqueTimes{stimNum}(1,uniqueNum) & specials{specialNum}<uniqueTimes{stimNum}(end,uniqueNum)+1/binsPerSec);
                theseSpecials=theseSpecials-uniqueTimes{stimNum}(1,uniqueNum);
                newCol=full(sparse(1+floor(theseSpecials*binsPerSec),1,1));
                unqSpecials{stimNum,specialNum}(1:length(newCol),uniqueNum)=newCol;
            end
            
            pkInds=find(pks>=uniqueTimes{stimNum}(1,uniqueNum) & pks<uniqueTimes{stimNum}(end,uniqueNum)+1/binsPerSec);
            pkTimes=pks(pkInds);
            pkTimes=pkTimes-uniqueTimes{stimNum}(1,uniqueNum);
            pkTimes=1+floor(pkTimes*binsPerSec);
            uniquePokes{stimNum}(pkTimes,uniqueNum)=pkcodes(pkInds);
        end
    end
    
    name = sprintf('%s compiled data.mat',file);
    save(fullfile(wd,name),'binsPerSec','uniqueStimVals','repeatStimVals','uniqueTimes','repeatTimes','uniqueColInds','repeatColInds','uniqueSpikes','uniquePokes','repeatSpikes','repeatPokes','rptSpecials','unqSpecials');
    
    if drawSummary
        figure %(fileNum)
        for stimNum=1:numStims
            
            subplot(numStims,3,1+3*(stimNum-1))
            
            range=max(max(repeatStimVals{stimNum}))-min(min(repeatStimVals{stimNum}));
            
            if drawStims
                if ~isempty(uniqueStimVals{stimNum})
                    plot(repeatStimVals{stimNum}+repmat(range*repeatColInds{stimNum},size(repeatStimVals{stimNum},1),1),'k')
                    hold on
                    plot(uniqueStimVals{stimNum}+repmat(range*uniqueColInds{stimNum},size(uniqueStimVals{stimNum},1),1),'r')
                else
                    plot(repeatStimVals{stimNum})
                    hold on
                end
            end
            
            colors=['y','r','g','m'];
            sizes=[50, 30, 30, 50];
            order=[1,4,3,2];
            if all(length(repeatColInds{stimNum}) == [size(repeatStimVals{stimNum},2) size(repeatTimes{stimNum},2)])
                numRepeats(stimNum)=length(repeatColInds{stimNum});
            else
                error('numRepeats error')
            end
            if numRepeats(stimNum)>1
                subplot(numStims,3,2+3*(stimNum-1))
                for specialNum=order
                    spy([rptSpecials{stimNum,specialNum} zeros(size(repeatSpikes{stimNum},1),1) unqSpecials{stimNum,specialNum}]',colors(specialNum),sizes(specialNum));
                    hold on
                end
                spy([repeatSpikes{stimNum} ones(size(repeatSpikes{stimNum},1),1) uniqueSpikes{stimNum}]','k',5);
                axis fill
                
                subplot(numStims,3,3+3*(stimNum-1))
                colorPokes=[repeatPokes{stimNum} ones(size(repeatPokes{stimNum},1),1) uniquePokes{stimNum}]';
                spy(colorPokes,'k',1);
                hold on
                spy(colorPokes==32,'r',1);
                spy(colorPokes==64,'g',1);
                spy(colorPokes==128,'b',1);
                axis fill
            else
                plot(find(repeatSpikes{stimNum}),2*range,'rx');
                hold on
                tmp=find(repeatPokes{stimNum});
                if ~isempty(tmp)
                    plot(tmp,3*range,'ko');
                end
            end
            
        end
    end
end
end

function [vals expanded]=markSample(marks,begin,step,stim,str)
fprintf(['resampling ' str '... '])
inds=round((marks-begin)/step);

ex=zeros(length(stim),1);
ex(inds)=1;

subs=cumsum(ex)+1;
vals = accumarray(subs,stim);
vals([1 end])=nan;
expanded=vals(subs);
vals=vals(2:end-1);
fprintf('done\n')
end

function doHist(x)
%x=x(~isnan(x));
%x=x(6*std(x)>abs(x-mean(x)));
[mu sig]=normfit(x);
[counts bins]=hist(x,1000);

semilogy(bins,counts,'b');
hold on
gbins=linspace(-.5*max(bins),max(bins),1000);
gaussfit=normpdf(gbins,mu,sig);
gaussfit=max(counts)*gaussfit/max(gaussfit);
semilogy(gbins,gaussfit,'r')
legend({'actual','gaussian'})
ylim([min(counts(counts>0)) max(counts)])
end

function nPlot(a,b,c)
b=b-min(b);
b=b/max(b);
plot(a,b,c);
end

function x=normalize(x)
x=x-min(x);
x=x/max(x);
end

function x=normalizeCols(x)
x=x-repmat(min(x),size(x,1),1);
x=x./repmat(max(x),size(x,1),1);
end

function out=wrap(vals,rpt,offset,normalize)
numRepeats=ceil(length(vals)/rpt);
out=reshape([vals; nan(rpt*numRepeats-length(vals),1)] ,rpt,numRepeats);
if normalize
    out=out/max(out(:));
end
out=out+repmat(offset*(1:numRepeats),rpt,1);
end

function out=nearInt(in)
out= 0==in-round(in);
end

function out=padToMatrix(in)
len=max(cellfun(@length,in));
out=zeros(len,length(in));
for i=1:length(in)
    out(1:length(in{i}),i)=in{i};
end
end

function [data ts first step]=checkForCompiledMat(wd,fType,fName,forceRecompile,contents,resampFreq)
mattedName = sprintf('%s matted %s.mat',fName,fType);

if any(strcmp(contents.mat,mattedName)) && ~forceRecompile
    d=load(fullfile(wd,mattedName));
    data=d.data;
    first=d.first;
    step=d.step;
else
    fprintf('have to load %s for first time -- this takes awhile\n',fType)
    
    tName=sprintf('%s %s.txt',fName,fType);
    
    C=doScan(fullfile(wd,tName),'%% START %% %f %f',6);
    
    first=C{1};
    step=C{2};
    
    if first<0 || abs(1- step * 40000)>.5
        error('bad first or step')
    end
    
    data=load(fullfile(wd,tName));
    disp(sprintf('file %s loaded',tName))
    
    save(fullfile(wd,mattedName),'data','first','step');
    disp(sprintf('matted version saved'))
end

ts=getTimes(first, step, length(data));

if isscalar(resampFreq)
    
    checkSecs=3;
    checkInds=1:checkSecs/step;
    figure
    plot(ts(checkInds),data(checkInds),'b')
    hold on
    
    if ~all(arrayfun(@isNearInteger,[resampFreq,1/step]))
        %         [resampFreq,1/step]
        %         warning('resample requires ints -- need to find ints P,Q, s.t. P/Q = ')
        %         resampFreq * step
        str = sprintf('%g',resampFreq*step);
        while str(end)=='0';
            str=str(1:end-1);
        end
        decstr=str;
        decCount=0;
        while length(decstr)>0 && decstr(end)~='.';
            decstr=decstr(1:end-1);
            decCount=decCount+1;
        end
        if isempty(decstr)
            P=resampFreq*step;
            Q=1;
            if ~isNearInteger(P)
                error('shouldn''t be possible')
            end
        else
            P=resampFreq*step*10^decCount;
            Q=10^decCount;
        end
        if (P/Q ~= resampFreq*step)
            error('fix didn''t work')
        end
    else
        P=resampFreq;
        Q=1/step;
    end
    fprintf('resampling %s\n',fType)
    data=resample(data,P,Q);
    step=1/resampFreq;
    ts=getTimes(first, step, length(data));
    fprintf('done resampling phys\n')
    
    checkInds=1:checkSecs/step;
    plot(ts(checkInds),data(checkInds),'r')
end
end

function out=getTimes(first, step, len)
out=cumsum([first step*ones(1,len-1)]);
end

function spectralAnalysis(data,t)
if true
    
    p=.95;
    winDur = .1;
    
    hz=1/unique(diff(t));
    if length(hz)~=1
        error('bad hz')
    end
    
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
end
end

function gram(S,t,f,type)
imagesc(t,f,S);
axis xy;
xlabel('time (s)');
ylabel('freq (hz)');
colorbar;
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