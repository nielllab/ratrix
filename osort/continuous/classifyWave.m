function [waveFormStat,mD,sD,d, dd] = classifyWave( wave );
%
%classifies a signle wave
%
%inputs: 32 datasamples of a single spike
%
%
%returns:
%waveFormStat: true if good, false if bad
%mD: mean of first derivative of wave
%sD: std of first derivative of wave
%d:first derivate
%
%urut feb04
%----

waveFormStat=true;
mD=0;
sD=0;
d=0;
dd=0;

%below spike (other max)
mm = max(wave);
zeroCrossings=length ( find ( diff( sign( wave-1/2*mm)) ) );
if zeroCrossings>2
	waveFormStat=false;
end

return;



%take derivative
%d = diff ( [0 wave] );
%mD = mean( d );
%sD = std ( d );

%%second derivative
%dd = diff ( [0 d] );


% indMaxD = find ( d == max(d) );
% if length(indMaxD)>1
%     indMaxD=indMaxD(1);
% end
%         
% indMax  = find ( wave == max(wave) );
% if length(indMax)>1
%     indMax=indMax(1);
% end
% 
% if indMaxD > indMax 
%     waveFormStat=false;
%     return;
% end

%criteria on first derivative: +- 3*std
%if length(find(d>=mD+5*sD))>0 || length(find(d<=mD-5*sD))>0
%    waveFormStat=false;
%    return;
%end

%criteria on second derivative: +- 3*std
%ddTest=dd(4:end);
%mDD = mean( ddTest );
%sDD = std ( ddTest );
%if length(find(ddTest>=mDD+3.5*sDD))>0 || length(find(ddTest<=mDD-3.5*sDD))>0
%    waveFormStat=false;
%    return;
%end

%number of zero crossings


%finds number of zero crossings reliably if no point is ==0
%zeroCrossings=length ( find ( diff( sign( wave)) ) );

%if zeroCrossings>8
%    waveFormStat=false;
%end



