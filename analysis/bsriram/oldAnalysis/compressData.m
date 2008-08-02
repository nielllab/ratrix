function d = compressData(t)
    % Define the flat structure. Instantiate it.
    d(length(t)).rat = [];
    d(length(t)).trialNumber = [];
    d(length(t)).trialtype = [];
    d(length(t)).date = [];
    d(length(t)).correction = [];
    d(length(t)).target = [];
    d(length(t)).response = [];
    d(length(t)).correct = [];
    d(length(t)).eyepuffMS = [];
    d(length(t)).rewdur = [];
    d(length(t)).licks = [];
    d(length(t)).licktimes = [];
    d(length(t)).lickdur = [];

    for i = 1:length(t)
        d(i).rat = t(i).subjectsInBox;
        d(i).trialNumber = t(i).trialNumber;
        d(i).trialtype = t(i).trialManagerClass;
        d(i).date = t(i).date;
        try
            d(i).correction = t(i).stimDetails.correctionTrial;
        catch
            d(i).correction = [];
        end
        d(i).target = t(i).targetPorts;
        d(i).response = t(i).response;
        d(i).correct = t(i).correct;
        d(i).eyepuffMS = t(i).trialManager.trialManager.eyepuffMS;
        d(i).rewdur = t(i).actualRewardDuration;
        try 
            d(i).licks = t(i).responseDetails.tries;
        catch
            d(i).licks = [];
        end
        try
            d(i).licktimes = t(i).responseDetails.times;
        catch
            d(i).licktimes = [];
        end
        try
            d(i).lickdur = t(i).responseDetails.durs;
        catch
            d(i).lickdur = [];
        end         
    end
end
        