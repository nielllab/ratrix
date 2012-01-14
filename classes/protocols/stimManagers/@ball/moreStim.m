function [out doFramePulse cache dynamicDetails textLabel i indexPulse]=moreStim(s,stim,i,textLabel,destRect,cache,scheduledFrameNum,dropFrames,dynamicDetails)

%keep position in center of infinite white field
%draw track in black
%have red line goal for water

out=rand(size(stim))>.5;

border=10;
out([1:border end-border:end],:)=false;
out(:,[1:border end-border:end])=false;

doFramePulse = true;
indexPulse = true;

if IsWin
    [x,y] = GetMouse;
elseif IsUnix %does this catch OSX and linux?
    sca
    keyboard
    [a,b,c]=GetMouseIndices; %use this to get non-virtual slave indices (http://tech.groups.yahoo.com/group/psychtoolbox/message/13259)
    [x,y,buttons,focus,valuators,valinfo] = GetMouse(windowPtrOrScreenNumber, mouseDev);
    SetMouse(x,y,windowPtrOrScreenNumber, mouseid);
end

textLabel = num2str([destRect getScaleFactor(s) i x y]);
end