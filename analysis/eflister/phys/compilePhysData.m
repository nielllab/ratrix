function compilePhysData(fileNames,stimTimes,pulseTimes,rec,stimType,targetBinsPerSec,force,figureBase,analysisFilt)

%winExist needed for very long path/file names on win, but doesn't solve
%problem that matlab can't load file...
    function out=winExist(f)
        [a b c d]=fileparts(f);
        fs=dir(a);
        [tf n]=ismember([b c],{fs.name});
        out = tf & ~fs(n).isDir;            
    end

if analysisFilt(rec,stimType)
    
    [pth name]=fileparts([fileparts(fileNames.targetFile) '.blah']);
    prefix=fullfile(pth,name);
    
    fileGood = false;
    if exist(fileNames.targetFile,'file') && ~force %|| winExist(fileNames.targetFile)
        load(fileNames.targetFile,'binsPerSec');
        if binsPerSec==targetBinsPerSec
            fileGood = true;
        end
    end

    if ~fileGood
            keyboard
        fprintf('compiling %s\n',fileNames.targetFile);

        resetDir(prefix);
        
        binsPerSec=targetBinsPerSec;
        
        [stim stimT phys physT] = getStimAndPhys(stimType,pth,force,binsPerSec,stimTimes);
        
        if ~ismember(stimType,{'junk','off'})
            
            [thesePulses,stimBreaks,nominalSecondsPerFrame,stim,stimT,phys,physT,origPulses]=getPulses(fileNames.pulseFile,pulseTimes,rec,stimType,stim,stimT,phys,physT);
            
            [tStim, stimVals, expandedStim, binVals, expandedBins, binT]=doStimFrames(binsPerSec,thesePulses,stim,stimT,prefix,name,nominalSecondsPerFrame);
            
            dropTimes=frameDropReport(nominalSecondsPerFrame,thesePulses,prefix,name,stimT,tStim,expandedStim,expandedBins,origPulses);
            
            [uniqueStimVals,repeatStimVals,uniqueTimes,repeatTimes,uniqueColInds,repeatColInds,binnedVals,binnedT,bestBinOffsets,phys,physT]=findRepeats(stimBreaks,stimType,stimVals,nominalSecondsPerFrame,binVals,prefix,name,thesePulses,binT,physT,phys,binsPerSec);
            
        else
            uniqueStimVals=[];
            repeatStimVals=[];
            uniqueTimes=[];
            repeatTimes=[];
            uniqueColInds=[];
            repeatColInds=[];
            binnedVals=[];
            binnedT=[];
            bestBinOffsets=[];
            dropTimes=[];
            stimBreaks=[];
        end
        
        % clear stim;
        
        save(fileNames.targetFile,'binsPerSec','uniqueStimVals','repeatStimVals','uniqueTimes','repeatTimes','uniqueColInds','repeatColInds','dropTimes','binnedVals','binnedT','bestBinOffsets','phys','physT','stimBreaks');
    end
    
    fileNames.wavemarkFile=parseWaveforms(fileNames.wavemarkFile,pth,rec.chunks.spkChan,force);
    
    tmpAnalysis(fileNames,stimTimes,pulseTimes,rec,stimType,targetBinsPerSec,force,figureBase);
end
end

function [uniqueStimVals,repeatStimVals,uniqueTimes,repeatTimes,uniqueColInds,repeatColInds,binnedVals,binnedT,bestBinOffsets,physVals,physT]=findRepeats(stimBreaks,stimType,stimVals,nominalSecondsPerFrame,binVals,pth,name,boundaries,binT,physTms,phys,binsPerSec)
test=false;
if test
    numrpts=10.3;
    framesPerRpt=509;
    stimVals=randn(framesPerRpt,1);
    noise=.5*randn(round(numrpts*framesPerRpt),1);
    stimVals=noise+[repmat(stimVals,floor(numrpts),1); stimVals(1:round((numrpts-floor(numrpts))*framesPerRpt))];
end

