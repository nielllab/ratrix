% compile with mcc -a 'C:\Documents and Settings\rlab\Desktop\ratrix\db\classes12_g.jar' -m -I 'C:\Documents and Settings\rlab\Desktop\ratrix\db' analysis.m

function analysis
if ~isdeployed
[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(pathstr)),'bootstrap'))
%addpath('C:\Documents and Settings\rlab\Desktop\phil analysys')
end

clc
clear classes
clear java
clear mex
close all
format long g

if ~isdeployed
warning('off','MATLAB:dispatcher:nameConflict')
addpath(RemoveSVNPaths(genpath(getRatrixPath)));
warning('on','MATLAB:dispatcher:nameConflict')
end

if isdeployed
    javaaddpath('analysis_mcr/Documents and Settings/rlab/Desktop/ratrix/db/classes12_g.jar')
end
conn=dbConn;

%rack_ids=[1 2];

stations=getStations(conn);
stations=[stations{:}];
rack_ids=unique([stations.rack_id]);

rackStrs={};
defaultRackStrIndex=1;
for i=1:length(rack_ids)
    rackStrs{end+1}=['rack ' num2str(rack_ids(i))];
end



selection.rack=rack_ids(defaultRackStrIndex);
apath=getCompiledDirForRack(selection.rack);
lastRack=-1;
fs=[];

heats=getHeats(conn);
heatStrs={'all heats'};
for i=1:length(heats)
    if ~ismember(heats{i}.name,{'Test','Black'})
        heatStrs{end+1}=heats{i}.name;
    end
end
selection.heat=heatStrs{1};
closeConn(conn);


typeStrs={'all','performance','trials per day','trial rate','weight','bias'};
filterTypeIndex=2;
selection.type=typeStrs{filterTypeIndex};
selection.filterVal=10;
selection.filter='all';
selection.filterParam='days';



selection.station='';
stationStrs={};
stationIds={};
numRows=0;
numCols=0;
getStationInfo
    function getStationInfo
        conn=dbConn;
        %s=getStations(conn)
        s=getStationsOnRack(conn,selection.rack);
        stationStrs={'all stations'};
        stationIds=stationStrs;
        numRows=0;
        numCols=0;
        for i=1:length(s)
            %s{i}
            stationStrs{end+1}=['station ' num2str(selection.rack) s{i}.station_id ' (' s{i}.mac ')'];
            stationIds{end+1}=s{i}.station_id;
            numRows=max(numRows,s{i}.row);
            numCols=max(numCols,s{i}.col);
            %station=getStation(conn,s{i}.rack_id,s{i}.station_id)
            %station=getStationFromMac(conn,s{i}.mac)
        end
        selection.station=stationIds{1};
        closeConn(conn);
    end




oneRowHeight=25;
margin=10;
ddWidth=100;
bWidth=50;
eWidth=50;


