function [stim frameTimes]=createDiscriminandumContextOnOffMovie(t,empty,targetOnly,contextOnly,targetAndContext,targetOnOff,contextOnOff)
%this makes a 2-5 frame stimulus for the timedFrames type in stimOGL,
%set the displayMethod=frameTimes to use the appropriate timed frames


[height width]=size(empty);

if 0 % this code was used until Nov 1st, becasue it is simpler for some timing
    
    %     if targetOnOff(2)==contextOnOff(2)
    %         %okay because they both turn off at the same time
    %     else
    %         sca
    %         keyboard
    %         error ('targetAndContext expected to turn off at the same time')
    %     end
    %
    %     if targetOnOff(1)<contextOnOff(1)
    %         error('target can''t come first')
    %     elseif targetOnOff(1)>contextOnOff(1)
    %         stim=reshape([empty contextOnly targetAndContext empty],height,width,4);
    %     elseif targetOnOff(1)==contextOnOff(1)
    %         stim=reshape([empty targetAndContext empty],height,width,3);
    %     end
    %
    %     changeTimes=unique([targetOnOff contextOnOff]);
    %     if any(changeTimes==0)
    %         stim=stim(:,:,2:end); %this makes the first scene start right away with no mean screen
    %         frameTimes=[diff(changeTimes)]; % hold last frame using a zero
    %     else
    %         firstWait=changeTimes(1);
    %         frameTimes=[firstWait diff(changeTimes)]
    %     end
    %
    %
    %     %reshape([empty flankersOnly targetAndFlankers targetOnly empty],height,width,5); %general: for everything
    
else %old code revived and improved on Nov. 1st b/c it accomplishes the same effects more generally
    changeTimes=unique([targetOnOff contextOnOff]);
    
    if any(changeTimes==0)
        frameTimes=diff(changeTimes);
        %this makes the first scene start right away with no mean screen
        stimInd=1;
    else  %there is a delay beforethe first stim
        firstWait=changeTimes(1);
        frameTimes=[firstWait diff(changeTimes)]
        %this lets the first stim frame be a mean screen
        stimInd=2;
    end
    
    %make the meanscreen background movie
    stim=repmat(empty,[1 1 length(frameTimes)+1]);
    
    %    this commented out code is actually incorrect and very confusing  (the stim may end when the flanker should persist, but ends up shutting off the flanker)
    %     %the first frame with context or target or both
    %     if contextOnOff(1)<targetOnOff(1)
    %         %draw context first
    %         stim(:,:,stimInd)=contextOnly;
    %         if contextOnOff(2)<targetOnOff(1)
    %             %context is off before target is on
    %             stimInd=stimInd+1; %advance to leave a mean screen in between
    %         end
    %     elseif targetOnOff(1)<contextOnOff(1)
    %         %draw target first
    %         stim(:,:,stimInd)=targetOnly;
    %         if targetOnOff(2)<targetOnOff(1)
    %             %target is off before context is on
    %             stimInd=stimInd+1; %advance to leave a mean screen in between
    %         end
    %     elseif contextOnOff(1)==targetOnOff(1)
    %         stim(:,:,stimInd)=targetAndContext;
    %     end
    %
    %     %the second frame with context or target
    %     stimInd=stimInd+1;
    %     if contextOnOff(1)<targetOnOff(1)
    %         stim(:,:,stimInd)=targetOnly;
    %     elseif targetOnOff(1)<contextOnOff(1)
    %         stim(:,:,stimInd)=contextOnly;
    %     elseif contextOnOff(1)==targetOnOff(1)
    %         %determine which turns off first and draw the other
    %         if contextOnOff(2)<targetOnOff(2)
    %             stim(:,:,stimInd)=targetOnly;
    %         elseif targetOnOff(2)<contextOnOff(2)
    %             stim(:,:,stimInd)=contextOnly;
    %         elseif targetOnOff(2)==contextOnOff(2)
    %             %do nothing because they turn off together
    %         end
    %     end
    
    % calculate everything dirrectly... easier to understand
    for i=1:length(changeTimes)
        time=changeTimes(i);  %the moment the change time happens
        
        % on is inclusive but off is exclusive!
        if time>=targetOnOff(1)  &&  time<targetOnOff(2)
            targetIsOn=true;
        else
            targetIsOn=false;
        end
        
        if time>=contextOnOff(1)  &&  time<contextOnOff(2)
            contextIsOn=true;
        else
            contextIsOn=false;
        end
        
        if targetIsOn && ~contextIsOn
            stim(:,:,stimInd)=targetOnly;
        elseif ~targetIsOn && contextIsOn
            stim(:,:,stimInd)=contextOnly;
            
        elseif   targetIsOn && contextIsOn
            stim(:,:,stimInd)=targetAndContext;
            
        elseif ~targetIsOn && ~contextIsOn
            stim(:,:,stimInd)=empty;  % is already mean screen , but setting it again for clarity
            
        else
            error('impossible!')
        end
        stimInd=stimInd+1;
        
    end
    
    %and the last frame is already mean screen
end


%this adds a zero at the end which causes the last frame to be displayed indefinitely
%also turns it into a int8 which it must be
frameTimes=int8([frameTimes 0]);

if length(frameTimes)~=size(stim,3)
    length(frameTimes)
    size(stim,3)
    error('must be the same length!')
end

debug=0;
if debug
    sca
    for i=1:size(stim,3)
        subplot(1,size(stim,3),i);
        imagesc(stim(:,:,i),[0 255])
        if i>1
            title(changeTimes(i-1))
        end
        xlabel(frameTimes(i))
        x=double(stim(:,:,i));
        minmax(x(:)')
        set(gca,'xTick',[],'yTick',[])
    end
    colormap(gray)
    subplot(1,size(stim,3),1);
    ylabel(sprintf('t:[%s]   c:[%s]',num2str(targetOnOff),num2str(contextOnOff)))
    keyboard
    
end

end