function physAnalysis = getPhysAnalysis(analysisPath,analysisMode)
physAnalysisFile = fullfile(analysisPath,'physAnalysis.mat')
switch analysisMode
    case {'overwriteAll','onlyAnalyze'}
        if exist(physAnalysisFile,'file')
            temp = stochasticLoad(physAnalysisFile,{'physAnalysis'});
            physAnalysis = temp.physAnalysis;
        else
            physAnalysis = {};
        end
    otherwise
        error('unsupported analysisMode');
end
end