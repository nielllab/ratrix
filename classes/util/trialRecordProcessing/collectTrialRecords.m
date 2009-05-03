function trialRecords = collectTrialRecords(tr)
% tr should be a struct with fields 'tr0', 'tr1', 'tr2', etc
% where tr0 is a blank (empty to create the trialRecords.mat file)
% and subsequent trN fields are the trialRecord for each the N-th trial
%
% we should return a struct array of trialRecords in our customary format
% and also do some sanity checking

fields=fieldnames(tr);
unsortedRecords=[];
order=[];

for i=1:length(fields)
    [match tokens] = regexpi(fields{i},'tr(\d+)','match','tokens');
    if ~isempty(match) && ~strcmp(match,'tr0')
        order=[order str2double(tokens{1}{1})];
        unsortedRecords=[unsortedRecords tr.(fields{i})];
    end
end

[b ind]=sort(order);
trialRecords=unsortedRecords(ind);
if isempty(trialRecords) % when would this happen? 
	return;
end

% sanity checks
if any([trialRecords.trialNumber]~=trialRecords(1).trialNumber:trialRecords(end).trialNumber)
    error('trialNumber not monotonically increasing');
end

if length(unique([trialRecords.sessionNumber]))>1
    error('more than one unique sessionNumber');
end

if length(unique([trialRecords.subjectsInBox]))>1
    error('more than one unique subjectInBox');
end

end