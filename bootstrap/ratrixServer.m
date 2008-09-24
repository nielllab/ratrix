%would like to compile to standalone with:
%mcc -m -I C:\psychtoolbox\Psychtoolbox -I \\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\ -d standalone ratrixServer.m
%but this yields:
%
% ??? Undefined function or method 'FlushEventsNoJVM' for input arguments of type
% 'char'.
%
% Error in ==> FlushEvents at 89
%
% Error in ==> setupEnvironment at 19
%
% Error in ==> ratrixServer at 2
%
% can't see C:\psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR11\FlushEventsNoJVM.dll
% this is removed from path for 2007a installs...
%
%
% i temporarily moved this, then got:
%
% This MATLAB file does not have proper version information and may be corrupt.
% The file
%    '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\getRatrixHeatInfo.m'
%
%    is not in the application's expanded CTF archive at
%     'C:\Documents and Settings\rlab\Desktop\ratrix\bootstrap\standalone\ratrixSe
% rver_mcr'.
% This is typically caused by calls to ADDPATH in your startup.m or matlabrc.m fil
% es. Please see the compiler documentation and use the ISDEPLOYED function to ens
% ure ADDPATH commands are not executed by deployed applications.
% ??? The M-file
%    "\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\getRatrixHeatInfo.m"
%
% cannot be executed.
%
% Error in ==> ratrixServer at 48
%
% MATLAB:err_parse_cannot_run_m_file

function ratrixServer
setupEnvironment;
addJavaComponents();
checkCurrentRevision; % 9/24/08 - check current code version
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

diary off
warning('off','MATLAB:MKDIR:DirectoryExists')
mkdir(fullfile(dataPath,'diaries'))
warning('on','MATLAB:MKDIR:DirectoryExists')
diary([fullfile(dataPath,'diaries') filesep datestr(now,30) '.txt'])

servePump=false;
quit=false;

margin=5;
oneRowHeight=23;
longTWidth=200;
ddWidth=150;
bWidth=75;
miniSz=360;

started=[];
heatUpSinceTStr='';
buttonT='start';

