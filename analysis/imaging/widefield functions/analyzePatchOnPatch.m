%%%analyzePatchOnPatch
close all
clear all

%select batch file
batchPhilIntactSkull
cd(pathname)
 
%select animals to use
alluse = find(strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))
sprintf('%d animals',length(alluse)/2)
allsubj = unique({files(alluse).subj})

redoani = input('reanalyze individual animal data? 0=no, 1=yes: ')
if redoani
    reselect = input('reselect ROI in each experiment? 0=no, 1=yes: ')
end   

% %%% use this one to average all sessions that meet criteria
for s=1:1
use = alluse;
allsubj{s}
%%% calculate gradients and regions
clear map merge
x0=0; y0=0; sz=128;
% doTopography;
doPatchOnPatch;
% doFunctionalConnectivity
end

sprintf('complete')