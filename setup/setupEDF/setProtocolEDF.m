function r = setProtocolEDF(r,subIDs)

if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('subIDs','var') || isempty(subIDs)
    subIDs=intersect(getEDFids,getSubjectIDs(r));
end

if strcmpi(subIDs,'test')
    subIDs=getEDFids;
    subIDs={subIDs{~cellfun(@isempty,strfind(lower(subIDs),sprintf('rack%dtest',getRackIDFromIP)))}};
end

if ~all(ismember(subIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

rackNum=getRackIDFromIP;
asgns=[];
conn=dbConn;
heats=getHeats(conn);
for i=1:length(heats)
    assignments=getAssignments(conn,rackNum,heats{i}.name);
    for j=1:length(assignments)
        if isempty(asgns)
            asgns=assignments{j};
        else
            asgns(end+1)=assignments{j};
        end
    end
end
closeConn(conn);

asgns=asgns(ismember({asgns.owner},{'eflister' 'bsriram' 'pmeier'})); %162, 164 curently pmeier, 173-176 bsriram

for i=1:length(subIDs)
    ind=find(strcmp(subIDs{i},{asgns.subject_id}));
    if length(ind)==1 && ismember(asgns(ind).subject_id,getEDFids)
        skip=false;
        switch asgns(ind).experiment
            case {'goToSide' 'Flicker' 'Rel Cue' 'Rel Block' 'Box Transfer' 'Tube Transfer' 'Tube Physiology'}
                p=makeEDFProtocol(asgns(ind).experiment,false);
                stepNum=1;
            case {'Testing'}
                p=makeEDFProtocol(asgns(ind).experiment,true);
                stepNum=1;
            case 'Cross Modal'
                skip=true;
                warning('cross modal not built yet')
            otherwise
                subIDs{i}
                asgns(ind).experiment
                error('didn''t recognize experiment for subject')
        end
    else
        subIDs{i}
        ind
        error('didn''t find unique subject id in db assignments for this rack or edf rat ids')
    end

    if ~skip
        subj=getSubjectFromID(r,subIDs{i});
        [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolEDF','edf');
        fprintf('set %s on step %d of %s\n',subIDs{i},stepNum,asgns(ind).experiment)
    else
        fprintf('skipping %s on %s\n',subIDs{i},asgns(ind).experiment)
    end
    clear('p','stepNum','skip')
end