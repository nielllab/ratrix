function step = getLastTrainingStep(subjectID, permanentStorePath)

conn = dbConn();
files=getTrialRecordFiles(conn,subjectID);
closeConn(conn);
if isempty(files)
    % If there are no trial records, then return traing step 1
    step = 1;
else
    % Get date and trial number ranges for the trial record files
    recs=getRangesFromTrialRecordFileNames(files);
    % Sort the trial records by trial start number
    [garbage sortIndices]=sort([recs.trialStart],2);
    sortedRecs = recs(sortIndices);
    subjPath = fullfile(permanentStorePath,subjectID);
    f=sortedRecs(end).name;
    tr=load(fullfile(subjPath,f));
    rec=tr.trialRecords(end);
    if ~isfield(rec,'trainingStepNum')
        error('Trial Records does not have trainingStepNum field')
    else
        step = rec.trainingStepNum;
    end
end

