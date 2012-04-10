function reportSettings(r)
if ~exist('r','var') || isempty(r)
    r=init;
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

ids=getSubjectIDs(r);

if ~isempty(ids)
    conn=dbConn();
    rrs=getRacksAndRoomsFromServerName(conn, getServerNameFromIP);
    stations=getStationsForServer(conn,getServerNameFromIP);
    closeConn(conn);
    rrs=[rrs{:}];
    stations=[stations{:}];
    
    if ~isempty(rrs)
        rackNums=[rrs.rackID];
        stationIDs=[num2str([stations.rack_id]') [stations.station_id]'];
        stationIDs=mat2cell(stationIDs,ones(1,size(stationIDs,1)));
        networked=true;
    else
        rackNums=1;
        stations={'1'};
        stationIDs={'1'};
        subjects=reshape(ids,1,1,[]);
        heats=ids;
        networked=false;
    end

    for rackNum=1:length(rackNums)
        
        if networked
            [heats stations subjects]=getRatLayout(rackNums(rackNum));
            %subjects is ids in {row,col,heat}
            %stations is ids in {row, col}
        end
        
        maxLen=0;
        for i=1:length(heats)
            if length(heats{i})>maxLen
                maxLen=length(heats{i});
            end
        end
        
        for rowNum=1:size(stations,1)
            for colNum=1:size(stations,2)
                if ~isempty(stations{rowNum,colNum}) && ismember(stations{rowNum,colNum},stationIDs) %have to check for empties cuz of 3G being renamed to 4A
                    fprintf('\n station: %s\n',stations{rowNum,colNum})
                    for h=1:length(heats)
                        fprintf('\theat: %s',[heats{h} repmat(' ',1,maxLen-length(heats{h}))])
                        sub=subjects{rowNum,colNum,h};
                        
                        fprintf('\tsub: %s',sub)
                        
                        if isempty(sub)
                            fprintf('none\n');
                        else
                            found=false;
                            for i=1:length(ids)
                                ratID=ids{i};
                                if strcmp(ratID,sub)
                                    if found
                                        error('found multiple subj')
                                    end
                                    found=true;
                                    
                                    s = getSubjectFromID(r,ratID);
                                    [p t]=getProtocolAndStep(s);
                                    if ~isempty(p)
                                        tm=getTrialManager(getTrainingStep(p,t));
                                        sm=getStimManager(getTrainingStep(p,t));
                                        fprintf('\t%s(%d/%d)\ttrlMgr:%s\t',getName(p),t,getNumTrainingSteps(p),class(tm));
                                        
                                        
                                        [junk rewardSizeULorMS requestRewardSizeULorMS msPenalty] = calcReinforcement(getReinforcementManager(tm),[]);
                                        fprintf('reward:%g pnlty:%g\n',rewardSizeULorMS,msPenalty)
                                        coherence=struct(sm).coherence
                                        sideDisplay=struct(sm).sideDisplay
                                    else
                                        fprintf('\t\t\t%s has no protocol\n',ratID);
                                    end
                                    
                                end
                            end
                            if ~found
                                fprintf(' subject not found in ratrix\n');
                                %error('no subj found')
                            end
                        end
                    end
                end
            end
        end
    end
else
    'no subjects defined'
end