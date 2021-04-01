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

frames = [12 15 18 21];
s = 1 ;%

% left=1;
% bottom=0;
% 
% width=4;
% height=7; 
% 
% pos = [left bottom width height]
clear c
figure
for c = 1:length(uniqueContrasts); % for each unique contrast
% for c = 1:length(contrasts);    

%    trials =  abs(tcTrial)==contrasts(c);
%    trialsMinusOne = trials(1,1:length(trials)-1); 

     clear cthTrials
     cthConOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetsMeetBothCriteria);
     cthTrials = cthConOrderedByTrialMeetCriteria == uniqueContrasts(c);
   
    for f = 1:length(frames) 
        %subplot(7,4,'Position',pos)
        subplot(7,4,s)
        %axes('Position',[left bottom width height])
        imagesc(mean(onsetDf(:,:,frames(f),cthTrials),4)-mean(onsetDf(:,:,11,cthTrials),4),range);   
%         
        s = s + 1;
        axis off;
        axis image;

    end
    
end

% A = mean(onsetDf(:,:,frames(f),cthTrialsMinusOne),4)-mean(onsetDf(:,:,11,cthTrialsMinusOne),4);
% imagesc(linspace(0,1,4),linspace(0,1,7),A)
% imageChangeInDfFromStimOnseToFrameNum = mean(onsetDf(:,:,frames(f),cthTrialsMinusOne),4)-mean(onsetDf(:,:,11,cthTrialsMinusOne),4);
% imagesc(linspace(0,1,4),linspace(0,1,7),imageChangeInDfFromStimOnseToFrameNum)
        