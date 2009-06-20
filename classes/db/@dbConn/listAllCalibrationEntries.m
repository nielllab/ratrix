function results=listAllCalibrationEntries(conn,mac)
% list all calibration entries for a given MAC

str=sprintf('select to_char(timestamp,''mm-dd-yyyy hh24:mi''), comment, calibrationString from MONITOR_CALIBRATION where station_mac=''%s''',mac);
results=query(conn,str);


end % end function