stimMins = nominalSecondsPerFrame * length(stimVals) / 60;

    function giveup
        plot(b(xInd:end),rptStrength)
        hold on
        plot(b(xInd:end),thresh*max(rptStrength)*ones(1,length(rptStrength)))
        failStr=sprintf('could not find repeats for %g min stim.(%g xcorr thresh)',stimMins,thresh);
        title(failStr)
        fprintf(['\t' failStr ': ']);
        if stimMins < 5 % || true
            fprintf('moving on\n')
            saveas(f,fullfile(pth,[failStr '.' name '.fig']));
            close(f)
            
            uniqueStimVals=[];
            repeatStimVals=[];
            uniqueTimes=[];
            repeatTimes=[];
            uniqueColInds=[];
            repeatColInds=[];
            
            binnedVals=binVals;
            binnedT=binT;
            
            bestBinOffsets=[];
            physVals=phys;
            physT=physTms;
        else
            error('can''t find rpts')
        end
    end

f=figure;
if isempty(stimBreaks)
    fprintf('\t\tstarting xcorr...')
    [xc b]=xcorr(stimVals);
    fprintf('done')
    xInd=(length(xc)+1)/2;
    
    rptStrength=[0; diff(xc(xInd:end))];
    thresh=.6;
    potentials=find(rptStrength>thresh*max(rptStrength));
    
    if length(potentials)~=1
        if strcmp(stimType,'sinusoid')
            
            potentials=[];
            threshs=.7:-.1:.3;
            threshNum=0;
            while length(potentials)<15 && threshNum<length(threshs)
                threshNum=threshNum+1;
                thresh=threshs(threshNum);
                potentials=find(rptStrength>thresh*max(rptStrength));
            end
            
            
            tmp=sort(diff(potentials));
            tmp=tmp(end);
            potentials=potentials(potentials>.75*tmp & potentials<1.25*tmp);
            %         if mod(length(potentials),2)==1
            %             rptFrames=potentials(ceil(length(potentials)/2));
            %         else
            %             error('shouldn''t it be odd?')
            %         end
            [garbage winner]=sort(rptStrength(potentials));
            rptFrames=potentials(winner(end))-1;
            if rptFrames*nominalSecondsPerFrame < 1
                giveup;
                return
            end
        else
            potentials=potentials-1;
            rptFrames=min(potentials);
            if .5 > sum(nearInt(potentials/rptFrames))/length(potentials)
                giveup;
                return
            end
        end
    else
        rptFrames=b(xInd+potentials-1);
    end
else
    rptFrames=round(median(diff(stimBreaks))/nominalSecondsPerFrame);
end

fprintf(' wrapping...')
repeatStimVals= wrap(stimVals,rptFrames,0,true);
fprintf('done')

fprintf(' plotting rpts 1...')
subplot(3,1,1)
plot(repeatStimVals);
title(sprintf('repeats at %g frames (%g secs)',rptFrames,rptFrames*nominalSecondsPerFrame))
xlabel('frame num')
fprintf('done')

numRepeats = size(repeatStimVals,2);
repeatTimes = wrap(boundaries,rptFrames,0,false);

succStr=sprintf('(%g repeats of %g mins each).',length(binT)/binsPerSec/(rptFrames*nominalSecondsPerFrame),rptFrames*nominalSecondsPerFrame/60);
fprintf(['\tfound ' succStr '!\n'])

fprintf('\t\tnormalizing',numRepeats)

repeatStarts=repeatTimes(1,:);
binVals=normalize(binVals);

fprintf('done.  doing bins and phys...')
for rNum = 1:numRepeats
    mask  = binT    >= repeatStarts(rNum);
    pmask = physTms >= repeatStarts(rNum);
    
    if rNum < numRepeats
        mask  = mask  & binT    < repeatStarts(rNum+1);
        pmask = pmask & physTms < repeatStarts(rNum+1);
    else
        pmask = pmask & physTms < binT(end)+1/binsPerSec;
    end
    
    binnedVals{rNum}=binVals(mask);
    binnedT{rNum}=binT(mask);
    
    physVals{rNum}=phys(pmask);
    physT{rNum}=physTms(pmask);
end
fprintf('done')

maxLagSecs = .5;