% ===========================================================================================
% These variables control who gets affected by the 'run' function - important!
% rackNum=getRackIDFromIP;
rackNum=1; %garbage variable now (gets reset later)
[server_name myIP] = getServerNameFromIP; %this needs to be determined by a function getServerNameFromIP (based on what this machine's IP is)
if isempty(server_name)
%     server_name='server-02-female-pmm-156'; %only for testing
%     myIP = '132.239.158.156'; % only for testing
    error('could not retreive server uin based on this machines IP');
end


% ===========================================================================================

conn=dbConn;
hts=getHeats(conn);
% ===========================================================================================
% SERVER SUBJECTS
% let this loop get the subjects we care about
for i=1:length(hts)
    heats{i,1}={hts{i}.name [hts{i}.red hts{i}.green hts{i}.blue]};
%     hts{i}.name
    assignments=getAssignmentsForServer(conn,server_name,hts{i}.name);
    coaches = getCoachAssignmentsForServer(conn,server_name,hts{i}.name);
    for j=1:length(assignments)
        stn=getStation(conn,assignments{j}.rack_id,assignments{j}.station_id);
        heats{i,2}{j}={assignments{j}.subject_id ...
            {[stn.row stn.col] stn.mac stn.rack_id} assignments{j}.owner assignments{j}.experiment coaches{j}.coach};
    end
end
% ===========================================================================================
% % loop again through all 3 racks to get greyed-out subjects

% initialize others
other_assignments={};
other_heats={};

% ==========================================================================================
% INCLUDE OTHER SUBJECTS FROM ALL RACKS

% get all server_uins from db that are on 
% uins = cell2mat(getAllServerUINs(conn));
% uins = find(uins~=server_uin); % all OTHER servers (not including THIS one)
% 
% for k=1:length(uins)
%     % for each server, retreive assignments and heats
%     for i=1:length(hts)
%         tempheats{i,1}={hts{i}.name [hts{i}.red hts{i}.green hts{i}.blue]};
%         tempassignments=getAssignmentsForServer(conn,uins(k),hts{i}.name);
%         for j=1:length(tempassignments)
%             stn=getStation(conn,tempassignments{j}.rack_id,tempassignments{j}.station_id);
%             tempheats{i,2}{j}={tempassignments{j}.subject_id {[stn.row stn.col] stn.mac stn.rack_id} tempassignments{j}.owner tempassignments{j}.experiment};
%         end
%     end
%     
%     % vertcat the heats and assignments for this rack
%     other_assignments = vertcat(other_assignments, tempassignments);
%     if size(heats,2) == 2 % if we have assignments for this physical rack, then cat them
%         other_heats = vertcat(other_heats, tempheats); % this is what we want
%     end
%     
% end

% ==========================================================================================
% ONLY INCLUDE OTHER SUBJECTS FROM RACKS BEING USED BY CURRENT SERVER
% get all assignments on any rack being used for heats
rrs = getRacksAndRoomsFromServerName(conn,server_name);
racks_used = zeros(1, size(rrs,1));
rooms_used = cell(1, size(rrs,1));
for i=1:size(rrs,1)
    racks_used(i) = rrs{i}.rackID; % get racks used
    rooms_used{i} = rrs{i}.room; % get rooms used
end
% racks_used = unique(racks_used)
% rooms_used = unique(rooms_used)
% racks_used
% rooms_used

% for each of these racks, get subjects that do not belong to this server
% for k=1:length(racks_used)
%     for i=1:length(hts)
%         tempheats{i,1}={hts{i}.name [hts{i}.red hts{i}.green hts{i}.blue]};
%         tempassignments=getAssignmentsNotOnServer(conn,racks_used(k), hts{i}.name, server_uin);
%         for j=1:length(tempassignments)
%             stn=getStation(conn,tempassignments{j}.rack_id,tempassignments{j}.station_id);
%             tempheats{i,2}{j}={tempassignments{j}.subject_id {[stn.row stn.col] stn.mac stn.rack_id} tempassignments{j}.owner tempassignments{j}.experiment};
%         end
%     end
%     
%     % vertcat the heats and assignments for this rack
%     other_assignments = vertcat(other_assignments, tempassignments);
%     if size(tempheats,2) == 2 % if we have assignments for this physical rack, then cat them
%         other_heats = vertcat(other_heats, tempheats); % this is what we want
%     end
%     
% end

% ==========================================================================================
    
% other_heats
% size(other_heats)
        
closeConn(conn);

subjects={};
heatStrs={};
for i=1:size(heats,1)
    heatStrs{end+1}=heats{i,1}{1};
end

doDelete=false;
running=false;

roomBorderWidth = 25;
fWidth=margin+ddWidth+margin+longTWidth+margin+bWidth+margin;
fWidth2=margin+margin+margin+margin+miniSz*length(racks_used)+roomBorderWidth*2*length(unique(rooms_used));

fWidth=max(fWidth,fWidth2);

fHeight=margin+oneRowHeight+margin+miniSz+margin+roomBorderWidth;
% fHeight=fHeight*2;
f = figure('Visible','off','MenuBar','none','Name',sprintf('ratrix control: %s IP: %s',server_name, myIP),'NumberTitle','off','Resize','off','CloseRequestFcn',@cleanup,'Units','pixels','Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt)
        doDelete=true;
        updateUI;
    end

    function updateUI()
        if doDelete
            if running
                errordlg('must stop running before closing','error','modal')
                doDelete=false;
            else
                ListenChar(0) %'called listenchar(0) -- why doesn''t keyboard work?'
                ShowCursor(0)

                closereq;
                exit
                return
            end
        elseif running
            buttonT='stop';
            upSince=etime(clock,started);
            hrs=floor(upSince/60/60);
            mins=floor((upSince-hrs*60*60)/60);
            secs=floor(upSince-hrs*60*60-mins*60);
            heatUpSinceTStr=sprintf('up time %d:%02d:%02d',hrs,mins,secs);
            set(heatUpSinceT,'ForegroundColor',[0 0 0]);
            set(swapM,'Enable','off')
        else
            buttonT='start';
            heatUpSinceTStr='not running';
            set(heatUpSinceT,'ForegroundColor',[1 0 0]);
            set(swapM,'Enable','on')
        end
        set(heatUpSinceT,'String',heatUpSinceTStr);
        set(cycleB,'String',buttonT);
        drawnow;
    end

swapM = uicontrol(f,'Style','popupmenu',...
    'String',heatStrs,...
    'Value',1,'Units','pixels','Position',[margin 2*margin+miniSz+2*roomBorderWidth ddWidth oneRowHeight],'Callback',@swapC);
    function swapC(source,eventdata)
        setHeat;
    end

    function setHeat
        try
            heat=heatStrs{get(swapM,'Value')};
            
            % ===========================================================
            % SERVER SUBJECTS
            for i=1:size(heats,1)
                if strcmp(heats{i,1}{1},heat)
                    subjects=heats{i,2}; % server subjects
                    % add coach to each subject cell array
                    
                    heatCol=heats{i,1}{2};
                end
            end
            % ===========================================================
            % OTHER SUBJECTS
%             size(other_heats,1)
%             other_heats
            all_other_subjects = {};
            for i=1:size(other_heats,1)
                if strcmp(other_heats{i,1}{1},heat) && size(other_heats, 2) > 1
                    other_subjects=other_heats{i,2}; % other subjects
                    all_other_subjects = horzcat(all_other_subjects, other_subjects);
                    heatCol=other_heats{i,1}{2};
                end
            end            
            % ===========================================================
%             other_subjects
%             size(other_subjects)
%             all_other_subjects
%             size(all_other_subjects)
            makeMini(subjects,all_other_subjects,racks_used,rooms_used,miniSz,f,heatCol,roomBorderWidth);
        catch ex
            ple(ex)
            y=errordlg(['call erik or philip before closing this box.  quitting due to error: ' ex.message],'ratrix error','modal')
            uiwait(y)
            cleanup
        end
    end

heatUpSinceT=uicontrol(f,'Style','text','HorizontalAlignment','Left','String',heatUpSinceTStr,'Units','pixels','Position',[2*margin+ddWidth 2*margin+miniSz longTWidth oneRowHeight/2]);

cycleB=uicontrol(f,'Style','togglebutton','String',buttonT,'Units','pixels','Position',[3*margin+ddWidth+longTWidth 2*margin+miniSz bWidth oneRowHeight],'Callback',@buttonC);
    function buttonC(source,eventdata)
        if get(cycleB,'Value')
            started=datevec(now);
            running=true;
            run();
        else
            running=false;
        end
        updateUI;
    end

    function run
        fixSystemTime;
        [r sys rx]=startServer(servePump,dataPath);

        er=0;
        autoUpdateInterval=.3;
        while ~doDelete && running && ~quit
            updateUI();
            [quit r rx sys er]=doAServerIteration(r,rx,servePump,sys,subjects);
            WaitSecs(autoUpdateInterval);
        end
        updateUI();
        [r rx sys]=stopServer(r,rx,servePump,sys,er,subjects);
        rp=getRatrixPath;
        rp=fullfile(rp,'analysis','eflister');
        
        % ==============================================================================================================
        % FIX THIS PART TO ONLY COMPILE SUBJECTS OWNED BY THIS SERVER
        % we need to compile records for every rack used here
        cmdStr=sprintf('matlab -automation -r "cd(''%s'');setupEnvironment;cd(''%s'');compileTrialRecords(%d);quit" &',fullfile(getRatrixPath,'bootstrap'),rp,server_name);
        system(cmdStr); %testing only
%         for i=1:length(racks_used)
%             rackNum = racks_used(i);
%             cmdStr=sprintf('matlab -automation -r "cd(''%s'');setupEnvironment;cd(''%s'');compileTrialRecords(%d);quit" &',fullfile(getRatrixPath,'bootstrap'),rp,rackNum);
%             system(cmdStr); %testing only
%         end
                    
        % END EDITS
        % ==============================================================================================================

        doClears();
        if er
            rethrow(lasterror)
        end
    end

align([swapM heatUpSinceT cycleB],'Fixed',margin,'Middle');

% ha = axes('Parent',f,'Visible','off','Units','pixels','Position',[round((fWidth-miniSz)/2),margin,miniSz,miniSz]);
% ha = axes('Parent',f,'Visible','on','Units','pixels','Position', ...
%     [margin,margin,miniSz*length(racks_used)+roomBorderWidth*length(unique(rooms_used)),miniSz+roomBorderWidth]);
% %     [margin,margin,miniSz*length(racks_used)+roomBorderWidth*length(unique(rooms_used)),miniSz+roomBorderWidth]);
% axis(ha,'ij');
% axis(ha,'equal')

setHeat;
set(f,'Visible','on')
updateUI;
end

% End ratrixUITest
% ===========================================================================================

% Helper functions

function makeMini(subjects,other_subjects,racks_used,rooms_used,miniSz,f,heatCol,roomBorderWidth)

% ===========================================================================================
% this needs to be for all racks
% Draw grey background in for each cell (all racks)



conn=dbConn;
% get rackIDs
% rackIDs = cell2mat(getAllRackIDs(conn));

% for each room, do this loop independently
% for uniqInd=1:1
for uniqInd=1:length(unique(rooms_used)) % MAIN LOOP PER ROOM
    
    racks_in_this_room = [];
    all_stationInfo = {};
    roomPosition = [5+(roomBorderWidth*2+miniSz)*(uniqInd-1), 5, roomBorderWidth,miniSz+roomBorderWidth];
    
    % loop through all racks in this room
    for roomInd=1:length(rooms_used)
        if strcmp(rooms_used{roomInd}, rooms_used{uniqInd})
            rackNum=racks_used(roomInd);
            racks_in_this_room = horzcat(racks_in_this_room, rackNum);
        end
    end

    % ENTER ANOTHER MAIN LOOP FOR EACH RACK IN THIS ROOM
    for rackInd=1:length(racks_in_this_room)
        rackNum = racks_in_this_room(rackInd);
        stationInfo=getStationsOnRack(conn,rackNum);
        all_stationInfo={};
        all_stationInfo = vertcat(all_stationInfo, stationInfo);

        

        places_with_subjects = zeros(3,3);
        theseStations=[];
        stationNames={};
        for i=1:length(all_stationInfo)
            theseStations(end+1,:)=[all_stationInfo{i}.row all_stationInfo{i}.col];
            stationNames{end+1}=[num2str(all_stationInfo{i}.rack_id) all_stationInfo{i}.station_id];
        end

        % all_stationInfo
        % all_stationInfo{1,1}
    %     theseStations
    %     stationNames

%         numRows=max(theseStations(:,1));
%         numCols=max(theseStations(:,2))*length(racks_in_this_room);
%         numCols=max(theseStations(:,2));
        
        numRows=3;
        numCols=3;

        rackPix=zeros(miniSz,miniSz,3);
        columnBoundaries=floor(linspace(1,miniSz,numCols+1)); % 3 racks
        rowBoundaries=floor(linspace(1,miniSz,numRows+1));

        % boundaries between racks
        % rackBoundaries = floor(linspace(1,miniSz*length(racks_used),length(racks_used)+1));
        % rackBoundaries = rackBoundaries(2:end-1)
        % rackBorderColor = 1;
        % given these rack boundaries, modify columnBoundaries accordingly
        % for ind=1:length(rackBoundaries)
        %     for innerind=1:length(columnBoundaries)
        %         if columnBoundaries(innerind) >= rackBoundaries(ind)
        %             columnBoundaries(innerind) = columnBoundaries(innerind) + 10;
        %         end
        %     end
        % end

        % columnBoundaries


        borderColor=0;
        col=.5*ones(1,3);

        rackPix(:,columnBoundaries,:)=borderColor;

        passedCounter = 0;
        prevrow = 0;
        prevcol = 0;
        % for each station
        for j=1:size(theseStations,1)
            row=theseStations(j,1);
            if (row < prevrow) || (row==prevrow && column<prevcol)
                passedCounter = passedCounter+1;
            end
            column=theseStations(j,2);
            prevrow = row;
            prevcol = column;
%             column = column+ 3*passedCounter; % have to do this moving after setting prevcol


            rows=(rowBoundaries(row)+1):(rowBoundaries(row+1)-1);
            columns=(columnBoundaries(column)+1):(columnBoundaries(column+1)-1);
            rackPix(rows,columns,:)=repmat(reshape(col,[1 1 3]),[length(rows) length(columns) 1]);
        end


        % draw left border
        ha = axes('Parent',f,'Visible','off','Units','pixels','Position', ...
            [5+(roomBorderWidth*2+miniSz)*(uniqInd-1)+(rackInd-1)*ceil(miniSz+roomBorderWidth/2), 5, ceil(roomBorderWidth/2),miniSz]);
        axis(ha,'ij');
        axis(ha,'equal');
        borderPix = zeros(roomBorderWidth+miniSz,ceil(roomBorderWidth/2),3);
        borderPix(:,:,:) = 0; %0.8
%         borderPix(:,end-10:end,:) = 0;
        image('Parent',ha,'CData',borderPix);

        newPosition = get(ha, 'Position');
        % draw each station in this room
        ha = axes('Parent',f,'Visible','off','Units','pixels','Position', ...
            [newPosition(1)+roomBorderWidth/2, newPosition(2), miniSz,miniSz]);
        axis(ha,'ij');
        axis(ha,'equal');
        image('Parent',ha,'CData',rackPix);
        
        rowCenters=rowBoundaries(1:end-1)+diff(rowBoundaries)/2;
        colCenters=columnBoundaries(1:end-1)+diff(columnBoundaries)/2;
        margin=5;

    %     
    %     % reset ha
    %     ha = axes('Parent',f,'Visible','on','Units','pixels','Position', ...
    %         [5+miniSz*(uniqInd-1), 5, miniSz,miniSz]);
    %     axis(ha,'ij');
    %     axis(ha,'equal')




        % ===========================================================================================
        % SERVER SUBJECTS
        % change from all subjects that belong to this server to all subjects that are in the current room on this server
    %     subjects
    %     racks_in_this_room

        % write subject, owner, and experiment text
        for i=1:length(subjects)

            loc=subjects{i}{2}{1};
            rack=subjects{i}{2}{3};
            if find(racks_in_this_room==rack)
                row = loc(1);
                col = loc(2);

    %         % find right place to put this subject
    %         loc=subjects{i}{2}{1};
    %         rack=subjects{i}{2}{3};
                racks_on_ui=find(racks_in_this_room==rack);
%                 col = col + 3*(racks_on_ui-1); % move the subject over to the correct rack
               

                name=subjects{i}{1};
                name(name=='_')=' ';
                owner=subjects{i}{3};
                exp=subjects{i}{4};
                coach=subjects{i}{5};



                %note axis ij, so row/col flipped!
                fontsize=ceil(.775*(mean(diff(columnBoundaries)))/length(name));
                if rack == rackNum
                    % store where we have subjects so we can grey out stations later
                    places_with_subjects(row, col) = 1;
%                     warning('found row col %d %d with subject %s', row, col, name);
                    text('Parent',ha,'Position',[colCenters(col) rowCenters(row)-margin ],'String',name,'Color',heatCol,'FontSize',fontsize,'FontWeight','bold','VerticalAlignment','middle','HorizontalAlignment','center');
                    text('Parent',ha,'Position',[columnBoundaries(col)+margin rowBoundaries(row+1) ],'String',sprintf('owner: %s\nexp: %s\ncoach: %s',owner,exp,coach),'Color',[0 0 0],'FontSize',8,'FontWeight','normal','VerticalAlignment','bottom','HorizontalAlignment','left');
                end
            end

        end
        % ===========================================================================================

        % ===========================================================================================
        % OTHER SUBJECTS
        % write subject, owner, and experiment text IN GREY
        % for i=1:length(other_subjects)
        %     % find right place to put this subject
        %     loc=other_subjects{i}{2}{1};
        %     rack=other_subjects{i}{2}{3};
        %     racks_on_ui=find(racks_used==rack);
        %     row = loc(1);
        %     col = loc(2);
        %     col = col + 3*(racks_on_ui-1); % move the subject over to the correct rack
        %     
        %     
        %     name=other_subjects{i}{1};
        %     name(name=='_')=' ';
        %     owner=other_subjects{i}{3};
        %     exp=other_subjects{i}{4};
        %     %note axis ij, so row/col flipped!
        %     fontsize=ceil(.875*(mean(diff(columnBoundaries)))/length(name));
        %     text('Parent',ha,'Position',[colCenters(col) rowCenters(row) ],'String',name,'Color',[0.75 0.75 0.75],'FontSize',fontsize,'FontWeight','bold','VerticalAlignment','middle','HorizontalAlignment','center');
        %     text('Parent',ha,'Position',[columnBoundaries(col)+margin rowBoundaries(row+1) ],'String',sprintf('owner: %s\nexp: %s',owner,exp),'Color',[0.75 0.75 0.75],'FontSize',8,'FontWeight','normal','VerticalAlignment','bottom','HorizontalAlignment','left');
        % end

        % ===========================================================================================
        % this is for all 3 racks
        % write stationName
        prevrow = 0;
        prevcol=0;
        passedCounter = 0;
        for i=1:length(stationNames)
            virtual_col = theseStations(i,2);
            virtual_row = theseStations(i,1);
            if (virtual_row < prevrow) || (virtual_row==prevrow && virtual_col<prevcol)
                passedCounter = passedCounter+1;
            end
            prevrow = virtual_row;
            prevcol = virtual_col;

            actual_row = virtual_row;
            actual_col=virtual_col;
%             actual_col = virtual_col + 3*passedCounter; % have to do the col moving after setting prevcol

            % assign 'Color' according to if there is a subject here
            if places_with_subjects(actual_row, actual_col) == 1
                stationColor = [0 0 0];
            else
                stationColor = [0.65 0.65 0.65];
            end

        %     text('Parent',ha,'Position',[columnBoundaries(theseStations(i,2))+margin rowBoundaries(theseStations(i,1)) ],'String',[stationNames{i}],'Color',[0 0 0],'FontSize',30,'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','left');

            text('Parent',ha,'Position',[columnBoundaries(actual_col)+ ...
                margin rowBoundaries(actual_row) ], ...
                'String',[stationNames{i}],'Color',stationColor,'FontSize',25,'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','left');


        end
        
        % now draw a rack border
%         ha = axes('Parent',f,'Visible','off','Units','pixels','Position', ...
%             [newPosition(1)+roomBorderWidth, newPosition(2), miniSz*length(racks_in_this_room),miniSz]);
%         axis(ha,'ij');
%         axis(ha,'equal');
%         borderPix = zeros(roomBorderWidth+miniSz,roomBorderWidth/2,3);
%         borderPix(:,:,:) = 0;
%         image('Parent',ha,'CData',borderPix);
        
    end % end for each rack in this room LOOP
    
    
    % ===========================================================================================
    % now draw room border
    % horizontal (top)
    newPosition = [5 5 length(racks_in_this_room)*ceil(miniSz+roomBorderWidth/2) roomBorderWidth];
    ha = axes('Visible','off','Units','pixels','Position', ...
        [newPosition(1), newPosition(2)+miniSz, newPosition(3), roomBorderWidth]);
    axis(ha,'ij');
    axis(ha,'equal')
%     
    borderPix=zeros(newPosition(4), newPosition(3), 3);
%     borderPix(1:10,:,:)=0.80;
%     size(borderPix)
    image('Parent',ha,'CData',borderPix);
    text('Parent',ha,'Position',[newPosition(3)/2, 0],'String',sprintf('Room: %s',rooms_used{uniqInd}),'Color',[1 1 1], ...
        'FontSize',15,'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','center');
    
    % vertical
    ha = axes('Visible','off','Units','pixels','Position', ...
        [newPosition(1)+((roomBorderWidth/2)+miniSz)*length(racks_in_this_room), newPosition(2), roomBorderWidth, miniSz+roomBorderWidth]);
    axis(ha,'ij');
    axis(ha,'equal')
    
    borderPix=ones(miniSz+roomBorderWidth, roomBorderWidth, 3);
    borderPix(:,:,:) = 0; %0.8
    borderPix(:,1:10,:) = 0;
%     if uniqInd ~= length(unique(rooms_used))
%         borderPix(11:end,end-10:end,:) = 0;
%     end
%     size(borderPix)
%     finalPostion = get(ha, 'Position')
    image('Parent',ha,'CData',borderPix);


% ===========================================================================================
end % end unique room loop

closeConn(conn);

end % end function

function [r sys rx]=startServer(servePump,dataPath)
if servePump
    sys=initPumpSystem(makePumpSystem());
else
    sys=[];
end

%addJavaComponents; %would like to have this in the rnet constructor, but doesn't work
%     the caller has to call it before constructing an
%     rnet for some reason.  can't figure out why, but if you don't do it, even
%     though the dynamic path is updated correctly, the import appears to
%     fail.
r = rnet('server');
clearTemporaryFiles(r);

fprintf('%s: server running...\n',datestr(now))

rx=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

[rx ids]=emptyAllBoxes(rx,'ratrixServer starting','ratrix');
if length(ids)>0
    ids
    warning('found subjects in boxes at ratrixServer startup')
end
end

function [r rx sys]=stopServer(r,rx,servePump,sys,er,subjects)
fprintf('%s: quitting ratrix server\n',datestr(now))
[sys,r,rx]=cleanup(servePump,sys,r,rx,subjects);
end

function [quit r rx sys er]=doAServerIteration(r,rx,servePump,sys,subjects)
try
    %     while CharAvail() %note have to hit ctrl-c once for this to ever succeed!
    %         %this gives us ascii value 3, which is   ETX  ^C 		End of Text
    %         k=GetChar(0);
    %
    %         if double(k)==3
    %             'trapped ctrl-c!'
    %             ListenChar(2)
    %         end
    %     end

    quit=false;
    er=false;
    constants = getConstants(r);

    if servePump
        %setOnlineRefill(sys); %need to rapidly call this over and over to avoid flooding!
        ensureAllRezFilled(sys); %less efficient, but more safe than setOnlineRefill()
    end

    % update client register
    clients = listClients(r);
    connectedClients={}; %note, switching to cell array from a java () array!
    for i=1:length(clients)
        if isConnected(r,clients(i))
            connectedClients{end+1}=clients(i);
        else
            [r rx]=unregisterClient(r,clients(i),rx,subjects);
            tossClient(r,clients(i));
        end
    end

    clients=[]; %release references to java objects
    for i=1:length(connectedClients) %this needs to happen after disconnections have been removed to prevent fast reconnects from confusing me!
        reregistered = clientReregistered(r,connectedClients{i});
        if reregistered
            % If reregistered, unregister it first
            if clientIsRegistered(r,connectedClients{i})
                [r rx]=unregisterClient(r,connectedClients{i},rx,subjects);
            end
        end
        if ~clientIsRegistered(r,connectedClients{i}) || reregistered
            [quit mac]=getClientMACaddress(r,connectedClients{i});

            %ask client for its type -- if monitor vs station

            if quit
                fprintf('Client is no longer connected\n');
                tossClient(r,connectedClients{i});
            else

                %                 [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD,{'svn://132.239.158.177/projects/ratrix/trunk'});
                %                 if ~quit
                %                     timeout=10.0;
                %                     [quit updateConfirm updateConfirmCmd updateConfirmArgs]=waitForSpecificCommand(r,connectedClients{i},constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD,timeout,'waiting for client response to S_UPDATE_SOFTWARE_CMD',[]);
                %                     if isempty(updateConfirm) || isempty(updateConfirmCmd)
                %                         error('appeared to get error from client -- waitForSpecificCommand should know to also check for sendErrors() that have to do with that specific command (it''s objectID, not just its type)')
                %                     end
                %                     com=[]; %should this be something else?
                %                     updateConfirm=[];
                %                 end
                %                 if quit
                %                     fprintf('Client is no longer connected %s\n',mac);
                %                     tossClient(r,connectedClients{i});
                %                 elseif updateConfirmArgs{1}
                %                     fprintf('Updating software on %s\n',mac);
                %                     tossClient(r,connectedClients{i});
                %                 else

                quit=replicateClientTrialRecords(r,connectedClients{i},{});

                z=[];
                if ~quit
                    z=getZoneForStationMAC(rx,mac);
                end

                gotGoodRatrix=false;
                if ~isempty(z)
                    [r rx tf]=registerClient(r,connectedClients{i},mac,z,rx,subjects);

                    [rx quit]=updateRatrixFromClientRatrix(r,rx,connectedClients{i});

                    if ~quit && tf
                        nonPersistedRatrix=makeNonpersistedRatrixForStationMAC(rx,mac);
                        if ~isempty(nonPersistedRatrix)
                            gotGoodRatrix=true;
                            [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_START_TRIALS_CMD,{nonPersistedRatrix});
                            if ~quit
                                nonPersistedRatrix=[];
                                fprintf('\nsent ratrix to %s\n',mac)
                                timeout=5.0;
                                quit=waitForAck(r,com,timeout,'waiting for ack from sent ratrix');
                            end

                            com=[]; %release references to java objects
                        end
                    end
                end
%                 if isempty(z) || ~tf || quit || ~gotGoodRatrix
                if isempty(z) || quit || (~gotGoodRatrix && tf)  % 9/22/08 - don't toss clients w/o a subject running
                    % toss client if there is no zone, or if quit is received, or if client is registered but did not get a good ratrix
                    % do not toss in the event that we registered a client that has no subject running (tf will be false)
                    fprintf('shutting down client -- no entry for that mac or lost connection %s\n',mac);
                    [r rx]=remoteClientShutdown(r,connectedClients{i},rx,subjects); %will handle unregistering
                    tossClient(r,connectedClients{i});
                end
            end
        end
    end
    connectedClients={}; %release references to java objects

    if length(listClients(r)) >= 1

        % Handle a SERVER RESET
        if resetRequested(r)
            fprintf('Responding to Server Reset Request\n');
            % Attempt to disconnect all clients
            clients = listClients(r);
            for i=1:length(clients)
                % disconnectClient(r,clients(i));
            end
            clients=[];
            %do we need to restart the server here or something?
        end

        com = getNextCommand(r);
        if ~isempty(com) %commandsAvailable(r) %used to be while, but want to loop faster so online equalization tank refills happen more often
            disp(sprintf('%s: handling command.  num other commands in queue: %d\n',datestr(now),commandsAvailable(r)))
            %com = getNextCommand(r);
            startTime=GetSecs();
            [sys r rx]=serverHandleCommand(r,com,sys,rx,subjects);
            fprintf('\tcommand handling time was %g secs\n',GetSecs()-startTime);
            com=[];
        else
            if servePump
                sys = considerOpportunisticRefill(sys);
            end
        end
    end
    clients={};  %release references to java objects
catch ex
    quit=true;
    er=true;

    fprintf('%s: shutting down rnet and pump system due to error\n',datestr(now))
    ple(ex)

    %if call ListenChar(0) to undo the ListenChar(2) before this point, seems to replace useful errors with 'Undefined function or variable GetCharJava_1_4_2_09.'

    %release references to java objects
    com=[];
    clients=[];
end
end

function tossClient(r,c)
commandsWaitingFromClient=disconnectClient(r,c);
fprintf('tossed client\n')
if ~isempty(commandsWaitingFromClient)
    fprintf('\tfound the following commands left unhandled for that client!\n')
    commandsWaitingFromClient
    commandsWaitingFromClient=[]; % i'll ignore leftover commands for now
end
end

function [sys,r,rx]=cleanup(servePump,sys,r,rx,subjects)
if servePump
    try
        sys=closePumpSystem(sys);
    catch ex
        fprintf('error shutting down pump\n')
        ple(ex)
    end
end

try
    [r rx]=shutdown(r,rx,subjects);
catch ex
    fprintf('error shutting down rnet\n')
    ple(ex)
end

[rx ids]=emptyAllBoxes(rx,'ratrixServer cleanup','ratrix');
if length(ids)>0
    ids
    warning('subjects were left in boxes at ratrixServer cleanup')
end

rx=[];
end

function doClears

debug=1;
if ~debug
    clear classes
    clearJavaComponents();
end

% java.lang.System.gc();
% clear java
% WaitSecs(.5)
% clear classes
% clear java
% java.lang.System.gc();

end
