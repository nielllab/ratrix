% adds session number to permStore records.

permStoreRack2 = '\\Reinagel-lab.ad.ucsd.edu\RLAB\Rodent-Data\ratrixAdmin\subjects';

for rat = {'268','269','270'}%{'267'}%
    display(char(rat));
    pause(0);
    
    d = dir(fullfile(permStoreRack2,char(rat)));
    d = d(~ismember({d.name},{'.','..'}));
    dNameVec = strvcat(d.name);
    
    display(['number of session Records: ' int2str(length(d))]);
    pause(0);
    
    currentTrialNo = 1;
    
    for currentSessionNo = 1: length(d) 
        display(int2str(currentSessionNo));pause(0);
        currentPattern = ['trialRecords_' int2str(currentTrialNo) '-'];
        currentHit = strmatch(currentPattern, dNameVec);
        currentTrialRecName = d(currentHit).name;
        display(char(currentTrialRecName));
        pause(0);
        load(fullfile(permStoreRack2,char(rat),currentTrialRecName));
        for tNo = 1:length(trialRecords)
            trialRecords(tNo).sessionNumber = currentSessionNo;
        end
        save(fullfile(permStoreRack2,char(rat),currentTrialRecName),'trialRecords');
        currentTrialNo = trialRecords(end).trialNumber + 1;
    end
    display(['done rat' char(rat)]);
    pause(1);
end
