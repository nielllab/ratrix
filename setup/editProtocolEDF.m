function editProtocolEDF(r,subIDs,stepNums,comment,auth)
%can't be used remotely cuz ratrices use their own stored path to themselves, which is a local path

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData',filesep);
    %dataPath='\\mtrix2\Users\nlab\Desktop\mouseData\';
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('setNums','var') || isempty(stepNums)
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

requestMode               = 'first';
fractionOpenTimeSoundIsOn = 1;
fractionPenaltySoundIsOn  = 1;
scalar                    = 1;

requestRewardSizeULorMS   = 0;
rewardSizeULorMS          = 90;
msPenalty                 = 7000;

msAirpuff                 = msPenalty;

rm=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

subs=getSubjectsFromIDs(r,subIDs);

juvs={'e1rt','e2rt','e1lt','e2lt'};
adus={'n5rt','n5rn','n5lt','n8lt'};

for i=1:length(subs)
    [p t]=getProtocolAndStep(subs{i});
    if ~isempty(p)
        for j=1:getNumTrainingSteps(p)
            ts=getTrainingStep(p,j);
            
            if j==getNumTrainingSteps(p) || j==getNumTrainingSteps(p)-1
                
                if any(getID(subs{i})=='l') || true
                    ts = setTrialManager(ts, setResponseWindow(getTrialManager(ts), [800 inf]));
                end
                
                if false
                    ts = setReinforcementParam(ts,'reinforcementManager',rm);
                    ts = setCriterion(ts,performanceCriterion(.85,int32(200)));
                end
                
                p = changeStep(p, ts, uint8(j));
                
                if false
                    ts2 = setStimManager(ts, setSideDisplay(getStimManager(ts),1));
                    p=addTrainingStep(p, setCriterion(ts2,repeatIndefinitely));
                end
                
                [~, r]=setProtocolAndStep(subs{i},p,true,true,false,t,r,comment,auth);
            end
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