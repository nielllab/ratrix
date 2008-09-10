function out=handleExtractDetailFieldsException(sm,ex,trialRecords)
ex
out=struct; %official way to bail
if ismember(ex.identifier,{'MATLAB:catenate:structFieldBad'})
    warning('bailing: stimDeatils have varying field names')
elseif ismember(ex.identifier,{'MATLAB:nonExistentField'})
    [trialRecords.stimDetails]
    warning('bailing: apparently fields missing from stimDetails')
elseif ismember(ex.identifier,{'MATLAB:nonStrucReference'}) %this occurs if we are sent zero trials in the input when we try to look past the first struct level down (which doesn't exist) -- eg   [stimDetails.HFdetails]
    if length(trialRecords)~=0
        size(trialRecords)
        warning('bailing: got MATLAB:nonStrucReference even though there were trialRecords -- expect this only when trialRecords has length zero and we try to access nested structure fields that can''t be present in zero record structs')
    else
        warning('you got a MATLAB:nonStrucReference (as expected) because trialRecords was empty -- should never happen because we never send empty trialRecords to extractDetailFields')
    end
else
    rethrow(ex);
end