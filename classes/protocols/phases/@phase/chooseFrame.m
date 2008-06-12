function [ output_args ] = chooseFrame( input_args )
%CHOOSEFRAME Summary of this function goes here
%   Detailed explanation goes here

        %calculate which frame in stim to show
        maxI=length(stimSpec.frameTimes);
        if strcmp(phase,'progressive') && stimSpec.framesPerRequest~=0 %progressive disclosure
            if stimSpec.frameTimes(end)~=0
                error('can''t loop progressive disclosure waitForRequest') %frame calc would screw up due to wrap around
            end
            frameInd=(frameNum-lastRequestFrame+1)+sum(stimSpec.frameTimes(1:((numRequests-1)*stimSpec.framesPerRequest))); %correct for previously requested chunks
            maxI=numRequests*stimSpec.framesPerRequest;
        elseif stimSpec.frameTimes(end)==0 %don't loop
            frameInd=frameNum;
        else %loop
            frameInd=rem(frameNum,sum(stimSpec.frameTimes)); %remove previous loops
        end
        i=min(find(frameInd<=cumsum(double(stimSpec.frameTimes)))); %no cumsum for int types!
        i=min(i,maxI);
        if isempty(i)
            if stimSpec.frameTimes(end)~=0
                error('should never happen')
            end
            i=maxI; %played through once, hold last
        end