function [out doFramePulse cache dynamicDetails textLabel i indexPulse sounds finish]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails,trialRecords)

[relPos, targetPos, sounds, finish, dynamicDetails, i, indexPulse, doFramePulse]=computeTrail(s, i, dynamicDetails, trialRecords);

sf=getScaleFactor(s);
relPos=round(relPos./repmat(sf',1,i));
targetPos=round(targetPos/sf(1));

lines=false(size(stim));
dots=lines;
wall=lines;

%continuous lines between points -- tough to vetcorize?
d = diff(relPos,[],2);
for j=2:i
    corners=relPos(:,j-[1 0]);
    if any(d(:,j-1)) && any(corners(:)>0 & corners(:)<=repmat(size(lines)',2,1)) || j==2
        inds = count(corners(1,1),corners(1,end));
        for k=1:length(inds)
            if inds(k)>0 && inds(k)<=size(lines,2)
                ys = round(corners(2,1)+d(2,j-1)*(k-[1 0])/length(inds));
                ys = count(ys(1),ys(end));
                lines(ys(ys>0 & ys<=size(lines,1)),inds(k))=true;
            end
        end
    end
end

%dot at each point
relPos=relPos(:,all(relPos>0 & relPos<=repmat(fliplr(size(dots))',1,size(relPos,2))));
dots(sub2ind(size(dots),relPos(2,:),relPos(1,:)))=true;

%target line
if targetPos>0 && targetPos<=size(wall,2)
    wall(:,targetPos)=true;
end

%red wall, blue dots, white lines
out(:,:,3) = dots | lines;
out(:,:,2) = lines & ~dots;
out(:,:,1) = (wall | lines) & ~dots;

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