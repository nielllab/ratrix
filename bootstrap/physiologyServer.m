function physiologyServer()

% 2/2/09 - start the event GUI now - we have to do it locally so that the data is within the scope of this daemon
% so that datanet can request a trial's worth of events
events_data=[];
eventsToSendIndex=1;

f2=[];
a2=[];

% ========================================================================================
% size of the GUI - parameters
oneRowHeight=25;
margin=10;
fieldWidth=100;
fWidth=2*margin+9*fieldWidth;
fHeight=margin+20*oneRowHeight+margin;

% ========================================================================================
% lists of values for settings
ratIDStrs={'demo1','test1'};
experimenterStrs={'eflister','pmeier'};
electrodeMakeStrs={'Maker'};
electrodeModelStrs={'Model'};
lotNumStrs={'lot a', 'lot b'};
IDNumStrs={'id1','id2'};
impedanceStrs={'0.05','0.10'};

eventTypeStrs={'top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell','electrode bend'};
visualHashStrs={'weak','strong'};
snrStrs={};
for i=1:0.5:7
    snrStrs{end+1}=num2str(i);
end
vcTypeStrs={'on','off','unsure'};
vcEyeStrs={'ipsi','contra','both'};
vcBurstyStrs={'yes','no'};
vcRFAzimuthStrs={};
for i=-90:5:180
    vcRFAzimuthStrs{end+1}=num2str(i);
end
vcRFElevationStrs={};
for i=-90:5:180
    vcRFElevationStrs{end+1}=num2str(i);
end
    
defaultIndex=1;
visualHashIndex=7;
cellIndices=[3 4 8];
vcIndex=8;


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
        closereq;
        return;
    end % end cleanup function

    function updateDisplay()
        numToShow=length(events_data);
        toShow=events_data(end-numToShow+1:end);
        dispStr='';
        lastP=0;
        lastPosition=[0 0 0];
        newP=true;
        for i=length(toShow):-1:1
            %         for i=1:length(toShow)
            % if this was a new penetration, get duration of previous
            if toShow(i).penetrationNum~=lastP
                if lastP~=0
                    % get the duration between the last event of lastP and the first event of lastP
                    % or should it be (now - firstEventOfLastP)?
                    lastPduration=events_data(find([events_data.penetrationNum]==lastP,1,'first')).time - ...
                        events_data(find([events_data.penetrationNum]==toShow(i).penetrationNum,1,'first')).time;
                    %                     lastP
