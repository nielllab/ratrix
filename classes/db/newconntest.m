conn=dbConn();
subject_id = '102';
ids = {'102','159','160'};
rack_id=1;
station_id='A';
heat_name='Red';
mac = '0018F35E0281';
%[w d t] = getBodyWeightHistory(conn,subject_id);
for i=1:1
    heats=getHeats(conn)


    tr=getTrialRecordFiles(conn,subject_id);
    size(tr);
    class(tr{1});

    assignments=getAssignments(conn,rack_id,heat_name)

    s = getSubjects(conn,ids)

    sts = getStations(conn)

    st = getStation(conn,rack_id,station_id)

    otherst = getStationFromMac(conn,mac)

end

closeConn(conn);
