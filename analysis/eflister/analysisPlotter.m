function fs=analysisPlotter(selection,compiledFileDir,includeKeyboard)


% if ~isdeployed
% addpath('C:\Documents and Settings\rlab\Desktop\phil analysys');
% end

%compileTrialRecords

fs=[];
for i=1:size(selection.subjects,1)
    fs(end+1)=figure('Name',[selection.titles{i} '    ' selection.type],'NumberTitle','off');

    if length(size(selection.subjects))==3
        numRows=size(selection.subjects,2);
        numCols=size(selection.subjects,3);
    else
        numRows=1;
        numCols=1;
        if prod(size(selection.subjects))>1
            size(selection.subjects)
            selection.subjects
            error('bad selection.subjects')
        end
    end

    for j=1:numRows
        for k=1:numCols
            if ~isempty(selection.subjects{i,j,k})
                subplot(numRows,numCols,(j-1)*numCols+k)
                title(selection.subjects{i,j,k})
                doAnalysisPlot(compiledFileDir,selection.subjects{i,j,k},selection.type, selection.filter, selection.filterVal, selection.filterParam,includeKeyboard);
            end
        end
    end
end

%
% subjectID='159';
% compiledFile=fullfile(compiledFileDir,[subjectID '.compiledTrialRecords.*.mat']);
% d=dir(compiledFile);
% records=[];
% for i=1:length(d)
%     if ~d(i).isdir
%         [rng num er]=sscanf(d(i).name,[subjectID '.compiledTrialRecords.%d-%d.mat'],2);
%         if num~=2
%             d(i).name
%             er
%         else
%             ctr=load(fullfile(compiledFileDir,d(i).name));
%             records=ctr.compiledTrialRecords;
%         end
%     end
% end
%
% if ~isempty(records)
%     processedRecords.info.subject={subjectID};
%     processedRecords.response=zeros(1,length(records));
%     processedRecords.correctionTrial=zeros(1,length(records));
%     processedRecords.date=zeros(1,length(records));
%     processedRecords.correct=zeros(1,length(records));
%     processedRecords.step=zeros(1,length(records));
%
%     for i=1:length(records)
%         processedRecords.step(i)=length(records(i).stimDetails.orientations);
%         resp=find(records(i).response);
%         if length(resp)~=1 || ischar(records(i).response)
%             processedRecords.response(i)=-1;
%         else
%             processedRecords.response(i)=resp(1);
%         end
%         processedRecords.date(i)=datenum(records(i).date);
%         if ismember('correctionTrial',fields(records(i).stimDetails))
%             processedRecords.correctionTrial(i)=records(i).stimDetails.correctionTrial;
%         else
%             processedRecords.correctionTrial(i)=false;
%         end
%     end
%     processedRecords.correct=[records.correct];
%
%     doPlot('plotTrialsPerDay',processedRecords);
%     figure
%     doPlot('percentCorrect',processedRecords);
%     figure
%     doPlot('plotBias',processedRecords);
%     figure
%     doPlot('plotRatePerDay',processedRecords);
% else
%     d.name
%     error('didn''t find any records')
% end
