function compileDetailedRecords(ids,pth,outPth)
ids={'225','226','239','241'};
pth='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
outPth='C:\Documents and Settings\rlab\Desktop\detailedRecords';

%the following is stolen from compileTrialRecords -- this function should be
%integrated into that function so don't have to open individual trialRecord files twice
subjectFiles={};
ranges={};
for i=1:length(ids)
    [subjectFiles{end+1} ranges{end+1}]=getTrialRecordFiles(fullfile(pth,ids{i})); %unreliable if remote
end

%this will recompile from scratch every time -- integrate into
%compileTrialRecords so only compiles new data by default

classes={};

for i=1:length(ids)
    expectedTrialNumber=1;
    for j=1:length(subjectFiles{i})
        fprintf('doing %s of %d\n',subjectFiles{i}{j},ranges{i}(2,end));
        tr=load(subjectFiles{i}{j});
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
                fprintf('making first %s\n',tr(k).stimManagerClass)
                classes{1,end+1}=tr(k).stimManagerClass;
                classes{2,end}=eval(tr(k).stimManagerClass); %construct default stimManager of correct type, to fake static method call
                ind=size(classes,2);
            end
            sm=classes{2,ind};

        end
    end
    compiledDetails=[];
    save(fullfile(outPth,sprintf('compiledDetails.%s.%d-%d.mat',ids{i},ranges{i}(1,1),ranges{i}(2,end))),'compiledDetails');
end