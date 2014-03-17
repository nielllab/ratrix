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

if ~exist('source','var') || isempty(source)
    conn=dbConn();
end

for i=1:length(ids)
    % if we have source, don't overwrite it!
    if ~exist('source','var') || isempty(source)
        store_path = getPermanentStorePathBySubject(conn, ids{i});
        store_path = store_path{1}; % b/c this gets returned by the query as a 1x1 cell array holding the char array
    else
        store_path = fullfile(source, ids{i});
        %         source
    end
    [subjectFiles{end+1} ranges{end+1}]=getTrialRecordFiles(store_path); %unreliable if remote
end

if ~exist('source','var') || isempty(source)
    closeConn(conn);
end

%this will recompile from scratch every time -- add feature to only compile new data by default
% 12/12/08 - added parameter 'recompile'; if false will try to load existing compiledRecords

if ~exist('destination','var') || isempty(destination)
    conn=dbConn();
end

sm=stimManager;
for i=1:length(ids)
    fprintf('\ndoing %s\n',ids{i});
    compiledDetails=[];
    compiledTrialRecords=[]; % used to be called basicRecs, but we want to keep same syntax as compileTrialRecords
    compiledLUT={};
    expectedTrialNumber=1;
    classes={};
    if ~exist('destination', 'var') || isempty(destination)
        compiledRecordsDirectory=getCompilePathBySubject(conn, ids{i});
        compiledRecordsDirectory = compiledRecordsDirectory{1};
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
            'response',...
            'responseTime',...
            'actualRewardDuration'};
        %error('need to incorporate currentShapedValue if available...')
        
        try
            [compiledTrialRecords compiledDetails compiledLUT]=loadDetailedTrialRecords(compiledFile,compiledRange,fieldNames);
        catch ex
            disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
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
            try
                classes{2,k} = eval(compiledDetails(k).className);
            catch
                classes{2,k} = eval('stimManager()');
            end
            classes{3,k} = sort([compiledDetails(k).trialNums compiledDetails(k).bailedTrialNums]);
        end
    end % end load from existing compile record
    
    allDetails=compiledDetails;
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
        
        printFrameDropReports=false;
        if printFrameDropReports
            frameDropDir=fullfile(compiledRecordsDirectory,'framedropReports',ids{i});
            [status,message,messageid]=mkdir(frameDropDir);
            
            if status~=1
                message
                messageid
                status
                error('couldn''t make framedrop dir')
            end
            
            try
                trialNums=[tr.trialNumber];
                [frameDropFID frameDropMsg] = fopen(fullfile(frameDropDir,['framedrops.' ids{i} '.trials.' sprintf('%d-%d',trialNums(1),trialNums(end)) '.txt']), 'wt');
                
                if frameDropFID==-1 || ~isempty(frameDropMsg)
                    frameDropMsg
                    error('couldn''t open framedrop file')
                end
                
                for trNum=1:length(tr)
                    for phNum=1:length(tr(trNum).phaseRecords)
                        thisRec=tr(trNum).phaseRecords(phNum).responseDetails;
                        fprintf(frameDropFID,'framedrop report for trial %d phase %d:\n',trNum,phNum);
                        
                        for mNum=1:length(thisRec.misses)
                            printDroppedFrameReport(frameDropFID,thisRec.missTimestamps(mNum),thisRec.misses(mNum),thisRec.missIFIs(mNum),tr(trNum).station.ifi,'caught');
                        end
                        if length(thisRec.misses) ~= length(thisRec.missTimestamps) || length(thisRec.misses) ~= length(thisRec.missIFIs)
                            fprintf(frameDropFID,'hmm, %d misses, but %d miss timestamps and %d miss ifis\n',length(thisRec.misses),length(thisRec.missTimestamps),length(thisRec.missIFIs));
                        end
                        
                        for mNum=1:length(thisRec.apparentMisses)
                            printDroppedFrameReport(frameDropFID,thisRec.apparentMissTimestamps(mNum),thisRec.apparentMisses(mNum),thisRec.apparentMissIFIs(mNum),tr(trNum).station.ifi,'unnoticed');
                        end
                        if length(thisRec.apparentMisses) ~= length(thisRec.apparentMissTimestamps) || length(thisRec.apparentMisses) ~= length(thisRec.apparentMissIFIs)
                            fprintf(frameDropFID,'hmm, %d apparent misses, but %d apparent miss timestamps and %d apparent miss ifis\n',length(thisRec.apparentMisses),length(thisRec.apparentMissTimestamps),length(thisRec.apparentMissIFIs));
                        end
                        
                        fprintf(frameDropFID,'\n\n');
                    end
                    fprintf(frameDropFID,'*********end of trial*******\n\n');
                end
                fclose(frameDropFID);
            catch ex
                disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                if frameDropFID~=-1
                    fclose(frameDropFID);
                end
                warning('couldn''t write frame drop report file')
            end
        end
        
        % 3/5/09 - we should separate the compile process based on trainingStepNum
        % to handle manual training step transitions gracefully
        % tsIntervals should be [tsNum startNum stopNum; ...] for each unique ts interval
        tsNums=double([tr.trainingStepNum]);
        tsIntervals=[];
        tsIntervals(:,1)=[tsNums(find(diff(tsNums))) tsNums(end)]';
        tsIntervals(:,2)=[1 find(diff(tsNums))+1];
        tsIntervals(:,3)=[find(diff(tsNums)) length(tsNums)];
        loadedClasses=classes;
        
        for intInd=1:size(tsIntervals,1)
            tsNum=tsIntervals(intInd,1);
            thisTsInds=tsIntervals(intInd,2):tsIntervals(intInd,3);
            classes=loadedClasses;
            compiledDetails=[];
            
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
                    % throw out all classes that aren't this trainingStep's type
                    toDelete=[];
                    for x=1:size(classes,2)
                        if ~strcmp(classes{1,x},LUTlookup(sessionLUT,tr(k).stimManagerClass))
                            toDelete=[toDelete x];
                        end
                    end
                    classes(:,toDelete)=[];
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
                    try
                        classes{2,end}=eval(LUTlookup(sessionLUT,tr(k).stimManagerClass)); %construct default stimManager of correct type, to fake static method call
                    catch
                        classes{2,end}=eval('stimManager()');
                    end
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
                try
                    compiledTrialRecords=concatAllFields(compiledTrialRecords,newBasicRecs);
                catch
                    keyboard
                end
            end
            for c=1:size(classes,2)
                if length(classes{3,c})>0 %prevent subtle bug that is easy to write into extractDetailFields -- if you send zero trials to them, they may try to look deeper than the top level of fields, but they won't exist ('MATLAB:nonStrucReference') -- see example in crossModal.extractDetailFields()
                    %no way to guarantee that a stim manager's calcStim will make a stimDetails
                    %that includes all info its super class would have, so cannot call this
                    %method on every anscestor class.  must leave calling super class's
                    %extractDetailFields up to the sub class.
                    colInds=classes{3,c};
                    
                    LUTparams=[];
                    LUTparams.lastIndex=length(compiledLUT);
                    LUTparams.compiledLUT=compiledLUT;
                    LUTparams.sessionLUT = sessionLUT;
                    [newRecs compiledLUT]=extractDetailFields(classes{2,c},colsFromAllFields(newBasicRecs,colInds),tr(thisTsInds),LUTparams);
                    % if extractDetailFields returns a stim-specific LUT, add it to our main compiledLUT
                    % 5/14/09 - this already happens b/c we pass in the compiledLUT to extractDetailFields!
                    %                     if ~isempty(newLUT)
                    %                         compiledLUT = [compiledLUT newLUT];
                    %                     end
                    
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
                    tmp=colsFromAllFields(newBasicRecs,colInds);
                    if bailed
                        compiledDetails(c).bailedTrialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                    else
                        compiledDetails(c).trialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                    end
                end
            end
            
            if isempty(allDetails)
                allDetails=compiledDetails;
            else
                for d=1:length(compiledDetails)
                    [tf loc]=ismember(compiledDetails(1).className,{allDetails.className});
                    if tf
                        % append records, dont make new class
                        if ~isempty(compiledDetails(d).records)
                            allDetails(loc).records=concatAllFields(allDetails(loc).records,compiledDetails(d).records);
                        end
                        allDetails(loc).trialNums=[allDetails(loc).trialNums compiledDetails(d).trialNums];
                        allDetails(loc).bailedTrialNums=[allDetails(loc).bailedTrialNums compiledDetails(d).bailedTrialNums];
                    else
                        allDetails=[allDetails compiledDetails(d)];
                    end
                end
            end
            
            % END COMPILE PROCESS
            % ================================================
        end % end for each trainingStep loop
        
        % sometimes useful for debuggging or recompiling all, when errors may happen
        buildAsYouGo=false;
        if buildAsYouGo
            compiledDetails=allDetails;
            maxTrialDone=max([compiledDetails.trialNums]);
            save(fullfile(compiledRecordsDirectory,sprintf('%s.compiledTrialRecords.%d-%d.mat',ids{i},ranges{i}(1,1),maxTrialDone)),'compiledDetails','compiledTrialRecords','compiledLUT');
        end
        
        if any(cellfun(@isempty,compiledLUT))
            warning('empty found in LUT! - WHY? debug it!')
            %the empty will cause errors down the line... all cells must be char
            compiledLUT
            keyboard
        end
    end
    
    % delete old compiledDetails file if we added records
    if addedRecords
        delete(compiledFile);
        % save
        compiledDetails=allDetails;
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
    else
        dispStr=sprintf('nothing to do for %s',ids{i});
        disp(dispStr);
    end
    
    %     doPlot=true;
    %     if doPlot
    %         figure
    %         tmp=tmp(:,b);
    %         plot(tmp(1,:),tmp(2,:))
    %     end
