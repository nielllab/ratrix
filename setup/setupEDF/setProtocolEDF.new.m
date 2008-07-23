function r = setProtocolEDF(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('subjIDs','var') || isempty(subjIDs)
    subjIDs=getEDFids;
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
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
        switch asgns(ind).experiment
            case {'goToSide' 'Flicker' 'Rel Cue' 'Rel Block' 'Box Transfer' 'Tube Transfer' 'Tube Physiology'}
                p=makeProtocol(asgns(ind).experiment,false);
                stepNum=1;
            case {'Testing'}
                p=makeProtocol(asgns(ind).experiment,true);
                stepNum=1;   
            case 'Cross Modal'
                error('cross modal not built yet')
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

    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolEDF','edf');
    clear('p','stepNum')
end