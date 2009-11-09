function targetIsPresent=checkTargetIsPresent(sm,details)


switch details.protocolType
    
    case {'goToRightDetection','goNoGo','cuedGoNoGo'}
        
        %details.correctResponseIsLeft=-1; %goNoGo uses the stimulus that means "go right"==stimulus is there
        %this is only the wierd historic convention of ifFeatureGoRightWithTwoFlank, 
        %and future stim managers can use whatever fact they want in checkTargetIsPresent
        
        if details.correctResponseIsLeft==1       
              if details.targetContrast==0
                  targetIsPresent=false;
              else 
                  error('should never get here');
              end
            elseif details.correctResponseIsLeft==-1 
                if details.targetContrast==0
                    error('should never get here');
                else
                    targetIsPresent=true;
                end
            else
                error('Invalid response side value. details.correctResponseIsLeft must be -1 or 1.')
            end

    case 'goToLeftDetection'
        if details.correctResponseIsLeft==1       
            if details.targetContrast==0
                error('should never get here');
            else
                targetIsPresent=true;
            end
        elseif details.correctResponseIsLeft==-1
            if details.targetContrast==0
                targetIsPresent=false;
            else
                error('should never get here');
            end
        else
            error('Invalid response side value. details.correctResponseIsLeft must be -1 or 1.')
        end
        
    case {'tiltDiscrim','goToSide'}
        error('Discrimination does not define if target is absent of present');
    
    otherwise
        error('That protocolType is not handled');

end


