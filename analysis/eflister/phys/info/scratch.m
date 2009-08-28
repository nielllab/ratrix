%function scratch
close all
clear all
clc
format long g

if 0 %fake data
    [repeatStim,repeatResponses,uniqueStims,uniqueResponses,whiteStim,whiteResponse,filt]=simulatedData;
else %real data
    load('g02 compiled data');

    repeatResponses=full(repeatSpikes{3});
    repeatStim=mean([repeatStimVals{3}]');

    whiteResponse=full(repeatSpikes{1});
    whiteStim=repeatStimVals{1};
    smooth=1;
    if smooth
        %windowSize=19;
        windowSize=16;
        whiteStim=filter(bartlett(windowSize),1,whiteStim);
        repeatStim=filter(bartlett(windowSize),1,repeatStim);
    end
    whiteStim=whiteStim-mean(whiteStim);
    repeatStim=repeatStim-mean(repeatStim);
    
    filt=zeros(1,100);
    
    clear('repeatStimVals','repeatTimes','stims','uniqueTimes','uniqueStimVals','repeatSpikes','uniqueSpikes');
    'data loaded'
end

if 0
    doStimReconstruction(repeatResponses,repeatStim);

end


numMIDims=1;
nBins=50^numMIDims;
totalMI=1;
[bestDims,edges]=doMID(totalMI,repeatStim,repeatResponses,[filt;zeros(numMIDims-1,length(filt))],nBins);
%taking too long to run on whitestim (has to refilter the data every call), and i think i
%get bad answers when running on somethign short like repeatstim

runAnalysis(normRows(bestDims),whiteStim,whiteResponse,repeatStim,repeatResponses,edges);%nBins);