fWidth=9*margin+6*ddWidth+eWidth+bWidth;
fHeight=margin+oneRowHeight+margin;
f = figure('Visible','off','MenuBar','none','Name','ratrix analysis','NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 fWidth fHeight]);

rackM = uicontrol(f,'Style','popupmenu',...
    'String',rackStrs,...
    'Enable','on',...
    'Value',defaultRackStrIndex,'Units','pixels','Position',[margin margin ddWidth oneRowHeight],'Callback',@rackC);
    function rackC(source,eventdata)
        selection.rack=rack_ids(get(rackM,'Value'));
        if selection.rack~=lastRack
            getStationInfo
            set(stationM ,'String',stationStrs,'Value',1)
            apath=getCompiledDirForRack(selection.rack);

            lastRack=selection.rack;
        end

        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

heatM = uicontrol(f,'Style','popupmenu',...
    'String',heatStrs,...
    'Value',1,'Units','pixels','Position',[2*margin+ddWidth margin ddWidth oneRowHeight],'Callback',@heatC);
    function heatC(source,eventdata)
        selection.heat=heatStrs{get(heatM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

stationM = uicontrol(f,'Style','popupmenu',...
    'String',stationStrs,...
    'Value',1,'Units','pixels','Position',[3*margin+2*ddWidth margin ddWidth oneRowHeight],'Callback',@stationC);
    function stationC(source,eventdata)
        selection.station=stationIds{get(stationM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

% subjectM = uicontrol(f,'Style','popupmenu',...
%     'String',subjectStrs,...
%     'Value',1,'Units','pixels','Position',[4*margin+3*ddWidth margin ddWidth oneRowHeight],'Callback',@subjectC);
%     function subjectC(source,eventdata)
%     end




typeM = uicontrol(f,'Style','popupmenu',...
    'String',typeStrs,...
    'Value',filterTypeIndex,'Units','pixels','Position',[4*margin+3*ddWidth margin ddWidth oneRowHeight],'Callback',@typeC);
    function typeC(source,eventdata)
        selection.type=typeStrs{get(typeM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

filterM = uicontrol(f,'Style','popupmenu',...
    'String',{'all','first','last'},...
    'Value',1,'Units','pixels','Position',[5*margin+4*ddWidth margin ddWidth oneRowHeight],'Callback',@filterC);
    function filterC(source,eventdata)
        strs=get(filterM,'String');
        selection.filter=strs{get(filterM,'Value')};
        switch get(filterM,'Value')
            case 1
                set(filterE,'Enable','off');
                set(filterParamM,'Enable','off');
            case {2,3}
                set(filterE,'Enable','on');
                set(filterParamM,'Enable','on');
            otherwise
                error('weird')
        end
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

filterE = uicontrol(f,'Style','edit','String',num2str(selection.filterVal),'Units','pixels','Enable','off','Position',[6*margin+5*ddWidth margin eWidth oneRowHeight],'Callback',@startC);
    function startC(source,eventdata)
        newFilterVal=str2num(get(filterE,'String'));
        if ~isempty(newFilterVal) && isNearInteger(newFilterVal) && newFilterVal>0
            selection.filterVal=uint32(newFilterVal);
        else
            set(filterE,'String',selection.filterVal);
        end
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end

filterParamM = uicontrol(f,'Style','popupmenu',...
    'String',{'days','trials'},...
    'Value',1,'Units','pixels','Enable','off','Position',[7*margin+5*ddWidth+eWidth margin ddWidth oneRowHeight],'Callback',@filterParamC);
    function filterParamC(source,eventdata)
        strs=get(filterParamM,'String');
        selection.filterParam=strs{get(filterParamM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s);
    end


plotB=uicontrol(f,'Style','pushbutton','String','plot','Units','pixels','Position',[8*margin+6*ddWidth+eWidth margin bWidth oneRowHeight],'Callback',@buttonC);
    function buttonC(source,eventdata)
        for i=1:length(fs)
            figure(fs(i))
            close(fs(i));
        end
        fs=analysisPlotter(selection,apath,false);
    end



%align([rackM heatM stationM subjectM typeM plotB],'Fixed',margin,'Middle');
set(f,'Visible','on')
selection=calcplot(selection,heatStrs,numRows,numCols,s);
end

    function out=getRow(s,assign)

        done=false;
        for i=1:length(s)
            if strcmp(s{i}.station_id,assign.station_id)
                if done
                    error('found multiple stations for that id')
                end
                out=s{i}.row;
                done=true;
            end
        end
        if ~done
            error('didn''t find station for that id')
        end

    end

    function out=getCol(s,assign)

        done=false;
        for i=1:length(s)
            if strcmp(s{i}.station_id,assign.station_id)
                if done
                    error('found multiple stations for that id')
                end
                out=s{i}.col;
                done=true;
            end
        end
        if ~done
            error('didn''t find station for that id')
        end
    end

function selection=calcplot(selection,heatStrs,numRows,numCols,s)
conn=dbConn;

selection.subjects={};
selection.titles={};

if strcmp(selection.heat,'all heats')

    if strcmp(selection.station,'all stations')

        for k=1:length(heatStrs)-1
            for i=1:numRows
                for j=1:numCols
                    selection.subjects{k,i,j}={};
                end
            end
        end
    else
        selection.titles={['station ' num2str(selection.rack) selection.station ': all heats']};
        for i=1:ceil(sqrt(length(heatStrs)-1))
            for j=1:ceil((length(heatStrs)-1)/ceil(sqrt(length(heatStrs)-1)))
                selection.subjects{1,i,j}={};
            end
        end
    end

    for i=1:length(heatStrs)
        if ~strcmp(heatStrs{i},'all heats')
            if strcmp(selection.station,'all stations')
                selection.titles{end+1}=[heatStrs{i} ' heat'];
            end
            assignments=getAssignments(conn,selection.rack,heatStrs{i});
            for j=1:length(assignments)
                if strcmp(selection.station,'all stations') %all heats, all stations
                    selection.subjects{i-1,getRow(s,assignments{j}),getCol(s,assignments{j})}=assignments{j}.subject_id;
                    %fprintf('%s %s %d %d\n',heatStrs{i},assignments{j}.subject_id,getRow(s,assignments{j}),getCol(s,assignments{j}))
                else %specific station, all heats
                    if strcmp(assignments{j}.station_id,selection.station)
                        selection.subjects{i-1}=assignments{j}.subject_id;
                    end
                end
            end
        end
    end
else
    assignments=getAssignments(conn,selection.rack,selection.heat);

    if strcmp(selection.station,'all stations') %specific heat, all stations
        %selection.subjects={};
        selection.titles={[selection.heat ' heat: all stations']};
        for j=1:length(assignments)
            selection.subjects{1,getRow(s,assignments{j}),getCol(s,assignments{j})}=assignments{j}.subject_id;
        end

    else %specific heat, specific station

        done=false;
        selection.titles={['station ' num2str(selection.rack) selection.station ': ' selection.heat ' heat']};
        for j=1:length(assignments)

            if strcmp(assignments{j}.station_id,selection.station)
                if done
                    error('found multiple subjects for that station and heat')
                end
                selection.subjects{1,1,1}=assignments{j}.subject_id;
                done=true;
            end
        end
        if ~done
            warning('couldn''t find subject for that station and heat')
        end

    end
end

closeConn(conn);
selection
permute(selection.subjects,[2 3 1])
end
