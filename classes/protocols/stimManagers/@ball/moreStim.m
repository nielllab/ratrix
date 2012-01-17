function [out doFramePulse cache dynamicDetails textLabel i indexPulse]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails,trialRecords)

%add red line goal for water

if isempty(dynamicDetails)
    dynamicDetails=trialRecords(end).stimDetails;
    dynamicDetails.times=dynamicDetails.track;
end

p = deal(mouse(s));

x=p(1);
y=p(2);

i=i+1;
if i>size(dynamicDetails.track,2)
    error('reallocate?')
elseif i>1
    dynamicDetails.track(:,i)=[x y]';
    if ~IsOSX
        dynamicDetails.track(:,i) = dynamicDetails.track(:,i) + dynamicDetails.track(:,i-1) - s.initialPos;
    end
end

relPos=dynamicDetails.track(:,1:i)-repmat(dynamicDetails.track(:,i)-s.initialPos,1,i);

out=true(size(stim));

relPos=round(relPos./repmat(getScaleFactor(s)',1,i));
relPos=relPos(:,all(relPos>0 & relPos<=repmat(fliplr(size(out))',1,size(relPos,2))));
out(sub2ind(size(out),relPos(2,:),relPos(1,:)))=false;

doFramePulse = true;
indexPulse = true;

dynamicDetails.times(i)=GetSecs;

if false
    textLabel = num2str([destRect getScaleFactor(s) i x y scheduledFrameNum]); %num2str is slow
end

end