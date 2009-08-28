function bestDims=midDemo
close all
clear all
clc
format long g

numDims=1;

[repeatStim,repeatResponses,uniqueStims,uniqueResponses,filt]=simulatedData;

if 1
    %repeatResponseIndex=getIndexedResponses(repeatResponses,[1:10]);
    tic
    uniqueResponseIndex=getIndexedResponses(uniqueResponses,[1:5]);
    toc
    totalMI=getTotalMI(repeatResponses, uniqueResponseIndex);
else
    totalMI=1;
end

[bestDims]=doMID(totalMI,repeatStim,repeatResponses,[filt;zeros(numDims-1,length(filt))]);










