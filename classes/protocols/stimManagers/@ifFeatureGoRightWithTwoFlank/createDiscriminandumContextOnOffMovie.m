function [stim frameTimes]=createDiscriminandumContextOnOffMovie(t,empty,targetOnly,contextOnly,targetAndContext,targetOnOff,contextOnOff)
%this makes a 2-5 frame stimulus for the timedFrames type in stimOGL,
%set the displayMethod=frameTimes to use the appropriate timed frames
% policy: the on frame is the index if the frame that will first se the
% target, the off-1 is the last frame to se the target (b/c it will be off on the off frame)

[height width]=size(empty);

if targetOnOff(2)==contextOnOff(2)
    %okay because they both turn off at the same time
else
    error ('targetAndContext expected to turn off at the same time')
end

if targetOnOff(1)<contextOnOff(1)
    error('target can''t come first')
elseif targetOnOff(1)>contextOnOff(1)
    stim=reshape([empty contextOnly targetAndContext empty],height,width,4);
elseif targetOnOff(1)==contextOnOff(1)
    stim=reshape([empty targetAndContext empty],height,width,3);
end

changeTimes=unique([targetOnOff contextOnOff]);
if any(changeTimes==1)
    stim=stim(:,:,2:end); %this makes the first scene start right away with no mean screen
    frameTimes=[diff(changeTimes)]; % hold last frame using a zero
else
    firstWait=changeTimes(1)-1;
    frameTimes=[firstWait diff(changeTimes)]
end

%this adds a zero at the end which causes the last frame to be displayed indefinitely
%also turns it into a int8 which it must be
frameTimes=int8([frameTimes 0]);

if length(frameTimes)~=size(stim,3)
    length(frameTimes)
    size(stim,3)
    error('must be the same length!')
end

%reshape([empty flankersOnly targetAndFlankers targetOnly empty],height,width,5); %general: for everything

if 0 %old code but it accomplishes the same effects more generally
    changeTimes=unique([targetOnOff contextOnOff]);

    if any(changeTimes==1)
        frameTimes=diff(changeTimes);
        %this makes the first scene start right away with no mean screen
        stimInd=1;
    else  %there is a delay beforethe first stim
        firstWait=changeTimes(1)-1;
        frameTimes=[firstWait diff(changeTimes)]
        %this lets the first stim frame be a mean screen
        stimInd=2;
    end

 

    %make the meanscreen background movie
    stim=background(ones([size(contextImage),size(frameTimes,2)]));

    %the first frame with context or target or both
    if contextOnOff(1)<targetOnOff(1)
        %draw context first
        stim(:,:,stimInd)=stim(:,:,stimInd)+contextImage;
        if contextOnOff(2)<targetOnOff(1)
            %context is off before target is on
            stimInd=stimInd+1; %advance to leave a mean screen in between
        end
    elseif targetOnOff(1)<contextOnOff(1)
        %draw target first
        stim(:,:,stimInd)=stim(:,:,stimInd)+targetImage;
        if targetOnOff(2)<targetOnOff(1)
            %target is off before context is on
            stimInd=stimInd+1; %advance to leave a mean screen in between
        end
    elseif contextOnOff(1)==targetOnOff(1)
        stim(:,:,stimInd)=stim(:,:,stimInd)+contextImage+targetImage;
    end

    %the second frame with context or target
    stimInd=stimInd+1;
    if contextOnOff(1)<targetOnOff(1)
        stim(:,:,stimInd)=stim(:,:,stimInd)+targetImage;
    elseif targetOnOff(1)<contextOnOff(1)
        stim(:,:,stimInd)=stim(:,:,stimInd)+contextImage;
    elseif contextOnOff(1)==targetOnOff(1)
        %determine which turns off first and draw the other
        if contextOnOff(2)<targetOnOff(2)
            stim(:,:,stimInd)=stim(:,:,stimInd)+targetImage;
        elseif targetOnOff(2)<contextOnOff(2)
            stim(:,:,stimInd)=stim(:,:,stimInd)+contextImage;
        elseif targetOnOff(2)==contextOnOff(2)
            %do nothing because they turn off together
        end
    end

    %and the last frame is already mean screen
end
end