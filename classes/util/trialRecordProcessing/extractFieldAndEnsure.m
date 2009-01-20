function [out LUT] = extractFieldAndEnsure(trialRecords,fieldPath,ensureMode,LUT)
% this function extracts the given field from trialRecords using the provided fieldPath and ensureMode
%   ensureMode is one of {'scalar','scalarLUT','equalLengthVects',{'typedVector',type},'datenum','none'} where type specifies the type of vector
%
% for use by the general extractBasicFields and the stim-specific extractDetailFields so that NaNs are inserted instead of bailing on trials
% scalar - each trialRecord has a single scalar value at this field
% scalarLUT - each trialRecord has a single value at this field, but it may be a char that needs to be put into the LUT
% equalLengthVects - each trialRecord has a vector at this field, and the length of the vector is constant across all trials
% typedVector - each trialRecord has a vector at this field, and the type of the vector is consistent across all trials
% datenum - each trialRecord has a datevec at this field, and is converted to a datenum in a specific format
% isNotEmpty - each trialRecord may or may not have this field, and this will return 1 if it does, 0 if it doesnt (on a per-trial basis)
% NthValue = each trialRecord has a vector/matrix at this field, and we grab the N-th value of this vector for each trial
% none - just grab this field for each trial

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
        case 'isNotEmpty'
            f=fields(trialRecords);
            if ~strcmp(fieldPath,f)
                out=zeros(size(trialRecords));
            else
                cellValues={trialRecords.(fieldPath)};
                out = cell2mat(cellfun('isempty',cellValues, 'UniformOutput',false));
            end
        case 'NthValue'
            if ~isempty(ensureType)
                %get nth value of matrix
                cellValues={trialRecords.(fieldPath)};
                cellNth=repmat({ensureType},1,(length(trialRecords)));
                out = cell2mat(cellfun(@takeNthValue,cellValues ,cellNth, 'UniformOutput',false));
                if size(out)~=size(trialRecords)
                    cellValues
                    out
                    size(out)
                    size(trialRecords)
                    error('should have one value per trial! failed!  maybe nans emptys in values?')
                end
            else
                error('should have one value per trial! failed! and nthValue is undefined')
            end
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

function out=takeNthValue(values,N)
out=values(N);
end