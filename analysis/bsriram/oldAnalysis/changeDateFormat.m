function o = changeDateFormat(d)
    for i = 1:length(d)
        d(i).date = datenum(d(i).date);
    end
    o = d;
end