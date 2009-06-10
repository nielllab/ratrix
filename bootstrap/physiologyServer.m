function physiologyServer()


global ai;

% ========================================================================================
f2=[];
a2=[];
data=[];
groups={};
ai=[];

% ========================================================================================
% size of the GUI - parameters
oneRowHeight=25;
margin=10;
fieldWidth=100;
fWidth=2*margin+9*fieldWidth;
fHeight=margin+20*oneRowHeight+margin;

ai_parameters=[];
ai_parameters.numChans=3;
ai_parameters.sampRate=40000;
ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);

% ========================================================================================
% lists of values for settings
clientIPStrs={'132.239.158.180'};
ratIDStrs={'demo1','test1','fan_demo1','131'};
ratProtocolStrs={'setProtocolTEST','setProtocolPhys2'};
experimenterStrs={'','eflister','pmeier','bsriram'};
electrodeMakeStrs={'FHC','MPI'};
electrodeModelStrs={'','UEWMCGLEEN3M','UEWMCGTECN3M','WE3PT35.0A3-ME4925'};
lotNumStrs={'','885191','885192','885431','120016','57'};
IDNumStrs={'','1','2','3','4','5','6','7','8','9','10','11','12'};
impedanceStrs={'','1','5'};

running=false;
recording=false;
keepLooping=false;
runningLoop=false;
recordingT='start recording';
runningT='start trials';
cellT='start cell';
cellActive=false;
externalRequest=[];

neuralFilename=[];
stimFilename=[];
data=[];

eventTypeStrs={'comment','top of fluid','top of brain','ctx cell','hipp cell',...
	'deadzone','theta chatter','visual hash','visual cell','electrode bend','clapping','rat obs',...
	'anesth check'};
visualHashStrs={'weak','strong'};
snrStrs={[]};
for i=1:0.5:7
    snrStrs{end+1}=num2str(i);
end
vcTypeStrs={[],'on','off','unsure'};
vcEyeStrs={[],'ipsi','contra','both'};
vcBurstyStrs={[],'yes','no'};
vcRFAzimuthStrs={[]};
for i=-90:5:180
    vcRFAzimuthStrs{end+1}=num2str(i);
end
vcRFElevationStrs={[]};
for i=-90:5:180
    vcRFElevationStrs{end+1}=num2str(i);
end

arousalStrs={[],'awake','asleep','anesth'};
eyesStrs={[],'open','closed','squinty','stable','saccades','poor signal'};
faceStrs={[],'whisking','no whisking','grinding','licking','squeaking'};

isofluraneStrs={[],'0.0','1.0','1.5','2.0','2.5','3.0','4.0','5.0','oxy'};
withdrawalStrs={[],'none','sluggish','quick'};
breathPerMinStrs={[],'24-','30','36','42','48','54','60+'};
breathTypeStrs={[],'normal','arrhythmic','wheezing','hooting'};

displayModeStrs={'full','condensed'};

% indices for event types
defaultIndex=1;
visualHashIndex=find(strcmp(eventTypeStrs,'visual hash'));
cellIndices=find(ismember(eventTypeStrs,{'ctx cell','hipp cell','visual cell'}));
visualCellIndex=find(strcmp(eventTypeStrs,'visual cell'));
ratObsIndex=find(strcmp(eventTypeStrs,'rat obs'));
anesthCheckIndex=find(strcmp(eventTypeStrs,'anesth check'));
displayModeIndex=find(strcmp(displayModeStrs,'condensed'));

% ========================================================================================
events_data=[];
eventNum=1;
eventsToSendIndex=1;
savePath=fullfile('\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\physiology',ratIDStrs{defaultIndex},...
    datestr(now,'mm.dd.yyyy'));
