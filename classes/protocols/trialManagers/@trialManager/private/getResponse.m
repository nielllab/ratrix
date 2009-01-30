function [r details] = getResponse(trialManager, responseOptions, requestOptions, method, startTime,station)
error('deprecated')
switch method
    case 'keyboard'
        done=0;
        attempt=1;
        
        while ~done
            in=input(['[' num2str(responseOptions) ']?'],'s');
            endTime=etime(clock,startTime);
            
            if any(strcmp(in,cellstr(num2str(responseOptions'))))
                r=str2num(in);
                done=1;
            
            else

                if strcmp(in,cellstr(num2str(requestOptions)))
                    trialManager.soundMgr=playSound(trialManager.soundMgr,'keepGoingSound',.5,station);
                else
                    disp(['that wasn''t one of [' num2str(responseOptions) ']'])
                    trialManager.soundMgr=playSound(trialManager.soundMgr,'trySomethingElseSound',.5,station);
                end
            end
            
            details.tries{attempt}=in;
            details.times{attempt}=endTime;
            attempt=attempt+1;
        end

    case 'parallelPort'
        error('imagesc parallelPort not yet implemented')
    
    otherwise
        error('unknown responseMethod')
end
