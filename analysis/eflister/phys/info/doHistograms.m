function [pSpkGivenStim binnedStim edges]=doHistograms(filteredStim,spkTimes,edges,priorSpkProb,tit,numReps)%numBins)

[edges(1:3) edges(end-3:end)]

[nDims stimLength]=size(filteredStim);

%binsPerDim=floor(numBins^(1/nDims));
%edges=linspace(min(filteredStim(:))-0.1,max(filteredStim(:))+0.1,1+binsPerDim);

[h binnedStim hCount]=binStim(filteredStim,edges);
hCount=hCount*numReps;

trigs=filteredStim(:,spkTimes);

[spkH binnedTrigs spkHCount]=binStim(trigs,edges);

if any(spkH(h==0)>0)
    error('found a trig that was not a stim!')
end

if 0 %blur -- careful, this will normalize spkH and you probably don't want that, esp. for heirarchical method below
    spkH=convn(spkH,blur*h,'same'); %use h as a convenient n-d gaussian blur kernel
    spkH=spkH/sum(spkH(:));
end

figure

    warning off 'MATLAB:divideByZero'
    pSpkGivenStim=spkH./h;
    warning on 'MATLAB:divideByZero'

doHierarchical=1;
if doHierarchical


    
    [maxPSpkPosterior, meanPSpkPosterior]=doHierarchicalBayes(spkHCount,hCount);
    
    useMax=1;
    if useMax
        pSpkGivenStim=maxPSpkPosterior;
    else
        pSpkGivenStim=meanPSpkPosterior;
    end
    
else
    numNans=sum(isnan(pSpkGivenStim(:)));
    disp(sprintf('got %d nans',numNans))
    pSpkGivenStim(isnan(pSpkGivenStim))=0;

    pSpkGivenStim=pSpkGivenStim/sum(pSpkGivenStim(:));

    minEvidence=.00005;
    pSpkGivenStim(h<minEvidence)=0;%should use priorSpkProb, but not working

    if any(isinf(pSpkGivenStim(:)))
        error('got an inf')
    end
end

if nDims>1
    if nDims~=size(size(h),2);
        error('bad dims')
    end

    if nDims>2
        dimDivs=size(h,1);
        h=reshape(h,dimDivs,[]);
        spkH=reshape(spkH,dimDivs,[]);
        pSpkGivenStimSlices=reshape(pSpkGivenStim,dimDivs,[]);
    end
    subplot(3,1,1)
    imagesc(h)
    title(tit)
    subplot(3,1,2)
    imagesc(spkH)
    subplot(3,1,3)
    imagesc(pSpkGivenStim)
elseif nDims==1
    if size(h,2)~=nDims
        error('bad dims 2')
    end

    subplot(2,1,1)
    plot(h,'k','LineWidth',2)
    hold on
    plot(spkH,'r','LineWidth',2)
    legend({'stims','trigs'})
    title(tit)
    subplot(2,1,2)
    plot(pSpkGivenStim,'k','LineWidth',2)
    legend('p(spike|stim)')
else
    error('problem')
end
