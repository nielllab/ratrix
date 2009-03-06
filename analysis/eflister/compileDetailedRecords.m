%should replace compileTrialRecords, but of course will break lots of graphing -- will need to update graphing code
function compileDetailedRecords(server_name,ids,recompile,source,destination)


%compileDetailedRecords({'demo1'},'C:\Documents and Settings\rlab\Desktop\ratrixData\PermanentTrialRecordStore','C:\Documents and Settings\rlab\Desktop\ratrixData\CompiledTrialRecords');

% switch type
%     case 'crossModal'
%         ids={'225','226','239','241'};
%         source='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
%     case 'images'
%         ids={'280','281','283'};
%         source='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\subjects';
%     otherwise
%         error('unrecognized type')
% end
% destination='C:\Documents and Settings\rlab\Desktop\detailedRecords';

% ==============================================================================================
% set up parameters if not passed in
if (~exist('server_name','var') || isempty(server_name)) && (~exist('ids','var') || isempty(ids)) ...
        && (~exist('source','var') || isempty(source))
    error('we need a server_name to know which subjects to compile, or need a list of ids passed in, or at least a source to look in')
end
if ~exist('recompile','var') || isempty(recompile)
    recompile = false;
end
if ~exist('ids','var') || isempty(ids) % if ids not given as input, retrieve from oracle or from source
    if exist('server_name','var') && ~isempty(server_name)
        % get from oracle b/c server_name is provided
        conn = dbConn();
        ids = getSubjectIDsFromServer(conn, server_name);
        closeConn(conn);
        if isempty(ids)
            error('could not find any subjects for this server: %s', server_name);
        end
    elseif exist('source','var') && ~isempty(source)
        % get from source directory b/c server_name is not provided
        ids={};
        d=dir(source);
        for i=1:length(d)
            if d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
                ids{end+1} = d(i).name;
            end
        end
    else
        error('should not be here - must either have a server_name or a source if no subjectIDs are given');
    end
end

% ==============================================================================================
% get trialRecord files
subjectFiles={};
ranges={};
for i=1:length(ids)
    % if we have source, don't overwrite it!
    if ~exist('source','var') || isempty(source)
        conn = dbConn();
        store_path = getPermanentStorePathBySubject(conn, ids{i});
        store_path = store_path{1}; % b/c this gets returned by the query as a 1x1 cell array holding the char array
        closeConn(conn);
    else
        store_path = fullfile(source, ids{i});
        %         source
    end
    [subjectFiles{end+1} ranges{end+1}]=getTrialRecordFiles(store_path); %unreliable if remote
end

%this will recompile from scratch every time -- add feature to only compile new data by default
% 12/12/08 - added parameter 'recompile'; if false will try to load existing compiledRecords

