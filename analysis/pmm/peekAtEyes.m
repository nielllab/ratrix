

path = '\\132.239.158.179\datanet_storage\';
subjectID='138';
trials=1:20;
eyeRecordPath = fullfile(path, subjectID, 'eyeRecords');


h=length(trials); w=1; 
for i=1:length(trials)
eyeData=getEyeRecords(eyeRecordPath, currentTrial,timestamp);

subplot(h,w,i)
end
