function [out doFramePulse cache dynamicDetails textLabel i indexPulse sounds finish]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails,trialRecords)

doFramePulse = true;
indexPulse = true;

if isempty(dynamicDetails)
    dynamicDetails = trialRecords(end).stimDetails;
    dynamicDetails.track = [s.initialPos nan(2,dynamicDetails.nFrames)];
    dynamicDetails.times = dynamicDetails.track(1,:);
end

i=i+1;

dynamicDetails.times(i)=GetSecs;

if i > 1
    dynamicDetails.track(:,i)=mouse(s)';
    if ~IsOSX
        dynamicDetails.track(:,i) = dynamicDetails.track(:,i) + dynamicDetails.track(:,i-1) - s.initialPos;
    end
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
    dynamicDetails.result = 'timeout';
    finish = true;
elseif i > 1
    switch sign(diff(dynamicDetails.track(1,i-[1 0])))
        case sign(target)
            sounds={'keepGoingSound'};
        case -sign(target)
            sounds={'trySomethingElseSound'};
    end    
end

sf=getScaleFactor(s);

out=true(size(stim));

relPos=dynamicDetails.track(:,1:i)-repmat(dynamicDetails.track(:,i)-s.initialPos,1,i);
relPos=round(relPos./repmat(sf',1,i));

if true %continuous lines between points -- tough to vetcorize? consider expert mode w/vectorized Screen('DrawLines')
    d = diff(relPos,[],2);
    for j=2:i
        corners=relPos(:,j-[1 0]);
        if any(d(:,j-1)) && any(corners(:)>0 & corners(:)<=repmat(size(out)',2,1)) || j==2
            inds = count(corners(1,1),corners(1,end));
            for k=1:length(inds)
                if inds(k)>0 && inds(k)<=size(out,2)
                    ys = round(corners(2,1)+d(2,j-1)*(k-[1 0])/length(inds));
                    ys = count(ys(1),ys(end));
                    out(ys(ys>0 & ys<=size(out,1)),inds(k))=false;
                end
            end
        end
    end
else %dot at each point
    relPos=relPos(:,all(relPos>0 & relPos<=repmat(fliplr(size(out))',1,size(relPos,2))));
    out(sub2ind(size(out),relPos(2,:),relPos(1,:)))=false;
end

targetPos=round((target+2*s.initialPos(1)-dynamicDetails.track(1,i))/sf(1));

if targetPos>0 && targetPos<=size(out,2)
    out(:,targetPos)=false;
end

    function out=count(x,y)
        % x:sign(diff([x y])):y %fails when x==y
        % out = linspace(x,y,1+abs(diff([x y]))); %linspace slow
        
        if x>y
            out = x:-1:y;
        else
            out = x:y;
        end
    end
end