test=false;
if test
    adj = .5;
    numRepeats = 15;
    template=rand(1,10*binsPerSec);
    for rNum=1:ceil(numRepeats)
        binnedVals{rNum}=[rand(1,round(rand*adj*maxLagSecs*binsPerSec)) template+.2*rand(1,length(template)) rand(1,round(rand*adj*maxLagSecs*binsPerSec))];
        binnedVals{rNum}=binnedVals{rNum}(ceil(rand*adj*maxLagSecs*binsPerSec):end-round(rand*adj*maxLagSecs*binsPerSec));
        binnedT{rNum}=rand*binsPerSec*(adj*maxLagSecs)+(1:length(binnedVals{rNum}))/binsPerSec;
    end
end

fprintf(' making pad...')
sigs = padToMatrix(binnedVals);
fprintf('done\n')

colors=colormap(jet);

if numRepeats<=15
    %this will run out of memory if numRepats > ~15.  how fix?
    %could do 15 at a time...
    
    fprintf('\t\t\t secondary alignment xcorr...')
    [xc b]=xcorr(sigs,maxLagSecs*binsPerSec); %must use ZERO padding, not nan padding!!!
    fprintf('done.  normalizing...')
    
    xc=normalizeCols(xc);
    fprintf('done.  solving constraints...')
    
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
                        fprintf('\tpeakwidth: %g\n',length(strInds)-length(iso))
                        if strengths(s1,s2)<.1 && false % disabling -- can't remember what i was doing here
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
    
    subplot(3,1,3)
    
    bestBinOffsets=nan(1,numRepeats);
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
        
        if isnan(bestBinOffsets(s1))
            if isnan(bestBinOffsets(s2))
                if all(isnan(bestBinOffsets))
                    bestBinOffsets(s1)=0;
                    bestBinOffsets(s2)=offsets(s1,s2);
                else
                    if isnan(constraints(s1,s2))
                        constraints(s1,s2)=offsets(s1,s2);
                    else
                        error('shouldn''t get multiple constraints per pair')
                    end
                end
            else
                bestBinOffsets(s1)=bestBinOffsets(s2)-offsets(s1,s2);
            end
        else
            if isnan(bestBinOffsets(s2))
                bestBinOffsets(s2)=bestBinOffsets(s1)+offsets(s1,s2);
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
        if (bestBinOffsets(s2)-bestBinOffsets(s1))~=constraints(s1,s2);
            violations(s1,s2)=constraints(s1,s2)-(bestBinOffsets(s2)-bestBinOffsets(s1));
        end
        constraints(s1,s2)=nan;
    end
    
    if any(~isnan(violations(:)))
        warning('constraints violated')
        violations
    end
    
    bestBinOffsets=(bestBinOffsets-bestBinOffsets(1))/binsPerSec;
    fprintf(' done\n')
    
    subplot(3,1,2)
    for rNum = 1:numRepeats
        plot(binnedT{rNum}-binnedT{rNum}(1)-bestBinOffsets(rNum),(rNum*.05)+normalize(binnedVals{rNum}),'Color',colors(round((rNum/numRepeats)*size(colors,1)),:)) %seems like we are going to zero index into colors -- what prevents this?
        hold on
    end
    xlabel('secs')
    title(sprintf('binned at %g hz',binsPerSec))
    
    saveas(f,fullfile(pth,['overlayed repeats.' succStr name '.fig']));
    close(f)
    
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
    
    saveas(f,fullfile(pth,['forgot what this xcorr plot means.' name '.fig']));
    close(f)
    
else
    fprintf('\t\t\tskipping bin offsetting cuz too many repeats\n')
    bestBinOffsets=[];
    
    subplot(3,1,2)
    for rNum = 1:numRepeats
        plot(binnedT{rNum}-binnedT{rNum}(1),(rNum*.05)+normalize(binnedVals{rNum}),'Color',colors(ceil((rNum/numRepeats)*size(colors,1)),:))
        hold on
    end
    xlabel('secs')
    title(sprintf('binned at %g hz',binsPerSec))
    
    saveas(f,fullfile(pth,['overlayed repeats.' succStr name '.fig']));
    close(f)
