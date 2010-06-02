function commentString = getCommentStringFromEventsData(eventData,commentBoundaryType,commentBoundary,commentExtractionOptions)

% check for includeTrailingComments: allows comments following the end of
% proposed boundary until the beginning of the next boundary of given
% boundary type to be included in the commentString
if any(strcmp(commentExtractionOptions,'includeTrailingComments'))
    locationOfOption = find(strcmp(commentExtractionOptions,'includeTrailingComments'));
    includeTrailingComments = commentExtractionOptions{locationOfOption+1};
    if ~islogical(includeTrailingComments)
        error('includeTrailingComments has to be of logical type');
    end
else 
    includeTrailingComments = false; %default is false. only the comments strictly between the boundary will be in commentString
end

% check for errorOnMultipleHitsOfBoundaryType: Often the trialNumber
% repeats and runs through previously recorder trialNumbers. The cause is
% currently unknown. This logical sets how we deal with the presence of
% these multiple hits. if 'true' error out of the function. if 'false, make
% note of multiple hits in the string.
if any(strcmp(commentExtractionOptions,'errorOnMultipleHitsOfBoundaryType'))
    locationOfOption = find(strcmp(commentExtractionOptions,'errorOnMultipleHitsOfBoundaryType'));
    errorOnMultipleHitsOfBoundaryType = commentExtractionOptions{locationOfOption+1};
    if ~islogical(errorOnMultipleHitsOfBoundaryType)
        error('errorOnMultipleHitsOfBoundaryType has to be of logical type');
    end
else 
    errorOnMultipleHitsOfBoundaryType = true; %default is true. will error out unless specified.
end

switch commentBoundaryType
    case 'trialNumber'
        % get the required trial Numbers
        if length(commentBoundary)>2 || length(commentBoundary)<1
            error('length(commentBoundary) >=1 and <=2');
        elseif length(commentBoundary)==1
            startTrial = commentBoundary;
            stopTrial = commentBoundary;
        elseif length(commentBoundary)==2
            startTrial = commentBoundary(1);
            stopTrial = commentBoundary(2);
        end
        if startTrial>stopTrial
            error('startTrial has to be lesser than stopTrial')
        end
       
        commentCell = {};
        
        % find where to start collecting comment strings
        startTrialEventsNum = find(strcmp({eventData.eventType},'trial start'));
        stopTrialEventsNum = find(strcmp({eventData.eventType},'trial end'));
        
        eventsWithStartTrial = eventData(startTrialEventsNum);
        eventsWithStartTrialParams = [eventsWithStartTrial .eventParams];
        startEventNum = [eventsWithStartTrial(find([eventsWithStartTrialParams.trialNumber]==startTrial)).eventNumber];
        if isempty(startEventNum)
            commentString = ''; 
            return % there are no trials of given start trial Number. do nothing else.
        elseif length(startEventNum)>1 && errorOnMultipleHitsOfBoundaryType
            error('there are multiple trials of trialNumber %d. check events_data for correctness.',startTrial);
        elseif length(startEventNum)>1 && ~errorOnMultipleHitsOfBoundaryType
            commentCell{end+1} = {sprintf('Found %d startTrial events with trialNumber %d.',length(startEventNum),startTrial)};
        end
        
        % find out where to stop collecting commentStrings
        if includeTrailingComments
            stopEventNum = [eventsWithStartTrial(find([eventsWithStartTrialParams.trialNumber]==(stopTrial+1))).eventNumber]-1;
        else
            stopEventNum = [];
            for i = 1:length(startEventNum) % stopEventNum is the first eventNum after the startEventNum where 'trial end' is the eventType.
                stopEventNum = [stopEventNum find(stopTrialEventsNum>startEventNum(i),1)];
            end
        end
        
        if isempty(stopEventNum)
            commentCell{end+1} = {'Found end of events_data. Setting stopEventNum to max of EventNum'};
            stopEventNum = length(eventData);
        elseif length(stopEventNum)>1 && errorOnMultipleHitsOfBoundaryType
            error('there are multiple trials of trialNumber %d. check events_data for correctness.',stopTrial);
        elseif length(startEventNum)>1 && ~errorOnMultipleHitsOfBoundaryType
            commentCell{end+1} = {sprintf('Found %d stop events with trialNumber %d.',length(stopEventNum),stopTrial)};
        end
        
        if length(startEventNum)>1 || length(stopEventNum)>1
            commentCell{end+1} = {sprintf('choosing the minimum of the eventNumbers for startTrialNumber %d and stopTrialNumber %d',startTrial,stopTrial)};
            startEventNum = min(startEventNum);
            stopEventNum = min(stopEventNum);
        end
        
        withinTrial = false;
        perTrialCommentCell = {};
        for currEventNum = startEventNum:stopEventNum
            
            if strcmp(eventData(currEventNum).eventType,'trial start')
                withinTrial = true;
                perTrialCommentCell{end+1} = sprintf('trial %d:',eventData(currEventNum).eventParams.trialNumber);
            elseif strcmp(eventData(currEventNum).eventType,'trial end')
                withinTrial = false;
                if length(perTrialCommentCell)>1
                    commentCell{end+1} = perTrialCommentCell;
                    perTrialCommentCell = {};
                else
                    perTrialCommentCell = {};
                end
            elseif ~withinTrial 
                if strcmp(eventData(currEventNum).eventType,'comment')
                    commentCell{end+1} = {eventData(currEventNum).comment};
                else 
                    commentCell{end+1} = {eventData(currEventNum).eventType};
                end
            else
                if strcmp(eventData(currEventNum).eventType,'comment')
                    perTrialCommentCell{end+1} = eventData(currEventNum).comment;
                else 
                    perTrialCommentCell{end+1} = eventData(currEventNum).eventType;
                end
            end
        end
        commentString = getCommentStringFromCommentCell(commentCell);
                       
    otherwise
        error('unknown commentBoundaryType');
end
end

function commentString = getCommentStringFromCommentCell(commentCell)
commentString = '';
for i = 1:length(commentCell)
    currentLine = commentCell{i};
    currentLineStr = '%';
    for j = 1:length(currentLine)
        currentLineStr = sprintf('%s:%s',currentLineStr,currentLine{j});
    end
    commentString = sprintf('%s\n',currentLineStr);
end
end