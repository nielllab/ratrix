function [relPos, targetPos, sounds, finish, dynamicDetails, i, indexPulse, doFramePulse, textLabel]=computeTrail(s, i, dynamicDetails, trialRecords)

doFramePulse = true;
indexPulse = true;

if isempty(dynamicDetails)
    dynamicDetails = trialRecords(end).stimDetails;
    dynamicDetails.track = nan(2,dynamicDetails.nFrames);
    dynamicDetails.times = dynamicDetails.track(1,:);
end

if i > 0    
    if IsOSX
        offset = s.initialPos;
    else
        offset = dynamicDetails.track(:,i);
    end
    
    p = s.gain .* (mouse(s)' - s.initialPos) + offset;
else
    mouse(s,true);
    p = s.initialPos;
end

if i == 0 || any(diff([dynamicDetails.track(:,i) p],[],2))
    i=i+1;
    dynamicDetails.times(i)=GetSecs;
    dynamicDetails.track(:,i)=p;
end

target = dynamicDetails.target;
sounds={};
finish = false;
if sign(target) * (dynamicDetails.track(1,i) - s.initialPos(1) - target) >= 0
    dynamicDetails.result = 'correct';
    finish = true;
    dynamicDetails.times=dynamicDetails.times(1:i);
    dynamicDetails.track=dynamicDetails.track(:,1:i);
elseif i >= size(dynamicDetails.track,2)
    dynamicDetails.result = 'timedout';
    finish = true;
elseif i > 1
    if sign(diff(dynamicDetails.track(1,i-[1 0]))) == sign(target)
        sounds={'keepGoingSound'};
    else
        sounds={'trySomethingElseSound'};
    end
end

relPos=dynamicDetails.track(:,1:i)-repmat(dynamicDetails.track(:,i)-s.initialPos,1,i);
targetPos=target+2*s.initialPos(1)-dynamicDetails.track(1,i);

textLabel = sprintf('%g movements to go',dynamicDetails.nFrames - i);
end