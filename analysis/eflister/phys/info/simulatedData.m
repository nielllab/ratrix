function [repeatStim,repeatResponses,uniqueStims,uniqueResponses,whiteStim,whiteResponse,filt]=simulatedData

%stims
stimLength=50000;
numRepeats=100;
numUniques=200;
whiteStimLength=1000000;
noiseAmp=1;

%model
filtLength=20;
filt=sin(linspace(0,4*pi,filtLength));
filt=filt.*normpdf(linspace(-1,1,filtLength),-0.2,0.3);

%filt=randn(1,filtLength);
%filt=filt.*normpdf(linspace(-1,1,filtLength),-.5,0.3);

filt=orth(filt');
filt=filt';
rate=.005;

%%%%%%%%%%%%%%%%%%%%

repeatStim=noiseAmp*randn(1,stimLength)+randn(1,stimLength);
repeatGenerator=filter(filt,1,repeatStim);

figure
subplot(2,1,1)
plot(repeatStim,'k')

pctSpks=0;
threshLo=0;
threshHi=max(repeatGenerator);

maxPct=length(find(diff(repeatGenerator>0)==1))/stimLength;
if rate>maxPct
    error(sprintf('max rate for filter: %g',maxPct))
end

%set thresh to hit specified rate
while  abs(1-pctSpks/rate)>.3 %abs(pctSpks-rate)>rate*.01 
    disp(num2str(threshHi-threshLo))
    
    thresh=(threshHi+threshLo)/2;
    repeatResponseTimes = find(diff(repeatGenerator>thresh)==1);
    repeatResponse = zeros(1,stimLength);
    repeatResponse(repeatResponseTimes)=1;
    pctSpks=length(repeatResponseTimes)/stimLength;

    if pctSpks>rate
        threshLo=thresh;
    elseif pctSpks<rate
        threshHi=thresh;
    end
end



% close all
% plot(repeatStim)
% hold on
% plot(repeatGenerator,'r')
% plot(thresh*ones(1,stimLength),'k')
% plot(repeatResponse,'k')

%calculate responses
repeatStim=randn(1,stimLength);
repeatNzStims=noiseAmp*randn(numRepeats,stimLength)+repmat(repeatStim,numRepeats,1);
uniqueStims=randn(numUniques,stimLength);
uniqueNzStims=noiseAmp*randn(numUniques,stimLength)+uniqueStims;
whiteStim=randn(1,whiteStimLength);
whiteNzStim=noiseAmp*randn(1,whiteStimLength)+whiteStim;

repeatGenerators=filter(filt,1,repeatNzStims');
uniqueGenerators=filter(filt,1,uniqueNzStims');
whiteGenerator=filter(filt,1,whiteNzStim');

repeatResponses=zeros(stimLength,numRepeats);
uniqueResponses=zeros(stimLength,numUniques);
whiteResponse=zeros(whiteStimLength,1);

repeatResponses(logical([diff(repeatGenerators>thresh)==1;zeros(1,numRepeats)]))=1;
uniqueResponses(logical([diff(uniqueGenerators>thresh)==1;zeros(1,numUniques)]))=1;
whiteResponse(logical([diff(whiteGenerator>thresh)==1;0]))=1;

repeatResponses=repeatResponses';
uniqueResponses=uniqueResponses';
whiteResponse=whiteResponse';

% spy(uniqueResponses,'r')
% hold on
subplot(2,1,2)
spy(repeatResponses,'k')
axis fill