% d=dir(fullfile(savePath,'*.mat')); % look for existing files
% % should only have one element in d
% if length(d)==1
%     load(fullfile(savePath,d(1).name));
%     disp('loaded existing event data');
% else
%     events_data=[];
% end
% eventNum=length(events_data)+1;
% eventsToSendIndex=eventNum;
% ========================================================================================
% the GUI
f = figure('Visible','off','MenuBar','none','Name','neural GUI',...
    'NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 fWidth fHeight],...
    'CloseRequestFcn',@cleanup);
    function cleanup(source,eventdata)
        % return event here
        %         events = guidata(f);
        %         events_data
        %         save temp events_data;
        if running
            errordlg('must stop running before closing','error','modal')
        else
            FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
            ListenChar(0) %'called listenchar(0) -- why doesn''t keyboard work?'
            ShowCursor(0)
            closereq;
            return;
        end
    end % end cleanup function
    function updateDisplay(source,eventdata)
        doDisplayUpdate(displayModeStrs{get(displayModeSelector,'Value')});
    end
    function doDisplayUpdate(mode)
        numToShow=length(events_data);
        toShow=events_data(end-numToShow+1:end);
        dispStrs={};
        lastP=0;
        lastPosition=[0 0 0];
        firstTrialNumOfInterval=0;
        firstStartTimeOfInterval=[];
        lastTrialNum=0;
        lastStimClass='unknown';
        lastEventType=[];
        newP=true;
        switch mode
            case 'full'
                for i=length(toShow):-1:1
                    switch toShow(i).eventType
                        case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                                'electrode bend','clapping','rat obs','anesth check'}
                            % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                            str=sprintf('%s\t%d\t',datestr(toShow(i).time,'HH:MM'),toShow(i).eventNumber);
                            if toShow(i).penetrationNum~=lastP
                                appnd=sprintf('Pene#:%d\t',toShow(i).penetrationNum);
                                newP=true;
                                str=[str appnd];
                            else
                                appnd=sprintf('\t');
                                str=[str appnd];
                            end
                            % AP and ML (if differ from last)
                            for j=1:2
                                if isfield(toShow(i),'position') && (toShow(i).position(j)~=lastPosition(j) || newP)
                                    appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                                else
                                    appnd = sprintf('\t');
                                end
                                str=[str appnd];
                            end
                            % Z and type-specific comment
                            appnd = sprintf('%.2f\t',toShow(i).position(3));
                            str=[str appnd];
                            if ~strcmp(toShow(i).eventType,'comment')
                                appnd=sprintf('%s\t',toShow(i).eventType);
                                str=[str appnd];
                            end
                            if ~isempty(toShow(i).eventParams)
                                fn=fields(toShow(i).eventParams);
                            else
                                fn=[];
                            end
                            for j=1:length(fn)
                                val=toShow(i).eventParams.(fn{j});
                                if ~isnan(val)
                                    if isnumeric(val)
                                        val=num2str(val);
                                    end
                                    appnd=sprintf('%s:%s\t',fn{j},val);
                                    str=[str appnd];
                                end
                            end
                            appnd=sprintf('%s',toShow(i).comment);
                            str=[str appnd];
                            % update lastP
                            lastP=toShow(i).penetrationNum;
                            lastPosition=toShow(i).position;
                            newP=false;
                        case {'trial start','trial end','cell start','cell stop'}
                            % these only have an eventType, time, and eventNumber
                            str=sprintf('%s\t%d\t%s',datestr(toShow(i).time,'HH:MM'),toShow(i).eventNumber,toShow(i).eventType);
                        otherwise
                            toShow(i)
                            error('unrecognized event type');
                    end
                    dispStrs{end+1}=str;
                end
                
            case 'condensed'
                for i=1:length(toShow)
                    switch toShow(i).eventType
                        case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                                'electrode bend','clapping','rat obs','anesth check'}
                            % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                            str=sprintf('%s\ttrial %d:\t',datestr(toShow(i).time,'HH:MM'),lastTrialNum);
                            if toShow(i).penetrationNum~=lastP
                                appnd=sprintf('Pene#:%d\t',toShow(i).penetrationNum);
                                newP=true;
                                str=[str appnd];
                            else
                                appnd=sprintf('\t');
                                str=[str appnd];
                            end
                            % AP and ML (if differ from last)
                            for j=1:2
                                if isfield(toShow(i),'position') && (toShow(i).position(j)~=lastPosition(j) || newP)
                                    appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                                else
                                    appnd = sprintf('\t');
                                end
                                str=[str appnd];
                            end
                            % Z and type-specific comment
                            appnd = sprintf('%.2f\t',toShow(i).position(3));
                            str=[str appnd];
                            if ~strcmp(toShow(i).eventType,'comment')
                                appnd=sprintf('%s\t',toShow(i).eventType);
                                str=[str appnd];
                            end
                            if ~isempty(toShow(i).eventParams)
                                fn=fields(toShow(i).eventParams);
                            else
                                fn=[];
                            end
                            for j=1:length(fn)
                                val=toShow(i).eventParams.(fn{j});
                                if ~isnan(val)
                                    if isnumeric(val)
                                        val=num2str(val);
                                    end
                                    appnd=sprintf('%s:%s\t',fn{j},val);
                                    str=[str appnd];
                                end
                            end
                            appnd=sprintf('%s',toShow(i).comment);
                            str=[str appnd];
                            % update lastP
                            lastP=toShow(i).penetrationNum;
                            lastPosition=toShow(i).position;
                            newP=false;
                            dispStrs{end+1}=str; % always add a new str to display
                        case {'trial start','trial end'}
                            if strcmp(toShow(i).eventType,'trial start')
                                if strcmp(toShow(i).eventParams.stimManagerClass,lastStimClass)
                                    % same stim still
                                    str=sprintf('%s\ttrial %d-%d:\t%s',datestr(firstStartTimeOfInterval,'HH:MM'),firstTrialNumOfInterval,...
                                        toShow(i).eventParams.trialNumber,toShow(i).eventParams.stimManagerClass);
                                    dispStrs{end}=str;
                                else
                                    % new stim class
                                    str=sprintf('%s\ttrial %d-%d:\t%s',datestr(toShow(i).time,'HH:MM'),firstTrialNumOfInterval,...
                                        lastTrialNum,lastStimClass);
                                    firstTrialNumOfInterval=toShow(i).eventParams.trialNumber;
                                    firstStartTimeOfInterval=toShow(i).time;
                                    dispStrs{end+1}=str;
                                end
                                lastTrialNum=toShow(i).eventParams.trialNumber;
                                lastStimClass=toShow(i).eventParams.stimManagerClass;
                            end
                        case {'cell start','cell stop'}
                            % these only have an eventType, time, eventNumber, and trialNumber
                            str=sprintf('%s\ttrial %d:\t%s',datestr(toShow(i).time,'HH:MM'),lastTrialNum,toShow(i).eventType);
                            dispStrs{end+1}=str;
                        otherwise
                            toShow(i)
                            error('unrecognized event type');
                    end
                end
                dispStrs=fliplr(dispStrs);
            otherwise
                error('unsupported mode for now');
        end
        
        set(recentEventsDisplay,'String',dispStrs);
        dispStrs={};
        for i=length(events_data):-1:1
            dispStrs=[dispStrs;num2str(i)];
        end
        set(eventsSelector,'String',dispStrs);
    end % end function
