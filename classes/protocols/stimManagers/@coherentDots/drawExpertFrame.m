function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse sounds finish] ...
    = drawExpertFrame(s,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
    destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,...
    dynamicDetails,trialRecords,currentCLUT,phaseRecords,phaseNum,trialManager)

dontclear = 0;

filt = 0; % 0 = Nearest neighbour filtering, 1 = Bilinear filtering (default)

switch phaseRecords(phaseNum).phaseType
    case 'pre-request'
        error('huh')
        
    case {'discrim' 'reinforced' 'pre-response'}
        doFramePulse = true;
        indexPulse = true;
        finish = false;
        sounds = {};
        
        %         background.contrastFactor=2;
        %         background.sizeFactor=2;
        %         background.densityFactor=10;
        
        %         [dots_movie2 alldotsxy2] = cdots(s.num_dots,s.screen_width,s.screen_height,num_frames,selectedCoherence,selectedSpeed/s.screen_height,dotDirection,shape,false);
        %         out = dots_movie-dots_movie2;
        %
        %         background =  cdots(s.num_dots*s.background.densityFactor,s.screen_width,s.screen_height,1,selectedCoherence,selectedSpeed/s.screen_height,dotDirection,ones(selectedDotSize/s.background.sizeFactor),false);
        %         background2 = cdots(s.num_dots*s.background.densityFactor,s.screen_width,s.screen_height,1,selectedCoherence,selectedSpeed/s.screen_height,dotDirection,ones(selectedDotSize/s.background.sizeFactor),false);
        %         background = repmat((background-background2)/s.background.contrastFactor,[1,1,num_frames]);
        %
        %         inds=find(out==0);
        %         out(inds)=background(inds);
        %         out = out-min(out(:));
        %         out = selectedContrast*out/max(out(:));
        
        if ~isfield(dynamicDetails,'xys')
            if phaseNum > 1 && isfield(phaseRecords(phaseNum-1).dynamicDetails,'xys')
                %for 'reinforced,' might want to condition on trialRecords(end).trialDetails.correct
                dynamicDetails.xys=phaseRecords(phaseNum-1).dynamicDetails.xys(end,:,:);
            else
                [floatprecision tex] = determineColorPrecision(trialManager,1,[]);
                expertCache.tex = Screen('MakeTexture',window,tex,[],[],floatprecision);
                
                expertCache.r = ScaleRect(SetRect(0,0,1,1),trialRecords(end).stimDetails.selectedDotSize,trialRecords(end).stimDetails.selectedDotSize);
                
                if isempty(s.background)
                    numFactor = 1;
                    expertCache.colors = uint8(ones(1,s.num_dots));
                else
                    [floatprecision tex] = determineColorPrecision(trialManager,.5,[]);
                    expertCache.bgt = Screen('MakeTexture',window,tex,[],[],floatprecision);
                    
                    numFactor = 2;
                    expertCache.colors = uint8(1+(randperm(numFactor*s.num_dots)>s.num_dots));
                    
                    [floatprecision tex] = determineColorPrecision(trialManager,0,[]);
                    expertCache.tex(2) = Screen('MakeTexture',window,tex,[],[],floatprecision);
                end
                
                dynamicDetails.colors = expertCache.colors;
                dynamicDetails.xys=rand(1,numFactor*s.num_dots,2);
            end
        else
            %consider preallocating
            [~, dynamicDetails.xys(end+1,:,:)] = cdots([],s.screen_width,s.screen_height,[],trialRecords(end).stimDetails.selectedCoherence,...
                trialRecords(end).stimDetails.selectedSpeed/s.screen_height,trialRecords(end).stimDetails.dotDirection,[],false,dynamicDetails.xys(end,:,:));
        end
        
        xy = squeeze(dynamicDetails.xys(end,:,:)).*repmat([s.screen_width s.screen_height],length(expertCache.colors),1);
        
        if ~isempty(s.background)
            Screen('DrawTexture',window,expertCache.bgt,[],destRect,[],filt);
            dontclear = 1;
        end
        
        %can't use DrawDots cuz they have a max size of 63 on some hardware, plus textures are more flexible.
        Screen('DrawTextures',window,expertCache.tex(expertCache.colors),[],CenterRectOnPointd(expertCache.r, xy(:,1), xy(:,2))',[],filt);
        
        i = i+1;
    otherwise
        phaseNum
        phaseRecords(phaseNum)
        error('huh')
end

% textLabel = ['tfn:' num2str(totalFrameNum) ' i:' num2str(i)]; % ' ' textLabel];

ctStr = 'correction trial!';
if trialRecords(end).stimDetails.correctionTrial && isempty(strfind(textLabel,ctStr))
    textLabel = [ctStr ' ' textLabel];
end
end