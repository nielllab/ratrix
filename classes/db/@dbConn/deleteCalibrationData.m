function out=deleteCalibrationData(conn,mac,timeRange)
% this function deletes calibrationData entries based on a mac and timeRange

out=0;
str=sprintf('select data, to_char(timestamp,''mm-dd-yyyy hh24:mi''),comment,calibrationString from MONITOR_CALIBRATION where station_mac=''%s''',mac);
results=query(conn,str);
list=results(:,[2 3 4]);

for i=1:size(results,1)
    results{i,2}=datenum(results{i,2},'mm-dd-yyyy HH:MM');
end
which=find(cell2mat(results(:,2))>=timeRange(1)&cell2mat(results(:,2))<=timeRange(2));

if ~isempty(which)
    dispStr=sprintf('This will DELETE %d calibration data entries! Are you sure you want to delete (Y/N)?',length(which));
    validInput=false;
    while ~validInput
        s=input(dispStr,'s');
        if strcmpi(s,'Y')
            validInput=true;
            % do delete
            for i=1:length(which)
                str=sprintf('delete from MONITOR_CALIBRATION where comment=''%s'' and calibrationString=''%s'' and timestamp=to_date(''%s'',''mm-dd-yyyy hh24:mi'')',...
                    list{which(i),2},list{which(i),3},list{which(i),1})
                exec(conn,str);
                out=out+1;
            end
        elseif strcmpi(s,'N')
            validInput=true;
            % do not delete
            disp('No entries deleted.');
        else
            disp('Invalid input - please try again');
        end
    end        
elseif isempty(which)
    error('failed to find any entries for the given mac address and timeRange');
end

end % end function