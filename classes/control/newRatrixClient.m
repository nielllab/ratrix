function ratrixClient

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup

addpath(RemoveSVNPaths(genpath(fileparts(mfilename('fullpath')))));

clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model

serverAddresses={'132.239.158.169'};
serverUpSinceTStr=[];
serverConnected=false;
currentServer=[];

doDelete=false;

serverState.serverStarted=[2007,10,31,11,1,12.515];
serverState.serialPortErrors=0;
serverState.valveErrors=0;
serverState.healedCxnFailures=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% begin setting up UI

units='pixels';

f = figure('Visible','off','MenuBar','none','Name','ratrix control','NumberTitle','off','CloseRequestFcn',@cleanup,'Units',units,'Position',[100 200 900 800]);
    function cleanup(src,evt)
        if get(autoUpdateB,'Value')
            doDelete=true;
        else
            closereq;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main controls

serverC = uicontrol('Style','popupmenu', 'String',serverAddresses, 'Value',1,'Units',units,'Callback',{@serverC_Callback});
    function serverC_Callback(source,eventdata)
        serverConnected=~serverConnected;
        updateUI();
    end
    function updateUI()
        if doDelete
            closereq;
            return
        elseif serverConnected
            currentServer=serverAddresses{get(serverC,'Value')};
            upSince=etime(clock,serverState.serverStarted);
            days=floor(upSince/60/60/24);
            hrs=floor((upSince-days*24*60*60)/60/60);
            mins=floor((upSince-days*24*60*60-hrs*60*60)/60);
            secs=floor(upSince-days*24*60*60-hrs*60*60-mins*60);
            serverUpSinceTStr=sprintf('up time %d:%d:%02d:%02d (errors: %d serial, %d valve, %d cXn)',days,hrs,mins,secs,serverState.serialPortErrors,serverState.valveErrors,serverState.healedCxnFailures);
            set(serverUpSinceT,'ForegroundColor',[0 0 0]);

            switch get(tabC,'Value');
                case 1
                    set(stationControlInspectorP,'Visible','on');
                    set(analysisInspectorP,'Visible','off');
                case 2
                    set(stationControlInspectorP,'Visible','off');
                    set(analysisInspectorP,'Visible','on');
                otherwise
                    error('unknonwn value from tab control')
            end
        else
            currentServer=[];
            serverUpSinceTStr='server not connected';
            set(serverUpSinceT,'ForegroundColor',[1 0 0]);

            set(stationControlInspectorP,'Visible','off');
            set(analysisInspectorP,'Visible','off');
            set(tabC,'Value',1);
        end
        set(serverUpSinceT,'String',serverUpSinceTStr);
        drawnow;
    end

serverUpSinceT=uicontrol('Style','text','HorizontalAlignment','Left','String',serverUpSinceTStr,'ForegroundColor',[1 0 0],'Units',units);
serverCycleB=uicontrol('Style','pushbutton','String','cycle','Units',units);

autoUpdateB=uicontrol('Style','togglebutton','String','auto','Units',units,'Callback',{@autoUpdateB_Callback});
    function autoUpdateB_Callback(source,eventdata)
        if get(autoUpdateB,'Value')
            runAutoUpdates();
        end
    end
    function runAutoUpdates
        autoUpdateInterval=1;
        while ~doDelete && get(autoUpdateB,'Value')
            updateUI();
            WaitSecs(autoUpdateInterval);
        end
        updateUI();
    end

tabC = uicontrol('Style','popupmenu','String',{'station control','analysis'},'Value',1,'Units',units,'Callback',{@tabC_Callback});
    function tabC_Callback(source,eventdata)
        updateUI();
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inspectors

stationControlInspectorP=uipanel('Visible','off','Title','station control','ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'BorderType','line','Units',units);
analysisInspectorP=uipanel('Visible','off','Title','analysis','ForegroundColor',[1 1 1],'BackgroundColor',[0 0 0],'BorderType','line','Units',units);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constants

dropDownWidth=150;
buttonWidth=50;
rowHeight=40;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% station control layout

%col 2 stretches
stationControlInspector_col_ks = [ 1  0   1  ];
stationControlInspector_col_ds = [...
    dropDownWidth 100 buttonWidth;  %defaults
    dropDownWidth 100 buttonWidth;  %mins
    dropDownWidth inf buttonWidth]; %maxes

%row 3 stretches
stationControlInspector_row_ks = [ 1  1 0 ];
stationControlInspector_row_ds = [...
    rowHeight rowHeight 200;    %defaults
    rowHeight rowHeight 200;    %mins
    rowHeight rowHeight inf];   %maxes];

stationControlInspectorL = xtargets_springgridlayout(stationControlInspectorP, stationControlInspector_row_ks, stationControlInspector_row_ds, stationControlInspector_col_ks, stationControlInspector_col_ds);

stationControlInspectorC = stationControlInspectorL.create_constraint();

stationControlInspectorC.row=3;
stationControlInspectorC.col=3;
stationControlInspectorL.add(uicontrol('Style','pushbutton','String','cycle','Units',units),stationControlInspectorC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main layout

%col 3 stretches
col_ks = [ 1  1   0   1  1];
col_ds = [...
    dropDownWidth dropDownWidth 100 buttonWidth buttonWidth;    %defaults
    dropDownWidth dropDownWidth 100 buttonWidth buttonWidth;    %mins
    dropDownWidth dropDownWidth inf buttonWidth buttonWidth];   %maxes

%row 2 stretches
row_ks = [ 1   0 ];
row_ds = [...
    rowHeight 200;  %defaults
    rowHeight 200;	%mins
    rowHeight inf];	%maxes];

layout = xtargets_springgridlayout(f, row_ks, row_ds, col_ks, col_ds);

constraint = layout.create_constraint();

%available constraints:
%     c.row = 1;
%     c.col = 1;
%     c.rowspan = 1;
%     c.colspan = 1;
%     c.padding = [0 0 0 0];
%     c.fillx = true;
%     c.filly = true;
%     c.alignx = 'centre'; % 'top' | 'bottom' | 'centre'
%     c.aligny = 'centre'; % 'left' | 'right' | 'centre'

constraint.rowspan = 1;
constraint.colspan = 1;
constraint.padding = 5*ones(1,4);
constraint.fillx = true;
constraint.filly = false;
constraint.alignx = 'left';
constraint.aligny = 'centre';

constraint.col=1;
constraint.row=1;
layout.add(tabC,constraint);

constraint.col=2;
layout.add(serverC,constraint);

constraint.col=3;
constraint.filly = true;
layout.add(serverUpSinceT,constraint);

constraint.col=4;
constraint.filly = false;
layout.add(serverCycleB,constraint);

constraint.col=5;
layout.add(autoUpdateB,constraint);

constraint.col=1;
constraint.row=2;
constraint.filly = true;
constraint.colspan=length(col_ks);
constraint.alignx = 'centre';
layout.add(stationControlInspectorP,constraint);
layout.add(analysisInspectorP,constraint);

updateUI();
set(f,'Visible','on');
end