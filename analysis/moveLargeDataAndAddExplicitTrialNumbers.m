function [success] = moveLargeDataAndAddExplicitTrialNumbers(source, destination, subjects)
%this function was used to move from the old location to a new one

if ~exist('source', 'var')
    source = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats'; %where old files used to be before the move
end

if ~exist('destination', 'var')
    destination = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords';
end

if ~exist('subjects', 'var')

    % get the list of the acceptable subjects
    f = dir(sprintf('%s%srat_*', source, filesep));
    for i = 1:length(f)
        islower(i) = strcmp(f(i).name(1: 3), 'rat');
    end
    f=f(islower);
    %f=rmfield(f,{'date','bytes', 'isdir', 'datenum'})
    subjects = {f.name} % same as struct2cell
    %subjects=subjects(~strcmp(subjects,'rat_114'));  % remove a baddie for latter
    subjects=subjects(~strcmp(subjects,'rat_116'));  % remove a baddie for latter

    subjects=subjects(~strcmp(subjects,'rat_102'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_106'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_112'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_113'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_114'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_115'));  % remove completed
    
    subjects=subjects(~strcmp(subjects,'rat_117'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_126'));  % remove completed
    
    subjects=subjects(~strcmp(subjects,'rat_127'));  % remove completed
    %Data.20070817T104345 -deleted empty folder
    %Data.20071218T223018
    
    subjects=subjects(~strcmp(subjects,'rat_128'));  % remove completed
    %Data.20071120T173016
    %20071202T125851
    
    subjects=subjects(~strcmp(subjects,'rat_129'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_130'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_131'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_132'));  % remove completed
    subjects=subjects(~strcmp(subjects,'rat_133'));  % remove completed
    
    %subjects=subjects(~strcmp(subjects,'rat_134'));  % error nonchronological request
    %168 out of 168 files completed, when checking if request for chronological
    
    %20071202T131236

    %subjects=subjects(~strcmp(subjects,'rat_144'));  % remove completed
    %20071204T200951

    %subjects=subjects(~strcmp(subjects,'rat_147'));  % remove completed
    %20071202T124052
    
    
    % for testing one

    %subjects = {'rat_114'};
    %subjects = {'rat_215','rat_214'}
end



%make dirs
[suc,MESSAGE,MESSAGEID] = mkdir(destination,'subjects');
if ~suc
    suc
    MESSAGE
    MESSAGEID
    error('bad mkdir')
end

%make dirs
[suc,MESSAGE,MESSAGEID] = mkdir(destination,'saveLog');
if ~suc
    suc
    MESSAGE
    MESSAGEID
    error('bad mkdir')
end


for i =1:length(subjects)
    subjectNumericalID = subjects{i}(end-2: end);

    %make dirs
    [suc,MESSAGE,MESSAGEID] = mkdir(fullfile(destination,'subjects'), subjectNumericalID );
    if ~suc
        suc
        MESSAGE
        MESSAGEID
        error('bad mkdir')
    end

    %make dirs
    [suc,MESSAGE,MESSAGEID] = mkdir(fullfile(destination,'saveLog'), subjectNumericalID );
    if ~suc
        suc
        MESSAGE
        MESSAGEID
        error('bad mkdir')
    end

    % load saveLogs
    clear saveLog
    load(fullfile(source, subjects{i}, 'saveLog.mat' ));
    expectedRecords = length(saveLog.sessionID);

    dataFolders = dir(fullfile(source, subjects{i}, 'largeData', '*Data*'));
    dataFolderNames = {dataFolders.name};

    %chronologicalRequests
    [sessionIDs ] = getSessionIDsFromFilePaths(dataFolderNames);
    if ~all(diff(sessionIDs)>0)
        subjectNumericalID=subjectNumericalID
        plot(sessionIDs)
        keyboard
        error('nonchronological request')
    end

    startTrial=1;
    numEmptyRecords=0;

    quickPreCheck=0;
    if quickPreCheck
        pass=length(dataFolders) == expectedRecords;
        if pass
            disp( sprintf('%d passes',str2num(subjectNumericalID)))
        else
            disp( sprintf('%d fails!',str2num(subjectNumericalID)))

            disp([num2str(expectedRecords)  ' expected files but found ' num2str(length(dataFolders)) ' files'  ] )

            sessionIDList=[];
            for j = 1:length(saveLog.sessionID)
                sessionIDList(j) = datenumFor30(dataFolderNames{j}( 6: end ) );
            end
            foundFiles=sort(sessionIDList);
            xPectedFiles=sort(saveLog.sessionID);
            suspect=min(find(foundFiles~=xPectedFiles));
            if xPectedFiles(suspect-1)==foundFiles(suspect-1) && xPectedFiles(suspect)~=foundFiles(suspect)
                %found the first non-match

                if ismember(foundFiles(suspect),xPectedFiles)
                    newFile=foundFiles(suspect);
                    disp([ 'new ' datestr(newFile,30)  ' from ' ])
                    disp(sprintf('or maybe: %s',datestr(xPectedFiles(suspect),30)))
                    error('ack new')
                end

                if  ismember(xPectedFiles(suspect),foundFiles)
                    missingFile=xPectedFiles(suspect);
                    stations=unique(saveLog.stationID);
                    disp(['previous: ' datestr(foundFiles(suspect-1),30)     ]);
                    disp(['missing:  ' datestr(foundFiles(suspect),30) ' from station ' num2str(stations) ] )
                    disp(['after:    ' datestr(foundFiles(suspect+1),30)     ]);
                    disp(['maybe ' num2str(-(foundFiles(suspect-1)-foundFiles(suspect+1)))   ' days lost from 1st file' ])
                    %disp(sprintf('or maybe: %s',datestr(xPectedFiles(suspect),30)))


                    d=getSmalls(subjects{i});
                    trialAfter=min(find(d.date>foundFiles(suspect)));
                    trialBefore=max(find(d.date<foundFiles(suspect)));
                    gap=min([d.date(trialAfter)  foundFiles(suspect+1)  ])-max([d.date(trialBefore) foundFiles(suspect-1) ]);
                    disp(['at most ' num2str(gap)  ' days lost from 1st file' ])
                    disp(sprintf('trialAfterGap=%s ',num2str(trialAfter)));
                end
                %disp([length(xPectedFiles) length(unique(xPectedFiles)) length(foundFiles) length(unique(foundFiles))])
            end





            %             checkLog=saveLog;
            %             [suc,MESSAGE,MESSAGEID] = mkdir(fullfile(destination,'checkLog'));
            %             [suc,MESSAGE,MESSAGEID] = mkdir(fullfile(destination,'checkLog'), subjectNumericalID );
            %             for j = 1:length(dataFolders)
            %                 sessionID = datenumFor30(dataFolderNames{j}( 6: end ) );
            %                 savLogPathNoSub = fullfile(destination,'checkLog');
            %                 checkLog=addToSaveLog(checkLog, subjectNumericalID,savLogPathNoSub,sessionID,{'explitAddTrialNum'},{1},0);
            %
            %                 %error if any files that don't exist in save log
            %                 if ~any(checkLog.sessionID==sessionID)
            %                     sessionID
            %                     datestr(sessionID)
            %                     error('bad one')
            %                 end
            %
            %             end
            %
            %             for j = 1:length(checkLog.sessionID)
            %                 sessionIDList(j) = datenumFor30(dataFolderNames{j}( 6: end ) );
            %             end
            %
            %             for j = 1:length(checkLog.sessionID)
            %                 %error if any files that don't exist in folders found
            %                 if ~any(checkLog.sessionID(j)==sessionIDList)
            %                     sessionID
            %                     datestr(sessionID)
            %                     error('bad one')
            %                 end
            %             end



            %badOnes=find(checkLog.explitAddTrialNum~=1)

        end

    else

        previousEndDate=0;
        sessionNumber=1;
        for j = 1:length(dataFolders)
            load(fullfile(source, subjects{i}, 'largeData', dataFolderNames{j}, 'trialRecords.mat'));
            sessionID = datenumFor30(dataFolderNames{j}( 6: end ) );
            station=saveLog.stationID(saveLog.sessionID == sessionID);

            % find station for data file

            if length(trialRecords)>0 % only save if trials are here

                [trialRecords , endTrial]= addTrialNumbers(trialRecords, startTrial,sessionNumber, station);


                %check nonoverlapping
                thisStartDate=datenum(trialRecords(1).date);
                if previousEndDate<thisStartDate
                    %okay

                else
                    error('overlapping trials!')
                end
                previousEndDate=datenum(trialRecords(end).date);


                try

                    startDate=datestr(trialRecords(1).date,30);
                    endDate=datestr(trialRecords(end).date,30);
                    destinationFile = fullfile(destination,'subjects',subjectNumericalID ,sprintf('trialRecords_%d-%d_%s-%s.mat', startTrial, endTrial,startDate,endDate));

                    disp(sprintf('%d of %d %s', j,length(dataFolders), destinationFile));
                    save(destinationFile, 'trialRecords')
                    confirmSave(destinationFile)
                    sessionNumber=sessionNumber+1;

                catch ex 
                    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                    keyboard
                end

                savLogPathNoSub = fullfile(destination,'saveLog');
                saveLog=addToSaveLog(saveLog, subjectNumericalID,savLogPathNoSub,sessionID,{'explitAddTrialNum'},{1},0);


                startTrial = endTrial +1;
            else
                numEmptyRecords=numEmptyRecords+1;
                warning('empty trialRecords')
            end
        end

        % confirm expected number of records are there
        x = dir(fullfile(destination,'subjects',subjectNumericalID,'*Records*'));
        numRecords = length(x);
        if numRecords + numEmptyRecords +2 < expectedRecords  % bad check to accept losses
            numRecords = numRecords
            expectedRecords = expectedRecords
            numEmptyRecords=numEmptyRecords
            check=load(fullfile(savLogPathNoSub, subjectNumericalID, 'saveLog.mat'));
            keyboard


            %skip=1


            if ~skip
                error('missing records?')
            end
        end

        disp(sprintf('***********finished subject %d of %d', i,length(subjects)));
    end
end

disp('done!')

function  [trialRecords , totalTrials]= addTrialNumbers(trialRecords, startTrial,sessionNumber, station)

numTrials = length(trialRecords);
totalTrials = startTrial + numTrials-1;

for i = 1: numTrials
    trialRecords(i).trialNumber = startTrial + i-1;
    trialRecords(i).sessionNumber = sessionNumber;
    trialRecords(i).station = station;

    %     %add new rewards fields  --dont bother they are already structs
    %     if any(strcmp(fields(trialRecords(i)),'reinforcementManagerClass'))
    %          trialRecords(i).reinforcementManagerClass=class(trialRecords(i).reinforcementManager);
    %     else
    %             trialRecords(i).reinforcementManagerClass=[];
    %     end


    if any(strcmp(fields(trialRecords(i).trialManager.trialManager),'reinforcementManager'))
        rm=trialRecords(end).trialManager.trialManager.reinforcementManager;
        switch class(rm)
            case {'rewardNcorrectInARow','constantReinforcement'}
                trialRecords(i).reinforcementManagerClass=class(rm);
            case 'struct'
                f=fields(trialRecords(1).trialManager.trialManager.reinforcementManager)
                if strcmp(f{1},'msRewardNthCorrect')
                    disp('guessing rewardNcorrectInARow because first field is msRewardNthCorrect');
                    %old versions of rewardNcorrectInARow did not have a rewardScalar; effectively it was one
                    %if other struct exists switch on
                    %                 p=trialRecords(1).trialManager.trialManager.reinforcementManager.msPenalty;
                    %                 smallData.penalty=p*double(smallData.correct);
                    %                 smallData.rewardScalar=1*ones(size(smallData.date));
                    trialRecords(i).reinforcementManagerClass='msRewardNthCorrect';

                else
                    trialRecords(i).reinforcementManagerClass='unknown';  % could be constantReinforcement when definition changed
                end
            otherwise
                error ('can''t retrieve information from that rewardManager');
                trialRecords(i).reinforcementManagerClass=[];
        end
    else
        trialRecords(i).reinforcementManagerClass=[];
    end

    trialRecords(i).proposedRewardSizeULorMS=trialRecords(i).trialManager.trialManager.msRewardDuration;
    trialRecords(i).proposedMsPenalty=trialRecords(i).trialManager.trialManager.msPenalty;
    trialRecords(i).proposedMsRewardSound=trialRecords(i).trialManager.trialManager.msRewardSoundDuration;
    trialRecords(i).proposedMsPenaltySound=trialRecords(i).trialManager.trialManager.msPenalty;

end


function confirmSave(destinationFile)

[junk, filename, ext] = fileparts(destinationFile);
x = dir(destinationFile);

if any(strcmp([filename  ext], {x.name}))
    %okay
else
    error('bad save')
end



%
% 102 passes
% 106 passes
% 112 passes
% 114 passes
% 115 passes
% 116 fails!
% 352 expected files but found 353 files
% previous: 20071129T151828
% missing:  20071129T161252 from station 9
% after:    20071129T214618
% maybe 0.26933 days lost from 1st file
% at most 0.037924 days lost from 1st file
% trialAfterGap=134540
% 117 passes
% 126 passes
% 127 fails!
% 233 expected files but found 235 files
% previous: 20070816T143752
% missing:  20070817T104345 from station 1  9
% after:    20070817T115323
% maybe 0.88578 days lost from 1st file
% at most 0.8376 days lost from 1st file
% trialAfterGap=3597
% 128 fails!
% 258 expected files but found 260 files
% previous: 20071120T172242
% missing:  20071120T173016 from station 2
% after:    20071120T173111
% maybe 0.0058912 days lost from 1st file
% at most 0.0058912 days lost from 1st file
% trialAfterGap=32064
% 129 passes
% 130 passes
% 131 passes
% 132 passes
% 133 passes
% 134 fails!
% 181 expected files but found 182 files
% previous: 20071201T151712
% missing:  20071202T131236 from station 4
% after:    20071205T162728
% maybe 4.0488 days lost from 1st file
% at most 3.9617 days lost from 1st file
% trialAfterGap=25160
% 135 passes
% 136 passes
% 137 passes
% 138 passes
% 139 passes
% 140 passes
% 141 passes
% 142 passes
% 143 passes
% 144 fails!
% 184 expected files but found 185 files
% previous: 20071204T173940
% missing:  20071204T200951 from station 3
% after:    20071204T213420
% maybe 0.16296 days lost from 1st file
% at most 0.16094 days lost from 1st file
% trialAfterGap=2307
% 145 passes
% 146 passes
% 147 fails!
% 108 expected files but found 109 files
% previous: 20071130T220309
% missing:  20071202T124052 from station 11
% after:    20071202T140400
% maybe 1.6673 days lost from 1st file
% at most 1.6562 days lost from 1st file
% trialAfterGap=1034
% 148 passes
% 195 passes
% 196 passes
% 213 passes
% 214 passes
% 215 passes
% 216 passes
% 217 passes
% 218 passes
% 219 passes
% 220 passes
% 221 passes
% 222 passes
% done!