end % end for each subject loop

if ~exist('destination','var') || isempty(destination)
    closeConn(conn);
end

end % end function

function a=concatAllFields(a,b)
if isempty(a) && isscalar(b) && isstruct(b)
    a=b;
    return
end
if isscalar(a) && isscalar(b) && isstruct(a) && isstruct(b)
    fn=fieldnames(a);
    if all(ismember(fieldnames(b),fn)) && all(ismember(fn,fieldnames(b)))
        for k=1:length(fn)
            try
                numRowsBNeeds=size(a.(fn{k}),1)-size(b.(fn{k}),1);
            catch
                ple
                keyboard
            end
            if iscell(b.(fn{k}))
                if ~iscell(a.(fn{k})) && all(isnan(a.(fn{k})))
                    a.(fn{k})=cell(1,length(a.(fn{k})));
                    
                    %turn nans into a cell
                    %a.(fn{k});
                    %warning('that point where its slow')
                    %[x{1:length(a.(fn{k}))}]=deal(nan);  nan filling is slow, but empty filling is fast
                    %a.(fn{k})=x;
                    %keyboard
                    %[a.(fn{k}){:,end+1:end+size(b.(fn{k}),2)}]=deal(b.(fn{k}));
                    
                    % %                     %other way
                    % %                     temp=cell(1,length(a.(fn{k}))+size(b.(fn{k}),2));
                    % %                     [temp{end-size(b.(fn{k}),2)+1:end}]=deal(b.(fn{k}){:});
                    % %                     a.(fn{k})=temp;
                    
                    
                else
                    if numRowsBNeeds~=0
                        error('nan padding cells not yet implemented')
                    end
                    
                end
                [a.(fn{k}){:,end+1:end+size(b.(fn{k}),2)}]=deal(b.(fn{k}));
            elseif ~iscell(a.(fn{k})) && ~iscell(b.(fn{k})) %anything else to check?  %isarray(a.(fn{k})) && isarray(b.(fn{k}))
                if numRowsBNeeds>0
                    b.(fn{k})=[b.(fn{k});nan*zeros(numRowsBNeeds,size(b.(fn{k}),2))];
                elseif numRowsBNeeds<0
                    a.(fn{k})=[a.(fn{k});nan*zeros(-numRowsBNeeds,size(a.(fn{k}),2))];
                end
                a.(fn{k})=[a.(fn{k}) b.(fn{k})];
            else
                (fn{k})
                error('only works if both are cells or both are arrays')
            end
        end
    else
        % 4/10/09 - added 'actualTargetOnSecs', 'actualTargetOffSecs', 'actualFlankerOnSecs', and 'actualFlankerOffSecs' to compiledDetails
        % for ifFeature, which were not there previously.
        % now, instead of erroring here, we should just fill w/ nans in a and recall concatAllFields
        warning('a and b do not match in fields - padding with nans')
        fieldsToNan=setdiff(fieldnames(b),fn);
        numToNan=length(a.(fn{1}));
        for k=1:length(fieldsToNan)
            a.(fieldsToNan{k})=nan*ones(1,numToNan);
        end
        fieldsToNan=setdiff(fn,fieldnames(b));
        numToNan=length(b.(fn{1}));
        for k=1:length(fieldsToNan)
            b.(fieldsToNan{k})=nan*ones(1,numToNan);
        end
        a=concatAllFields(a,b);
    end
else
    a
    b
    error('a and b have to both be scalar struct')
end
end

function recsToUpdate=getIntersectingFields(fieldsInLUT,recs)
recsToUpdate={};
for i=1:length(fieldsInLUT)
    pathToThisField = regexp(fieldsInLUT{i},'\.','split');
    thisField=recs;
    canAdd=true;
    for nn=1:length(pathToThisField)
        if isfield(thisField,pathToThisField{nn})
            thisField=thisField.(pathToThisField{nn});
        else
            canAdd=false;
            break;
        end
    end
    if canAdd
        recsToUpdate{end+1}=fieldsInLUT{i};
    end
end
end