sm=stimManager;
for i=1:length(ids)
    fprintf('\ndoing %s\n',ids{i});
    compiledDetails=[];
    compiledTrialRecords=[]; % used to be called basicRecs, but we want to keep same syntax as compileTrialRecords
    compiledLUT={};
    expectedTrialNumber=1;
    classes={};
    if ~exist('destination', 'var') || isempty(destination)
        conn=dbConn();
        compiledRecordsDirectory=getCompilePathBySubject(conn, ids{i});
        compiledRecordsDirectory = compiledRecordsDirectory{1};
        closeConn(conn);
    else
        compiledRecordsDirectory=destination;
    end
    
    % 12/12/08 - need to load old compiledTrialRecords and compiledDetails (if they exist in destination), also set expectedTrialNumber and classes appropriately
    % get compiledFile and compiledRange for this subjectID
    d=dir(fullfile(compiledRecordsDirectory,[ids{i} '.compiledTrialRecords.*.mat'])); %unreliable if remote
    compiledFile=[];
    compiledRange=zeros(2,1);
    done=false;
    addedRecords=false;
    for k=1:length(d)
        if ~d(k).isdir
            [rng num er]=sscanf(d(k).name,[ids{i} '.compiledTrialRecords.%d-%d.mat'],2);
            if num~=2
                d(k).name
                er
                error('couldnt parse')
            else
                %d(k).name
                if ~done
                    compiledFile=fullfile(compiledRecordsDirectory,d(k).name);
                    if ~recompile
                        compiledRange=rng;
                        done=true;
                    end
                else
                    d.name
                    error('found multiple compiledTrialRecords files')
                end
            end
        else
            d(k).name
            error('bad dir name')
        end
    end
    % load from existing compile record if it exists
    if ~isempty(compiledFile) && ~recompile
        fieldNames={  'trialNumber',...
            'sessionNumber',...
            'date',...
            'soundOn',...
            'physicalLocation',...
            'numPorts',...
            'step',...
            'trainingStepName',...
            'protocolName',...
            'numStepsInProtocol',...
            'manualVersion',...
            'autoVersion',...
            'protocolDate',...
            'correct',...
            'trialManagerClass',...
            'stimManagerClass',...
            'schedulerClass',...
            'criterionClass',...
            'reinforcementManagerClass',...
            'scaleFactor',...
            'type',...
            'targetPorts',...
            'distractorPorts',...
            'result',...
            'containedManualPokes',...
            'didHumanResponse',...
            'containedForcedRewards',...
            'didStochasticResponse',...
            'containedAPause',...
            'correctionTrial',...
            'numRequests',...
            'firstIRI',...
            'response'};
        try
            [compiledTrialRecords compiledDetails compiledLUT]=loadDetailedTrialRecords(compiledFile,compiledRange,fieldNames);
        catch
            ex=lasterror
            % if loadDetailedTrialRecords throws an error, then skip this subject and try to compile the next one
            % typically this means that old-style compiledRecords exist for this subject
            warning('error loading compiledRecord for %s, most likely because the compiled file is old-style for this subject - skipping!',ids{i});
            continue;
        end            
        % set expectedTrialNumber
        expectedTrialNumber = compiledTrialRecords.trialNumber(end) + 1;
        % set classes
        for k=1:length(compiledDetails)
            classes{1,k} = compiledDetails(k).className;
            classes{2,k} = eval(compiledDetails(k).className);
            classes{3,k} = sort([compiledDetails(k).trialNums compiledDetails(k).bailedTrialNums]);
        end
    end % end load from existing compile record
    
    for j=1:length(subjectFiles{i})
        % why do this?
        for k=1:size(classes,2)
            classes{3,k}=[];
        end      
        [matches tokens] = regexpi(subjectFiles{i}{j}, 'trialRecords_(\d+)-(\d+).*\.mat', 'match', 'tokens');
        rng=[str2num(tokens{1}{1}) str2num(tokens{1}{2})];
        if expectedTrialNumber ~= rng(1)
