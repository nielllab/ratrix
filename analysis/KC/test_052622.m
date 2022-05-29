x = -2:0.25:2;
y = x;
[X,Y] = meshgrid(x);

F = X.*exp(-X.^2-Y.^2);
surf(X,Y,F)

%normalized_meanPupDiameterAllTrials_allSessAsOneVector

%meanSpeedAllTrials_eachSess_in_cm

%% 

heatmap(tbl,xvar,yvar)

% how many trials in category 'low pupil diameter high run, vs the 3 other
% categories, column sored as hi & run speeds, rows sorted as high & low
% pupil diameter,
% color of square indicating 'density' (number) of trials in that behavior
% state
xvar = meanSpeedAllTrials_eachSess_in_cm;
yvar = normalized_meanPupDiameterAllTrials_allSessAsOneVector;

% heat map takes a table as input

% HiRunHiPup_cat = 'HiRunHiPup';
% LoRunLoPup_cat = 'LoRunLoPup';
% HiPupLoRun_cat = 'HiPupLoRun';
% LoRunHiPup_cat = 'LoRunHiPup';

hiRunLoRun_col = 'hi_run';
hiPupLoPup_col = 'hi_run';

runThresh*pix2cmRatio
meanSpeedAllTrials_eachSess_in_cm

pupThreshold 
normalized_meanPupDiameterAllTrials_allSessAsOneVector

%%

hiRunHiPupTrials = 0;
loRunLoPupTrials = 0;

hiRunLoPupTrials = 0;
loRunHiPupTrials = 0;

for tr = 1:length(meanSpeedAllTrials_eachSess_in_cm) % for each trial
    if meanSpeedAllTrials_eachSess_in_cm(1,tr) > runThresh*pix2cmRatio
        if  normalized_meanPupDiameterAllTrials_allSessAsOneVector(1,tr) > pupThreshold
            hiRunHiPupTrials = hiRunHiPupTrials+1;
            num_hiRunHiPupTrials = sum(hiRunHiPupTrials);
        end 
    end % end hi run hi pup num trial collector
    
    if meanSpeedAllTrials_eachSess_in_cm(1,tr) < runThresh*pix2cmRatio
        if  normalized_meanPupDiameterAllTrials_allSessAsOneVector(1,tr) < pupThreshold
            loRunLoPupTrials = loRunLoPupTrials+1;
            num_loRunLoPupTrials = sum(loRunLoPupTrials);
        end 
    end
    
    if meanSpeedAllTrials_eachSess_in_cm(1,tr) > runThresh*pix2cmRatio
        if  normalized_meanPupDiameterAllTrials_allSessAsOneVector(1,tr) < pupThreshold
            hiRunLoPupTrials = hiRunLoPupTrials+1;
            num_hiRunLoPupTrials = sum(hiRunLoPupTrials);
        end 
    end
    
    if meanSpeedAllTrials_eachSess_in_cm(1,tr) < runThresh*pix2cmRatio
        if  normalized_meanPupDiameterAllTrials_allSessAsOneVector(1,tr) > pupThreshold
            loRunHiPupTrials = loRunHiPupTrials+1
            num_loRunHiPupTrials = sum(loRunHiPupTrials);
        end 
    end
  
end % end trial loop


num_hiRunHiPupTrials
num_loRunLoPupTrials

num_hiRunLoPupTrials
num_loRunHiPupTrials

tot_num_trials = sum([num_hiRunHiPupTrials,num_loRunLoPupTrials,num_hiRunLoPupTrials,num_loRunHiPupTrials])            




%%

tbl = table(

LastName = ['Sanchez';'Johnson';'Zhang';'Diaz';'Brown'];
Age = [38;43;38;40;49];
Smoker = [true;false;true;false;true];
Height = [71;69;64;67;64];
Weight = [176;163;131;133;119];
BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];

patients = table(LastName,Age,Smoker,Height,Weight,BloodPressure)

