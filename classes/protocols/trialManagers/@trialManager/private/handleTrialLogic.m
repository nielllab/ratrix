function [tm responseDetails lookForChange respStart isRequesting requestRewardPorts requestRewardStarted requestFrame ...
  stimStarted stimToggledOn lastPorts frameNum potentialStochasticResponse didStochasticResponse attempt done response stopListening] = ...
  handleTrialLogic(tm, responseDetails, paused, verbose, lastPorts, ...
  ports, lookForChange, respStart, isRequesting, station, toggleStim, stimToggledOn, requestOptions, responseOptions, ... 
  requestRewardPorts, requestRewardStarted, requestFrame, ...
  stimStarted, frameNum, potentialStochasticResponse, didStochasticResponse, audioStim, startTime, attempt, done, response, stopListening, logIt)

% This function handles trial logic (for the nAFC and freeDrinks non-phased trial managers). Will have to be changed to handle phased
% Stores responseDetails, requests reward as necessary, plays audio
% Part of stimOGL rewrite.
% INPUT: tm, responseDetails, paused, verbose, lastPorts, ports, lookForChange, respStart, isRequesting, station, toggleStim, stimToggledOn, 
%   requestOptions, responseOptions, requestRewardPorts, requestRewardStarted, requestFrame, stimStarted, frameNum, 
%   potentialStochasticResponse, didStochasticResponse, audioStim, startTime, attempt, done, response, stopListening, logIt
% OUTPUT: tm, responseDetails, lookForChange, respStart, isRequesting, requestRewardPorts, requestRewardStarted, requestFrame, 
%   stimStarted, stimToggledOn, lastPorts, frameNum, potentialStochasticResponse, didStochasticResponse, attempt, done, response, stopListening


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

        % Only play if there is no audio stimulus
        if isempty(audioStim)
            tm.soundMgr = playLoop(tm.soundMgr,'keepGoingSound',station,1);
        end

        if ~lookForChange
            logIt=1;
        end
        stopListening=1;

    end

    if isa(tm,'freeDrinks') && all(~ports)
        if rand<getFreeDrinkLikelihood(tm)
            %ports(ceil(rand*length(responseOptions)))=1; %whoops -- bug
            ports(ceil(rand*getNumPorts(station)))=1;
            %'FREE LICK AT PORT AS FOLLOWS -- NEED TO OFFICIALLY RECORD THIS'
            potentialStochasticResponse=1; %might not be a viable response option, so don't log didStocasticResponse yet
        else
            potentialStochasticResponse=0;
        end
    end

    %subject gave a well defined response
    if any(ports(responseOptions)) && stimStarted
        done=1;
        response = ports;
        logIt=1;
        stopListening=1;
        responseDetails.durs{attempt+1}=0;
        if potentialStochasticResponse
            didStochasticResponse=1;
        end
    end

    %subject gave a response that is neither a stimulus request nor a well defined response
    if any(ports) && ~stopListening
        if isempty(audioStim)
            tm.soundMgr = playLoop(tm.soundMgr,'trySomethingElseSound',station,1);
        end

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
    frameNum=frameNum+1;
    %logwrite(sprintf('advancing to frame: %d',frameNum));
end


end % end function