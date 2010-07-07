function [mnResp stdResp fastResp ciResp categories raw]=getResponseStats(d,whichIncluded,categories,analyzedRange,doPlot)
%[mnResp stdResp ciResp]=getResponseStats(d,conditionInds(j,:),{'correct','incorrect'},[0.01 10])

if ~exist('categories','var') || isempty(categories)
    categories={'all','correct','incorrect','yes','no','hits','misses','CRs','FAs'}
end

if ~exist('analyzedRange','var') || isempty(analyzedRange)
    %block out values that are beyond the analyzed range
    %example: don't look at reactimes lager than 10 seconds (rat gave up) or
    %less than 0.01 (faster than possible for a rat)
    %analyzedRange=[0.01 10];
    analyzedRange=[-Inf Inf];
end

if ~exist('doPlot','var') || isempty(doPlot)
    doPlot=false;
end


alpha=0.05;


if ~ismember('yes',fields(d))
    d=addYesResponse(d);
end

for i=1:length(categories)
    switch categories{i}
        case 'all'
            thisCategory=ones(size(d.date));
        case 'correct'
            thisCategory=d.correct==1;
        case 'incorrect'
            thisCategory=d.correct~=1;
        case 'yes'
            thisCategory=d.yes==1;
        case 'no'
            thisCategory=d.yes==0;
        case 'hits'
            thisCategory=d.correct==1 & d.targetContrast>0;
        case 'misses'
            thisCategory=d.correct==0 & d.targetContrast>0;
        case 'CRs'
            thisCategory=d.correct==1 & d.targetContrast==0;
        case 'FAs'
            thisCategory=d.correct==0 & d.targetContrast==0;
        otherwise
            categories
            categories(i)
            error('bad category')
    end

    responseType='responseTime';
    response=sort(d.(responseType)(whichIncluded & thisCategory)); % rank order
    raw.(categories{i})=response; % output
    response=response(response>analyzedRange(1) & response<analyzedRange(2)); % remove out of range
    numResponses=length(response);
    ciInds=[max(floor(alpha*numResponses),1) ceil((1-alpha)*numResponses)];
    fastInd=max(floor(0.1*numResponses),1); % the fastest 10% of responses are at least this fast
    
    %output
    if length(response)>0
        mnResp(i)=mean(response);
        stdResp(i)=std(response);
        fastResp(i)=response(fastInd);
        try
            ciResp(i,1:2)=response(ciInds);
        catch
            disp(sprintf('weird ci inds: %f %f',ciInds))
            keyboard
        end
    else
        [mnResp(i) stdResp(i) ciResp(i,1:2) fastResp(i)]=deal(nan);
    end
    if doPlot
        hold on;
        edges=[0:.2:10];
        count=histc(response,edges);
        colors=jet(length(categories));
        plot(count./sum(count),'color',colors(i,:))
        
    end


end

if doPlot
    legend(categories)
end


