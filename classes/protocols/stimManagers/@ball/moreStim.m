function [out doFramePulse cache dynamicDetails textLabel i indexPulse]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails)

%add red line goal for water

[x,y] = mouse(s);
i=i+1;
if i>1
    dynamicDetails.track(:,i)=dynamicDetails.track(:,i-1)+[x y]';
end

relPos=dynamicDetails.track(:,1:i)-dynamicDetails.track(:,i)+s.initialPos;

out=true(size(stim));
cellfun(@draw,mat2cell(round(relPos),2,ones(1,i)));
    function draw(p)
        if all(p>0) && all(p<=size(out)')
            out(p(1),p(2))=false;
        end
    end

if false
    out=rand(size(stim))>.5;
    
    border=10;
    out([1:border end-border:end],:)=false;
    out(:,[1:border end-border:end])=false;
end

doFramePulse = true;
indexPulse = true;

textLabel = num2str([destRect getScaleFactor(s) i x y]);
end