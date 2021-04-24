% CONTRAST calc's
% this part needed for any loops involving looping over CONTRAST:

% need to make vectors with contrast values 
for i=1:length(stimDetails); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    % note: stim details contains info (incl. contrast values) for every 
    % possible condition. It is NOT ordered by trial.
    con(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end

% note: trial cond is a list of indicies for tc/stimdetails.targContrast.
% These indicies *are* ordered by trial
% so now, by using trialCond to index into tc, we can get a list of target
% contrasts in the order that they were presented:

conOrderedByTrial = con(trialCond); % use trial cond to index into vector of 
% target contrast value for that condition during each trial, save in new
% vector 'conTrial' that is a list of trial conditions ordered by trial

uniqueContrasts = unique(con); % gets a list of the contrast value options, 
% so we know how many contrasts to loop over

%%
range = [0 0.1];

% LOAD CORRECT MOUSE/EXPERIMENT FILE

frames = [12 15 18 21];
s = 1 ;

% date
[filepath,name,ext] = fileparts('20210411T123140_25.mat')

datePart = name(1:8);

year = datePart(1:4);
month = datePart(5:6);
day = datePart(7:8);

date = sprintf('%s ', month, day, year);

clear c
figure

subjName = subjData{1,1}.name % subjNameStr is a char, not string
titleText = ': peri-stimulus cortical response to varying contrasts' % making char variables for sprintf/title later
supTit = suptitle(sprintf('%s', date, subjName, titleText))
set(supTit, 'FontSize', 14)

for c = 1:length(uniqueContrasts);    

     clear cthTrials
     cthConOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetsMeetBothCriteria);
     cthTrials = cthConOrderedByTrialMeetCriteria == uniqueContrasts(c);
     %cthTrials = cthConOrderedByTrialMeetCriteria == contrasts(c);
   
    for f = 1:length(frames) 
        
        subplot(7,4,s)
        
        imagesc(mean(onsetDf(:,:,frames(f),cthTrials),4)-mean(onsetDf(:,:,11,cthTrials),4),range); 
        
        s = s + 1;
        axis off;
        axis image;

    end
    
end



