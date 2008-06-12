function positionFrame = getCalibrationPositionFrame(t)  % 
% positionFrame=getCalibrationPositionFrame(trialManager)

width=t.maxWidth ;
height=t.maxHeight;

% switch type
%    case 'fluxCapacitor'
        
%        %old code centered -  definitely works
        positionFrame = zeros(height, width, 'uint8');
%         if 0
%             [leftRight, topDown] = meshgrid( -width/2:1:width/2-1, -height/2:1:height/2-1);
%             [locationBOTTOM] = ((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0));
%             [locationTOP] = ((leftRight == 0)& (topDown < 0));
%             positionFrame(locationBOTTOM | locationTOP) = 255;
%         end

        %new code general - probably works
        xPos=0.5;
        yPos=0.5;
        pixFromLeft=round(xPos*width);  % round or floor or ceil?  test fraction with 1/3 of a pixel and 2/3 and 0.5...
        pixFromRight=round((1-xPos)*width);
        pixFromTop=round(yPos*height);
        pixFromBottom=round((1-yPos)*height);
        [leftRight, topDown] = meshgrid( -pixFromLeft:pixFromRight-1, -pixFromTop:pixFromBottom-1);
        [locationBOTTOM] = ((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0));
        [locationTOP] = ((-0.5 <= leftRight & leftRight <= 0.5)& (topDown < 0));
        positionFrame(locationBOTTOM | locationTOP) = 255;

        %oneline:
        %positionFrame(((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0)) | ((-0.5 <= leftRight & leftRight <= 0.5)& (topDown < 0)))=255;
%    otherwise
%        error(' bad positionFrame type')
%end



% function trialManager = getSpyderPositionImage(trialManager)
% 
% This code should be intergrated into the trialManager.calibrate
%
% switch trialManager.calib.method
% 
%     case 'sweepAllPhasesPerTargetOrientation'
%         
%     case 'sweepAllFlankers'
%     otherwise
%       numPatchesInserted=1; 
%       szY=size(trialManager.cache.goRightStim,1);
%       szX=size(trialManager.cache.goRightStim,2);
%     
%       pos=round...
%       ...%yPosPct                      yPosPct                    xPosPct                   xPosPct
%     ([ stimulus.targetYPosPct       stimulus.targetYPosPct        xPosPct                   xPosPct;...                   %target
%       .* repmat([ height            height                        width         width],numPatchesInserted,1))...          %convert to pixel vals
%       -  repmat([ floor(szY/2)      -(ceil(szY/2)-1 )             floor(szX/2) -(ceil(szX/2)-1)],numPatchesInserted,1); %account for patch size
%          
%       if any(any((pos(:,1:2)<1) | (pos(:,1:2)>height) | (pos(:,3:4)<1) | (pos(:,3:4)>width)))
%           width
%           height
%           pos
%           error('At least one image patch is going to be off the screen.  Make patches smaller or closer together.')
%       end
% 
% 
%       %stim class is inherited from flankstim patch
%       %just check flankerStim, assume others are same
%       if isinteger(trialManager.cache.flankerStim) 
%         details.mean=stimulus.mean*intmax(class(trialManager.cache.flankerStim));
%       elseif isfloat(trialManager.cache.flankerStim)
%           details.mean=stimulus.mean; %keep as float
%       else
%           error('stim patches must be floats or integers')
%       end
%       stim=details.mean(ones(height,width,3,'uint8')); %the unit8 just makes it faster, it does not influence the clas of stim, rather the class of details determines that
%       
%       
%       insertPatch
% end
%
% positionFrame=stim