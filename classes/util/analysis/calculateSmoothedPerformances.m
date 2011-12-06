function [performances colors]=calculateSmoothedPerformances(correct,windowSizes,smoothingMethod,colorMethod)
%returns local calculation of probability correct for a range of window sizes
%current smoothingMethod is default 'boxcar' or 'symetricBoxcar'
%current colorMethod is 'BWpowerlaw'
%06xxxx edf written
%070216 pmm turned into a util
%080526 pmm changed default boxcar filter to be historical rather than symetric
%090430 pmm added some defaults

if ~exist('smoothingMethod','var') || isempty(smoothingMethod)
    smoothingMethod='boxcar';
end

if ~exist('colorMethod','var') || isempty(colorMethod)
    colorMethod='powerlawBW';
end

if ~any(ismember(smoothingMethod,{'boxcar','symetricBoxcar'})) | ~strcmp(colorMethod,{'powerlawBW'})
    error('Bad smoothing or color method. others not defined yet')
end

switch smoothingMethod
    case 'boxcar'
        historicalFilter=1;
    case 'symetricBoxcar'
        historicalFilter=0;
end

totalTrials=size(correct,1);
performances=zeros(totalTrials,length(windowSizes));

%BOXCAR METHOD
runningVals=windowSizes;

for i = 1:totalTrials
    before = correct(1:i);
    for j = 1:length(runningVals)
        if length(before)>=runningVals(j)
            lastCorrects = before((length(before)-runningVals(j)+1):end);
            performances(i,j) = sum(lastCorrects)/runningVals(j);
        else
            performances(i,j) = NaN;            
        end
    end
end

if historicalFilter
    %do nothing
else
    %take half the nans from the beginning and put them on top of the zeros
    %at the end -pmm's comment; edf's code
    for j = 1:length(runningVals)
        k=round(runningVals(j)/2);
        %rates(:,j) = [rates(times(k):end,j);rates(1:times(k)-1,j)];
        %responseTimes(:,j) = [responseTimes(k:end,j);responseTimes(1:k-1,j)];
        if length(find(not(isnan(performances(:,j)))))>0
            performances(:,j) = [performances(k:end,j);performances(1:k-1,j)];
        end
    end
end

%COLOR
for i=1:length(runningVals)
    Q=.95; %min val
    A=-3; %how fast we get from 0 to min val
    
    C=(length(runningVals)^(-A))-1;
    
    if C>0
        B=Q+(Q/C);
        M=-Q/C;
        fix(i) = M*(i^(-A))+B;
    else
        fix(i) = 0;
    end
    
    colors(i,:)=zeros(1,3)+fix(i);
end