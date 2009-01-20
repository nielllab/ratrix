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


% =============================================================
% flag for skipping calcplot stuff - if by subject, we already have our assignment picked out
bySubject = false;
% flag for showing test subjects
show_test_subjects=1;

% =============================================================
% set apath to be empty if we have an oracle connection, otherwise use the default standalone path

% 10.3.08 - apath is now subject specific, so initialize to null
apath = fullfile(fileparts(fileparts(getRatrixPath())),'ratrixData','compiledTrialRecords',filesep);
% 12/15/08 - set apath to be the local compiled directory if in standalone mode
% but this will never work here, because we need a dbConn() to do the rest of analysis below....
% hmm...
standAlone = false;
try
    conn=dbConn();
    closeConn(conn);
catch
    disp('no network connection detected - using local compiled directory only');
    apath = fullfile(fileparts(fileparts(getRatrixPath())),'ratrixData','compiledTrialRecords');
    standAlone = true;
    bySubject = true;
end

% =============================================================
% in-line function that is called to initialize data, and also when server is changed
% will not get called in standalone mode
function getStationInfo
    conn=dbConn;
    %s=getStations(conn)
    class(selection.server)
    selection.server
    s=getStationsForServer(conn,selection.server);

    % ====================================
    % 10/3/08 - do some processing here on s, so that we make the row field independent of the rack (for erik's server, we just put the rows one after another)
    racks_used = s{1}.rack_id;
    rows_in_this_rack = s{1}.row;
    row_counter = 1;
%         max_row_so_far = s{1}.row;
    for i=1:length(s)
%             racks_used
%             s{i}.rack_id
        if isempty(find(racks_used == s{i}.rack_id)) % if this rack hasnt been used yet
%                 fprintf('found new rack %d\n', s{i}.rack_id)
            racks_used(end+1) = s{i}.rack_id; 
            rows_in_this_rack(1) = s{i}.row;
            row_counter = row_counter + 1;
        else
            % this rack is already in racks_used
            if isempty(find(rows_in_this_rack == s{i}.row)) % if this row hasnt been seen in this rack, increment row_counter
                rows_in_this_rack(end+1) = s{i}.row;
%                     fprintf('found a new row %d\n', s{i}.row)
                row_counter = row_counter+1;
            else
%                     fprintf('row %d already in rack %d\n', s{i}.row, s{i}.rack_id)
            end
        end
        % now that we have row_counter set properly, assign it
        s{i}.row = row_counter;

    end

    % ====================================


%         for i=1:length(s)
%             row = s{i}.row
%         end
    % ====================================
    stationStrs={'all stations'};
    stationIds=stationStrs;
    numRows=0;
    numCols=0;
    for i=1:length(s)
        %s{i}
        stationStrs{end+1}=['station ' num2str(s{i}.rack_id) s{i}.station_id ' (' s{i}.mac ')'];
        stationIds{end+1}=s{i}.station_id;
        numRows=max(numRows,s{i}.row);
        numCols=max(numCols,s{i}.col);
        %station=getStation(conn,s{i}.rack_id,s{i}.station_id)
        %station=getStationFromMac(conn,s{i}.mac)
    end
    selection.station=stationIds{1};
    closeConn(conn);
end


% =============================================================
% setup UI variables
serverStrs = {};
subjectStrs = {};
remoteSubjectStrs={};
localSubjectStrs={};
s=[];
fs=[];
numRows=0;
numCols=0;
heatStrs={'all heats'};
stationStrs={'all stations'};
%     selection.type='performance';
%     typeStrs={'performance','trials per day','trial rate','bias'};
%     set(typeM,'Value',1);
if ~standAlone
    typeStrs={'all','performance','trials per day','trial rate','weight','bias'};
else
    typeStrs={'performance','trials per day','trial rate','bias'};
end
defaultServerStrIndex = 1;
% gather information from oracle if not in standalone mode
if ~standAlone
    conn=dbConn;
    %rack_ids=[1 2];
    stations=getStations(conn);
    stations=[stations{:}];
    servers = getServers(conn);
    server_ips = {};
    for i=1:length(servers)
        server_ips{end+1} = servers{i}.address;
        serverStrs{end+1} = servers{i}.server_name;
    end
    serverStrs{end+1} = 'by subject'; % added to allow by subject analysis
    bySubjectIndex = length(serverStrs); % this holds the value of the serverM button that points to "by subject"
    selection.server=serverStrs{defaultServerStrIndex};
    lastServer=selection.server;


    % populate subjectStrs
    subjectUINs = {};
    subjects = getAllSubjects(conn);
    for i=1:length(subjects)
        remoteSubjectStrs{end+1}=subjects{i}.subjectID;
        subjectUINs{end+1}=subjects{i}.subject_uin;
    end



    heats=getHeats(conn);
    for i=1:length(heats)
        if ~ismember(heats{i}.name,{'Test','Black'})
            heatStrs{end+1}=heats{i}.name;
        end
    end
    selection.heat=heatStrs{1};
    closeConn(conn);



    selection.station='';
    stationStrs={};
    stationIds={};
    getStationInfo
    subjectStrs=remoteSubjectStrs;
end

% also get info from local ratrixData
serverStrs{end+1}='local';
if isempty(heatStrs)
    heatStrs{end+1}='n/a';
end
if isempty(stationStrs)
    stationStrs{end+1}='n/a';
end
% get subjectStrs from apath
d=dir(apath);
for ind=1:length(d)
    [matches tokens] = regexpi(d(ind).name,'(.*)\.compiledTrialRecords\.\d+-\d+\.mat','match','tokens');
    if ~isempty(matches) && length(tokens{1})==1
        % we found a compiledTrialRecord
        localSubjectStrs{end+1}=tokens{1}{1};
    end
end
% set defaults
if standAlone
    % in standalone mode, set subjectStrs to be local subjects
    subjectStrs=localSubjectStrs;
else
    % reset apath to be empty (after we've used it to initialize localSubjectStrs)
    apath='';
end
bySubjectIndex=length(serverStrs)-1;
localIndex=length(serverStrs);
filterTypeIndex=1;
selection.type=typeStrs{filterTypeIndex};
selection.filterVal=10;
selection.filter='all';
selection.filterParam='days';
if ~isempty(subjectStrs)
    selection.subjects{1,1,1}=subjectStrs{1}; % default to first subject in list
else
    selection.subjects={};
end


% =============================================================
% start drawing UI

oneRowHeight=25;
margin=10;
ddWidth=100;
bWidth=50;
eWidth=50;


fWidth=10*margin+7*ddWidth+eWidth+bWidth;
fHeight=margin+oneRowHeight+margin;
f = figure('Visible','off','MenuBar','none','Name','ratrix analysis','NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 fWidth fHeight]);

serverM = uicontrol(f,'Style','popupmenu',...
    'String',serverStrs,...
    'Enable','on',...
    'Value',defaultServerStrIndex,'Units','pixels','Position',[margin margin ddWidth oneRowHeight],'Callback',@serverC);
    function serverC(source,eventdata)
        
        % if this is a server, not "by subject"
        if get(serverM,'Value')~=bySubjectIndex && get(serverM,'Value')~=localIndex
            % disable and hide by subject dropdown, enable heatM and stationM
            set(subjectM,'Enable','off','Visible','off');
            set(heatM,'Enable','on','Visible','on');
            set(stationM,'Enable','on','Visible','on');
            set(testM,'Enable','on','Visible','on');
%             set(typeM,'Enable','on');
            bySubject = false;
            
            selection.server=serverStrs{get(serverM,'Value')};
    %         if selection.server~=lastServer
            if ~strcmp(selection.server, lastServer)
                getStationInfo
                set(stationM ,'String',stationStrs,'Value',1)
%                 apath=getCompiledDirForServer(selection.server); %10/3/08 - apath is now subject-specific, so useless to set here

                lastServer=selection.server;
            end
            
            % reset apath to be empty (so retrieve from oracle)
            apath='';
        else
            % this is "by subject"
            % update UI to show subject dropdown
            set(subjectM,'Enable','on','Visible','on');
            set(heatM,'Enable','off','Visible','off');
            set(stationM,'Enable','off','Visible','off');
            set(testM,'Enable','off','Visible','off');
            numRows=0;
            numCols=0;
            set(typeM,'Value',1);
            bySubject = true;
            set(subjectM,'Value',1);
            
            % if this is bySubject
            if get(serverM,'Value')==bySubjectIndex
                typeStrs={'all','performance','trials per day','trial rate','weight','bias'};
                set(subjectM,'String',remoteSubjectStrs);
                apath='';
            else % this is local
                typeStrs={'performance','trials per day','trial rate','bias'};
                set(subjectM,'String',localSubjectStrs);
                selection.subjects={};
                selection.subjects{1,1,1}=localSubjectStrs{get(subjectM,'Value')};
                apath=fullfile(fileparts(fileparts(getRatrixPath())),'ratrixData','compiledTrialRecords');
            end
            set(typeM,'String',typeStrs);
            set(typeM,'Value',1);
            selection.type=typeStrs{get(typeM,'Value')};
        end
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

heatM = uicontrol(f,'Style','popupmenu',...
    'String',heatStrs,...
    'Value',1,'Units','pixels','Position',[2*margin+ddWidth margin ddWidth oneRowHeight],'Callback',@heatC);
    function heatC(source,eventdata)
        selection.heat=heatStrs{get(heatM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

stationM = uicontrol(f,'Style','popupmenu',...
    'String',stationStrs,...
    'Value',1,'Units','pixels','Position',[3*margin+2*ddWidth margin ddWidth oneRowHeight],'Callback',@stationC);
    function stationC(source,eventdata)
        selection.station=stationIds{get(stationM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

% subjectM = uicontrol(f,'Style','popupmenu',...
%     'String',subjectStrs,...
%     'Value',1,'Units','pixels','Position',[4*margin+3*ddWidth margin ddWidth oneRowHeight],'Callback',@subjectC);
%     function subjectC(source,eventdata)
%     end

% ========================================================================================
% added 10/3/08
subjectM = uicontrol(f,'Style','popupmenu',...
    'String',subjectStrs,'Enable','off','Visible','off',...
    'Value',1,'Units','pixels','Position',[2*margin+ddWidth margin ddWidth oneRowHeight],'Callback',@subjectC);
    function subjectC(source,eventdata)
        % update selection.subjects to include this one subject
        selection.subjects={};
        if get(serverM,'Value')==localIndex
            selection.subjects{1,1,1}=localSubjectStrs{get(subjectM,'Value')};
            selection.titles{1,1,1}=localSubjectStrs{get(subjectM,'Value')};
        else
            selection.subjects{1,1,1}=subjectStrs{get(subjectM,'Value')};
            selection.titles{1,1,1}=subjectStrs{get(subjectM,'Value')};
        end
    end

% ========================================================================================
% added 12/4/08
% whether or not to show test subjects
testM = uicontrol(f,'Style','checkbox',...
    'String','show test rats','Enable','on','Visible','on',...
    'Value',1,'Units','pixels','Position',[4*margin+3*ddWidth margin ddWidth oneRowHeight],'Callback',@testC);
    function testC(source,eventdata)
        show_test_subjects=get(testM,'Value');
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

% ========================================================================================

typeM = uicontrol(f,'Style','popupmenu',...
    'String',typeStrs,...
    'Value',filterTypeIndex,'Units','pixels','Position',[5*margin+4*ddWidth margin ddWidth oneRowHeight],'Callback',@typeC);
    function typeC(source,eventdata)
        selection.type=typeStrs{get(typeM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

filterM = uicontrol(f,'Style','popupmenu',...
    'String',{'all','first','last'},...
    'Value',1,'Units','pixels','Position',[6*margin+5*ddWidth margin ddWidth oneRowHeight],'Callback',@filterC);
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
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

filterE = uicontrol(f,'Style','edit','String',num2str(selection.filterVal),'Units','pixels','Enable','off','Position',[7*margin+6*ddWidth margin eWidth oneRowHeight],'Callback',@startC);
    function startC(source,eventdata)
        newFilterVal=str2num(get(filterE,'String'));
        if ~isempty(newFilterVal) && isNearInteger(newFilterVal) && newFilterVal>0
            selection.filterVal=uint32(newFilterVal);
        else
            set(filterE,'String',selection.filterVal);
        end
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end

filterParamM = uicontrol(f,'Style','popupmenu',...
    'String',{'days','trials'},...
    'Value',1,'Units','pixels','Enable','off','Position',[8*margin+6*ddWidth+eWidth margin ddWidth oneRowHeight],'Callback',@filterParamC);
    function filterParamC(source,eventdata)
        strs=get(filterParamM,'String');
        selection.filterParam=strs{get(filterParamM,'Value')};
        selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
    end


plotB=uicontrol(f,'Style','pushbutton','String','plot','Units','pixels','Position',[9*margin+7*ddWidth+eWidth margin bWidth oneRowHeight],'Callback',@buttonC);
    function buttonC(source,eventdata)
        for i=1:length(fs)
            figure(fs(i))
            close(fs(i));
        end
        fs=analysisPlotter(selection,apath,false);
    end

% 12/17/08 - setup UI properly if in standalone mode (disable heat/station selection, enable subject selection)
if standAlone
    set(subjectM,'Enable','on','Visible','on');
    set(heatM,'Enable','off','Visible','off');
    set(stationM,'Enable','off','Visible','off');
    set(testM,'Enable','off','Visible','off');
    bySubject = true;
end


%align([rackM heatM stationM subjectM typeM plotB],'Fixed',margin,'Middle');
set(f,'Visible','on')
selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects);
end

    function out=getRow(s,assign)

        done=false;
        for i=1:length(s)
            if strcmp(s{i}.station_id,assign.station_id) && s{i}.rack_id == assign.rack_id
                if done
                    s{i}
                    assign
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
            if strcmp(s{i}.station_id,assign.station_id) && s{i}.rack_id == assign.rack_id
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

function selection=calcplot(selection,heatStrs,numRows,numCols,s,bySubject,show_test_subjects)


% if by subject, all you need to do is assign the title (subjects is already assigned)
if bySubject
    selection.titles = {[selection.subjects{1,1,1}]};
else
% not by subject - do the usual
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
            selection.titles={['station ' selection.station ': all heats']};
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
                assignments=getAssignmentsForServer(conn,selection.server,heatStrs{i},show_test_subjects);
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
        assignments=getAssignmentsForServer(conn,selection.server,selection.heat,show_test_subjects);

        if strcmp(selection.station,'all stations') %specific heat, all stations
            %selection.subjects={};
            selection.titles={[selection.heat ' heat: all stations']};
            for j=1:length(assignments)
                selection.subjects{1,getRow(s,assignments{j}),getCol(s,assignments{j})}=assignments{j}.subject_id;
            end

        else %specific heat, specific station

            done=false;
            selection.titles={['station ' selection.station ': ' selection.heat ' heat']};
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

end % end function




