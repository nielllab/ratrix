function detailAnalysis
ids={'225','226','239','241'};
pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';

for i=1:length(ids)
    f=dir(fullfile(pth,sprintf('compiledDetails.%s.1-*.mat',ids{i})));
    if length(f)==1
        fprintf('loading %s\n',f(1).name);
        r=load(fullfile(pth,f(1).name));

        sms={r.compiledDetails.className};
        for j=1:length(sms)
            if ~isempty(r.compiledDetails(j).trialNums)
                sm=eval(sms{j});
                detailRecords=colsFromAllFields(r.basicRecs,r.compiledDetails(j).trialNums);
                detailRecords=mergeStructs(detailRecords,r.compiledDetails(j).records);
                analysis(sm,detailRecords,ids{i});
            end
        end
    else
        error('bad file matches')
    end
end
end