% quick plot events
% % %         vhToPlot=strcmp({events_data.eventType},'visual hash');
% % %         vcToPlot=strcmp({events_data.eventType},'visual cell');
% % %         vhp=vertcat(events_data(vhToPlot).position);
% % %         vcp=vertcat(events_data(vcToPlot).position);
% % %         if ~exist('f2','var') || isempty(f2)
% % %             f2=figure('Name','physiology events quick plot','NumberTitle','off');
% % %         end
% % %         if ~exist('a2','var') || isempty(a2)
% % %             a2=axes;
% % %         end
% % %
% % %         set(0,'CurrentFigure',f2)
% % %         set(f2,'CurrentAxes',a2)
% % %         hold off
% % %         if ~isempty(vhp)
% % %             plot3(a2,vhp(:,1),vhp(:,2),vhp(:,3),'.');
% % %         end
% % %         hold on
% % %         if ~isempty(vcp)
% % %             plot3(a2,vcp(:,1),vcp(:,2),vcp(:,3),'.r');
% % %         end
% % %         hold off
% % %         xlabel('x position');
% % %         ylabel('y position');
% % %         zlabel('z position');
% % %         grid on;
% % %     end % end updateDisplay function

    function updateUI()
        % updates the physiologyServer UI control panel (not the recent events display)
        if recording
            recordingT='stop recording';
        else
            recordingT='start recording';
        end
        if running
            runningT='stop trials';
        else
            runningT='start trials';
        end
        set(toggleRecordingButton,'String',recordingT);
        set(toggleTrialsButton,'String',runningT);
        set(toggleCellButton,'String',cellT);
        drawnow;
    end
	
	function turnOffAllLabelsAndMenus()
		set(visualHashLabel,'Visible','off');
		set(snrLabel,'Visible','off');
		set(vcTypeLabel,'Visible','off');
		set(vcEyeLabel,'Visible','off');
		set(vcBurstyLabel,'Visible','off');
		set(vcRFAzimuthLabel,'Visible','off');
		set(vcRFElevationLabel,'Visible','off');
		set(arousalLabel,'Visible','off');
		set(eyesLabel,'Visible','off');
		set(faceLabel,'Visible','off');
		set(isofluraneLabel,'Visible','off');
		set(withdrawalLabel,'Visible','off');
		set(breathPerMinLabel,'Visible','off');
		set(breathTypeLabel,'Visible','off');
		set(visualHashMenu,'Visible','off','Enable','off');
		set(snrMenu,'Visible','off','Enable','off');
		set(vcTypeMenu,'Visible','off','Enable','off');
		set(vcEyeMenu,'Visible','off','Enable','off');
		set(vcBurstyMenu,'Visible','off','Enable','off');
		set(vcRFAzimuthMenu,'Visible','off','Enable','off');
		set(vcRFElevationMenu,'Visible','off','Enable','off');
		set(arousalMenu,'Visible','off','Enable','off');
		set(eyesMenu,'Visible','off','Enable','off');
		set(faceMenu,'Visible','off','Enable','off');
		set(isofluraneMenu,'Visible','off','Enable','off');
		set(withdrawalMenu,'Visible','off','Enable','off');
		set(breathPerMinMenu,'Visible','off','Enable','off');
		set(breathTypeMenu,'Visible','off','Enable','off');
	end