end

if false % uniquesEvery > 0
    uniqueColInds=[uniquesEvery:uniquesEvery:numRepeats];
    repeatColInds=setdiff(1:numRepeats,uniqueColInds);
    
    uniqueTimes = repeatTimes(:,uniqueColInds);
    repeatTimes = repeatTimes(:,repeatColInds);
    
    uniqueStimVals = repeatStimVals(:,uniqueColInds);
    repeatStimVals = repeatStimVals(:,repeatColInds);
else
    uniqueTimes=[];
    uniqueStimVals=[];
    uniqueColInds=[];
    repeatColInds=1:numRepeats;
end
end

function tmp
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

function [vals expanded]=markSample(marks,times,stim,str)
step=mean(diff(times));
marks=marks(marks>times(1));

inds=floor((marks-times(1))/step)+1;
inds=inds(inds<=length(stim));

ex=zeros(length(stim),1);
ex(inds)=1;

if false
    figure
    subplot(2,1,1)
    plot(marks)
    hold on
    plot(times,'r')
    subplot(2,1,2)
    plot(ex)
end

fprintf(['\taccumulating ' str '... '])
subs=cumsum(ex)+1;
vals = accumarray(subs,stim);
expanded=vals(subs);

fprintf('done\n')

if false
    figure
    subplot(2,1,1)
    plot(vals)
    subplot(2,1,2)
    plot(expanded)
    keyboard
end
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
out= abs(in-round(in))<.01;
end

function out=padToMatrix(in)
len=max(cellfun(@length,in));
out=zeros(len,length(in));
for i=1:length(in)
    out(1:length(in{i}),i)=in{i};
end
end

function [P,Q]=getPQ(resampFreq,step)
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
P=round(P);
Q=round(Q);
if ~almostEqual(resampFreq, P/Q/step)
    error('PQerr')
end
fprintf('resampling from %g to %g (P=%d, Q=%d)\n',1/step,resampFreq,P,Q);
end

function [data ts first step]=checkForResampledMat(fType,pth,force,resampFreq)
checkPlot=false;
cs={};
ds={};
checkSecs=1;

[garbage code]=fileparts(pth);
origName = fullfile(pth,[fType '.' code '.mat']);
if ~exist(origName,'file')
    error('no file')
end

mattedName = fullfile(pth,[fType '.' code '.resamp.' num2str(resampFreq) '.mat']);

if exist(mattedName,'file') && ~force
    d=load(mattedName);
    data=d.data;
    first=d.first;
    step=d.step;
    if ~almostEqual(step,(1/resampFreq))
        error('step doesn''t equal 1/resamp')
    end
