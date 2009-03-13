function spyderData=useSpyder(screenType, screenNum, clut, measurementsPerChannel)
%spyderData=useSpyder([screenType], [screenNum], [clut], [measurementsPerChannel])
%
%uses Datacolor Spyder http://spyder.datacolor.com/ to measure screen output.
%sweeps through the r, g, and b clut entries independently, then all together.
%
% screenType -- 'CRT' or 'LCD' (default is CRT)
% screenNum -- screen number as for psychtoolbox Screen() functions (default is max)
% clut -- normalized color look up table, format: repmat(linspace(0,1,2^8)',1,3) (default is current clut)
% measurementsPerChannel -- number of clut entries to measure per r, g, b, k channels (default is the full number of clut entries, typically 256, each takes 5 seconds to measure, a total of 90 minutes)
%
%spyderData is returned as capital [X Y Z] as defined at http://en.wikipedia.org/wiki/CIE_1931_color_space
%be aware that on very dark stims, the hue measurement will be very noisy.  (the spyder may give up and return zero in these cases)
%consider instead returning xyY, where Y=cd/m^2, white (x,y)=(1/3,1/3)
%
% http://psychtoolbox.org/wikka.php?wakka=UserContributed
%
%depends on spyder2 SDK available from Dana Gregory (dana@colorvision.com,customerservice@colorvision.com).
%necessary files from the SDK are included.
%only tested on windows, but includes OSX SDK (with dylib's), should work as drop-in replacement.
%must install the spyder driver and software, in my experience, you must run their software at least once to enable the driver.
%http://support.colorvision.ch/index.php?_m=downloads&_a=view
%
%code may be shared/modified as long as my name travels with it.
%
% Copyright (C) 2008 Erik Flister, UCSD, e_flister@REMOVEME.yahoo.com
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
% USA
clc
close all

Screen('Preference', 'SkipSyncTests',0);

p = mfilename('fullpath');
[pathstr, name, ext, versn] = fileparts(p);
addpath(genpath(pathstr))

if ~exist('screenNum','var') || isempty(screenNum)
    screenNum=max(Screen('Screens'));
elseif ~ismember(screenNum,Screen('Screens'))
    error('bad screen num')
end

if length(Screen('Screens'))>1
    Screen('Preference', 'SkipSyncTests',1);
    warning('detected multiple screens')
end

if ~exist('screenType','var') || isempty(screenType)
    screenType='CRT';
    warning('defaulting to CRT')
else
    switch screenType
        case {'CRT','LCD'}
        otherwise
            error('screenType must be CRT or LCD')
    end
end

patchRect=[0.2 0.2 0.8 0.8];

[oldClut, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);

if exist('clut','var') && ~isempty(clut)
    if all(clut(:)>=0 & clut(:)<=1) && size(clut,1) <= reallutsize && size(clut,2) == 3
        oldClut=Screen('LoadNormalizedGammaTable', screenNum, clut);
    else
        error('clut must be normalized and no longer than %d rows (3 columns)',reallutsize)
    end
else
    clut=oldClut;
end

if ~exist('measurementsPerChannel','var') || isempty(measurementsPerChannel)
   measurementsPerChannel=size(clut,1); 
elseif ~isscalar(measurementsPerChannel) || measurementsPerChannel<1 || measurementsPerChannel>size(clut,1)
    error(sprintf('measurementsPerChannel must be scalar btw 1 and number of clut entries: %d',size(clut,1)))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    originalPriority=Priority(MaxPriority('KbCheck'));

    [window winRect]=Screen('OpenWindow',screenNum);
    ifi =Screen('GetFlipInterval', window);

    [width, height]=Screen('WindowSize', window);
    patchRect=patchRect.*[width height width height];

    bg=Screen('MakeTexture',window,uint8(0));

    [whInd garbage]=find(clut==repmat(max(clut),size(clut,1),1)); %define white as max entries in each clut column?
    if length(whInd)~=3
        error('didn''t get 3 unique white indices')
    end
    
    wh=Screen('MakeTexture',window,whInd-1); %-1 cuz ptb clut indices in textures are zero-based

    r=zeros(1,1,3);
    g=zeros(1,1,3);
    b=zeros(1,1,3);
    k=ones(1,1,3);
    r(:,:,1)=1;
    g(:,:,2)=1;
    b(:,:,3)=1;

    measureInds=floor(linspace(1,size(clut,1),measurementsPerChannel)-1); %-1 cuz ptb clut indices in textures are zero-based
    xticks=[];
    
    for i=1:measurementsPerChannel
        stim(:,:,:,0*measurementsPerChannel+i)=r*measureInds(i);
        stim(:,:,:,1*measurementsPerChannel+i)=g*measureInds(i);
        stim(:,:,:,2*measurementsPerChannel+i)=b*measureInds(i);
        stim(:,:,:,3*measurementsPerChannel+i)=k*measureInds(i);
        xticks([0:3]*measurementsPerChannel+i)=measureInds(i);
    end

    for i=1:size(stim,4)
        t(i)=Screen('MakeTexture',window,stim(:,:,:,i));
    end
    success=Screen('PreloadTextures',window);
    if ~success
        error('insufficient VRAM to load all textures ahead of time, need to rewrite to be more dynamic')
    end

    spyderData=nan*zeros(size(stim,4),3);

    HideCursor

    xpos=20;
    ypos=20;
    tHeight=15;
    Screen('TextSize', window, tHeight);
    while ~KbCheck %seems to be necessary to loop on one of my systems to prevent erasing the text below after one frame
        Screen('DrawTexture',window,wh,[],winRect,[],0); %white screen required to open spyder
        Screen('DrawText',window,sprintf('verify white screen (clut indices [%d %d %d] = normalized values [%g %g %g])',...
            whInd(1),whInd(2),whInd(3),clut(whInd(1),1),clut(whInd(2),2),clut(whInd(3),3)),xpos,ypos,128);
        Screen('DrawText',window,sprintf('position the spider in center, hit a key to continue'),xpos,ypos+1.25*tHeight,128);
        Screen('DrawingFinished',window);
        vbl = Screen('Flip',window); %on the problem system, text shows up and stays if this is commented out and loop is removed!
    end

    Screen('DrawTexture',window,wh,[],winRect,[],0);
    Screen('DrawText',window,sprintf('initializing spyder... (screen must be white)'),xpos,ypos,128);
    Screen('DrawingFinished',window);
    vbl = Screen('Flip',window);
    
    spyderLib=[];
    [spyderLib refreshRate]=openSpyder(screenType); %wants white screen for this!
    fprintf('refresh rate: %g (psychtoolbox), %g (spyder)\n',1/ifi,refreshRate);

    %spyder wants 5 secs data per measurement
    numFramesPerValue=ceil(5/ifi); %spyder seems to measure 60Hz on LCD no matter what
    
    for i=1:size(stim,4)
        if KbCheck
            warning('aborted early by user keypress')
            break
        end
        Screen('DrawTexture',window,bg,[],winRect,[],0);
        Screen('DrawTexture',window,t(i),[],patchRect,[],0);
        Screen('DrawText',window,sprintf('%g%% done: clut index %d (hold a key to quit early)',100*(i-1)/size(stim,4),measureInds(1+mod(i-1,length(measureInds)))),xpos,ypos,128);
        Screen('DrawingFinished',window);

        when=0;

        vbl = Screen('Flip',window,when);

        %expect warning 0x00020002 for dark screens (can't detect frame edges)
        %but really should verify success was 1 or 20002 before storing...
        [success, x, y, z] = calllib(spyderLib,'CV_GetXYZ',numFramesPerValue,libpointer('int32Ptr',0),libpointer('int32Ptr',0),libpointer('int32Ptr',0));
        
        spyderData(i,:)=[double(x) double(y) double(z)]/1000;

        if success ~= 1
            spyderError(spyderLib,'CV_GetXYZ');
        end
    end
    
    channels={'red','green','blue','combined'};
    figure
    subplot(2,1,1)
    for i=1:4
        inds=(1:measurementsPerChannel)+(i-1)*measurementsPerChannel;
        plot(inds,spyderData(inds,2))
        text(inds(1),.75*max(spyderData(:)),sprintf('%s',channels{i}))
        hold on
    end
    set(gca,'XTick',1:size(spyderData,1))
    set(gca,'XTickLabel',xticks)
    title('CIE 1931 color space  Y=cd/m^2')
    ylabel('Y (brightness in cd/m^2)')
    
    subplot(2,1,2)
    sums=repmat((sum(spyderData'))',1,2);
    for i=1:4
        inds=(1:measurementsPerChannel)+(i-1)*measurementsPerChannel;
        plot(inds,spyderData(inds,1:2)./sums(inds,:))
        text(inds(1),.75*max(spyderData(:)),sprintf('%s',channels{i}))
        hold on
    end
    plot(ones(size(spyderData,1),2)/3,'k')
    set(gca,'XTick',1:size(spyderData,1))
    set(gca,'XTickLabel',xticks)
    title('x=X/(X+Y+Z)    y=Y/(X+Y+Z)    white = (x=1/3,y=1/3)')
    legend({'x','y'})
    xlabel('clut index')
    
    cleanup(originalPriority,screenNum,oldClut,spyderLib);

catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    cleanup(originalPriority,screenNum,oldClut,spyderLib);
end
end

function cleanup(originalPriority,screenNum,oldClut,spyderLib)
ShowCursor
Priority(originalPriority);
Screen('CloseAll');
Screen('LoadNormalizedGammaTable', screenNum, oldClut);
Screen('Preference', 'SkipSyncTests',0);
if ~isempty(spyderLib)
    closeSpyder(spyderLib);
end
end