% ========================================================================================
% draw text labels for surgery anchor
APHeader = uicontrol(f,'Style','text','String','AP','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
MLHeader = uicontrol(f,'Style','text','String','ML','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
ZHeader = uicontrol(f,'Style','text','String','Z','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorLabel = uicontrol(f,'Style','text','String','Surgery Anchor','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaLabel = uicontrol(f,'Style','text','String','Surgery Bregma','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% surgery anchor and bregma text fields
surgeryAnchorAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);

% checkbox to enable surgery field input
enableSurgeryFields = uicontrol(f,'Style','checkbox',...
    'String','unlock surgery fields','Enable','on','Visible','on',...
    'Value',0,'Units','pixels','Position',[2*margin+4*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth+margin*3 oneRowHeight],...
    'CallBack',@enableSurgeryEntry);
    function enableSurgeryEntry(source,eventdata)
        if get(enableSurgeryFields,'Value')==1
            set(surgeryAnchorAPField,'Enable','on');
            set(surgeryAnchorMLField,'Enable','on');
            set(surgeryAnchorZField,'Enable','on');
            set(surgeryBregmaAPField,'Enable','on');
            set(surgeryBregmaMLField,'Enable','on');
            set(surgeryBregmaZField,'Enable','on');
        else
            set(surgeryAnchorAPField,'Enable','off');
            set(surgeryAnchorMLField,'Enable','off');
            set(surgeryAnchorZField,'Enable','off');
            set(surgeryBregmaAPField,'Enable','off');
            set(surgeryBregmaMLField,'Enable','off');
            set(surgeryBregmaZField,'Enable','off');
        end
    end % end enableSurgeryEntry function

% ========================================================================================
% current anchor label
currentAnchorLabel = uicontrol(f,'Style','text','String','Current Anchor','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
% current anchor text field
currentAnchorAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
currentAnchorMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
currentAnchorZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);

% checkbox to enable current anchor field input
enableCurrentAnchorField = uicontrol(f,'Style','checkbox',...
    'String','unlock current anchor','Enable','on','Visible','on',...
    'Value',0,'Units','pixels','Position',[2*margin+4*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth+margin*3 oneRowHeight],...
    'CallBack',@enableCurrentAnchorEntry);
    function enableCurrentAnchorEntry(source,eventdata)
        if get(enableCurrentAnchorField,'Value')==1
            set(currentAnchorAPField,'Enable','on');
            set(currentAnchorMLField,'Enable','on');
            set(currentAnchorZField,'Enable','on');
        else
            set(currentAnchorAPField,'Enable','off');
            set(currentAnchorMLField,'Enable','off');
            set(currentAnchorZField,'Enable','off');
        end
    end % end enableCurrentAnchorEntry function

% ========================================================================================
% calculated theoretical center of LGN display
theoreticalLGNCenterLabel = uicontrol(f,'Style','text','String','theor. LGN center','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight]);
theoreticalLGNCenterAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');
theoreticalLGNCenterMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');
theoreticalLGNCenterZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');

% ========================================================================================
% calculated current - what is 'current' anyways?
currentLabel = uicontrol(f,'Style','text','String','Current','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight]);
currentAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');
currentMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');
currentZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight],...
    'HorizontalAlignment','center');

% ========================================================================================
% penetration parameters (ratID, experimenter, electrode make/model, lot#, ID#, impedance)
clientIPLabel = uicontrol(f,'Style','text','String','Client IP','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[8*margin+6*fieldWidth fHeight-1*oneRowHeight-margin fieldWidth oneRowHeight]);
ratIDLabel = uicontrol(f,'Style','text','String','Rat ID','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
ratProtocolLabel = uicontrol(f,'Style','text','String','Protocol','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
experimenterLabel = uicontrol(f,'Style','text','String','Experimenter','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeMakeLabel = uicontrol(f,'Style','text','String','electrode make','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeModelLabel = uicontrol(f,'Style','text','String','electrode model','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight]);
lotNumLabel = uicontrol(f,'Style','text','String','lot #','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-7*oneRowHeight-margin fieldWidth oneRowHeight]);
IDNumLabel = uicontrol(f,'Style','text','String','ID #','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
impedanceLabel = uicontrol(f,'Style','text','String','impedance','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);

clientIPField = uicontrol(f,'Style','popupmenu','String',clientIPStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[8*margin+7*fieldWidth fHeight-1*oneRowHeight-margin fieldWidth*1.4 oneRowHeight]);
ratIDField = uicontrol(f,'Style','popupmenu','String',ratIDStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight],...
    'Callback',@reloadEventsAndSurgeryFields);
    function reloadEventsAndSurgeryFields(source,eventdata)
        % reload physiology event log
        savePath=fullfile('\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\physiology',ratIDStrs{get(ratIDField,'Value')},...
            datestr(now,'mm.dd.yyyy'));
        d=dir(fullfile(savePath,'*.mat')); % look for existing files
        % should only have one element in d
        if length(d)==1
            events_data=load(fullfile(savePath,d(1).name));
            events_data=events_data.events_data;
            cellStartInds=find(strcmp({events_data.eventType},'cell start'));
            cellStopInds=find(strcmp({events_data.eventType},'cell stop'));
            if length(cellStopInds)==length(cellStartInds)
                cellT='start cell';
                cellActive=false;
            else
                cellT='stop cell';
                cellActive=true;
            end
        else
            events_data=[];
        end
        eventNum=length(events_data)+1;
        eventsToSendIndex=eventNum;
        updateDisplay();
        % get surgery anchor and bregma fields from oracle if possible
        try
            conn=dbConn();
            surg=getSurgeryFields(conn,ratIDStrs{get(ratIDField,'Value')});
            set(surgeryAnchorAPField,'String',num2str(surg.anchorAP));
            set(surgeryAnchorMLField,'String',num2str(surg.anchorML));
            set(surgeryAnchorZField,'String',num2str(surg.anchorZ));
            set(surgeryBregmaAPField,'String',num2str(surg.bregmaAP));
            set(surgeryBregmaMLField,'String',num2str(surg.bregmaML));
            set(surgeryBregmaZField,'String',num2str(surg.bregmaZ));
        catch ex
            warning('could not get surgery fields from oracle');
        end
            
    end
ratProtocolField = uicontrol(f,'Style','popupmenu','String',ratProtocolStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
experimenterField = uicontrol(f,'Style','popupmenu','String',experimenterStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeMakeField = uicontrol(f,'Style','popupmenu','String',electrodeMakeStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeModelField = uicontrol(f,'Style','popupmenu','String',electrodeModelStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight]);
lotNumField = uicontrol(f,'Style','popupmenu','String',lotNumStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-7*oneRowHeight-margin fieldWidth oneRowHeight]);
IDNumField = uicontrol(f,'Style','popupmenu','String',IDNumStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
impedanceField = uicontrol(f,'Style','popupmenu','String',impedanceStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% current event parameters - labels
eventTypeLabel = uicontrol(f,'Style','text','String','event type','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
visualHashLabel = uicontrol(f,'Style','text','String','visual hash','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+1*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
snrLabel = uicontrol(f,'Style','text','String','SNR','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+1*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
vcTypeLabel = uicontrol(f,'Style','text','String','vc type','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
vcEyeLabel = uicontrol(f,'Style','text','String','vc eye','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
vcBurstyLabel = uicontrol(f,'Style','text','String','vc bursty','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+4*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
vcRFAzimuthLabel = uicontrol(f,'Style','text','String','vc RF azimuth','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+5*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
vcRFElevationLabel = uicontrol(f,'Style','text','String','vc RF elevation (+ is up/right)','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+6*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
arousalLabel = uicontrol(f,'Style','text','String','arousal','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+1*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
eyesLabel = uicontrol(f,'Style','text','String','eyes','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
faceLabel = uicontrol(f,'Style','text','String','face','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
isofluraneLabel = uicontrol(f,'Style','text','String','isoflurane','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+1*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
withdrawalLabel = uicontrol(f,'Style','text','String','withdrawal','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
breathPerMinLabel = uicontrol(f,'Style','text','String','breath/min','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);
breathTypeLabel = uicontrol(f,'Style','text','String','breath type','Visible','off','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+4*fieldWidth fHeight-8*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% current event parameters - dropdown menus
eventTypeMenu = uicontrol(f,'Style','popupmenu','String',eventTypeStrs,'Visible','on','Units','pixels',...
    'Enable','on','Value',defaultIndex,'Callback',@eventTypeC,...
    'Position',[margin+0*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
    function eventTypeC(source,eventdata)
		turnOffAllLabelsAndMenus();
        if get(eventTypeMenu,'Value')==visualHashIndex
            set(visualHashLabel,'Visible','on');
            set(visualHashMenu,'Visible','on','Enable','on');
		elseif get(eventTypeMenu,'Value')==ratObsIndex
			set(arousalLabel,'Visible','on');
			set(eyesLabel,'Visible','on');
			set(faceLabel,'Visible','on');
			set(arousalMenu,'Visible','on','Enable','on');
			set(eyesMenu,'Visible','on','Enable','on');
			set(faceMenu,'Visible','on','Enable','on');
		elseif get(eventTypeMenu,'Value')==anesthCheckIndex
			set(isofluraneLabel,'Visible','on');
			set(withdrawalLabel,'Visible','on');
			set(breathPerMinLabel,'Visible','on');
			set(breathTypeLabel,'Visible','on');
			set(isofluraneMenu,'Visible','on','Enable','on');
			set(withdrawalMenu,'Visible','on','Enable','on');
			set(breathPerMinMenu,'Visible','on','Enable','on');
			set(breathTypeMenu,'Visible','on','Enable','on');
        elseif any(cellIndices==get(eventTypeMenu,'Value'))
            set(snrLabel,'Visible','on');
            set(snrMenu,'Visible','on','Enable','on');
            if get(eventTypeMenu,'Value')==visualCellIndex
                set(vcTypeLabel,'Visible','on');
                set(vcEyeLabel,'Visible','on');
                set(vcBurstyLabel,'Visible','on');
                set(vcRFAzimuthLabel,'Visible','on');
                set(vcRFElevationLabel,'Visible','on');
                set(vcTypeMenu,'Visible','on','Enable','on');
                set(vcEyeMenu,'Visible','on','Enable','on');
                set(vcBurstyMenu,'Visible','on','Enable','on');
                set(vcRFAzimuthMenu,'Visible','on','Enable','on');
                set(vcRFElevationMenu,'Visible','on','Enable','on');
            end
        else
			% do nothing - already all off
        end
    end % end function

visualHashMenu = uicontrol(f,'Style','popupmenu','String',visualHashStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+1*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
snrMenu = uicontrol(f,'Style','popupmenu','String',snrStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+1*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
vcTypeMenu = uicontrol(f,'Style','popupmenu','String',vcTypeStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+2*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
vcEyeMenu = uicontrol(f,'Style','popupmenu','String',vcEyeStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+3*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
vcBurstyMenu = uicontrol(f,'Style','popupmenu','String',vcBurstyStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+4*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
vcRFAzimuthMenu = uicontrol(f,'Style','popupmenu','String',vcRFAzimuthStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+5*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
vcRFElevationMenu = uicontrol(f,'Style','popupmenu','String',vcRFElevationStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+6*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
arousalMenu = uicontrol(f,'Style','popupmenu','String',arousalStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+1*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
eyesMenu = uicontrol(f,'Style','popupmenu','String',eyesStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+2*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
faceMenu = uicontrol(f,'Style','popupmenu','String',faceStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+3*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
isofluraneMenu = uicontrol(f,'Style','popupmenu','String',isofluraneStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+1*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
withdrawalMenu = uicontrol(f,'Style','popupmenu','String',withdrawalStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+2*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
breathPerMinMenu = uicontrol(f,'Style','popupmenu','String',breathPerMinStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+3*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
breathTypeMenu = uicontrol(f,'Style','popupmenu','String',breathTypeStrs,'Visible','off','Units','pixels',...
    'Enable','off','Value',defaultIndex,...
    'Position',[margin+4*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% offset event label, fields, and "submit" button
offsetEventLabel = uicontrol(f,'Style','text','String','Offset','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth oneRowHeight]);
offsetAPField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+1*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth oneRowHeight]);
offsetMLField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+2*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth oneRowHeight]);
offsetZField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+3*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentComment = uicontrol(f,'Style','edit','Units','pixels','String','',...
    'Enable','on','Position',[1*margin+4*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth*4 oneRowHeight]);

offsetEventSubmit = uicontrol(f,'Style','pushbutton','String','enter','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center','CallBack',@logEvent, ...
    'Position',[2*margin+8*fieldWidth fHeight-10*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function logEvent(source,eventdata)
        if isfield(events_data,'position')
            lastEventWithCoords=find(cellfun(@isempty,{events_data.position})==0,1,'last');
        else
            lastEventWithCoords=[];
        end

        % make a new entry in events
        events_data(end+1).time=now;
        events_data(end).eventNumber=eventNum;
        events_data(end).surgeryAnchor=[str2double(get(surgeryAnchorAPField,'String')) str2double(get(surgeryAnchorMLField,'String')) str2double(get(surgeryAnchorZField,'String'))];
        events_data(end).surgeryBregma=[str2double(get(surgeryBregmaAPField,'String')) str2double(get(surgeryBregmaMLField,'String')) str2double(get(surgeryBregmaZField,'String'))];
        events_data(end).currentAnchor=[str2double(get(currentAnchorAPField,'String')) str2double(get(currentAnchorMLField,'String')) str2double(get(currentAnchorZField,'String'))];
        events_data(end).position=[str2double(get(offsetAPField,'String')) str2double(get(offsetMLField,'String')) str2double(get(offsetZField,'String'))];
        events_data(end).eventType=eventTypeStrs{get(eventTypeMenu,'Value')};
        eventParams=[];
        switch events_data(end).eventType
            case 'visual hash'
                eventParams.hashStrength=visualHashStrs{get(visualHashMenu,'Value')};
            case {'ctx cell','hipp cell','visual cell'}
                eventParams.SNR=str2double(snrStrs{get(snrMenu,'Value')});
                if strcmp(events_data(end).eventType,'visual cell')
                    eventParams.vcType=vcTypeStrs{get(vcTypeMenu,'Value')};
                    eventParams.vcEye=vcEyeStrs{get(vcEyeMenu,'Value')};
                    eventParams.vcBursty=vcBurstyStrs{get(vcBurstyMenu,'Value')};
                    eventParams.vcRFAzimuth=str2double(vcRFAzimuthStrs{get(vcRFAzimuthMenu,'Value')});
                    eventParams.vcRFElevation=str2double(vcRFElevationStrs{get(vcRFElevationMenu,'Value')});
                end
            case 'rat obs'
                eventParams.arousal=arousalStrs{get(arousalMenu,'Value')};
                eventParams.eyes=eyesStrs{get(eyesMenu,'Value')};
                eventParams.face=faceStrs{get(faceMenu,'Value')};
            case 'anesth check'
                eventParams.isoflurane=isofluraneStrs{get(isofluraneMenu,'Value')};
                eventParams.withdrawal=withdrawalStrs{get(withdrawalMenu,'Value')};
                eventParams.breathPerMin=breathPerMinStrs{get(breathPerMinMenu,'Value')};
                eventParams.breathType=breathTypeStrs{get(breathTypeMenu,'Value')};
            otherwise
                % nothing
        end
        events_data(end).eventParams=eventParams;
        events_data(end).comment=get(currentComment,'String');

        % update pNum if necessary (if AP or ML differ from last)
        if ~isempty(lastEventWithCoords)
            if (length(events_data)>=2 && any(events_data(lastEventWithCoords).position(1:2)~=events_data(end).position(1:2))) ...
                    || length(events_data)==1
                % record events_data.penetrationParams here (ratID, experimenters,
                %   electrode make, model, lot#, ID#, impedance, reference mark xyz, target xy)

                params=[];
                params.ratID=ratIDStrs{get(ratIDField,'Value')};
                params.experimenter=experimenterStrs{get(experimenterField,'Value')};
                params.electrodeMake=electrodeMakeStrs{get(electrodeMakeField,'Value')};
                params.electrodeModel=electrodeModelStrs{get(electrodeModelField,'Value')};
                params.lotNum=lotNumStrs{get(lotNumField,'Value')};
                params.IDNum=IDNumStrs{get(IDNumField,'Value')};
                params.impedance=impedanceStrs{get(impedanceField,'Value')};
                events_data(end).penetrationParams=params;

                if length(events_data)==1
                    events_data(end).penetrationNum=1;
                else
                    events_data(end).penetrationNum=events_data(lastEventWithCoords).penetrationNum+1;
                end
            else
                events_data(end).penetrationNum=events_data(lastEventWithCoords).penetrationNum;
                events_data(end).penetrationParams=[];
            end
        else
            events_data(end).penetrationNum=1;
            events_data(end).penetrationParams=[];
        end

        % save event log
        deleteFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum-1);
        saveFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum);
        if ~isdir(savePath)
            mkdir(savePath);
        end
        save(fullfile(savePath,saveFilename),'events_data','groups');
        if eventNum~=1
            delete(fullfile(savePath,deleteFilename));
        end

        eventNum=eventNum+1;
        updateDisplay();
        % flush the comments buffer
        set(currentComment,'String','');
        % reset eventType to comment
        set(eventTypeMenu,'Value',defaultIndex);
        eventTypeC([],[]);
    end % end logEvent function

% ========================================================================================
% quick plot
quickPlotButton = uicontrol(f,'Style','pushbutton','String','quick plot','Visible','on','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','center','CallBack',@quickPlot, ...
    'Position',[2*margin+8*fieldWidth fHeight-18*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function quickPlot(source,eventdata)
        p=vertcat(events_data.position);
        g=figure;
        plot3(p(:,1),p(:,2),p(:,3),'.r');
        xlabel('x position');
        ylabel('y position');
        zlabel('z position');
        grid on;
    end

% ========================================================================================
% start/stop cell
toggleCellButton = uicontrol(f,'Style','togglebutton','String',cellT,'Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center','CallBack',@toggleCell, ...
    'Position',[2*margin+8*fieldWidth fHeight-14*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function toggleCell(source,eventdata)
        if get(toggleCellButton,'Value')
            externalRequest='cell start';
        else
            externalRequest='cell stop';
        end
        % get time from client machine (if it exists)
        if ~running
            events_data(end+1).time=now;
            events_data(end).eventType=externalRequest;
            events_data(end).eventNumber=eventNum;
            % save events
            % save event log
            deleteFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum-1);
            saveFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum);
            if ~isdir(savePath)
                mkdir(savePath);
            end
            save(fullfile(savePath,saveFilename),'events_data','groups');
            if eventNum~=1
                delete(fullfile(savePath,deleteFilename));
            end
            eventNum=eventNum+1;
            externalRequest=[];
        else
            % we just need to pass externalRequest to the run loop
        end
        fprintf('finished getting time from client\n')
        if get(toggleCellButton,'Value') % start the cell
            cellActive=true;
            cellT='stop cell';
        else
            cellActive=false;
            cellT='start cell';
        end
        updateDisplay();
        updateUI();
    end
% ========================================================================================
% start/stop recording
toggleRecordingButton = uicontrol(f,'Style','togglebutton','String',recordingT,'Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center','CallBack',@toggleRecording, ...
    'Position',[2*margin+8*fieldWidth fHeight-15*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function toggleRecording(source,eventdata)
        if get(toggleRecordingButton,'Value') % start recording
            recording=true;
            keepLooping=false;
             if ~running
                q=questdlg('Also start trials?','start recording','Yes','No','Cancel','Yes');
                switch q
                    case {'Yes','No'}
                        if strcmp(q,'Yes')
                            running=true;
                            set(toggleTrialsButton,'Value',1);
                        end
                    case 'Cancel'
                        recording=false;
                        keepLooping=true;
                        set(toggleRecordingButton,'Value',0);
                        return;
                    otherwise
                        error('bad response from question dialog');
                end
            end
            updateUI();
            % if not currently looping, then start the loop
            if ~runningLoop
                run();
            end
        else
            if running
                q=questdlg('Also stop running trials?','stop recording','Yes','No','Cancel','Yes');
                switch q
                    case {'Yes','No'}
                        if strcmp(q,'Yes')
                            running=false;
                            set(toggleTrialsButton,'Value',0);
                        end
                        recording=false;
                        keepLooping=false;
                    case 'Cancel';
                        % do nothing;
                        set(toggleRecordingButton,'Value',1);
                    otherwise
                        error('bad response from question dialog');
                end
            else
                recording=false;
                keepLooping=false;
            end
        end
        updateUI();
    end % end function

% ========================================================================================
% start/stop trials
toggleTrialsButton = uicontrol(f,'Style','togglebutton','String',runningT,'Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center','CallBack',@toggleTrials, ...
    'Position',[2*margin+8*fieldWidth fHeight-16*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function toggleTrials(source,eventdata)
        if get(toggleTrialsButton,'Value') % start running
            running=true;
            keepLooping=false;
            if ~recording
                q=questdlg('Also start recording?','start trials','Yes','No','Cancel','Yes');
                switch q
                    case {'Yes','No'}
                        if strcmp(q,'Yes')
                            recording=true;
                            set(toggleRecordingButton,'Value',1);
                        end
                    case 'Cancel'
                        running=false;
                        keepLooping=true;
                        set(toggleTrialsButton,'Value',0);
                        return
                    otherwise
                        error('bad response from question dialog');
                end
            end
            updateUI();
            if ~runningLoop % if not currently looping, then start the loop
                run();
            end
        else
            if recording
                q=questdlg('Also stop recording?','stop trials','Yes','No','Cancel','Yes');
                switch q
                    case {'Yes','No'}
                        if strcmp(q,'Yes')
                            recording=false;
                            set(toggleRecordingButton,'Value',0);
                        end
                        running=false;
                        keepLooping=false;
                    case 'Cancel';
                        % do nothing;
                        set(toggleTrialsButton,'Value',1);
                    otherwise
                        error('bad response from question dialog');
                end
            else
                running=false;
                keepLooping=false;
            end
        end
        updateUI();
    end % end function

    function run
        runningLoop=true;
        keepLooping=true;
        storepath=fullfile('\\132.239.158.179\datanet_storage',ratIDStrs{get(ratIDField,'Value')});
        % check that neuralRecords,eyeRecord,stimRecords folders exist
        if ~isdir(fullfile(storepath,'neuralRecords'))
            mkdir(fullfile(storepath,'neuralRecords'));
        end
        if ~isdir(fullfile(storepath,'eyeRecords'))
            mkdir(fullfile(storepath,'eyeRecords'));
        end
        if ~isdir(fullfile(storepath,'stimRecords'))
            mkdir(fullfile(storepath,'stimRecords'));
        end
        client_hostname=clientIPStrs{get(clientIPField,'Value')};
        neuralFilename=[];
        stimFilename=[];
        chunkCount=1;
        chunkClock=[];
        startTime=0;
        % ==============================================
        % SET UP TRIALS
        if running
            pnet('closeall')
            data = datanet('data', getIPAddress(),client_hostname,storepath,ai_parameters); % how do we get client_hostname,storepath, and ai_parameters?
            [dataCmdCon dataAckCon]= connectToClient(data,client_hostname);
            if isempty(dataCmdCon) || isempty(dataAckCon)
                % this should error, because we pressed 'start trials' and then failed to connect to a client
                error('failed to connect to client');
            else
                data=setCmdCon(data,dataCmdCon);
                data=setAckCon(data,dataAckCon);
                gotAck=startClientTrials(data,ratIDStrs{get(ratIDField,'Value')},ratProtocolStrs{get(ratProtocolField,'Value')});
                fprintf('started client trials\n');
                if ~gotAck
                    error('wtf how did we call startClientTrials and then not get an ack back?');
                else
                    gotAck
                end
            end
        end
        % ==============================================
        % SET UP NIDAQ
        if recording
            % how to set up neuralFilename
            dirStr=fullfile(storepath,'neuralRecords');
            goodTrials=[];
            d=dir(dirStr);
            for j=1:length(d)
                [matches tokens] = regexpi(d(j).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
                if length(matches) ~= 1
                    %         warning('not a neuralRecord file name');
                else
                    goodTrials(end+1)=str2double(tokens{1}{1});
                end
            end
            lastTrial=max(goodTrials);
            if isempty(lastTrial)
                lastTrial=1;
            end
            neuralFilename=fullfile(storepath,'neuralRecords',sprintf('neuralRecords_pretrial%d-%s.mat',lastTrial,datestr(now,30)));
            if ~running
                samplingRate=ai_parameters.sampRate;
                save(neuralFilename,'samplingRate'); %create the pretrial neuralRecords file!
            end
            chunkClock=GetSecs();
            startTime=chunkClock;
            [ai recordingFile]=startNidaq(ai_parameters);
        end

        quit=false;

        while ~quit && keepLooping
            params=[];
            params.ai=ai;
            params.neuralFilename=neuralFilename;
            params.stimFilename=stimFilename;
            params.samplingRate=ai_parameters.sampRate;
            params.chunkCount=chunkCount;
            params.startTime=startTime;
            % ==============================================
            % handle all TRIALS stuff
            if running && ~isempty(dataCmdCon) && ~isempty(dataAckCon)
                [quit retval status requestDone]=doServerIteration(data,params,externalRequest);
                if requestDone % we have to do this instead of just updating the value of externalRequest, becuase of some weird matlab scope issue
                    externalRequest=[];
                end
                if ~isempty(retval) % we have events_data to save
                    % retval should be a struct with fields 'time' and 'type' (and possibly others to add...)
                    for j=1:length(retval)
                        if isfield(retval(j),'errorMethod') && ~isempty(retval(j).errorMethod)
                            % this is not a phys event, but rather a
                            % 'restart' or 'quit' from client
                            
                            % 6/9/09 - should we delete the neuralRecord at
                            % neuralFilename b/c it was error trial?
                            % also corresponding stimRecord/eyeRecord?
                            delete(neuralFilename);
                            delete(stimFilename);
                            quit=true;
                            disp('quitting due to client disconnect');
                            method=retval(j).errorMethod;
                            if ischar(method)
                                if strcmp(method,'Restart')
                                    % do nothing
                                elseif strcmp(method, 'Quit')
                                    running=false;
                                    recording=false;
                                    set(toggleTrialsButton,'Value',0);
                                    set(toggleRecordingButton,'Value',0);
                                else
                                    error('if not restart or quit, then what is the client method?');
                                end
                            else
                                error('ERROR_RECOVERY_METHOD must be a string');
                            end
                            updateUI();
                            updateDisplay();
                        else
                            events_data(end+1).time=retval(j).time;
                            events_data(end).eventType=retval(j).type;
                            events_data(end).eventNumber=eventNum;
                            if strcmp(retval(j).type,'trial start')
                                neuralFilename=retval(j).neuralFilename;
                                stimFilename=retval(j).stimFilename;
                                % reset chunkCount and chunkClock?
                                chunkCount=1;
                                chunkClock=GetSecs();
                                startTime=chunkClock;
                                events_data(end).eventParams.trialNumber=retval(j).trialNumber;
                                events_data(end).eventParams.stimManagerClass=retval(j).stimManagerClass;
                            end
                            % should save events to phys log here?
                            % save event log
                            deleteFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum-1);
                            saveFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum);
                            if ~isdir(savePath)
                                mkdir(savePath);
                            end
                            save(fullfile(savePath,saveFilename),'events_data','groups');
                            if eventNum~=1
                                delete(fullfile(savePath,deleteFilename));
                            end
                            eventNum=eventNum+1;
                        end
                    end
                end
            else
                WaitSecs(0.3);
                drawnow;
            end
            % ==============================================
            % handle all NIDAQ stuff
            if recording
                % now check if it is time to spool off a 30sec chunk
                t=GetSecs();
                if t-chunkClock>=30 %hardcoded to 30 seconds for now?
                    numSampsToGet=get(ai,'SamplesAvailable');
                    [neuralData,neuralDataTimes]=getdata(ai,numSampsToGet);
                    elapsedTime=GetSecs()-startTime;
                    saveNidaqChunk(neuralFilename,neuralData,neuralDataTimes([1 end]),chunkCount,elapsedTime,ai_parameters.sampRate);
                    clear neuralData neuralDataTimes;
                    % now increment chunkCount and chunkClock
                    chunkCount=chunkCount+1;
                    chunkClock=t;
                end
            end
            updateDisplay();
            WaitSecs(0.3);
        end
        % ==============================================
        % after a quit, handle all TRIALS stuff
        if ~isempty(data) && ~quit && status && ~keepLooping %not a client disconnect (so a normal stop by setting keepLooping to false)
            [gotAck retval]=stopClientTrials(data,ratIDStrs{get(ratIDField,'Value')},params);
            if ~isempty(retval) % save last trial's TRIAL_END event (the call to stopClientTrials saved its neuralRecord)
                for j=1:length(retval)
                    events_data(end+1).time=retval(j).time;
                    events_data(end).eventType=retval(j).type;
                    events_data(end).eventNumber=eventNum;
                    % save event log
                    deleteFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum-1);
                    saveFilename=sprintf('physiologyEvents_%d-%d.mat',1,eventNum);
                    if ~isdir(savePath)
                        mkdir(savePath);
                    end
                    save(fullfile(savePath,saveFilename),'events_data','groups');
                    if eventNum~=1
                        delete(fullfile(savePath,deleteFilename));
                    end
                    eventNum=eventNum+1;
                end
            end
        end
        if ~isempty(ai) % stop nidaq recording after saving last chunk
            % need to spool off remaining neural data in standalone mode
            if isempty(data) % if we are running trials, then stopClientTrials handles saving of last chunk, DONT REPEAT
                try
                    numSampsToGet=get(ai,'SamplesAvailable');
                    [neuralData,neuralDataTimes]=getdata(ai,numSampsToGet);
                    elapsedTime=GetSecs()-startTime;
                    saveNidaqChunk(neuralFilename,neuralData,neuralDataTimes([1 end]),chunkCount,elapsedTime,ai_parameters.sampRate);
                    clear neuralData neuralDataTimes;
                    flushdata(ai);
                catch ex
                    getReport(ex)
                    disp('failed to get neural records');
                    keyboard
                end
            end
            ai=stopNidaq(ai);
        end

        % reset some flags for next instance of run
        pnet('closeall');
        data=[];
        ai=[];
        runningLoop=false;
        if running || recording % if we only turned off one of recording/running, then restart the run loop
            updateDisplay();
            run();
        end
    end

% ========================================================================================
% event selector (for grouping)
eventsSelector = uicontrol(f,'Style','listbox','String',{},'Visible','on','Units','pixels',...
    'FontWeight','normal','Value',[],'Enable','on','Max',999,'Min',0,...
    'Position',[margin+0*fieldWidth fHeight-17*oneRowHeight-1*margin fieldWidth*1-margin oneRowHeight*6]);

addGroupButton = uicontrol(f,'Style','pushbutton','String','add group','Visible','on','Units','pixels',...
    'Position',[margin+0*fieldWidth fHeight-19*oneRowHeight-1*margin fieldWidth*1-margin oneRowHeight],...
    'Value',0,'Callback',@addGroup);
    function addGroup(source,eventdata)
        v=length(events_data):-1:1;
        groups{end+1}=sort(v(get(eventsSelector,'Value')));
        groups{end}
    end

% ========================================================================================
% display box
recentEventsDisplay = uicontrol(f,'Style','edit','String','recent events','Visible','on','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','left','Max',999,'Min',0,'Value',[],'Enable','on', ...
    'Position',[margin+1*fieldWidth fHeight-19*oneRowHeight-1*margin fieldWidth*7-margin oneRowHeight*8]);

displayModeLabel = uicontrol(f,'Style','text','String','Display Mode','Visible','on','Units','pixels',...
    'HorizontalAlignment','center','Position',...
    [margin fHeight-20*oneRowHeight-2*margin fieldWidth*1-margin oneRowHeight]);
displayModeSelector = uicontrol(f,'Style','popup',...
    'String',displayModeStrs,'Enable','on','Visible','on',...
    'Value',displayModeIndex,'Units','pixels','Position',...
    [margin+fieldWidth fHeight-20*oneRowHeight-2*margin fieldWidth*1-margin oneRowHeight],...
    'Callback',@updateDisplay);

% recentEventsDisplay = uicontrol(f,'Style','listbox',...
%                 'String','recent events',...
%                 'Max',2,'Min',0,'Value',[1 3],,...
%                 'Position',[30 20 130 80]);

% ========================================================================================
% turn on the GUI
reloadEventsAndSurgeryFields([],[]);
set(f,'Visible','on');
end

% ========================================================================================
% HELPER FUNCTIONS
function [quit retval status requestDone]=doServerIteration(data,params,externalRequest)
% should also work in standalone phys logging mode (just do nothing...)
requestDone=false;
% check pnet('status') here if ratrix throws error, go back to
% connectToClient
status=pnet(getCmdCon(data),'status')>0 && pnet(getAckCon(data),'status')>0;

quit=false;
retval=[];
if ~isempty(getCmdCon(data)) && ~isempty(getAckCon(data))
    [data quit retval] = handleCommands(data,params);
end
if ~isempty(externalRequest)
    retval(end+1).time=getTimeFromClient(data);
    retval(end).type=externalRequest;
    requestDone=true;
end
% fprintf('did a server iteration\n')
WaitSecs(0.3);
end


function [ai recordingFile] = startNidaq(ai_parameters)
% start NIDAQ recording - in both standalone and ratrix cases
% ai_parameters = getAIParameters(data);
if isfield(ai_parameters, 'numChans')
    numChans = ai_parameters.numChans;
else
    numChans = 3;
end
if isfield(ai_parameters, 'sampRate')
    sampRate = ai_parameters.sampRate;
else
    sampRate = 40000;
end
if isfield(ai_parameters, 'inputRanges')
    inputRanges = ai_parameters.inputRanges;
else
    inputRanges = repmat([-1 6],numChans,1);
end
if isfield(ai_parameters, 'recordingFile')
    recordingFile = ai_parameters.recordingFile;
else
    recordingFile = [];
end
% start NIDAQ
sprintf('starting NIDAQ with %d channels %d sampRate',numChans,sampRate)
inputRanges

[ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile);
ai
recordingFile
set(ai)
get(ai)
get(ai,'Channel')
daqhwinfo(ai)
chans
set(chans(1))
get(chans(1))
start(ai);

end

function ai = stopNidaq(ai)
stop(ai);
delete(ai);
% clear ai;
ai=[];
end