else
    fprintf('\tresampling to %s\n',mattedName)
    boundaries=getRangeFromChunks(origName);
    
    total=diff(cellfun(@(x) x(boundaries),{@min @max}));
    finalLen=floor(resampFreq*total/1000);
    data=nan(1,finalLen);
    x=whos('data');
    fprintf('\tcompressing to %g MB\n',x.bytes/1000/1000); %sometimes up to 100MB
    
    P = [];
    Q = [];
    
    prevChunk = [];
    numChunks = length(boundaries) -1;
    step = [];
    ind = 1;
    extended=false;
    for chunkNum=0:numChunks-1
        out=getRangeFromChunks(origName,chunkNum);
        
        predictedEnd=boundaries(chunkNum+2);
        testStep=mean(diff(out(2,:)));
        if testStep < 1000/50000 || testStep > 1000/10000
            error('rate error')
        end
        if isempty(step)
            step=testStep;
        else
            if ~almostEqual(step,testStep)
                error('inconsistent rates')
            end
        end
        if chunkNum~=numChunks-1 || true %looks like last boundary includes one extra step?
            predictedEnd=predictedEnd-step;
        end
        
        if out(2,1) ~= boundaries(chunkNum+1) || abs(out(2,end) - predictedEnd) > .25*step
            if  abs(out(2,end) - predictedEnd) > .5*step
                error('time error')
            else
                abs(out(2,end) - predictedEnd)/step
                warning('time significantly off...') % note last ~1/3 of 03.25.09 d6 reports being off by 21.7% (both stim and phys, starting around chunk 33)?
                % same with 04.23.09 4b (also starting around chunk 30)
                % same with 04.24.09 91 (chunk 18)
                % and 04.29.09 c2 (chunk 33)
            end
        end
        
        if isempty(P) || isempty(Q)
            if ~ (isempty(P) && isempty(Q))
                error('PQ error')
            end
            [P,Q]=getPQ(resampFreq,step/1000);
            testLen=ceil((boundaries(end)-boundaries(1))*P/Q/step);
            switch testLen - length(data)
                case 1
                    data(end+1)=nan;
                    finalLen=finalLen+1;
                    extended=true;
                case 0
                    %pass
                otherwise
                    error('data len error')
            end
        end
        
        if checkPlot
            checkInds=floor(min(1000*checkSecs/step,size(out,2)));
            cs{end+1}=out(:,1:checkInds);
            cs{end+1}=out(:,end-checkInds:end);
        end
        
        fprintf('\tresampling %d of %d\n',chunkNum+1,numChunks)
        
        thisChunk=[prevChunk out];
        
        maxResampLen=7500000;
        miniNum=1;
        tag=1;
        while size(thisChunk,2)>maxResampLen
            if checkPlot
                checkInds=floor(min(1000*checkSecs/step));
                ds{end+1}=thisChunk(:,1:checkInds);
                ds{end+1}=thisChunk(:,maxResampLen-checkInds:maxResampLen);
            end
            
            fprintf('\t\tresampling mini %d of %g\n',miniNum,2*size(thisChunk,2)/maxResampLen)
            resamped=resample(thisChunk(1,1:maxResampLen),P,Q);
            
            tag=ceil(length(resamped)/4);
            lastInd=ind+length(resamped)-tag;
            
            if ind==1
                data(ind:length(resamped))=resamped;
                ind=lastInd+1;
            else
                data(ind:lastInd)=resamped(tag:end);
                ind=lastInd-tag;
            end
            
            cut=ceil(maxResampLen/2);
            if checkPlot
                ds{end+1}=thisChunk(:,cut-checkInds:cut+checkInds);
            end
            thisChunk=thisChunk(:,cut:end);
            
            miniNum=miniNum+1;
        end
        prevChunk = thisChunk;
    end
    
    if size(prevChunk,2)>size(out,2)
        out=prevChunk;
    end
    resamped=resample(out(1,:),round(P),round(Q));
    if tag==1 && extended && length(data)-length(resamped)==1
        data=data(1:end-1); %covers for some bug i don't understand when everything was in one chunk..
        finalLen=finalLen-1;
    end
    data(end-length(resamped)+tag:end)=resamped(tag:end);
    
    if any(isnan(data)) || length(data)~=finalLen
        error('missed')
    end
    
    fprintf('done resampling %s\n',fType)
    
    first=boundaries(1)/1000;
    step= 1/(P/(Q*step/1000));
    
    save(mattedName,'data','first','step');
end

ts=getTimes(first,step, length(data));

if checkPlot
    figure
    plot(ts,data,'b')
    hold on
    for c=1:length(cs)
        plot(cs{c}(2,:)/1000,cs{c}(1,:),'r')
    end
    for d=1:length(ds)
        plot(ds{d}(2,:)/1000,ds{d}(1,:),'g')
    end
    keyboard
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

function [frameTimes, stimBreaks, nominalSecondsPerFrame,stim,stimT,phys,physT,origPulses] = getPulses(pulseFile,pulseTimes,rec,stimType,stim,stimT,phys,physT)

frameTimes=[];
stimBreaks=[];

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

scheduledFrames=false; %how are we going to check for this?
if scheduledFrames
    error('not implemented');
end

