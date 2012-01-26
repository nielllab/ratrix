function [out doFramePulse cache dynamicDetails textLabel i indexPulse sounds]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails,trialRecords)

%add red line goal for water

if isempty(dynamicDetails)
    dynamicDetails=trialRecords(end).stimDetails;
    dynamicDetails.times=dynamicDetails.track;
end

p = deal(mouse(s));

x=p(1);
y=p(2);

sounds={};
target = 20*sign(randn);

i=i+1;

if i == 1
    % dynamicDetails.track(:,i) already set by calcStim
elseif i > 1
    dynamicDetails.track(:,i)=[x y]';
    if ~IsOSX
        dynamicDetails.track(:,i) = dynamicDetails.track(:,i) + dynamicDetails.track(:,i-1) - s.initialPos;
    end
    
    switch sign(diff(dynamicDetails.track(1,i-[1 0])))
        case sign(target)
            sounds={'keepGoingSound'};
        case -sign(target)
            sounds={'trySomethingElseSound'};
    end    
end

out=[];

if sign(target) * (dynamicDetails.track(1,i) - s.initialPos(1) - target) >= 0 %maybe don't want this initialPos subtracted?
    dynamicDetails.result = 'correct';
    sounds={};
elseif i >= size(dynamicDetails.track,2)
    dynamicDetails.result = 'timeout';
    sounds={};
else
    relPos=dynamicDetails.track(:,1:i)-repmat(dynamicDetails.track(:,i)-s.initialPos,1,i);
    
    out=true(size(stim));
    
    relPos=round(relPos./repmat(getScaleFactor(s)',1,i));
    
    if true %continuous lines between points -- tough to vetcorize?
        d = diff(relPos,[],2);
        for j=2:i
            corners=relPos(:,j-[1 0]);
            if any(d(:,j-1)) && any(corners(:)>0 & corners(:)<=repmat(size(out)',2,1))
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
    
    sf=getScaleFactor(s);
    targetPos=round((target-dynamicDetails.track(1,i)-s.initialPos(1))/sf(1));
    if targetPos>0 && targetPos<=size(out,2)
        out(:,targetPos)=false;
    end
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

doFramePulse = true;
indexPulse = true;

dynamicDetails.times(i)=GetSecs;

if false
    textLabel = num2str([destRect getScaleFactor(s) i x y scheduledFrameNum]); %num2str is slow
end

end