function matchedPair=matchWithNoSig(sig,noSig,method)
% accepts logicals of length numTrials
%matchedPair=matchWithNoSig(sig==[numCondition x numTrial],noSig[1 x numTrials])
%matches the number of trials from the sig with equal number of no sig
%throws out surplus noSig
%use case: there are more trials 0 contrast than a particular other contrast, and so the sig
%condition has fewer trials, unless you do this

if ~(size(sig,2)==size(noSig,2) && islogical(sig) && islogical(noSig))
    error('must be matched num trials of sigs and no sigs')
end

if size(noSig,1)~=1
    error('only 1 vector of noSigs allowed')
end

if ~exist('method','var') || isempty(method)
    method='random'; % seed0, nearest?
end

numConditions=size(sig,1);
matchedPair=logical(zeros(size(sig)));

if strcmp(method,'seed0')
    rand('seed',0);
end

switch method
    case {'random','seed0'}      
        for i=1:numConditions
            noSigInds=find(noSig);
            scambledNoSigs=noSigInds(randperm(length(noSigInds)));
            matchedNumNoSigIDs=scambledNoSigs(1:sum(sig(i,:)));
            matchedNumNoSig=zeros(size(noSig));
            matchedNumNoSig(matchedNumNoSigIDs)=1;
            matchedPair(i,:)=sig(i,:) | matchedNumNoSig;
        end
    otherwise
        method
       error('bad method')
end
        