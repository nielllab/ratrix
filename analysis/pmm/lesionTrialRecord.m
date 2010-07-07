function lesionTrialRecord(inFile,outPath,maxTrial)
% quick hack code...removes all the trials in records after maxTrial
% this is basically still an mfile and not a function yet... subjectName
% should be calulated not a feee param

subjectName='231';  %scary if they don't agree, which they could if you don't check here
maxTrial=195000;
inFile='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled\231.compiledTrialRecords.1-321278.mat';
outPath='C:\Documents and Settings\rlab\Desktop\test';

%load one
load(inFile)


%% chop the basic records
f=fields(compiledTrialRecords);
for i=1:length(f)
    compiledTrialRecords.(f{i})=compiledTrialRecords.(f{i})(:,1:maxTrial);
end
%% chop the detailed records (THEY CAN"T BE CELLS...will error if they are... okay for most)
for c=1:length(compiledDetails)
    whichRemoved=compiledDetails(c).trialNums>maxTrial;
    if any(whichRemoved)
        compiledDetails(c).trialNums(whichRemoved)=[];
        f=fields(compiledDetails(c).records);
        for i=1:length(f)
            compiledDetails(c).records.(f{i})(:,whichRemoved)=[];
        end
    end
end

%%
save(fullfile(outPath,sprintf('%s.compiledTrialRecords.%d-%d.mat',subjectName,1,maxTrial)),'compiledDetails','compiledTrialRecords','compiledLUT');

