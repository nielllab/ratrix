function [keepWorking secsRemainingTilStateFlip updateSchedule scheduler] = checkSchedule(scheduler,subject,trainingStep)
    keepWorking=1;
    secsRemainingTilStateFlip=0;
    updateSchedule=0;