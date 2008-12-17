function r = mergeMiniIntoRatrix(r,newR)
% Take the 'newR' that has a subset of information present in 'r'
% and merge the objects into 'r', only if the version number

% Go through all of the subjects in the new ratrix, and
newSubjectIDs = getSubjectIDs(newR);
for i=1:length(newSubjectIDs)
    [member index]=ismember(newSubjectIDs{i},getSubjectIDs(r));
    if member
        s=r.subjects{index};
        newS =getSubjectFromID(newR,newSubjectIDs{i});
        protocolVersion = getProtocolVersion(s);
        newProtocolVersion = getProtocolVersion(newS);
        [oldP oldTSNum]=getProtocolAndStep(s);
        [newP newTSNum]=getProtocolAndStep(newS);
        creationDate = getCreationDate(r);
        newCreationDate = getCreationDate(newR);
        % Check that the manual version of the current ratrix is NOT
        % higher than the new ratrix
        if creationDate == newCreationDate
            if protocolVersion.manualVersion == newProtocolVersion.manualVersion
                if protocolVersion.autoVersion == newProtocolVersion.autoVersion
                    % No change occurred
                elseif protocolVersion.autoVersion< newProtocolVersion.autoVersion
                    % Ok, no new manual version has appeared, we can safely
                    % overwrite the protocol and step
                    % p,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewSte
                    % pNum,i,r,comment,auth)
                    oldTS=getTrainingStep(oldP,oldTSNum);
                    newTS=getTrainingStep(newP,newTSNum);
                    isNewProtocol=false;
                    isNewTrainingStep=strcmp(display(oldTS),display(newTS));
                    isNewStepNum= oldTSNum~=newTSNum;
                    [s r]=setProtocolAndStep(s,newP,isNewProtocol,isNewTrainingStep,isNewStepNum,newTSNum,r,'Updating subject protocol on server ratrix','ratrix');
                    s=setProtocolVersion(s,newProtocolVersion);
                    r.subjects{index}=s;
                else
                    % The client auto version should never be lower than the
                    % server's auto version
                    protocolVersion.autoVersion
                    newProtocolVersion.autoVersion
                    error('The autoVersion of the new mini ratrix should never be older than the current ratrix')
                end
            elseif protocolVersion.manualVersion > newProtocolVersion.manualVersion
                % Someone has changed the protocol on the server
                warning('The manual protocol version has changed on the server, will NOT update the server copy with the client update');
            else
                % This is odd, the manual version is newer on the client
                error('The manualVersion of the new mini ratrix should never be newer than the current ratrix')
            end

        elseif creationDate > newCreationDate
            warning('The creation date of the ratrix is newer on the server, will NOT update the server copy with the client update');
        else
            error('The creation date of the current server ratrix should never be older than that of the client update');
        end
    else
        newSubjectIDs{i}
        warning('This subject id is not in the current server side ratrix, but is in the client side ratrix');
    end
end