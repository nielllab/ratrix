function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;

try
    stimDetails=[trialRecords.stimDetails];
    [out.strategy newLUT] = extractFieldAndEnsure(stimDetails,{'strategy'},'scalarLUT',newLUT);

catch ex
    out=handleExtractDetailFieldsException(sm,ex,trialRecords);
    verifyAllFieldsNCols(out,length(trialRecords));
    return
end

verifyAllFieldsNCols(out,length(trialRecords));
end