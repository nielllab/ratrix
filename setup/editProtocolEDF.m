function editProtocolEDF(r,subIDs,stepNums,comment,auth)
%can't be used remotely cuz ratrices use their own stored path to themselves, which is a local path

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

if ~exist('r','var') || isempty(r)
    %dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData',filesep);
    
    mtrix=4;
    %dataPath=['\\mtrix' num2str(mtrix) '\Users\nlab\Desktop\mouseData\'];
    
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('stepNums','var') || isempty(stepNums)
    stepNums='all';
end

if ~exist('subIDs','var') || isempty(subIDs)
    %    subIDs=intersect(getEDFids,getSubjectIDs(r));
    subIDs=getSubjectIDs(r);
end

if ~all(ismember(subIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

if ~exist('auth','var')
    auth='unspecified'; %bad idea?
end

if ~exist('comment','var')
    comment='';
end

if false
    requestMode               = 'first';
    fractionOpenTimeSoundIsOn = 1;
    fractionPenaltySoundIsOn  = 1;
    scalar                    = 1;
    
    requestRewardSizeULorMS   = 0;
    rewardSizeULorMS          = 40;
    msPenalty                 = 14000;
    
    msAirpuff                 = msPenalty;
    
    rm=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
end

subs=getSubjectsFromIDs(r,subIDs);

juvs={'e1rt','e2rt','e1lt','e2lt'};
adus={'n5rt','n5rn','n5lt','n8lt'};

for i=1:length(subs)
    [p t]=getProtocolAndStep(subs{i});
    if ~isempty(p)
        ts=getTrainingStep(p,getNumTrainingSteps(p));
        
        if true
            sm = getStimManager(ts);
            switch mtrix
                case 3
                    p=addTrainingStep(p,setStimManager(ts,setOrientations(sm,{getDistractorOrientations(sm) [] getTargetOrientations(sm)},'abstract')));
                case 4
                    tilt=pi/4;
                    p=addTrainingStep(p,setStimManager(ts,setOrientations(sm,tilt,-tilt)));
                otherwise
                    error('bad mtrix')
            end
            ts = setCriterion(ts,performanceCriterion(.9,int32(200)));
            p = changeStep(p, ts, uint8(getNumTrainingSteps(p)-1));
            
            [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t,r,comment,auth);
        end
        
        if false
            setRewardULorMS(subs{i},30,1,comment,auth);
        end
        
        if false
            [~, r]=setReinforcementParam(subs{i},'reinforcementManager',rm,getNumTrainingSteps(p),r,comment,auth);
        end
        
        if false
            p=addTrainingStep(p,setStimManager(ts, setShapeMethod(setPosition(setSideDisplay(getStimManager(ts),.5),.5),'position')));
            [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t+1,r,comment,auth);
        end
        
        if false
            dots = getStimManager(ts);
            
            s.speed=1.5;
            s.contrast=.25;
            s.dot_size=20;
            s.num_dots=5;
            dots=setDotParams(dots,s);
            
            background.contrastFactor=2;
            background.sizeFactor=2;
            background.densityFactor=10;
            dots=setBackground(dots,background);
            
            ts = setStimManager(ts, dots);
            p = changeStep(p, ts, uint8(getNumTrainingSteps(p)));
            [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t,r,comment,auth);
        end
        
        if false
            if any(getID(subs{i})=='l')
                ts = setTrialManager(ts, setResponseWindow(getTrialManager(ts), [800 inf]));
            end
            
            ts = setReinforcementParam(ts,'reinforcementManager',rm);
            ts = setCriterion(ts,performanceCriterion(.85,int32(200)));
            p = changeStep(p, ts, uint8(getNumTrainingSteps(p)));
            
            ts2 = setStimManager(ts, setSideDisplay(getStimManager(ts),1));
            p=addTrainingStep(p, setCriterion(ts2,repeatIndefinitely));
            
            [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t,r,comment,auth);
        end
        
        if false
            ts2 = setStimManager(ts, setCoherence(setDur(setSideDisplay(getStimManager(ts),.5),10),1));
            p=addTrainingStep(p,setReinforcementParam(ts2,'reinforcementManager',rm));
            
            p = changeStep(p, setCriterion(ts,numTrialsDoneCriterion(400)), uint8(getNumTrainingSteps(p)-1));
            
            [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t,r,comment,auth);
            %    [~, r]=setReinforcementParam(subs{i},'reinforcementManager',rm,6,r,comment,auth);
        end
    end
end

reportSettings(r)
end