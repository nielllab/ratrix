%%% run resting state analysis on subjects without topox topoy alignement

clear all; close all

%%% batch file of choice
%batchBehav_8mm
batchAcrylic_testing_jw
alluse = find( strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  )

length(alluse)
alluse = alluse(1)
allsubj = unique({files(alluse).subj})

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))

%%% use this one to average all sessions that meet criteria
for s=1:1
    use = alluse;    
    allsubj{s}   
    doCorrelationMap
end