%                     [events_data.penetrationNum]
                    %                     i
                    %                     toShow
                    %                     find([events_data.penetrationNum]==lastP)
                    %                 lastPduration=events_data(find([events_data.penetrationNum]==lastP,1,'last')).time - ...
                    %                     events_data(find([events_data.penetrationNum]==lastP,1,'first')).time;
                    durStr=sprintf('%sh %smin', datestr(lastPduration,'HH'), datestr(lastPduration,'MM'));
                    appnd = sprintf('\nlast penetration duration: %s\n',durStr);
                    dispStr=[dispStr appnd];
                end
                % write new penetration #, anchor, and top
                appnd = sprintf('Penetration #%d:\n\tAP\tML\tZ\nAnchor\t%.2f\t%.2f\t%.2f\nTop\t%.2f\t%.2f\t%.2f\n', toShow(i).penetrationNum,...
                    toShow(i).surgeryAnchor, toShow(i).surgeryBregma);
                dispStr=[dispStr appnd];
                newP=true;
            end
            % write this event
            appnd = sprintf('%s\t',datestr(toShow(i).time,'HH:MM'));
            dispStr=[dispStr appnd];
            % display AP and ML coordinates if they are diff from last, or if new penetration
            for j=1:2
                if toShow(i).position(j)~=lastPosition(j) || newP
                    appnd = sprintf('%.2f\t',toShow(i).position(j));
                else
                    appnd = sprintf('\t');
                end
                dispStr=[dispStr appnd];
            end
            % display Z coord and comment
            appnd = sprintf('%.2f\t%s\n',toShow(i).position(3),toShow(i).comment);
            dispStr=[dispStr appnd];
            % update lastP
            lastP=toShow(i).penetrationNum;
            lastPosition=toShow(i).position;
            newP=false;
        end

        % now update the recentEventsDisplay
        set(recentEventsDisplay,'String',dispStr);
        % quick plot events
        vhToPlot=strcmp({events_data.eventType},'visual hash');
        vcToPlot=strcmp({events_data.eventType},'visual cell');
        vhp=vertcat(events_data(vhToPlot).position);
        vcp=vertcat(events_data(vcToPlot).position);
        if ~exist('f2','var') || isempty(f2)
            f2=figure('Name','physiology events quick plot','NumberTitle','off');
        end
        if ~exist('a2','var') || isempty(a2)
            a2=axes;
        end
        
        set(0,'CurrentFigure',f2)
        set(f2,'CurrentAxes',a2)
        hold off
        if ~isempty(vhp)
            plot3(a2,vhp(:,1),vhp(:,2),vhp(:,3),'.');
        end
        hold on
        if ~isempty(vcp)
            plot3(a2,vcp(:,1),vcp(:,2),vcp(:,3),'.r');
        end
        hold off
        xlabel('x position');
        ylabel('y position');
        zlabel('z position');
        grid on;
    end % end updateDisplay function

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
ratIDLabel = uicontrol(f,'Style','text','String','Rat ID','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-1*oneRowHeight-margin fieldWidth oneRowHeight]);
experimenterLabel = uicontrol(f,'Style','text','String','Experimenter','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeMakeLabel = uicontrol(f,'Style','text','String','electrode make','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeModelLabel = uicontrol(f,'Style','text','String','electrode model','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
lotNumLabel = uicontrol(f,'Style','text','String','lot #','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight]);
IDNumLabel = uicontrol(f,'Style','text','String','ID #','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight]);
impedanceLabel = uicontrol(f,'Style','text','String','impedance','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+7*fieldWidth fHeight-7*oneRowHeight-margin fieldWidth oneRowHeight]);

ratIDField = uicontrol(f,'Style','popupmenu','String',ratIDStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-1*oneRowHeight-margin fieldWidth oneRowHeight]);
experimenterField = uicontrol(f,'Style','popupmenu','String',experimenterStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeMakeField = uicontrol(f,'Style','popupmenu','String',electrodeMakeStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
electrodeModelField = uicontrol(f,'Style','popupmenu','String',electrodeModelStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-4*oneRowHeight-margin fieldWidth oneRowHeight]);
lotNumField = uicontrol(f,'Style','popupmenu','String',lotNumStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-5*oneRowHeight-margin fieldWidth oneRowHeight]);
IDNumField = uicontrol(f,'Style','popupmenu','String',IDNumStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-6*oneRowHeight-margin fieldWidth oneRowHeight]);
impedanceField = uicontrol(f,'Style','popupmenu','String',impedanceStrs,'Units','pixels','Value',defaultIndex,...
    'Enable','on','Position',[margin+8*fieldWidth fHeight-7*oneRowHeight-margin fieldWidth oneRowHeight]);

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

% ========================================================================================
% current event parameters - dropdown menus
eventTypeMenu = uicontrol(f,'Style','popupmenu','String',eventTypeStrs,'Visible','on','Units','pixels',...
    'Enable','on','Value',defaultIndex,'Callback',@eventTypeC,...
    'Position',[margin+0*fieldWidth fHeight-9*oneRowHeight-margin fieldWidth oneRowHeight]);
    function eventTypeC(source,eventdata)
        if get(eventTypeMenu,'Value')==visualHashIndex
            set(visualHashLabel,'Visible','on');
            set(visualHashMenu,'Visible','on','Enable','on');
            set(snrLabel,'Visible','off');
            set(snrMenu,'Visible','off','Enable','off');
            set(vcTypeLabel,'Visible','off');
            set(vcEyeLabel,'Visible','off');
            set(vcBurstyLabel,'Visible','off');
            set(vcRFAzimuthLabel,'Visible','off');
            set(vcRFElevationLabel,'Visible','off');
            set(vcTypeMenu,'Visible','off','Enable','off');
            set(vcEyeMenu,'Visible','off','Enable','off');
            set(vcBurstyMenu,'Visible','off','Enable','off');
            set(vcRFAzimuthMenu,'Visible','off','Enable','off');
            set(vcRFElevationMenu,'Visible','off','Enable','off');
        elseif any(cellIndices==get(eventTypeMenu,'Value'))
            set(snrLabel,'Visible','on');
            set(snrMenu,'Visible','on','Enable','on');
            if get(eventTypeMenu,'Value')==vcIndex
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
            else
                set(vcTypeLabel,'Visible','off');
                set(vcEyeLabel,'Visible','off');
                set(vcBurstyLabel,'Visible','off');
                set(vcRFAzimuthLabel,'Visible','off');
                set(vcRFElevationLabel,'Visible','off');
                set(vcTypeMenu,'Visible','off','Enable','off');
                set(vcEyeMenu,'Visible','off','Enable','off');
                set(vcBurstyMenu,'Visible','off','Enable','off');
                set(vcRFAzimuthMenu,'Visible','off','Enable','off');
                set(vcRFElevationMenu,'Visible','off','Enable','off');
            end
            set(visualHashLabel,'Visible','off');
            set(visualHashMenu,'Visible','off','Enable','off');
        else
            set(visualHashLabel,'Visible','off');
            set(visualHashMenu,'Visible','off','Enable','off');
            set(snrLabel,'Visible','off');
            set(snrMenu,'Visible','off','Enable','off');
            set(vcTypeLabel,'Visible','off');
            set(vcEyeLabel,'Visible','off');
            set(vcBurstyLabel,'Visible','off');
            set(vcRFAzimuthLabel,'Visible','off');
            set(vcRFElevationLabel,'Visible','off');
            set(vcTypeMenu,'Visible','off','Enable','off');
            set(vcEyeMenu,'Visible','off','Enable','off');
            set(vcBurstyMenu,'Visible','off','Enable','off');
            set(vcRFAzimuthMenu,'Visible','off','Enable','off');
            set(vcRFElevationMenu,'Visible','off','Enable','off');
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
        % make a new entry in events
        events_data(end+1).time=now;
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
            otherwise
                % nothing
        end
        events_data(end).eventParams=eventParams;
        events_data(end).comment=get(currentComment,'String');       
        
        % update pNum if necessary (if AP or ML differ from last)
        if (length(events_data)>=2 && any(events_data(end-1).position(1:2)~=events_data(end).position(1:2))) ...
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
                events_data(end).penetrationNum=events_data(end-1).penetrationNum+1;
            end
        else
            events_data(end).penetrationNum=events_data(end-1).penetrationNum;
            events_data(end).penetrationParams=[];
        end
        
        updateDisplay();
        % flush the comments buffer
        set(currentComment,'String','');
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
% save events button
saveEventsSubmit = uicontrol(f,'Style','pushbutton','String','save events','Visible','on','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','center','CallBack',@saveEvents, ...
    'Position',[2*margin+8*fieldWidth fHeight-19*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function saveEvents(source,eventdata)
        [saveFilename,savePathname] = uiputfile('*.mat','Save Events As');
        if ischar(saveFilename) && ischar(savePathname)
            save(fullfile(savePathname,saveFilename),'events_data');
%         else % 0
%             disp('user canceled save');
        end
    end

% ========================================================================================
% display box
recentEventsDisplay = uicontrol(f,'Style','edit','String','recent events','Visible','on','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','left','Max',2,'Min',0, ...
    'Position',[margin+0*fieldWidth fHeight-19*oneRowHeight-1*margin fieldWidth*8-margin oneRowHeight*8]);

% ========================================================================================
% turn on the GUI
set(f,'Visible','on');

end
