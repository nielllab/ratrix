    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
    
    getSubjectIDs(r)
    step=5
    subject='s'
    [p stepCurrent]=getProtocolAndStep(getSubjectFromID(r,subject))
     
     
    stim=getStimManager(getTrainingStep(getProtocolAndStep(getSubjectFromID(r,subject)),step))
    sch=getScheduler(getTrainingStep(getProtocolAndStep(getSubjectFromID(r,subject)),step))
    
    
    display(stim)

    display(sch)
    
   