function trials = getNotrials(d)
% d is a vector of dates, one for each trial. They will be in the datenum
% format. output will be a vector containing data about the number of
% trials in each day since the first day.

startDate = floor(d(1));
endDate = floor(d(end));
trials = zeros((endDate-startDate+1),1);

for currDate = startDate:endDate
    trials(currDate-startDate+1) = sum((d>=currDate)&(d<currDate+1));
end

end