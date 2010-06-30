function [analysisPath analysisDirForRange]= createAnalysisPathString(boundaryRange,path,subjectID)
if boundaryRange(1)==boundaryRange(3)
    analysisDirForRange = sprintf('%d',boundaryRange(1));
else
    analysisDirForRange = sprintf('%d-%d',boundaryRange(1),boundaryRange(3));
end
analysisPath = fullfile(path,subjectID,'analysis',analysisDirForRange);
end
