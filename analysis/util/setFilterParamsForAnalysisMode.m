function filterParams = setFilterParamsForAnalysisMode(analysisMode, trialNum, chunkInd, boundaryRange)
switch analysisMode
    case 'overwriteAll'
        filterParams.filterMode = 'thisTrialAndChunkOnly';
        filterParams.trialNum = trialNum;
        filterParams.chunkInd = chunkInd;
    otherwise
        error('unknown analysisMode');
end