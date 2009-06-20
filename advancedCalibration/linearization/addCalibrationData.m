function out=addCalibrationData(CLUT,mac,timestamp,svnRev,comment,calibrationString)
% this function adds the given CLUT to the oracle table 'CLUTS'
% INPUTS:
%   CLUT - the color LUT; may include RGB/xyz measurements, linearized LUT, and validation data
%       all of which will be stored in a BLOB
%   mac - the mac address of the station (will be used to look up gfx and crt serials in the GFX_CRT_SERIALS table)
%   timestamp - the timestamp of this entry in the format 'mm-dd-yyyy hh24:mi'
%   svnRev - svn revision number
%   comment - comment for this calibration entry
%   calibrationString - automatically generated string for this calibration entry from the stim draw method, mode, screenType, and fitMethod

if ~isMACaddress(mac)
    error('mac must be a valid MAC address');
end
if ischar(timestamp)
    match=regexpi(timestamp,'\d{2}-\d{2}-\d{4} \d{2}:\d{2}');
    if isempty(match)
        error('timestamp did not match format ''mm-dd-yyyy hh24:mi''');
    end
else
    error('timestamp must be a string');
end

try
    conn=dbConn();
catch ex
    getReport(ex)
    error('unable to get valid dbConn - no access to oracle?');
end

% get current gfx and crt serials by mac address
str=sprintf('select gfx_serial, crt_serial from GFX_CRT_SERIALS where station_mac=''%s''',mac);
results=query(conn,str);
if ~isempty(results)
    if size(results,1)~=1
        error('got multiple gfx/crt entries for this mac address - please fix!');
    else
        gfx=results{1,1};
        crt=results{1,2};
    end
else
    error('failed to find a matching mac address!');
end

% insert into MONITOR_CALIBRATION
str=sprintf('insert into MONITOR_CALIBRATION (timestamp,station_mac,gfx_serial,crt_serial,svn_revision,comment,calibrationString,data) VALUES (to_date(''%s'',''mm-dd-yyyy hh24:mi''),''%s'',''%s'',''%s'',%d,''%s'',''%s'',empty_blob())',timestamp,mac,gfx,crt,svnRev,comment,calibrationString);
out=exec(conn,str);

updateCalibrationData(conn,mac,timestamp,CLUT);

closeConn(conn);

end % end function