function fixData
diary off
clc
diary(['diary.' num2str(now) '.txt'])

permanentStore='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects';

subjectDirs=dir(permanentStore);
subjectDirs
for d=1:length(subjectDirs)

    if ~ismember(subjectDirs(d).name,{'..','.'}) && subjectDirs(d).isdir % && str2num(subjectDirs(d).name)>=184
        %clc
        ['doing ' subjectDirs(d).name]
        historyFiles=dir(fullfile(permanentStore,subjectDirs(d).name));
        goodHistoryFiles={};
        badHistoryFiles={};
        ranges=[];
        for i=1:length(historyFiles)
            if ~ismember(historyFiles(i).name,{'..','.'}) && ~historyFiles(i).isdir
                if isempty(findstr('old',historyFiles(i).name)) && isempty(findstr('recov',historyFiles(i).name))
                    [rng num er]=sscanf(historyFiles(i).name,'trialRecords.%d-%d.mat',2);
                    if num~=2
                        historyFiles(i).name
                        er
                        error('sscanf fail')
                    else
                        goodHistoryFiles{end+1}=fullfile(permanentStore,subjectDirs(d).name,historyFiles(i).name);
                        ranges(:,end+1)=rng;
                    end
                else
                    badHistoryFiles{end+1}=fullfile(permanentStore,subjectDirs(d).name,historyFiles(i).name);
                end
            end
        end



        [sorted order]=sort(ranges(1,:));
        ranges=ranges(:,order);
        goodHistoryFiles=goodHistoryFiles(order);


        for i=1:size(ranges,2)
            if i==1
                if ranges(1,i)~=1
                    ranges
                    error('first verifiedHistoryFile doesn''t start at 1')
                end
            else
                if ranges(1,i)~=ranges(2,i-1)+1
                    ranges
                    error('ranges don''t follow consecutively')
                end
            end
        end
        if max(ranges(:)) ~= ranges(2,end)
            ranges
            error('didn''t find max at bottom right corner of ranges')
        end


        for i=1:length(goodHistoryFiles)
            fprintf('%s\n',goodHistoryFiles{i})
        end
        ranges
        for i=1:length(badHistoryFiles)
            fprintf('%s\n',badHistoryFiles{i})
        end


        if length(historyFiles)~=length(badHistoryFiles)+length(goodHistoryFiles)+sum([historyFiles.isdir])
            error('bad sum')
        end

        
        goodRecs=struct([]);
        goodDates=[];
        for i=1:length(goodHistoryFiles)
            ['loading '  goodHistoryFiles{i}]
            newRecs=load(goodHistoryFiles{i});

            if isempty(goodRecs)
                goodRecs=orderfields(newRecs.trialRecords);
            else

                [newRecs.trialRecords,goodRecs]=makeFieldsCompatible(newRecs.trialRecords,goodRecs);



                goodRecs(end+1:end+length(newRecs.trialRecords))=orderfields(newRecs.trialRecords);


            end
        end

        if all([goodRecs.trialNumber]==1:length(goodRecs))
            for j=1:length(goodRecs)
                goodDates(end+1)=datenum(goodRecs(j).date);
            end
            if ~all(diff(goodDates)>0)
                error('bad dates in good recs')
            end

            for j=1:length(goodRecs)
                if ~length(goodRecs(j).subjectsInBox)==1 && ismember(subjectDirs(d).name,goodRecs(j).subjectsInBox)
                    error('bad subject in good recs')
                end
            end

            goodRecs(end).date


            badRecs=struct([]);
            badDates=[];
            for j=1:length(badHistoryFiles)
                isDupe=true;
                newRecs=load(badHistoryFiles{j},'-mat');
                for k=1:length(newRecs.trialRecords)
                    match=find(datenum(newRecs.trialRecords(k).date)==goodDates);
                    if ~isempty(match)
                        if length(match)>1
                            match
                            error('too many matches')
                        else
                            if isSame(goodRecs(match),newRecs.trialRecords(k))
                            else
                                error('matching date, not matching trial')
                            end
                        end
                    else

                        if k>1 && isDupe
                            error('got a non dupe after a dupe')
                        end
                        isDupe=false;
                    end
                end
                badHistoryFiles{j}
                isDupe



                backupDir=fullfile(permanentStore,subjectDirs(d).name,'old');
                [succ,message,messageid] = mkdir(backupDir);
                if succ
                    [succ,message,messageid] = movefile(badHistoryFiles{j},backupDir);
                    if succ
                        %good
                    else
                                            message
                    messageid
                    error('couldn''t movefile')
                    end
                else
                    message
                    messageid
                    error('couldn''t mkdir')
                end



                if ~isDupe
                    if isempty(badRecs)
                        badRecs=orderfields(newRecs.trialRecords);
                    else
                        [badRecs newRecs.trialRecords]=makeFieldsCompatible(badRecs,newRecs.trialRecords);

                        badRecs(end+1:end+length(newRecs.trialRecords))=orderfields(newRecs.trialRecords);
                    end
                    for k=1:length(newRecs.trialRecords)
                        badDates(end+1)=datenum(newRecs.trialRecords(k).date);
                    end
                end
            end
            length(badRecs)
            [badDates order]=sort(badDates);
            datevec(badDates(1))
            datevec(badDates(end))
            
            if badDates(1)>goodDates(end)
                badRecs=badRecs(order);
                for k=1:length(badRecs)
                    if k==1
                    badRecs(k).trialNumber=ranges(2,end)+1;
                    else
                        badRecs(k).trialNumber=badRecs(k-1).trialNumber+1;
                    end
                    if length(badRecs(k).subjectsInBox)==1 && strcmp(badRecs(k).subjectsInBox{1},subjectDirs(d).name)
                        %good
                    else
                        error('bad subject in box')
                    end
                end
                badRecs(1).trialNumber
                badRecs(end).trialNumber
                trialRecords=badRecs;
                save(fullfile(permanentStore,subjectDirs(d).name,sprintf('synthesized.trialRecords.%d-%d.mat',badRecs(1).trialNumber,badRecs(end).trialNumber)),'trialRecords');
            else
                error('date in bads before last date in goods')
            end
        else
            error('bad trial numbers in good recs')
        end


        %pause
    end
