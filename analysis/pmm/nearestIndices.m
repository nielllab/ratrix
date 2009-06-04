
function out=nearestIndices(A,B,reduceEventsTo)
% finds non overlapping events in candidates A that are closest to events in B
% event locations are are identified as the by the indices of "true"
%
%accepts to vectors equal length logicals and returns a vector of logicals
%in with the number of true events in the returned vector equalt to the
%lesser.  sum(out)=sum(b), the locations of the events align
%with the events in more frequent vector, amd with minimal displacement and
%no overlap in event assigments.


if ~exist('A','var')
    A=rand(1,100)<.25;
    B=rand(1,100)<.1;
end

if ~exist('reduceEventsTo','var') || isempty(reduceEventsTo)
    %don't reduce any events
else
    b=find(B);
    B=zeros(size(B));
    %randomly remove events by one of two methods
    if reduceEventsTo<1 & reduceEventsTo>=0
        %METHOD 1- a fraction of events
        reduceEventsFraction=reduceEventsTo;
        remaining=rand(1,length(b))<reduceEventsFraction;
    elseif reduceEventsTo>1 & isWholeNumber(reduceEventsTo)
        %METHOD 2- a number of events
        if reduceToNumEvents>sum(B)
            error('reduced values is greater than available events')
        end
        reduceToNumEvents=reduceEventsTo;
        randInds=randperm(length(b));
        remaining=randInds(1:reduceToNumEvents);
    else
        error('reduceEventsTo must be a fraction between 0 and 1, or an integer of events')
    end
    %recreate the pruned down B
    B(b(remaining))=1;
end

if length(A)~=length(B) & all(ismember(A,[0 1])) & all(ismember(B,[0 1]))
    error('must be equal length vectors of (pseudo)-logicals')
end

a=find(A);
b=find(B);
numCands=length(a);
numLocs=length(b);

if numCands<numLocs
    error('there are more candidates than location events - maybe prune?')
end

method=2;
switch method
    case 1 % vectorized.  coompletely. may be memory limited
        
    case 2 % vectorized. somewhat.  one for loop
        remaining=a; % cands
        selected=zeros(size(A));
        for i=1:numLocs
            dist=abs(remaining-b(i));
            this=find(dist==min(dist));
            chosen=remaining(this(1)); % choose earlier if there is a tie
            selected(chosen)=1;
            remaining(this(1))=[]; % remove from list
        end
    case 2 % don't process the whole vector, save time by doiig one loop.  is this the principle behvend dynaic programing?
        indsBefore
        indsAfter
    otherwise
        method
        error('bad method')
end

out=selected;


if sum(out)~=sum(B)
    error('failed')
end


view=0;
if view
    c=find(selected);
    hold off
    plot(a,1,'r.')
    hold on
    plot(b,2,'b.')
    plot(c,1.1,'g.')
    plot([b;c],[2*ones(size(b)); 1.1*ones(size(b)) ],'k')
    set(gca,'YLim',[0 7])
end