function filterParams = setFilterParamsForAnalysisMode(analysisMode, trialNum, chunkInd, analysisBoundaryFile)
switch analysisMode
    case 'overwriteAll'
        filterParams.filterMode = 'thisTrialAndChunkOnly';
        filterParams.trialNum = trialNum;
        filterParams.chunkID = chunkInd;
    otherwise
        error('unknown analysisMode');
end