%%% run resting state analysis on subjects without topox topoy alignement

clear all; close all

%%% batch file of choice
batch_restingState
alluse = find( strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session') & isnan([files.age]) &strcmp({files.subj},'g62l4lt') & strcmp({files.expt},'120115') )

length(alluse)

allsubj = unique({files(alluse).subj})

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))

%%% use this one to average all sessions that meet criteria
for s=1:1
    use = alluse;    
    allsubj{s}   
    doCorrelationMapWholebrain
end



