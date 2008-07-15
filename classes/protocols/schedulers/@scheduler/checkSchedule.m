function [keepWorking secsRemainingTilStateFlip updateScheduler scheduler] = checkSchedule(scheduler,subject,trainingStep,trialRecords,sessionNumber)
    keepWorking=1;
    secsRemainingTilStateFlip=0;
    updateScheduler=0;
    newScheduler=[];
