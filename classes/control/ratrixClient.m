function ratrixClient

clear all
close all
clc

fWidth=1000;
fHeight=900;
f = figure('Visible','off','MenuBar','none','Name','ratrix control','NumberTitle','off','Resize','off','CloseRequestFcn',@cleanup,'Units','pixels','Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt)
        src
        evt
        'all done'
        closereq
    end

margin=5;
oneRowHeight=23;

serverAddresses={'132.239.158.169'};
serverTStr='server:';
serverUpSinceTStr='up since: days:hrs:mins:secs (18 serial port errors, 77 valve errors, 12 healed connection failures)';

shortTWidth=50;
ddWidth=150;
longTWidth=600;
bWidth=75;

serverPBottom=fHeight-2*oneRowHeight-3*margin;
serverP = uipanel(f,'Title','server',...
    'BorderType','line',...
    'Units','pixels','Position',[margin serverPBottom fWidth-2*margin 2*oneRowHeight+2*margin]);
serverT = uicontrol(serverP,'Style','text','HorizontalAlignment','Left',...
    'String',serverTStr,'Units','pixels','Position',[margin margin shortTWidth oneRowHeight/2]);
serverC = uicontrol(serverP,'Style','popupmenu',...
    'String',serverAddresses,...
    'Value',1,'Units','pixels','Position',[2*margin+shortTWidth margin ddWidth oneRowHeight]);
serverUpSinceT=uicontrol(serverP,'Style','text','HorizontalAlignment','Left','String',serverUpSinceTStr,'Units','pixels','Position',[3*margin+shortTWidth+ddWidth margin longTWidth oneRowHeight/2]);
serverCycleB=uicontrol(serverP,'Style','pushbutton','String','cycle','Units','pixels','Position',[4*margin+shortTWidth+ddWidth+longTWidth margin bWidth oneRowHeight]);
align([serverT serverC serverUpSinceT serverCycleB],'Fixed',margin,'Middle');


tabCBottom=serverPBottom-oneRowHeight-margin;
tabC = uicontrol(f,'Style','popupmenu',...
    'String',{'station control','analysis'},...
    'Value',1,'Units','pixels','Position',[margin tabCBottom ddWidth oneRowHeight],...
    'Callback',{@tabC_Callback});
    function tabC_Callback(source,eventdata)
        switch get(source,'Value');
            case 1
                set(controlInspectorP,'Visible','on');
                set(analysisInspectorP,'Visible','off');
            case 2
                set(controlInspectorP,'Visible','off');
                set(analysisInspectorP,'Visible','on');
            otherwise
                error('unknonwn value from tab control')
        end
    end


inspectorWidth=fWidth-2*margin;
inspectorHeight=tabCBottom-margin;
controlInspectorP = uipanel(f,'Title','station control',...
    'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'BorderType','line',...
    'Units','pixels','Position',[margin margin inspectorWidth inspectorHeight]);


heats={'heat 1','heat 2','overnight'}; %need to get from ratrix (which you need to get from server)
heatTStr='heat:';
heatRunningSinceTStr='running since: hrs:mins:secs';

heatPBottom=inspectorHeight-2*oneRowHeight-5*margin;
heatP = uipanel('Parent',controlInspectorP,'Title','heat',...
    'BorderType','line',...
    'Units','Pixels','Position',[margin  heatPBottom inspectorWidth-2*margin 2*oneRowHeight+2*margin]);
heatT = uicontrol(heatP,'Style','text','HorizontalAlignment','Left',...
    'String',heatTStr,'Units','pixels','Position',[margin margin shortTWidth oneRowHeight/2]);
heatC = uicontrol(heatP,'Style','popupmenu',...
    'String',heats,...
    'Value',1,'Callback',{@heatC_Callback},'Units','pixels','Position',[2*margin+shortTWidth margin ddWidth oneRowHeight]);
currHeat=1;
    function heatC_Callback(source,eventdata)
        if get(source,'Value')~=currHeat
            activateStations(false);
            currHeat=get(source,'Value');
        end
    end
heatRunningSinceT = uicontrol(heatP,'Style','text','HorizontalAlignment','Left','String',heatRunningSinceTStr,'Units','pixels','Position',[3*margin+shortTWidth+ddWidth margin longTWidth oneRowHeight/2]);
heatB=uicontrol(heatP,'Style','togglebutton','String','run trials','Units','pixels','Position',[4*margin+shortTWidth+ddWidth+longTWidth margin bWidth oneRowHeight],'Callback',{@heatB_Callback}); %need to get initial state from ratrix/server
align([heatT heatC heatRunningSinceT heatB],'Fixed',margin,'Middle');
    function heatB_Callback(source,eventdata)
        activateStations(get(source,'Value'));
    end

    function activateStation(i,active)
        if i<=0 || i>length(stationStates)
            error('bad station identifier')
        elseif ~strcmp(stationStates{i},'error')
            if strcmp(stationStates{i},'calibrating')
                calibrateStation(i,false);
            end
            if active
                stationStates{i}='active';
            else
                stationStates{i}='inactive';
            end
        end
        updateDisplay();
    end

    function activateStations(active)
        for i=1:length(stationStates)
            switch stationStates{i}
                case {'inactive','active'}
                    activateStation(i,active);
                case {'calibrating','error'}
                otherwise
                    error('bad station state found')
            end
        end
    end

    function calibrateStation(i,active)
        if i<=0 || i>length(stationStates)
            error('bad station identifier')
        elseif ~strcmp(stationStates{i},'error')
            if strcmp(stationStates{i},'active')
                activateStation(i,false);
            end
            if active
                stationStates{i}='calibrating';
            else
                stationStates{i}='inactive';
            end
        end
        updateDisplay();
    end

    function errorStation(i,active)
        if i<=0 || i>length(stationStates)
            error('bad station identifier')
        else
            switch stationStates{i}
                case 'calibrating'
                    calibrateStation(i,false);
                case 'active'
                    activateStation(i,false);
                case {'inactive','error'}
                otherwise
                    error('found bad station state')
            end
            stationStates{i}='error';
        end
        updateDisplay();
    end

    function updateDisplay()
       % set(f,'Visible','off');
        strRunning='stop trials';
        strNotRunning='start trials';
        strCalibrating='stop calibration';
        strNotCalibrating='calibrate';
        for i=1:length(stationStates)
            portBEnable='on';
            actionCEnable='on';
            runStr=strNotRunning;
            calibStr=strNotCalibrating;
            switch stationStates{i}
                case 'inactive'
                    col=stateColors{1};
                case 'active'
                    col=stateColors{2};
                    runStr=strRunning;
                case 'calibrating'
                    col=stateColors{3};
                    calibStr=strCalibrating;
                case 'error'
                    col=stateColors{4};
                    portBEnable='off';
                    actionCEnable='off';
                otherwise
                    error('bad station state found')
            end
            set(stationP(stations(i,1),stations(i,2),stations(i,3)),'BackgroundColor',col);
            set(actionC(stations(i,1),stations(i,2),stations(i,3)),'String',{'actions',runStr,calibStr});
            set(portB(stations(i,1),stations(i,2),stations(i,3),:),'Enable',portBEnable);
            set(actionC(stations(i,1),stations(i,2),stations(i,3)),'Enable',actionCEnable);
        end
        if any(strcmp(stationStates,'active'))
            set(heatB,'Value',true);
            set(heatB,'String',strRunning);
            set(heatRunningSinceT,'String',sprintf('%d of %d stations running (oldest: hh:mm:ss)',sum(strcmp(stationStates,'active')),size(stations,1)));
            set(heatRunningSinceT,'ForegroundColor',[0 0 0]);
        else
            set(heatB,'Value',false);
            set(heatB,'String',strNotRunning);
            set(heatRunningSinceT,'String',sprintf('no stations running'));
            set(heatRunningSinceT,'ForegroundColor',[1 0 0]);
        end
        makeMini(stationStates,stations,stateColors,selectedRack);
       %  set(f,'Visible','on');
    end

stateColors={[.5 .5 .5],[0 1 0],[1 1 0],[1 0 0]};
stations=[1 1 1;1 1 2;1 1 3;1 2 1;1 2 2;1 2 3;2 1 1;2 1 2;2 2 1;2 2 2;2 2 3;2 3 1;2 3 3]; %need to get from ratrix (which you need to get from server)
for i=1:size(stations,1)
    stationStates{i}='inactive'; %any vectorized way to do this?
end
maxes=max(stations);
numRacks=maxes(1);
rackNames={};
rackPHeight=heatPBottom-oneRowHeight-3*margin;
rackPWidth=inspectorWidth-2*margin;
portBWidth=20;
miniSz=30;
selectedRack=1;
for rackNum=1:numRacks
    rackNames{rackNum}=sprintf('rack %d',rackNum);
    rackP(rackNum)=uipanel('Parent',controlInspectorP,'Title',rackNames{rackNum},...
        'ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'BorderType','line',...
        'Units','pixels','Position',[margin margin rackPWidth rackPHeight]);
    if rackNum==selectedRack
        set(rackP(rackNum),'Visible','on');
    else
        set(rackP(rackNum),'Visible','off');
    end


    ha(rackNum) = axes('Parent',controlInspectorP,'Visible','off','Units','pixels','Position',[rackPWidth-(numRacks-rackNum+1)*(margin+miniSz),rackPHeight+margin,miniSz,miniSz]);
    axis(ha(rackNum),'ij');
    axis(ha(rackNum),'equal')

    theseStations=stations(stations(:,1)==rackNum,2:3);
    maxes=max(theseStations);
    stationPHeight=(rackPHeight-margin)/maxes(1)-margin;
    stationPWidth=rackPWidth/maxes(2)-2*margin;
    stationTWidth=stationPWidth-6*margin;
    for row=1:maxes(1)
        for col=1:maxes(2)
            stationMatches=all((theseStations==repmat([row col],size(theseStations,1),1))');
            if any(stationMatches)
                stationInd=find(all((stations==repmat([rackNum row col],size(stations,1),1))'));
                actualStationPHeight=stationPHeight-2*margin;
                outerPPos=[margin+(col-1)*rackPWidth/maxes(2) margin+(maxes(1)-row)*(stationPHeight+margin) stationPWidth actualStationPHeight];
                stationP(rackNum,row,col)=uipanel('Parent',rackP(rackNum),...
                    'Title',sprintf('station %d %d %d',rackNum,row,col),...
                    'BorderType','line',...
                    'Units','pixels','Position',outerPPos);

                innerStationP(rackNum,row,col)=uipanel('Parent',stationP(rackNum,row,col),...
                    'BorderType','line',...
                    'Units','pixels','Position',[margin margin outerPPos(3)-2*margin actualStationPHeight-4*margin]);

                stationStr=sprintf(['%s %s\n'...
                    'session: %d    trial: %d (%s ago)    %d%% correct\n'...
                    'status: %s\n'...
                    'trialManager: %s\n'...
                    'rwd ltncy (sess/since up): %g/%g(avg) %g/%g(90%%)\n',...
                    'since up: %d trials    rewards: %d (%d this session)\n'...
                    '               healed cx: %d    valve errs: %d\n'...
                    'up since: %s'],...
                    'rat',sprintf('%d%d%d',rackNum,row,col),...
                    8,32,'hh:mm:ss',67,...
                    'between sessions',...
                    'cuedOrientedNoise',...
                    5.0,6.7,7.8,9.9,...
                    943,244,9,...
                    17,88,...
                    'dd:hh:mm:ss');
                numLines=10;
                stationTBottom=actualStationPHeight-(numLines/2+1)*oneRowHeight;
                stationT(rackNum,row,col)= uicontrol(innerStationP(rackNum,row,col),'Style','text','HorizontalAlignment','Left','String',stationStr,'Units','pixels','Position',[margin stationTBottom stationTWidth numLines*oneRowHeight/2]);

                numPorts=3; %ask ratrix how many
                for portNum=1:numPorts
                    portB(rackNum,row,col,portNum)=uicontrol(innerStationP(rackNum,row,col),'Style','pushbutton','String',sprintf('%d',portNum),'Units','pixels','Position',[margin*portNum+(portNum-1)*portBWidth stationTBottom-2*margin-oneRowHeight portBWidth oneRowHeight]);
                end
                actionC(rackNum,row,col)=uicontrol(innerStationP(rackNum,row,col),'Style','popupmenu','String',{'actions','start trials','calibrate'},'Value',1,'Callback',{@actionC_Callback stationInd},'Units','pixels','Position',[margin stationTBottom-4*margin-2*oneRowHeight ddWidth oneRowHeight]);
            end
        end
    end
end
    function actionC_Callback(source,eventdata,whichStation)
        switch get(source,'Value')
            case 1
                %nothing
            case 2
                switch stationStates{whichStation}
                    case {'inactive','calibrating'}
                        activateStation(whichStation,true);
                    case 'active'
                        activateStation(whichStation,false);
                    case 'error'
                    otherwise
                        error('found bad station state')
                end
            case 3
                switch stationStates{whichStation}
                    case 'calibrating'
                        calibrateStation(whichStation,false);
                    case {'inactive','active'}
                        calibrateStation(whichStation,true);
                    case 'error'
                    otherwise
                        error('found bad station state')
                end
            otherwise
                error('bad value from action dropdown')
        end
        set(source,'Value',1);
    end

rackC = uicontrol(controlInspectorP,'Style','popupmenu',...
    'String',rackNames,...
    'Value',1,'Units','pixels','Position',[margin rackPHeight+margin ddWidth oneRowHeight],...
    'Callback',{@rackC_Callback});
    function rackC_Callback(source,eventdata)
        setSelectedRack(get(source,'Value'));
    end

    function mini_Callback(source,eventdata,rackNum)
        setSelectedRack(rackNum);
    end

    function setSelectedRack(rackNum)
        selectedRack=rackNum;
        set(rackC,'Value',selectedRack);
        for i=1:numRacks
            if selectedRack==i
                set(rackP(i),'Visible','on');
            else
                set(rackP(i),'Visible','off');
            end
        end
        updateDisplay();
    end

analysisInspectorP = uipanel(f,'Title','analysis',...
    'BorderType','line',...
    'Units','pixels','Position',[margin margin inspectorWidth inspectorHeight],'Visible','off');
analysisB = uicontrol(analysisInspectorP,'String','Push here',...
    'Position',[18 18 72 36]);

errorStation(11,true);
activateStations(false);
set(f,'Visible','on')


    function makeMini(stationStates,stationLocs,stateColors,selectedRack)
        numRacks=max(stationLocs(:,1));

        for i=1:numRacks
            theseStations=stationLocs(stationLocs(:,1)==i,2:3);
            numRows=max(theseStations(:,1));
            numCols=max(theseStations(:,2));

            rackPix=zeros(miniSz,miniSz,3);
            columnBoundaries=floor(linspace(1,miniSz,numCols+1));
            rowBoundaries=floor(linspace(1,miniSz,numRows+1));

            if i==selectedRack
                borderColor=1;
            else
                borderColor=.25;
            end
            rackPix(:,columnBoundaries,:)=borderColor;
            rackPix(rowBoundaries,:,:)=borderColor;

            for j=1:length(stationStates)
                if stationLocs(j,1)==i
                    switch stationStates{j}
                        case 'inactive'
                            col=stateColors{1};
                        case 'active'
                            col=stateColors{2};
                        case 'calibrating'
                            col=stateColors{3};
                        case 'error'
                            col=stateColors{4};
                        otherwise
                    end

                    row=stationLocs(j,2);
                    column=stationLocs(j,3);
                    rows=(rowBoundaries(row)+1):(rowBoundaries(row+1)-1);
                    columns=(columnBoundaries(column)+1):(columnBoundaries(column+1)-1);
                    rackPix(rows,columns,:)=repmat(reshape(col,[1 1 3]),[length(rows) length(columns) 1]);
                end
            end

            image('Parent',ha(i),'CData',rackPix,'ButtonDownFcn',{@mini_Callback,i});
        end
    end

end

% main()
% 	connectToServer(currentServerInDropdown)
% end
% 
% getViewData()
% 	asks server for:
% -time since server running, serial port errors, valve errors, healed connections
% -current ratrix (contains info about stations, subjects, heats, and assignedTrialManagers)
% -if/time since running trials
% -for each station, mini trial records for all trials this session:
% 	-rat contained
% 	-session num
% 	-trialManager class
% 	-reward latencies
% -for each station
% 	-cross-session station records
% 		-time since station was brought up
% 		-latencies, rewards, trials, connection failures, valve errors
% 	-current status
% end
% 
% updateDisplay()
% 	displayData(getViewData(server))
% end
% 
% connectToServer(server)
% attempt to connect to server
% if succeed
% 	updateDisplay()
% else
% 	display server text error in red
% 	keep retrying until succeed or someone picks a different server
% end
% 
% handlers:
% server dropdown:
% switch
% 	case same as before
% 		nothing
% 	case different
% 		connectToServer(selection)
% end