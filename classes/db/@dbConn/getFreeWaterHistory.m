function [dates free_water_amounts free_water_units] = getFreeWaterHistory(conn,subject_id)

dates={};
free_water_amounts={};
free_water_units={};

queryStr = sprintf('select to_char(observation_date, ''DD-MON-YYYY''), to_number(observations.water_amount), observations.water_unit FROM observations,subjects WHERE observations.subject_uin=subjects.uin AND water_amount is not null AND subjects.display_uin=''%s'' order by observation_date', subject_id);
data = query(conn, queryStr);
if ~isempty(data)
    dates=data(:,1);
    free_water_amounts=data(:,2);
    free_water_units=data(:,3);
end

dates=datenum(dates);
free_water_amounts=cell2mat(free_water_amounts);

end % end function