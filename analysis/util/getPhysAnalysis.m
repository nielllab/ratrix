function physAnalysisFile = getPhysAnalysis(analysisPath,analysisMode)
physAnalysisFile = fullfile(analysisPath,'physAnalysis.mat')
switch analysisMode
    case 'overwriteAll'
        if exist(physAnalysisFile,'file')
            temp = stochasticLoad(spikeRecordFile,{'physAnalysis'});
            physAnalysis = temp.physAnalysis;
        else
            physAnalysis = [];
        end
    otherwise
        error('unsupported analysisMode');
end
end