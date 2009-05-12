function out = getTimesNonphased(trialRecord)
if isfield(trialRecord,'times') % often the last trial lacks this
    out = cell2mat([trialRecord.times]);
else
    out = {NaN};
end
end