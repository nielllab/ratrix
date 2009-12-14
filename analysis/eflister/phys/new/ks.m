% vectoried version of kstest2 specialized for our application
% x1 is a matrix (stim vals) x (time bins) (conditional distribution)
% x2 is a vector of stim vals (prior distribution)
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

if ~isvector(x2)
    error('x2 must be vector')
else
    x2=x2(:);
end

if length(size(x1))~=2
    error('x1 must be matrix (stim vals) x (time bins)')
end

unqs=unique([x1(:);x2]);

% the following code modified from kstest2.m
binEdges    =  [-inf ; unqs; inf];

try
    binCounts1  =  histc (x1 , binEdges, 1);
    binCounts2  =  histc (x2 , binEdges, 1);
catch %OOM
    maxBins=100000;
    reductionFactor=ceil(length(unqs)/maxBins);
    fprintf('reducing by %d x',reductionFactor)
    
    binEdges = [-inf; unqs(0==mod(1:length(unqs),reductionFactor)); inf];
    binCounts1  =  histc (x1 , binEdges, 1);
    binCounts2  =  histc (x2 , binEdges, 1);
end

s=unique(sum(binCounts1));
if ~isscalar(s)
    error('histogram counts not all equal')
end

sumCounts1  =  cumsum(binCounts1)/s;
sumCounts2  =  cumsum(binCounts2)./sum(binCounts2);

sampleCDF1  =  sumCounts1(1:end-1,:);
sampleCDF2  =  sumCounts2(1:end-1);

% hardcode tail=0 -> 2-sided test: T = max|F1(x) - F2(x)|.
deltaCDF  =  abs(sampleCDF1 - repmat(sampleCDF2,1,size(sampleCDF1,2)));
KSstatistic   =  max(deltaCDF);

% Compute the asymptotic P-value approximation and accept or
% reject the null hypothesis on the basis of the P-value.

n1     =  size(x1,1);
n2     =  length(x2);
n      =  n1 * n2 /(n1 + n2);
lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);

%  Use the asymptotic Q-function to approximate the 2-sided P-value.
j       =  (1:101)';

if false
    for i=1:size(x1,2) %probably could be vectorized, but don't have time now (the above gave us a 4x speedup already, and this is just a scalar calculation and only replicated once for each timestep, no big deal)...
        pValues(i)  =  2 * sum((-1).^(j-1).*exp(-2*(lambda(i)^2)*j.^2));
    end
end

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