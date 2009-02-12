function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT={};

try
    stimDetails=[trialRecords.stimDetails];
    [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
    [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
    [out.strategy newLUT] = extractFieldAndEnsure(stimDetails,{'strategy'},'scalar',newLUT);
    [out.seedValues newLUT] = extractFieldAndEnsure(stimDetails,{'seedValues'},'equalLengthVects',newLUT);
    [out.spatialDim newLUT] = extractFieldAndEnsure(stimDetails,{'spatialDim'},'equalLengthVects',newLUT);
    [out.stixelSize newLUT] = extractFieldAndEnsure(stimDetails,{'stixelSize'},'equalLengthVects',newLUT);
    [out.std newLUT] = extractFieldAndEnsure(stimDetails,{'std'},'scalar',newLUT);
    [out.meanLuminance newLUT] = extractFieldAndEnsure(stimDetails,{'meanLuminance'},'scalar',newLUT);
    [out.numFrames newLUT] = extractFieldAndEnsure(stimDetails,{'numFrames'},'scalar',newLUT);

catch
    ex=lasterror;
    out=handleExtractDetailFieldsException(sm,ex,trialRecords);
    verifyAllFieldsNCols(out,length(trialRecords));
    return
end

verifyAllFieldsNCols(out,length(trialRecords));
end