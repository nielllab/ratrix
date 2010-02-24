% vectorized version of matlab's kstest2.m specialized for our application
% x1 is a matrix (stim vals) x (time bins) (conditional distribution)
% x2 is a vector of stim vals (prior distribution)
%    or a matrix of another conditional distribution
%
% we only return the pValues because the significance test is just:
% alpha = .05 %default
% H = (alpha >= pValue); %default 
% %     H = 0 => Do not reject the null hypothesis at significance level ALPHA.
% %     H = 1 => Reject the null hypothesis at significance level ALPHA.
function [pValues] = ks(x1, x2)

test=false;

if test
    n=999999;
    bins=10;
    triggers=[4 2];
    val=.9;
    
    x2=randn(1,n);
    s=sort(x2);
    thresh=x2>s(round(val*length(x2)));
    inds=repmat(1:bins,length(x2)-bins+1,1)+repmat((0:length(x2)-bins)',1,bins);
    thresh=thresh(inds);
    x1=x2(inds(all(thresh(:,ceil(bins./triggers)),2),:));
    tic
end

if isvector(x2)
    x2=x2(:);
elseif size(x1,2)~=size(x2,2)
    error('if x2 is a matrix, it must have same number cols as x1')
end

if ~all(cellfun(@(x) length(size(x))==2,{x1 x2}))
    error('input matrices must be (stim vals) x (time bins)')
end

if isempty(x1)
    warning('ks passed empty conditional')
    pValues=1;
    %keyboard
    return
elseif isempty(x2)
    error('ks passed empty prior')
end

unqs=unique([x1(:);x2(:)]); %this line can OOM when stim pre/post ms are 400ms on last cell -- most recent thing to fix

% the following code modified from kstest2.m
binEdges    =  [-inf ; unqs; inf];

try
    binCounts1  =  histc (x1 , binEdges, 1);
    binCounts2  =  histc (x2 , binEdges, 1);
catch %OOM
    maxBins=25000; %was 100000 -- reducing to keep cumsum (~line 72) from OOMing
    reductionFactor=ceil(length(unqs)/maxBins);
    fprintf('reducing by %d x',reductionFactor)
    
    binEdges = [-inf; unqs(0==mod(1:length(unqs),reductionFactor)); inf];
    binCounts1  =  histc (x1 , binEdges, 1);
    binCounts2  =  histc (x2 , binEdges, 1);
end

sampleCDF1=group(binCounts1);
if ~isvector(x2)
    sampleCDF2=group(binCounts2);
    n2 = size(x2,1);
else
    cs=cumsum(binCounts2)./sum(binCounts2);
    sampleCDF2 = repmat(cs(1:end-1),1,size(sampleCDF1,2));
    n2 = length(x2);
end
    function scdf=group(g)
        s=unique(sum(g));
        if ~isscalar(s)
            error('histogram counts not all equal')
        end
        cs=cumsum(g)/s; %OOM on this line
        scdf=cs(1:end-1,:);
    end

n1     =  size(x1,1);

clear binCounts1 binCounts2 x1 x2 unqs cs binEdges %note this kills our test below -- fix later

% hardcode tail=0 -> 2-sided test: T = max|F1(x) - F2(x)|.
KSstatistic   =  max(abs(sampleCDF1 - sampleCDF2));

% Compute the asymptotic P-value approximation

n      =  n1 * n2 /(n1 + n2);
lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);

%  Use the asymptotic Q-function to approximate the 2-sided P-value.
j       =  (1:101)';

pValues  =  2 * sum(repmat((-1).^(j-1),1,length(lambda)).*exp(-2*repmat((lambda.^2),length(j),1).*repmat(j.^2,1,length(lambda))));
pValues  =  min(max(pValues, 0), 1);

if test
    toc
    tic
    for i=1:size(x1,2)
        [junk pVerify] = kstest2(x1(:,i), x2);
        if pVerify~=pValues(i)
            error('optimized ks failed to match kstest2')
        end
    end
    toc
end
end