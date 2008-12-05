function [heatOrder stations subjects]=getRatLayout(rack)
conn=dbConn;


heatOrder={};

    heats=getHeats(conn);
        for i=1:length(heats)
            heatOrder{end+1}=heats{i}.name;
        end


s=getStationsOnRack(conn,rack);
for i=1:length(s)
    %     s{i}
    stations{s{i}.row,s{i}.col}=[num2str(s{i}.rack_id) s{i}.station_id];
    %
    %     stationStrs{end+1}=['station ' num2str(rack) s{i}.station_id ' (' s{i}.mac ')'];
    %     stationIds{end+1}=s{i}.station_id;
    %     numRows=max(numRows,s{i}.row);
    %     numCols=max(numCols,s{i}.col);
    %
    %station=getStation(conn,s{i}.rack_id,s{i}.station_id)
    %station=getStationFromMac(conn,s{i}.mac)
end



heats=getHeats(conn);
assignments={};
for ht=1:length(heatOrder)
    foundHeat=false;
    for i=1:length(heats)
        if strcmp(heats{i}.name,heatOrder{ht})
            if foundHeat
                error('found multiple heats')
            end
            foundHeat=true;
            assignments{end+1}=getAssignments(conn,rack,heats{i}.name);

           % fprintf('heat %s\n',heats{i}.name)
           subjects{size(stations,1),size(stations,2),ht}=[];
            for r=1:size(stations,1)
                for c=1:size(stations,2)
                    found=false;
                    for j=1:length(assignments{end})
                        sid=[num2str(assignments{end}{j}.rack_id) assignments{end}{j}.station_id];
                        if strcmp(sid,stations{r,c})
                            if found
                                error('found multiple subj')
                            end
                            found=true;
                            subjects{r,c,ht}=assignments{end}{j}.subject_id;
                        end
                    end
                    if ~found
                        %warning('no subj found for heat')
                    end
                end
            end
           % subjects
        end
    end
    if ~foundHeat
        error('no heat found')
    end
end



closeConn(conn);