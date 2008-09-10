function detailAnalysis
ids={'225','226','241'};
pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';
sm=crossModal;
for i=1:length(ids)
    f=dir(fullfile(pth,sprintf('compiledDetails.%s.1-*.mat',ids{i})));
    if length(f)==1
        fprintf('loading %s\n',f(1).name);
        r=load(fullfile(pth,f(1).name));
        n=find(strcmp('crossModal',{r.compiledDetails.className}));
        if length(n)==1
            detailRecords=colsFromAllFields(r.basicRecs,r.compiledDetails(n).trialNums);
            detailRecords=mergeStructs(detailRecords,r.compiledDetails(n).records);
            analysis(sm,detailRecords,ids{i});
        else
            error('bad stim manager matches')
        end
    else
        error('bad file matches')
    end
end
end