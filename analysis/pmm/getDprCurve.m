function [dprCurve critCurve]=getDprCurve(numSamps, dpr, crit, plotOn)
% returns a curve of dprime and criteria
% dpr = norminv(h)-norminv(f);
% cr =-(norminv(h)+norminv(f))/2;
%dprCurve= getDprCurve(51, 1)
%[dprCurve critCurve] = getDprCurve(51, 1, 0.5)
%handle = getDprCurve(51, 1, [], 1)
%[dprHandle critHandle] = getDprCurve(51, 1, 0.5, 1)

%%
if ~exist('numSamps','var')
    numSamps=51; %101
end

if ~exist('dpr','var')
    dpr=1;
end

if ~exist('crit','var')
    crit=[];
end

if ~exist('plotOn','var')
    plotOn=false;
end

h=linSpace(0,1,numSamps);
dprF=normcdf(norminv(h)-dpr); %calculate the false alarm rate for the desired dpr
dprCurve=[dprF; h];
if nargout>1
    if ~isempty(crit)
    warning('why negative signs that require 1-x?');
    critF=1-normcdf(norminv(h)+(2*crit)); %calculate the false alarm rate for the desired criteria
    critCurve=[critF; h];
    else
        error('Must define criteria as third arguement if asking for a critCurve');
    end
end


if plotOn
    if ~isempty(dpr)
        %pass out the handle if plotting is on
        dprCurve=plot(dprCurve(1,:), dprCurve(2,:))
    end
    if nargout>1
        %pass out the handle if plotting is on
        
        %WHY doesn't this work!
%         critCurve(:,diff(critCurve)>0)=nan %get rid of values below the diagonal
        critCurve=plot(critCurve(1,:), critCurve(2,:))
    end
end
