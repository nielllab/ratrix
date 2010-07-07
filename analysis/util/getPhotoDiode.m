function photoDiode = getPhotoDiode(photoDiodeData,frameIndices)
photoDiode=zeros(size(frameIndices,1),1);
% now calculate spikes in each frame
% channel = 1; % what channel of the neuralData to look at
% first go through and histogram the values to get a threshold

darkFloor=min(photoDiodeData); % is there a better way to determin the dark value?  noise is a problem! last value particularly bad... why?
darkFloor=-0.1; % somehting hard coded to get rid of some negative values (high gain mode on photodiode has negs), but be constant across chunks
for i=1:size(frameIndices,1)
    % photoDiode is the sum of all neuralData of the given channel for the given samples (determined by frame start/stop)
    photoDiode(i) = sum(photoDiodeData(frameIndices(i,1):frameIndices(i,2))-darkFloor);
    %why are these negative?... i thought black was zero... guess not! subtracting a darkfloor now -pmm 2009
    % a better value might be the mean... pmm 1/11/10
end

inspect=0;
if inspect
    %
    n=length(frameIndices)
    frameRange=[n-43 n]
    %frameRange=[1 min(1000,n)]
    plot(photoDiodeData(frameIndices(frameRange(1),1):frameIndices(frameRange(2),2)),'g')
    hold on
    for i=frameRange(1):frameRange(2)
        xIndStart= frameIndices(i,1)-frameIndices(frameRange(1),1);
        xIndEnd= frameIndices(i,2)-frameIndices(frameRange(1),1);
        %plot([xIndStart xIndEnd],-8+photoDiode([i i])/(12),'r-')
        plot([xIndStart xIndEnd],-0.46+10*photoDiode([i i])/(1+xIndEnd-xIndStart),'r-')
    end
end
end % end function