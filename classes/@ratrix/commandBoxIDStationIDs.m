function r=commandBoxIDStationIDs(r,cmd,boxID,stationIDs,comment,auth,secsAcknowledgeWait)
if ~ismember(cmd,{'start','stop'})
    error('cmd must be start or stop')
end

b=getBoxFromID(r,boxID);
status=zeros(1,length(stationIDs));
stationInds=getStationInds(r,stationIDs,boxID);
stationStr=[];
ackStr=[];

if all(stationInds>0)
    if (strcmp(cmd,'start') && all(~stationIDsRunning(r,stationIDs))) || (strcmp(cmd,'stop') && all(stationIDsRunning(r,stationIDs)))
        if ~boxIDEmpty(r,boxID)
            if authorCheck(r,auth)
                if testBoxSubjectAndStationDirs(r,b,stationIDs)
                    subIDs=r.assignments{boxID}{2};
                    theTime=clock;

                    for i=1:length(stationIDs)
                        stationID=stationIDs(i);
                        if strcmp(cmd,'start')
                            cmdStr='starting';
                            if writeObjectsToStationAndStart(r,b,stationID)
                                % dan hill recommended the following and it works! http://www.sysinternals.com/Utilities/PsTools.html
                                %[status, result]=dos('"C:\Documents and Settings\Rlab\Desktop\PsTools\psexec" \\rlab_rig1b -u rlab -p Pac3111 matlab')
                                %    -d         Don't wait for process to terminate (non-interactive).
                                %     -w         Set the working directory of the process (relative to remote computer).
                                %      -priority  Specifies -low, -belownormal, -abovenormal, -high or -realtime to run the process at a different priority.
                                % psexec [\\computer[,computer2[,...]
                                % PsKill - kill processes by name or process ID
                                % PsInfo - list information about a system
                                % PsList - list detailed information about processes
                                % PsShutdown - shuts down and optionally reboots a computer
                                % PsSuspend - suspends processes
                                %Note that the password is transmitted in clear text to the remote system.

                                % > the other useful command is "net use \\machine password /USER:username" which logs you into a remote machine.
                                % > the pattern is:
                                % >
                                % > "net use ..."  to log on
                                % > copy files over
                                % > psexec to run your program
                                % > pslist to see if its done
                                % > pskill to suddently end the session

                                status(i)=1;
                                if status(i)
                                    r.assignments{boxID}{1}{stationInds(i),2}=1;
                                else
                                    error('could not start matlab process for station')
                                end
                            else
                                error('cannot send objects to station or cannot write to station control directory')
                            end

                        elseif strcmp(cmd,'stop')
                            cmdStr='stopping';
                            if stopStation(r,b,stationID)
                                status(i)=1;
                                r.assignments{boxID}{1}{stationInds(i),2}=0;
                            else
                                error('cannot stop station')
                            end

                        else
                            error('unrecognized command')
                        end
                    end

                    saveDB(r,0);
                    pause(secsAcknowledgeWait);

                    for i=1:length(stationIDs)
                        if status(i)
                            ack(i) = checkStationAcknowledgeSince(r,getStationByID(r,stationIDs(i)),theTime);
                            if ~ack(i)
                                warning('station failed to acknowledge command')
                            end
                            stationStr=[stationStr ' ' num2str(stationIDs(i))];
                            ackStr=[ackStr ' ' num2str(ack(i))];
                        end
                    end

                    for sid=1:length(subIDs)
                        subID=subIDs{sid};
                        sub=getSubjectFromID(r,subID);

                        [p,i]=getProtocolAndStep(sub);
                        k=getNumTrainingSteps(p);
                        
                        recordInLog(r,sub,sprintf('%s: %s stations [%s] for subject %s in box %d on step %d/%d of protocol %s. station acknowledgements [%s] after %g secs.',comment,cmdStr,stationStr,subID,boxID,i,k,getName(p),num2str(ackStr),secsAcknowledgeWait),auth);
                    end

                else
                    error('cannot access station or box subject directory')
                end
            else
                error('author does not authenticate')
            end
        else
            error('box has no subjects')
        end
    else
        %strcmp(cmd,'start') 
        %stationIDsRunning(r,stationIDs)
        %all(~stationIDsRunning(r,stationIDs))
        error('to start, all stations must be stopped.  to stop, all stations must be running.')
    end
else
    error('box doesn''t contain all those stations')
end