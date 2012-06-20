function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse sounds finish] ...
    = drawExpertFrame(s,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
    destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,...
    dynamicDetails,trialRecords,currentCLUT,phaseRecords,phaseNum,trialManager)

originalLabel = textLabel;

dontclear = 0;

if ~isfield(expertCache,'clutSize')
    expertCache.clutSize = size(currentCLUT,1)-1;
end
white = expertCache.clutSize*ones(1,4);
black =       white.*[zeros(1,3)   1];
grey  = round(white.*[.5*ones(1,3) 1]);

filt = 0; % 0 = Nearest neighbour filtering, 1 = Bilinear filtering (default)

if ~isfield(expertCache,'tex')
    [floatprecision tex] = determineColorPrecision(trialManager,1,[]);
    expertCache.tex = Screen('MakeTexture',window,tex,[],[],floatprecision);
end

if ~isfield(expertCache,'r')
    expertCache.r = ScaleRect(SetRect(0,0,1,1),trialRecords(end).stimDetails.selectedDotSize,trialRecords(end).stimDetails.selectedDotSize);
end

switch phaseRecords(phaseNum).phaseType
    case 'pre-request'
        error('huh')
        
    case 'discrim'
        doFramePulse = true;
        indexPulse = true;
        finish = false;
        sounds = {};
        
        if ~isfield(dynamicDetails,'xys')
            dynamicDetails.xys=rand(1,s.num_dots,2);
        else
            %consider preallocating
            [~, dynamicDetails.xys(end+1,:,:)] = cdots([],s.screen_width,s.screen_height,[],trialRecords(end).stimDetails.selectedCoherence,...
                trialRecords(end).stimDetails.selectedSpeed/s.screen_height,trialRecords(end).stimDetails.dotDirection,[],false,dynamicDetails.xys(end,:,:));
        end
        
        %can't use DrawDots cuz they have a max size of 63 on some hardware, plus textures are more flexible.
        xy = squeeze(dynamicDetails.xys(end,:,:)).*repmat([s.screen_width s.screen_height],s.num_dots,1);
        Screen('DrawTextures',window,expertCache.tex,[],CenterRectOnPointd(expertCache.r, xy(:,1), xy(:,2))',[],filt);
        
        i = i+1;
    otherwise
        phaseNum
        phaseRecords(phaseNum)
        error('huh')
end

if trialRecords(end).stimDetails.correctionTrial
    textLabel = ['correction trial! ' textLabel];
end
end