function quit=clientHandleVerifiedCommand(r,com,cmd,args,stat)

if ~iscell(args)
    error('args must be a cell array')
end

if ~isa(com,'rnetcommand') %~strcmp(class(c),'rnetcommand') %does isa not work for java objects?
    error('com must be a rnetcommand')
end

if ~isValidClientCommand(r,cmd)
    error('cmd must be a command constant as defined in rnet.m: S_***_CMD')
end

if ~isValidStatus(r,stat)
    error('stat must be a status constant as defined in rnet.m')
end

quit=false;
constants = getConstants(r);

ratrixDataPath='C:\Documents and Settings\rlab\Desktop\testdata\'; %figure out where to store this

switch cmd
    %commands that require status=NO_RATRIX
    case constants.serverToStationCommands.S_START_TRIALS_CMD
        if stat==constants.statuses.NO_RATRIX
            fprintf('Got a ratrix to begin trials with\n');
            rx = args{1};
            if isGoodNonpersistedSingleStationRatrix(rx)
                fprintf('Ratrix is in good state to begin trials with\n');

                rx=establishDB(rx,fullfile(ratrixDataPath, 'ServerData'),1); %THIS DOESN'T WORK THE FIRST TIME, BUT DOES ONCE THE DIRS ARE CREATED
                quit=sendAcknowledge(r,com);

                ids=getSubjectIDs(rx);
                s=getSubjectFromID(rx,ids{1});
                b=getBoxIDForSubjectID(rx,getID(s));
                st=getStationsForBoxID(rx,b);

                %see commandBoxIDStationIDs() (need to add stuff for updating logs, keeping track of running, etc.)

                fprintf('About to run trials on new ratrix\n');
                rx=doTrials(st(1),rx,0,r); %0 means repeat forever
                quit=sendToServer(r,getClientIdent(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_STOPPED_TRIALS,{rx});
            else
                quit=sendError(r,com,constants.errors.CORRUPT_STATE_SENT,'ratrix is not good nonpersisted single station ratrix');
                fprintf('Ratrix is not in a good persistant state\n');
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_START_TRIALS_CMD');
        end
    case constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD
        'got shutdown from server'
        if stat==constants.statuses.NO_RATRIX
            if ~commandsAvailable(r)
                quit=true;
                sendAcknowledge(r,com);
                %sendRatrixToServer(ratrixDataPath,r,constants);
            else
                quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client has commands in queue - must allow them to complete or remove each using S_CLEAR_COMMAND_CMD before S_SHUTDOWN_STATION_CMD');
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_SHUTDOWN_STATION_CMD');
        end
    case constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD
        if stat==constants.statuses.NO_RATRIX
            [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
            if isempty(args)
                if runningSVNversion~=repositorySVNversion
                    writeSVNUpdateCommand(r);
                    quit=true;
                end
            else
                revNumber = args{1};
                if ischar(revNumber)
                    if ~strcmp(revNumber,url)
                        writeSVNUpdateCommand(r,revNumber);
                        quit = true;
                    elseif repositorySVNversion~=runningSVNversion
                        writeSVNUpdateCommand(r,repositorySVNversion); %temporary fix -- always go to head of that tag
                        quit = true;
                    end
                elseif isinteger(revNumber)
                    if revNumber~=runningSVNversion
                        writeSVNUpdateCommand(r,revNumber);
                        quit = true;
                    end
                else
                    error('Revision number has unexpected type')
                end
            end
            quitOnError=sendToServer(r,getClientIdent(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD,{quit});
            if quitOnError || quit
                quit=true;
            end
        else
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is not NO_RATRIX - must call S_STOP_TRIALS_CMD before S_UPDATE_SOFTWARE_CMD');
        end





        %commands that require a ratrix

    case constants.serverToStationCommands.S_GET_QUICK_REPORT_CMD
        if stat==constants.statuses.NO_RATRIX
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is NO_RATRIX - must call S_START_TRIALS_CMD(ratrix) before S_GET_QUICK_REPORT_CMD');
        else
            %C_RECV_REPORT_CMD
        end
    case constants.serverToStationCommands.S_STOP_TRIALS_CMD
        'got stop trials from server'
        if stat==constants.statuses.NO_RATRIX
            quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is NO_RATRIX - must call S_START_TRIALS_CMD(ratrix) before S_STOP_TRIALS_CMD');
        else
            quit=true;
            sendAcknowledge(r,com); %even tho this just means the client is telling itself to stop trials, not that it is done.
            %rather than sending an ack here, may be better to always return the ratrix w/C_RECV_RATRIX_CMD
            %no actually, need to let session clean itself up.  the ratrix
            %will get sent by the line after doTrials in the handler for
            %start_trials
        end




        %commands that are OK regardless of status

    case constants.serverToStationCommands.S_GET_RATRIX_CMD

        quit=sendRatrixToServer(ratrixDataPath,r,constants);


    case constants.serverToStationCommands.S_GET_PENDING_COMMANDS_CMD
        %C_RECV_COMMAND_LIST_CMD
    case constants.serverToStationCommands.S_CLEAR_COMMAND_CMD
        %ack?
        %     case constants.serverToStationCommands.S_GET_TRIAL_RECORDS_CMD
        %         C_RECV_TRIAL_RECORDS_CMD

        %     case constants.serverToStationCommands.S_CLEAR_TRIAL_RECORDS_CMD
        %         go clear all records
        %         sendAcknowledge(r,com);
    case constants.serverToStationCommands.S_REPLICATE_TRIAL_RECORDS_CMD
        paths=args{1};
        deleteOnSuccess=args{2};
        %
        %         boxDirsToCheck=dir(fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','Boxes'));
        %         for b=1:length(boxDirsToCheck)
        %             boxDir=boxDirsToCheck{b};
        %             if findstr('box',boxDir)==1
        %             subjectDirsToCheck=
        %
        %         for every data file you can find
        %             subjectName
        %             filePath
        %             fileName
        %
        %             for j=1:length(paths)
        %                 [success(j) message messageID]=mkdir(fullfile(paths{j},subjectName));
        %                 if success(j) %ignore warning if directory exists
        %                     d=dir(fullfile(paths{j},subjectName));
        %                     for i=1:length(d)
        %                         if strcmp(d(i).name,fileName)
        %                             if ~d(i).isdir
        %                                 dt=datevec(now);
        %                                 frac=dt(6)-floor(dt(6));
        %                                 [successM messageM messageIDM]=movefile(fullfile(paths{j},subjectName,fileName),fullfile(paths{j},subjectName,[fileName '.old.' datestr(dt,30) '.' sprintf('%03d',floor(frac*1000))]));
        %                                 if ~successM
        %                                     messageM
        %                                     messageIDM
        %                                     %error('couldn''t make backup of file with same name')
        %                                 end
        %                                 success(j)=success(j) && successM;
        %                             else
        %                                 success(j)=false;
        %                                 error('got an unexpected directory')
        %                             end
        %                         end
        %                     end
        %                     if success(j)
        %                         [successC messageC messageIDC]=copyfile(fullfile(filePath,fileName),fullfile(paths{j},subjectName,fileName));
        %                         if ~successC
        %                             messageC
        %                             messageIDC
        %                             %error('couldn''t copy file')
        %                         end
        %                         success(j)=success(j) && successC;
        %                     end
        %                 else
        %                     message
        %                     messageID
        %                     %error('couldn''t make destiation directory')
        %                 end
        %             end
        %             if deleteOnSuccess && all(success)
        %                 delete(fullfile(filePath,fileName))
        %             end
        %         end

        subDirs=struct([]);
        boxDirs=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','Boxes');
        boxDirsToCheck=dir(boxDirs);
        for b=1:length(boxDirsToCheck)
            boxDir=boxDirsToCheck(b).name;
            if findstr('box',boxDir)==1
                subjectDirs=fullfile(boxDirs,boxDir,'subjectData');
                subjectDirsToCheck=dir(subjectDirs);
                for s=1:length(subjectDirsToCheck)
                    subDir=subjectDirsToCheck(s).name;
                    if ~ismember(subDir,{'.','..'}) %&& findstr('test',lower(subDir))~=1
                        subName=subDir;
                        subDir=fullfile(subjectDirs,subName);
                        if length(dir(fullfile(subDir,'trialRecords.mat')))==1
                            subDirs(end+1).dir=subDir; %fullfile(subjectDirs,subDir);
                            subDirs(end).name=subName;
                            subDirs(end).file='trialRecords.mat';
                            %subDirs(end+1)=sub;
                        end
                    end
                end
            end
        end

        for f=1:length(subDirs)
            subjectName=subDirs(f).name;
            filePath=subDirs(f).dir;
            fileName=subDirs(f).file;

            [fp,fn,fe,fv]=fileparts(fileName);

            tr=load(fullfile(filePath,fileName));
            if ~isempty(tr.trialRecords)
                trialNums=[tr.trialRecords.trialNumber];
                if ~all(diff(trialNums)==1)
                    error('missing trials!')
                end

                newFileName=[fn '.' num2str(trialNums(1)) '-' num2str(trialNums(end)) fe];

                for j=1:length(paths)
                    [success(j) message messageID]=mkdir(fullfile(paths{j},subjectName));
                    if success(j) %ignore warning if directory exists
                        d=dir(fullfile(paths{j},subjectName));
                        for i=1:length(d)
                            if strcmp(d(i).name,newFileName)
                                if ~d(i).isdir
                                    dt=datevec(now);
                                    frac=dt(6)-floor(dt(6));
                                    [successM messageM messageIDM]=movefile(fullfile(paths{j},subjectName,newFileName),fullfile(paths{j},subjectName,[newFileName '.old.' datestr(dt,30) '.' sprintf('%03d',floor(frac*1000))]));
                                    if ~successM
                                        messageM
                                        messageIDM
                                        %error('couldn''t make backup of file with same name')
                                    end
                                    success(j)=success(j) && successM;
                                else
                                    success(j)=false;
                                    error('got an unexpected directory')
                                end
                            end
                        end
                        if success(j)
                            [successC messageC messageIDC]=copyfile(fullfile(filePath,fileName),fullfile(paths{j},subjectName,newFileName));
                            if ~successC
                                messageC
                                messageIDC
                                %error('couldn''t copy file')
                            end
                            success(j)=success(j) && successC;
                        end
                    else
                        message
                        messageID
                        %error('couldn''t make destiation directory')
                    end
                end
                if deleteOnSuccess && all(success)
                    %delete(fullfile(filePath,fileName))

                    [succ message messageID]=mkdir(fullfile(filePath,'backups'));
                    if ~succ
                        message
                        messageID
                    end

                    [successM messageM messageIDM]=movefile(fullfile(filePath,fileName),fullfile(filePath,'backups',newFileName));
                    if ~successM
                        messageM
                        messageIDM
                        msgSub='bad move';
                    else
                        msgSub='good move';
                    end
                    msg={sprintf('success: %d',successM),sprintf('message: %t',messageM),sprintf('messageID: %t',messageIDM),sprintf('path: %t',fullfile(filePath,'backups',newFileName)),sprintf('subject: %t',subjectName)};
                    sendmail('rlab.female.ratrix@biomail.ucsd.edu', 'eflister@biomail.ucsd.edu', msgSub, msg);
                end
            else
                %delete(fullfile(filePath,fileName))?
            end
        end
        'sending ack'
        sendAcknowledge(r,com);
        'sent ack'
    case constants.serverToStationCommands.S_GET_RATRIX_BACKUPS_CMD
        %C_RECV_RATRIX_BACKUPS_CMD
    case constants.serverToStationCommands.S_CLEAR_RATRIX_BACKUPS_CMD
        %ack?
    case constants.serverToStationCommands.S_GET_STATUS_CMD
        'got get status from server'
        quit=sendToServer(r,getClientIdent(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_STATUS_CMD,{stat});
    case constants.serverToStationCommands.S_GET_MAC_CMD
        'got mac req'
        [success mac]=getMACaddress();
        if ~success
            mac
            mac=constants.errors.CANT_DETERMINE_MAC;
        end
        quit=sendToServer(r,getClientIdent(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_MAC_CMD,{mac});



        %commands that should always be handled elsewhere
    case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
        quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD outside of a trial context');
    case {constants.serverToStationCommands.S_GET_VALVE_STATES_CMD constants.serverToStationCommands.S_SET_VALVES_CMD}
        %C_RECV_VALVE_STATES_CMD
        %C_VALVES_SET_CMD
        quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_GET_VALVE_STATES_CMD or S_SET_VALVES_CMD outside of a session context (a ratrix and station are needed to work valves)');
    otherwise
        quit=sendError(r,com,constants.errors.UNRECOGNIZED_COMMAND);
end

function quit=sendRatrixToServer(ratrixDataPath,r,constants)
try
    rx=ratrix(fullfile(ratrixDataPath, 'ServerData'),0); %load from file
catch
    noDBstr='no db at that location';
    x=lasterror;
    if ~isempty(findstr(x.message,noDBstr))
        rx=[];
    else
        [':' x.message ':']
        [':' noDBstr ':']
        class(x.message)
        length(x.message)
        length(noDBstr)
        x.message==noDBstr
        rethrow(lasterror);
    end
end

quit=sendToServer(r,getClientIdent(r),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_RECV_RATRIX_CMD,{rx});

%         if stat==constants.statuses.NO_RATRIX
%             quit=sendError(r,com,constants.errors.BAD_STATE_FOR_COMMAND,'client status is NO_RATRIX - must call S_START_TRIALS_CMD(ratrix) before S_GET_RATRIX_CMD');
%         else
%             %C_RECV_RATRIX_CMD
%         end