end





function out=isSame(a,b)
out=true;

fs={'correct',...
    'response',...
    'targetPorts',...
    'distractorPorts',...
    'stimManagerClass',...
    'trainingStepNum',...
    'protocolName',...
    'date'};

%trialNumber

for f=1:length(fs)
    out=out && all(a.(fs{f}) == b.(fs{f}));
end

out=out && strcmp(a.subjectsInBox{1},b.subjectsInBox{1}) && length(a.subjectsInBox)==1 && length(b.subjectsInBox)==1;





function [a b]=makeFieldsCompatible(a,b)

fs=fields(a);
fieldMatches=ismember(fs,fields(b));
mismatches=find(fieldMatches==0);

for m=1:length(mismatches)
    ['adding ' fs{m} ' to old' ]
    [b.(fs{m})]=deal([]);

end
b=orderfields(b);

fs=fields(b);
fieldMatches=ismember(fs,fields(a));
mismatches=find(fieldMatches==0);

for m=1:length(mismatches)
    ['adding ' fs{m} ' to new' ]
    [a.(fs{m})]=deal([]);

end
a=orderfields(a);




%                 fs=fields(newRecs.trialRecords);
%                 fieldMatches=ismember(fs,fields(goodRecs));
%                 mismatches=find(fieldMatches==0);
%
%                 for m=1:length(mismatches)
%                     ['adding ' fs{m} ' to old' ]
%                     goodRecs.(fs{m})=[];
%                     goodRecs=orderfields(goodRecs);
%                 end
%
%
%                                 fs=fields(goodRecs);
%                 fieldMatches=ismember(fs,fields(newRecs.trialRecords));
%                 mismatches=find(fieldMatches==0);
%
%                 for m=1:length(mismatches)
%                     ['adding ' fs{m} ' to new' ]
%                     newRecs.trialRecords.(fs{m})=[];
%                     newRecs.trialRecords=orderfields(newRecs.trialRecords);
%                 end



% 	dates=[reshape([x.trialRecords.date],6,length(x.trialRecords))]';
%     unique(dates(:,3))
