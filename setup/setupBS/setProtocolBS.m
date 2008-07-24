function r = setProtocolBS(r,subIDs)

% error catching
if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('subIDs','var') || isempty(subIDs)
    subIDs=intersect(getBSids,getSubjectIDs(r));
end

if ~all(ismember(subIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

% This might be necesary later....
% % find the rack
%  rackNum=getRackIDFromIP;
%  asgns=[];
% % this might not be relevant for me
%  conn=dbConn;
%  heats=getHeats(conn);
%  for i=1:length(heats)
%      assignments=getAssignments(conn,rackNum,heats{i}.name);
%      for j=1:length(assignments)
%          if isempty(asgns)
%              asgns=assignments{j};
%          else
%              asgns(end+1)=assignments{j};
%          end
%      end
%  end
%  closeConn(conn);
%  
% asgns=asgns(ismember({asgns.owner},{'eflister' 'bsriram' 'pmeier'})); %162, 164 curently pmeier, 173-176 bsriram

for i=1:length(subIDs)
    switch subIDs{i}
        case {'testRat'}
            'came to testRat'
            p = makeProtocol('goToSidewPuff',subIDs{i},true);
            stepNum = 3;
        case {'267','268','269','270'}
            p = makeProtocol('goToSidewPuff',subIDs{i},false);
            stepNum = 3;
        otherwise
            'came to otherwise'
            p = makeProtocol('goToSidewPuff',subIDs{i},false);
            stepNum = 3;
    end
%     ind=find(strcmp(subIDs{i},{asgns.subject_id}));
%     if length(ind)==1 && ismember(asgns(ind).subject_id,getEDFids)
%         skip=false;
%         switch asgns(ind).experiment
%             case {'goToSide' 'Flicker' 'Rel Cue' 'Rel Block' 'Box Transfer' 'Tube Transfer' 'Tube Physiology'}
%                 p=makeProtocol(asgns(ind).experiment,false);
%                 stepNum=1;
%             case {'Testing'}
%                 p=makeProtocol(asgns(ind).experiment,true);
%                 stepNum=1;
%             case 'Cross Modal'
%                 skip=true;
%                 warning('cross modal not built yet')
%             otherwise
%                 subIDs{i}
%                 asgns(ind).experiment
%                 error('didn''t recognize experiment for subject')
%         end
%     else
%         subIDs{i}
%         ind
%         error('didn''t find unique subject id in db assignments for this rack or edf rat ids')
%     end
%
    
    subj=getSubjectFromID(r,subIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolBS','bs');
    fprintf('set %s on step %d of %s\n',subIDs{i},stepNum,'gotoSidewPuff')
    %fprintf('skipping %s on %s\n',subIDs{i},asgns(ind).experiment)
    clear('p','stepNum')
end