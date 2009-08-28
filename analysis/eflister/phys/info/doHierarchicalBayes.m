function [maxPSpkPosterior, meanPSpkPosterior]=doHierarchicalBayes(spkH,h)
        warning off 'MATLAB:divideByZero'
    pSpkGivenStim=spkH./h;
    warning on 'MATLAB:divideByZero'
    
    smallVal=.0000001;
    pSpkPrior = pSpkGivenStim(:);
    pSpkPrior(pSpkPrior==1)=1-smallVal;
    pSpkPrior(pSpkPrior==0)=smallVal;
    if any(pSpkPrior>=1 | pSpkPrior<=0)
        spkH(spkH<0)
        spkH(spkH>h)
        h(spkH>h)
        h(h<0)
        error('spkH and h must have been wrong')
    end
    [phat pci] = betafit(pSpkPrior(~isnan(pSpkPrior)));
    alphaPrior = phat(1);
    betaPrior = phat(2);

    bins = linspace(0,1,100);

    pSpkPosterior=zeros(length(pSpkPrior),length(bins));
    for i=1:numel(pSpkGivenStim)
        %http://en.wikipedia.org/wiki/Conjugate_prior
        pSpkPosterior(i,:)=betapdf(bins,spkH(i)+alphaPrior,h(i)-spkH(i)+betaPrior);
    end

    maxLocs=pSpkPosterior'==repmat(max(pSpkPosterior'),size(pSpkPosterior,2),1);
    mults=(sum(maxLocs)>1);

    if any(mults)
        'found multiple peaks'
        sum(mults)
        f=find(mults);
        for j=1:length(f)
            i=f(j);
            inds=find(maxLocs(:,i));
            maxLocs(:,i)=zeros(size(maxLocs,1),1);
            maxLocs(:,inds(ceil(rand*length(inds))))=1;
        end
    end

    maxPSpkPosterior=zeros(size(pSpkGivenStim));
    meanPSpkPosterior=zeros(size(pSpkGivenStim));
    maxPSpkPosterior(:) = sum(repmat(bins',1,size(maxLocs,2)).*maxLocs);
    meanPSpkPosterior(:) = mean(diff(bins))*mean(pSpkPosterior,2);