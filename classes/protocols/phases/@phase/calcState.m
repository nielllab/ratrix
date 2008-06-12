function [ output_args ] = calcState( input_args )

%%%%%%%%%%%%
from compound (triggered) condition:
         if isempty(requestOptions)
            done=true;
         end
        

         if isempty(stimSpec)
            done=true;
         else
            
             
                     %         requestRewardStarted=false;
        %         requestRewardDone=false;
        %         requestRewardPorts=0*readPorts(station);
        %         requestRewardDurLogged=false;
        %         isRequesting=0;

        %the request that ended the waitForRequest phase counts as the first request
        numRequests=1;
        lastRequestFrame=1;
%%%%%%%%%%%%%%%


state=calcState(this,frame,state)
-collect input state (keyboard and ports)
-decide on QPM, should end now?







if ~paused
    ports=readPorts(station);
end

doValves=0*ports;

mThisLoop=0;
pThisLoop=0;

[keyIsDown,secs,keyCode]=KbCheck;
if keyIsDown
    logwrite(sprintf('keys are down:',num2str(find(keyCode))));

    asciiOne=int8('1');

    keys=find(keyCode);
    shiftDown=0;
    kDown=0;
    for keyNum=1:length(keys)
        shiftDown= shiftDown || strcmp(KbName(keys(keyNum)),'shift');
        kDown= kDown || strcmp(KbName(keys(keyNum)),'k');
    end

    if kDown
        for keyNum=1:length(keys)
            keyName=KbName(keys(keyNum));

            if strcmp(keyName,'p')
                pThisLoop=1;

                if ~pressingP && allowQPM

                    didAPause=1;
                    paused=~paused;

                    if paused
                        Priority(originalPriority);
                    else
                        Priority(priorityLevel);
                    end

                    pressingP=1;
                end
            elseif strcmp(keyName,'q') && ~paused && allowQPM
                done=1;
                response='manual kill';
            elseif ~isempty(keyName) && ismember(keyName(1),char(asciiOne:asciiOne+length(ports)-1))
                if shiftDown
                    if keyName(1)-asciiOne+1 == 2
                        'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
                        'quitting'
                        done=1;
                        response='shift-2 kill';
                    end
                    doValves(keyName(1)-asciiOne+1)=1;
                    didValves=true;
                else
                    ports(keyName(1)-asciiOne+1)=1;
                end
            elseif strcmp(keyName,'m')
                mThisLoop=1;

                if ~pressingM && ~paused && allowQPM

                    manual=~manual;
                    pressingM=1;
                end
            end
        end
    end

    if ~mThisLoop && pressingM
        pressingM=0;
    end
    if ~pThisLoop && pressingP
        pressingP=0;
    end
end

logwrite('calculating state');

if ~paused
    if verbose && any(lastPorts) && any(ports~=lastPorts)
        ports
    end

    %subject is finishing up an attempt -- record the end time
    if lookForChange && any(ports~=lastPorts)
        responseDetails.durs{attempt}=GetSecs()-respStart;
        lookForChange=0;

        tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
    end

    if ~toggleStim
        isRequesting=0;
    end

    %subject is requesting the stim
    if any(ports(requestOptions))

        if ~requestRewardStarted && isa(tm,'nAFC') && getRequestRewardSizeULorMS(tm)>0
            requestRewardPorts=ports & requestOptions;
            responseDetails.requestRewardPorts=requestRewardPorts;
            requestRewardStarted=true;
        end

        if ~stimStarted
            requestFrame=frameNum;
        end
        stimStarted=1;

        if toggleStim
            if any(ports~=lastPorts)
                if stimToggledOn
                    stimToggledOn=0;
                    isRequesting=0;
                else
                    stimToggledOn=1;
                    isRequesting=1;
                end
            end
        else
            isRequesting=1;
        end

        tm.soundMgr = playLoop(tm.soundMgr,'keepGoingSound',station,1);

        if ~lookForChange
            logIt=1;
        end
        stopListening=1;

    end

    if isa(tm,'freeDrinks') && all(~ports)
        if rand<getFreeDrinkLikelihood(tm)
            ports(ceil(rand*length(responseOptions)))=1;
            'FREE LICK AT PORT AS FOLLOWS -- NEED TO OFFICIALLY RECORD THIS'
            ports
        end
    end

    %subject gave a well defined response
    if any(ports(responseOptions)) && stimStarted
        done=1;
        response = ports;
        logIt=1;
        stopListening=1;
        responseDetails.durs{attempt+1}=0;
    end

    %subject gave a response that is neither a stimulus request nor a well defined response
    if any(ports) && ~stopListening

        tm.soundMgr = playLoop(tm.soundMgr,'trySomethingElseSound',station,1);

        if (attempt==0 || any(ports~=lastPorts))
            logIt=1;
        end
    end
    stopListening=0;

    if logIt
        if verbose
            ports
        end
        respStart=GetSecs();
        attempt=attempt+1;
        responseDetails.tries{attempt}=ports;
        responseDetails.times{attempt}=GetSecs()-startTime;
        lookForChange=1;
        logIt=0;
    end

    lastPorts=ports;

end





