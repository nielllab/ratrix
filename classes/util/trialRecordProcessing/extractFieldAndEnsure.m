function [out LUT] = extractFieldAndEnsure(trialRecords,fieldPath,ensureMode,LUT)
% this function extracts the given field from trialRecords using the provided fieldPath and ensureMode
%   ensureMode is one of {'scalar','scalarLUT','equalLengthVects',{'typedVector',type},'datenum','none'} where type specifies the type of vector
%
% for use by the general extractBasicFields and the stim-specific extractDetailFields so that NaNs are inserted instead of bailing on trials

% grab the mode if cell array, and set ensureType=type
if iscell(ensureMode) && length(ensureMode)==2
    ensureType=ensureMode{2};
    ensureMode=ensureMode{1};
end

% if fieldPath isnt a single element cell array, then follow it down to the last element
for i=1:length(fieldPath)-1
    if ismember(fieldPath{i},fields(trialRecords))
        trialRecords=[trialRecords.(fieldPath{i})];
    else
        out=nan*ones(1,length(trialRecords));
        return
    end
end
% now reset fieldPath to be only the last element
fieldPath=fieldPath{end}; % fieldPath is now just a string

try
    switch ensureMode
        case 'scalar'
            out=ensureScalar({trialRecords.(fieldPath)});
        case 'scalarLUT'
            try
                out=ensureScalar({trialRecords.(fieldPath)});
            catch
                ensureTypedVector({trialRecords.(fieldPath)},'char'); % ensure is char otherwise no reason to use LUT
                [out LUT]=addOrFindInLUT(LUT, {trialRecords.(fieldPath)});
            end
        case 'equalLengthVects'
            out=ensureEqualLengthVects({trialRecords.(fieldPath)});
        case 'typedVector'
            out=ensureTypedVector({trialRecords.(fieldPath)},ensureType);
        case 'datenum'
            out=datenum(reshape([trialRecords.(fieldPath)],6,length(trialRecords))')';
        case 'none'
            out=[trialRecords.(fieldPath)];
        otherwise
            ensureMode
            error('unsupported ensureMode');
    end
catch
    % if this field doesn't exist, fill with nans
    out=nan*ones(1,length(trialRecords));
end

end % end function