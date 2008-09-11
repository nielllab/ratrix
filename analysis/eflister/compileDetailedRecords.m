%should replace compileTrialRecords, but of course will break lots of graphing -- will need to update graphing code
function compileDetailedRecords(ids,pth,outPth)
type='images';

switch type
    case 'crossModal'
        ids={'225','226','239','241'};
        pth='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
    case 'images'
        ids={'280','281','283'};
        pth='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\subjects';
    otherwise
        error('unrecognized type')
end
outPth='C:\Documents and Settings\rlab\Desktop\detailedRecords';

subjectFiles={};
ranges={};
for i=1:length(ids)
    [subjectFiles{end+1} ranges{end+1}]=getTrialRecordFiles(fullfile(pth,ids{i})); %unreliable if remote
end

%this will recompile from scratch every time -- add feature to only compile new data by default

sm=stimManager;
classes={};
for i=1:length(ids)
    fprintf('\ndoing %s\n',ids{i});
    compiledDetails=[];
    basicRecs=[];
    expectedTrialNumber=1;
    for j=1:length(subjectFiles{i})
        for k=1:size(classes,2)
            classes{3,k}=[];
        end
        fprintf('\tdoing %s of %d\n',subjectFiles{i}{j},ranges{i}(2,end));
        warning('off','MATLAB:elementsNowStruc'); %expect some class defs to be out of date, will get structs instead of objects (shouldn't keep objects in records anyway)
        tr=load(subjectFiles{i}{j});
        warning('on','MATLAB:elementsNowStruc');
        tr=tr.trialRecords;
        for k=1:length(tr)
            if tr(k).trialNumber ~= expectedTrialNumber
                tr(k).trialNumber
                expectedTrialNumber
                error('got unexpected trial number')
            else
                expectedTrialNumber=expectedTrialNumber+1;
            end
            if ~isempty(classes)
                ind=find(strcmp(tr(k).stimManagerClass,classes(1,:)));
            else
                ind=[];
            end
            if length(ind)==1
                %nothing
            elseif length(ind)>1
                error('found more than one cached default stim manager class match')
            else
                fprintf('\t\tmaking first %s\n',tr(k).stimManagerClass)
                classes{1,end+1}=tr(k).stimManagerClass;
                classes{2,end}=eval(tr(k).stimManagerClass); %construct default stimManager of correct type, to fake static method call
                classes{3,end}=[];
                ind=size(classes,2);
            end
            classes{3,ind}(end+1)=k;
        end

        newBasicRecs=extractBasicFields(sm,tr);
        verifyAllFieldsNCols(newBasicRecs,length(tr));
        if isempty(basicRecs)
            basicRecs=newBasicRecs;
        else
            basicRecs=concatAllFields(basicRecs,newBasicRecs);
        end

        for c=1:size(classes,2)
            if length(classes{3,c})>0 %prevent subtle bug that is easy to write into extractDetailFields -- if you send zero trials to them, they may try to look deeper than the top level of fields, but they won't exist ('MATLAB:nonStrucReference') -- see example in crossModal.extractDetailFields()
                %no way to guarantee that a stim manager's calcStim will make a stimDetails
                %that includes all info its super class would have, so cannot call this
                %method on every anscestor class.  must leave calling super class's
                %extractDetailFields up to the sub class.
                newRecs=extractDetailFields(classes{2,c},colsFromAllFields(newBasicRecs,classes{3,c}),tr(classes{3,c}));

                verifyAllFieldsNCols(newRecs,length(classes{3,c}));
                bailed=isempty(fieldnames(newRecs)); %extractDetailFields bailed for some reason (eg unimplemented or missing fields from old records)

                if length(compiledDetails)<c
                    compiledDetails(c).className=classes{1,c};
                    if bailed
                        compiledDetails(c).records=[];
                    else
                        compiledDetails(c).records=newRecs;
                    end
                    compiledDetails(c).trialNums=[];
                    compiledDetails(c).bailedTrialNums=[];
                elseif strcmp(compiledDetails(c).className,classes{1,c})
                    if ~bailed
                        compiledDetails(c).records=concatAllFields(compiledDetails(c).records,newRecs);
                    end
                else
                    error('class name doesn''t match')
                end
                tmp=colsFromAllFields(newBasicRecs,classes{3,c});
                if bailed
                    compiledDetails(c).bailedTrialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                else
                    compiledDetails(c).trialNums(end+1:end+length(classes{3,c}))=tmp.trialNumber;
                end
            end
        end
    end
    save(fullfile(outPth,sprintf('compiledDetails.%s.%d-%d.mat',ids{i},ranges{i}(1,1),ranges{i}(2,end))),'compiledDetails','basicRecs');


    tmp=[];
    for c=1:length(compiledDetails)
        newNums=[compiledDetails(c).trialNums compiledDetails(c).bailedTrialNums];
        tmp=[tmp [newNums;repmat(c,1,length(newNums))]];
    end
    [a b]=sort(tmp(1,:));
    if any(a~=1:length(a))
        error('missing trials')
    end
    doPlot=true;
    if doPlot
        figure
        tmp=tmp(:,b);
        plot(tmp(1,:),tmp(2,:))
    end
end
end

function a=concatAllFields(a,b)
if isempty(a) && isscalar(b) && isstruct(b)
    a=b;
    return
end
if isscalar(a) && isscalar(b) && isstruct(a) && isstruct(b)
    fn=fieldnames(a);
    if all(ismember(fieldnames(b),fn))
        for k=1:length(fn)
            numRowsBNeeds=size(a.(fn{k}),1)-size(b.(fn{k}),1);
            if iscell(a.(fn{k})) && iscell(b.(fn{k}))
                if numRowsBNeeds~=0
                    error('nan padding cells not yet implemented')
                end
                a.(fn{k})(:,end+1:end+size(b.(fn{k}),2))=b.(fn{k});
            elseif ~iscell(a.(fn{k})) && ~iscell(b.(fn{k})) %anything else to check?  %isarray(a.(fn{k})) && isarray(b.(fn{k}))
                if numRowsBNeeds>0
                    b.(fn{k})=[b.(fn{k});nan*zeros(numRowsBNeeds,size(b.(fn{k}),2))];
                elseif numRowsBNeeds<0
                    a.(fn{k})=[a.(fn{k});nan*zeros(-numRowsBNeeds,size(a.(fn{k}),2))];
                end
                a.(fn{k})=[a.(fn{k}) b.(fn{k})];
            else
                error('only works if both are cells or both are arrays')
            end
        end
    else
        error('b has fields not in a')
    end
else
    a
    b
    error('a and b have to both be scalar struct')
end

end