%             dispStr=sprintf('skipping %d-%d where expected was %d\n',rng(1),rng(2),expectedTrialNumber);
%             disp(dispStr);
            continue;
        end
        addedRecords=true; % if we ever got passed the skip, then we added records and thus can delete compiledFile
        fprintf('\tdoing %s of %d\n',subjectFiles{i}{j},ranges{i}(2,end));
        warning('off','MATLAB:elementsNowStruc'); %expect some class defs to be out of date, will get structs instead of objects (shouldn't keep objects in records anyway)
        tr=load(subjectFiles{i}{j});
        warning('on','MATLAB:elementsNowStruc');
        try
            sessionLUT=tr.sessionLUT;
            fieldsInLUT=tr.fieldsInLUT;
        catch
            % no LUT in this trialRecords.mat file
            warning('no LUT found for this trialRecords file');
            sessionLUT=[];
            fieldsInLUT=[];
        end
        tr=tr.trialRecords;


        % 3/5/09 - we should separate the compile process based on trainingStepNum
        % to handle manual training step transitions gracefully
        uniqueTrainingSteps=unique([tr.trainingStepNum]);
        loadedClasses=classes;
        
        for tsNum=uniqueTrainingSteps
            thisTsInds=find([tr.trainingStepNum]==tsNum);
            classes=loadedClasses;
            
            % START COMPILE PROCESS
            % ================================================
            for k=thisTsInds
                if tr(k).trialNumber ~= expectedTrialNumber
                    k
                    tr(k).trialNumber
                    expectedTrialNumber
                    error('got unexpected trial number')
                else
                    expectedTrialNumber=expectedTrialNumber+1;
                end
                if ~isempty(classes)
                    ind=find(strcmp(LUTlookup(sessionLUT,tr(k).stimManagerClass),classes(1,:)));
                else
                    ind=[];
                end
                if length(ind)==1
                    %nothing
                elseif length(ind)>1
                    error('found more than one cached default stim manager class match')
                else
                    fprintf('\t\tmaking first %s\n',LUTlookup(sessionLUT,tr(k).stimManagerClass))
                    classes{1,end+1}=LUTlookup(sessionLUT,tr(k).stimManagerClass);
                    classes{2,end}=eval(LUTlookup(sessionLUT,tr(k).stimManagerClass)); %construct default stimManager of correct type, to fake static method call
                    classes{3,end}=[];
                    ind=size(classes,2);
                end
                 % this confusing term just means that we set the indices of trialRecords that belong to this class
                 % to start indexing at 1, instead of wherever they might fall on the session's multiple trainingSteps
                classes{3,ind}(end+1)=k-(thisTsInds(1)-1);
            end

            % it is very important that this function keep the same fieldNames in newBasicRecs as they were in trialRecords
            % because otherwise we don't know which fields are using the sessionLUT
            [newBasicRecs compiledLUT]=extractBasicFields(sm,tr(thisTsInds),compiledLUT);
            verifyAllFieldsNCols(newBasicRecs,length(tr(thisTsInds)));

            % 12/18/08 - now update newBasicRecs as appropriate (shift LUT indices by the length of compiledLUT)
            % then add sessionLUT to compiledLUT
            newBasicRecsToUpdate=intersect(fieldsInLUT,fields(newBasicRecs));
            for n=1:length(newBasicRecsToUpdate)
                % for each field in newBasicRecs that uses the sessionLUT
                try
                    % 1/2/09 - need to do something about fieldsInLUT to avoid this error?
                    % Warning: 'trialManager.trialManager.reinforcementManager.reinforcementManager.rewardStrategy'
                    % exceeds MATLAB's maximum name length of 63 characters and has been truncated to
                    % 'trialManager.trialManager.reinforcementManager.reinforcementMan'.
                    % - maybe separate each element of fieldsInLUT (a fieldPath) into each step, and then build thisFieldValue from that

                    % 1/20/09 - split fieldsInLUT using \. as the delimiter, and then loop through each "step" in the path
                    % this addresses the comment from 1/2/09
                    pathToThisField = regexp(newBasicRecsToUpdate{n},'\.','split');
                    thisField=newBasicRecs;
                    for nn=1:length(pathToThisField)
                        thisField=thisField.(pathToThisField{nn});
                    end
                    thisFieldValues = sessionLUT(thisField);
                catch
%                     warningStr=sprintf('could not find %s in newBasicRecs - skipping',newBasicRecsToUpdate{n});
%                     warning(warningStr);
                    continue;
                end
                [indices compiledLUT] = addOrFindInLUT(compiledLUT, thisFieldValues);
                for nn=1:length(indices)
                    evalStr=sprintf('newBasicRecs.%s(nn) = indices(nn);',newBasicRecsToUpdate{n});
                    eval(evalStr); % set new indices
                end
    %             newBasicRecs.(fieldsInLUT{n}) = indices; % set new indices based on integrated LUT
            end
            
            if isempty(compiledTrialRecords)
                compiledTrialRecords=newBasicRecs;
            else
                compiledTrialRecords=concatAllFields(compiledTrialRecords,newBasicRecs);
            end
            
            for c=1:size(classes,2)

                if length(classes{3,c})>0 %prevent subtle bug that is easy to write into extractDetailFields -- if you send zero trials to them, they may try to look deeper than the top level of fields, but they won't exist ('MATLAB:nonStrucReference') -- see example in crossModal.extractDetailFields()
                    %no way to guarantee that a stim manager's calcStim will make a stimDetails
                    %that includes all info its super class would have, so cannot call this
                    %method on every anscestor class.  must leave calling super class's
                    %extractDetailFields up to the sub class.
                    LUTparams=[];
                    LUTparams.lastIndex=length(compiledLUT);
                    LUTparams.compiledLUT=compiledLUT;
                    [newRecs newLUT]=extractDetailFields(classes{2,c},colsFromAllFields(newBasicRecs,classes{3,c}),tr(classes{3,c}),LUTparams);
                    
                    % if extractDetailFields returns a stim-specific LUT, add it to our main compiledLUT
                    if ~isempty(newLUT)
                        compiledLUT = [compiledLUT newLUT];
                    end



                    verifyAllFieldsNCols(newRecs,length(classes{3,c}));
                    bailed=isempty(fieldnames(newRecs)); %extractDetailFields bailed for some reason (eg unimplemented or missing fields from old records)

                    if length(compiledDetails)<c
                        compiledDetails(c).className=classes{1,c};
                        if bailed
                            compiledDetails(c).records=[];
                        else
                            compiledDetails(c).records=newRecs;
                        end
                        compiledDetails(c).trialNums=[];
                        compiledDetails(c).bailedTrialNums=[];
                    elseif strcmp(compiledDetails(c).className,classes{1,c})
                        if ~bailed
                            compiledDetails(c).records=concatAllFields(compiledDetails(c).records,newRecs);
                        end
                    else
                        error('class name doesn''t match')
                    end
                    tmp=colsFromAllFields(newBasicRecs,classes{3,c});
                    if bailed
                        compiledDetails(c).bailedTrialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                    else
                        compiledDetails(c).trialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                    end
                end
            end
            % END COMPILE PROCESS
            % ================================================
        end % end for each trainingStep loop
    end
    
    % delete old compiledDetails file if we added records
    if addedRecords
        delete(compiledFile);
    else
        dispStr=sprintf('nothing to do for %s',ids{i});
        disp(dispStr);
    end
    % save
    save(fullfile(compiledRecordsDirectory,sprintf('%s.compiledTrialRecords.%d-%d.mat',ids{i},ranges{i}(1,1),ranges{i}(2,end))),'compiledDetails','compiledTrialRecords','compiledLUT');

    tmp=[];
    for c=1:length(compiledDetails)
        newNums=[compiledDetails(c).trialNums compiledDetails(c).bailedTrialNums];
        tmp=[tmp [newNums;repmat(c,1,length(newNums))]];
    end
    [a b]=sort(tmp(1,:));
    if any(a~=1:length(a))
        error('missing trials')
    end
%     doPlot=true;
%     if doPlot
%         figure
%         tmp=tmp(:,b);
%         plot(tmp(1,:),tmp(2,:))
%     end
end % end for each subject loop
end % end function

function a=concatAllFields(a,b)
if isempty(a) && isscalar(b) && isstruct(b)
    a=b;
    return
end
if isscalar(a) && isscalar(b) && isstruct(a) && isstruct(b)
    fn=fieldnames(a);
    if all(ismember(fieldnames(b),fn))
        for k=1:length(fn)
            numRowsBNeeds=size(a.(fn{k}),1)-size(b.(fn{k}),1);
            if iscell(a.(fn{k})) && iscell(b.(fn{k}))
                if numRowsBNeeds~=0
                    error('nan padding cells not yet implemented')
                end
                a.(fn{k})(:,end+1:end+size(b.(fn{k}),2))=b.(fn{k});
            elseif ~iscell(a.(fn{k})) && ~iscell(b.(fn{k})) %anything else to check?  %isarray(a.(fn{k})) && isarray(b.(fn{k}))
                if numRowsBNeeds>0
                    b.(fn{k})=[b.(fn{k});nan*zeros(numRowsBNeeds,size(b.(fn{k}),2))];
                elseif numRowsBNeeds<0
                    a.(fn{k})=[a.(fn{k});nan*zeros(-numRowsBNeeds,size(a.(fn{k}),2))];
                end
                a.(fn{k})=[a.(fn{k}) b.(fn{k})];
            else
                error('only works if both are cells or both are arrays')
            end
        end
    else
        error('b has fields not in a')
    end
else
    a
    b
    error('a and b have to both be scalar struct')
end

end