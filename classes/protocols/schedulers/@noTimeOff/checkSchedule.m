function [keepWorking secsRemainingTilStateFlip updateScheduler scheduler] = checkSchedule(scheduler,subject,trainingStep)

keepWorking=1;
    secsRemainingTilStateFlip=0;
    updateScheduler =0;