switch rec.display_type
    case 'vrg'
        %note that the logic here would have to be carefully reworked
        %apparently vrg pulses lagged the gun peaks (verify this), whereas ratrix pulses precede them
        error('not implemented')
    case 'crt'
        switch rec.pulse_type
            case 'double'
                
                warning('new experiments shold use the index or LED protocols (for description, see scanTriple.m)')
                
                if strcmp(rec.stimPulseChan,'X') && strcmp(rec.framePulseChan,'X')
                    rec.framePulseChan=2; %a hack
                elseif ~all(strcmp({rec.indexPulseChan,rec.phasePulseChan,rec.stimPulseChan},'none'))
                    error('inconsistent pulse type')
                end
                
                % example pulse file:
                % 1   %CHANNEL%	%2%
                % 2   %Evt+-%
                % 3   %%
                % 4   %pulse%
                % 5
                % 6   %HIGH%
                % 7   1435.8024667
                % ... ...
                
                
                % doScan(file,format,headerlines,chanVerify,instancesVerify,fieldsVerify,rep)
                C=doScan(pulseFile,'%% %[^%] %%',5,rec.framePulseChan,1,1,false);
                
                if ~strcmp(C{1},'HIGH')
                    error('bad pulse parity')
                end
                
                C=doScan(pulseFile,'%% %[^%] %%',1,rec.framePulseChan,1,1,false);
                
                if ~strcmp(C{1},'Evt+-')
                    error('wrong channel type')
                end
                
                origPulses = load(pulseFile);
                origPulses = origPulses(origPulses>=pulseTimes(1) & origPulses<=pulseTimes(2));
                
                numFrames=length(origPulses)/6;
                pat=logical([0 0 0 0 1 0])';
                frameTimes=origPulses([repmat(pat,floor(numFrames),1) ; pat(1:round(length(pat)*(numFrames-floor(numFrames))))]);
                
                if numFrames~=round(numFrames) && false %disable cuz our pulse txt file extractor cuts off pulses at the end of a (sorting) chunk boundary
                    %even if a stim goes longer than that -- and we need the end of the stim to catch the right end pulses
                    %see extractPhysThenAnalyze.m/getLastStop()
                    numFrames
                    
                    figure
                    plot(origPulses,zeros(1,length(origPulses)),'kx')
                    hold on
                    plot(frameTimes,zeros(1,length(frameTimes)),'bo')
                    
                    title(sprintf('numFrames error: %g (should be     xxxx     ox   ) in %s (%g - %g) %s:%s',numFrames,stimType,stimT(1),stimT(end),[rec.rat_id ' ' datestr(rec.date)],rec.baseFile))
                    error('num pulses error')
                end
                
                if false %this method doesn't work cuz sometimes there is a 5ms gap BETWEEN the fast double pulses!
                    dPulses=diff(origPulses)<.0007; %.0004; %major problems if flip or stim comp is ever this fast, or if double pulses take longer than this
                    stimComputed=[false; dPulses] & [false; false; dPulses(1:end-1)] & [false; false; false; dPulses(1:end-2)]; %pulses preceded by 3 quick events
                    
                    frameTimes=origPulses([false; stimComputed(1:end-1)]); % take first down after the double to be the moment flip returns, gun will reach photodiode for this frame in about .9ms
                    
                    check=reshape(stimComputed,6,numFrames)==repmat([0 0 0 1 0 0]',1,numFrames);
                    if ~all(check(:)) %can be quite confident if we pass this
                        tmp=origPulses(find(check(:)~=1))
                        figure
                        plot(origPulses,zeros(1,length(origPulses)),'kx')
                        hold on
                        plot(repmat(frameTimes',2,1),repmat(.5*[-1; 1],1,length(frameTimes)),'b')
                        plot(repmat(tmp',2,1),repmat([-1; 1],1,length(tmp)),'r')
                        title('pulse errors')
                        error('pulse problem')
                    end
                end
                
                pulseOffsetPct = .65; %pct of a nominal frame duration that the gun LAGS the pulse (depends on pdiode location!)
                
            case 'triple'
                
                warning('new experiments shold use the index or LED protocols (for description, see scanTriple.m)')
                
                if ~all(strcmp({rec.indexPulseChan},'none'))
                    error('inconsistent pulse type')
                end
                
                [frameTimes origPulses]=scanTriple(pulseFile,rec.framePulseChan,rec.stimPulseChan,rec.phasePulseChan,pulseTimes);
                pulseOffsetPct = 0;
            case 'index'
                if pulseTimes(1)==3182.599 && ~isempty(findstr(pulseFile,'8d2b23279f87853a7c63e4ab0ed38b8b150c317d')) %hack - this needs to be fixed in spreadsheet -- currently starts mid-index pulse
                    pulseTimes(1)=3182.597;
                end
                
                [frameTimes origPulses stimBreaks]=scanTriple(pulseFile,rec.framePulseChan,rec.stimPulseChan,rec.phasePulseChan,pulseTimes, rec.indexPulseChan);
                
                pulseOffsetPct = 0;
                
            otherwise
                error('unknown protocol')
        end
    case 'led'
        if ~all(strcmp({rec.framePulseChan,rec.phasePulseChan,rec.stimPulseChan},'none')) || ~strcmp(rec.pulse_type,'led')
            error('inconsistent pulse type')
        end
        
        % example pulse file:
        %
        % %CHANNEL%       %9%
        %
        % 6123.743655
        % 6141.744280
        % 6159.744905
        % 6177.745530
        % 6195.746130
        % 6213.746755
        
        try
            [fid msg]=fopen(pulseFile,'rt');
            if ~isempty(msg)
                msg
            end
            
            if fid>2
                
                chanForm='%% CHANNEL %% %% %u8 %%';
                C = textscan(fid,chanForm,1);
                
                if isscalar(C)
                    if C{1}~= rec.indexPulseChan
                        error('wrong chan')
                    end
                else
                    error('bad chan')
                end
                
            else
                error('no file')
            end
            error('finally')
        catch ex
            if exist('fid','var')
                s=fclose(fid);
                if s
                    error('fclose error')
                end
            end
            
            if ~strcmp(ex.message,'finally')
                rethrow(ex)
            end
        end
        
        stimBreaks = load(pulseFile);
        stimBreaks = stimBreaks(stimBreaks>=pulseTimes(1) & stimBreaks<=pulseTimes(2));
        
        frameTimes=[pulseTimes(1):.001:pulseTimes(2)]';
        origPulses=frameTimes;
        
        pulseOffsetPct = 0;
    otherwise
        error('unknown dispType')
end

cutFrameTimes=frameTimes(frameTimes >= stimT(1) & frameTimes < stimT(end));

nominalSecondsPerFrame = median(diff(cutFrameTimes));
if abs(1-nominalSecondsPerFrame/.01) > .1
    1/nominalSecondsPerFrame
    warning('bad frame times')
end

frameTimes=frameTimes+pulseOffsetPct*nominalSecondsPerFrame;
origPulses=origPulses+pulseOffsetPct*nominalSecondsPerFrame;

aboveInd=find(frameTimes>=stimT(1),1,'first');
belowInd=find(frameTimes<=stimT(end),1,'last');
frameTimes=frameTimes(aboveInd:belowInd);

[stimT,stim]=chop(stimT,stim,[frameTimes(1),frameTimes(end)]);
[physT,phys]=chop(physT,phys,[frameTimes(1),frameTimes(end)]);

fprintf('\t%g mins of frames (%g hz)\n',(frameTimes(end)-frameTimes(1))/60,1/nominalSecondsPerFrame)
end

function [times,vals]=chop(times,vals,lims)
tMask=times>=lims(1) & times<lims(end);
times=times(tMask);
vals=vals(tMask);
end

function [stim stimT phys physT] = getStimAndPhys(stimType,pth,force,targetBinsPerSec,stimTimes)
% [phys physTms]
[phys physT]=checkForResampledMat('phys',pth,force,targetBinsPerSec);
fprintf('\tphys loaded\n')
if ~ismember(stimType,{'junk','off'})
    % [stim stimT first step]
    [stim stimT]=checkForResampledMat('stim',pth,force,targetBinsPerSec);
    
    minT = max([physT(1), stimT(1), stimTimes(1)]);
    maxT = min([physT(end), stimT(end), stimTimes(2)]);
    
    [stimT,stim]=chop(stimT,stim,[minT,maxT]);
    [physT,phys]=chop(physT,phys,[minT,maxT]);
    
    if false % this isn't necessary i don't think
        len = min(length(stimT),length(physT));
        if length(physT)==length(stimT)
            %pass
        elseif length(stimT) - len == 1
            stim=stim(1:end-1);
            stimT=stimT(1:end-1);
        elseif length(physT) - len == 1
            phys=phys(1:end-1);
            physT=physT(1:end-1);
        else
            error('bad stim/phys lengths')
        end
        
        step=median(diff(stimT));
        
        if ~all(abs(physT-stimT < .05 *step))
            error('stim/phys times don''t line up')
        end
    end
    fprintf('\tstim loaded\n')
else
    stimT=[];
    stim=[];
end

end

function [tStim,stimVals, expandedStim, binVals, expandedBins, binT]=doStimFrames(binsPerSec,thesePulses,stim,stimT,pth,name,nominalSecondsPerFrame)
clipS=[];
tStim=normalize(stim'); %photodiode measurements should be considered linear but not calibrated

[stimVals expandedStim]=markSample(thesePulses,stimT,tStim,'frames');
thesePulses = thesePulses(1:end-1);

binT=thesePulses(1): 1/binsPerSec : thesePulses(end);
[binVals expandedBins]=markSample(binT,stimT,tStim,'bins');
binT = binT(1:end-1);

f=figure;
subplot(3,1,1)
[pHist pBins]=hist(tStim,100);
if pHist(end)>pHist(end-1)
    warning('photodiode may have clipped')
    clipS='(possible photodiode clip).';
end
semilogy(pBins,pHist)
title(['photo dist -- any clipping?  ' clipS])

subplot(3,1,2)
doHist(stimVals);
title(sprintf('frame distribution (median hz: %g)',1/nominalSecondsPerFrame));

subplot(3,1,3)
doHist(binVals);
title(sprintf('bins of %g ms',1000/binsPerSec))

saveas(f,fullfile(pth,['stim dist.' clipS name '.fig']));
close(f)
fprintf('\tframes resolved\n')
end

function dropTimes=frameDropReport(nominalSecondsPerFrame,thesePulses,pth,name,stimT,tStim,expandedStim,expandedBins,origPulses)
contextFrames=25;
maxRowsPerFig=7;
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

winNum=0;
numFigs=ceil(length(dropWins)/maxRowsPerFig);
for fig=1:numFigs
    f=figure;
    for winNum=winNum+1:min(length(dropWins),winNum+maxRowsPerFig)
        if fig>5 && fig<numFigs
            skip=true;
        else
            skip=false;
            subplot(maxRowsPerFig,1,mod(winNum-1,maxRowsPerFig)+1)
            
            tRange=dropWins{winNum}(1)+contextSecs*[-1 1];
            tInds=stimT<tRange(2) & stimT>tRange(1);
            
            nPlot(stimT(tInds),expandedStim(tInds),'r');
            hold on
            nPlot(stimT(tInds),tStim(tInds),'b');
            nPlot(stimT(tInds),expandedBins(tInds),'g');
            plot(origPulses(origPulses<tRange(2) & origPulses>tRange(1)),.5,'kx');
            plot(thesePulses(thesePulses>=tRange(1) & thesePulses<=tRange(2)),.5,'bo')
            if ~isempty(dropTimes)
                plot(dropTimes,.5,'ro')
            end
            
            switch winNum
                case 1
                    legend({'stim','photo','bins','pulse'})
                    title(sprintf('first frame - %g total drops',numDrops))
                case length(dropWins)
                    title('last frame')
                otherwise
                    title(sprintf('%g total drops',numDrops));
            end
            xlim(tRange)
            ylim([0 1.1])
        end
    end
    if ~skip
        saveas(f,fullfile(pth,['drop report.' sprintf('(%d of %d - %d total drops).',fig,numFigs,numDrops) name '.fig']));
    end
    close(f)
end
fprintf('\tframe drop report done: %d drops\n',length(dropTimes))
end