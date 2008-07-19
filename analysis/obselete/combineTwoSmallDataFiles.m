function combined=combineTwoSmallDataFiles(d1,d2, toleratedOverlap, verbose)

if ~exist ('toleratedOverlap', 'var')
    toleratedOverlap=0;
end

if ~exist ('verbose', 'var')
    verbose=1;
end

if isempty(d1)
    combined=d2;
    %end this function
end

if isempty(d2)
    combined=d1;
    %end this function
end

%check that there is more data than just the info field
d1HasTrialData=0;
d2HasTrialData=0;
if ~isempty(d1) & ~isempty(d2) %can't do fields on the empty set
    f1=fields(d1);
    f2=fields(d2);
    if length(f1)<2
        combined=d2;
    else
        d1HasTrialData=1;
    end
    if length(f2)<2
        combined=d1;
    else
        d2HasTrialData=1;
    end
end

if ~isempty(d1) & ~isempty(d2) %this only happens if there is data to combine
    if d1HasTrialData & d2HasTrialData %this only happens if there is trialData

        %make sure d1 comes first
        if min(d1.date)>min(d2.date)
            temp=d1;
            d1=d2;
            d2=temp;
            f1=fields(d1);
            f2=fields(d2);
        end

        %check for overlapping trials
        combinedDates=[d1.date d2.date];
        uniques= unique (combinedDates);
        if verbose
            if size(uniques,2)<size(d1.date,2)+size(d2.date,2)
                display('there are overlapping trials')
            else
                display ('there is no overlap here')
            end
        end

        %determining non-overlapping trials, if any, otherwise total number of trials.
        [uniqueNewDates newIndices]=setdiff(d2.date, d1.date);

        %confirm the end of d1 is before the beginning of d2
        if max(d1.date)>min(d2.date)
            overlapDays=max(d1.date)-min(d2.date);
            display (sprintf('there are intermixed trial dates, overlap days: %d', overlapDays))
            %we expect there to be overlap of about two to three days
            if overlapDays>toleratedOverlap
                error(['more than toleratedOverlap of ' toleratedOverlap 'days'])
            end
        end


        if any(strcmp(f1,'info'))
            f1(find(strcmp(f1,'info')))=[];
        end
        if any(strcmp(f2,'info'))
            f2(find(strcmp(f2,'info')))=[];
        end

        %if there are new fields in d2 then fill them in d1
        for i=1:length(f2)
            if ~any(strcmp(f1,f2{i}))
                if verbose
                    disp(sprintf('found a new field in d2 that is not present in d1: %s',f2{i}))
                end
                %add nans for undefined field in the past (the past is d1)
                command=sprintf('d1.%s=nan(size(d1.date));',f2{i});
                try
                    eval(command)
                catch
                    disp(command);
                    e=lasterr;
                    e
                    error('problem with this command')
                end
            end
        end

        %redo for safety, because new terms may have been added.... but I doubt it
        f1=fields(d1);
        if any(strcmp(f1,'info'))
            f1(find(strcmp(f1,'info')))=[];
        end

        %if there are new fields in d1 then fill them in d2
        for i=1:length(f1)
            if ~any(strcmp(f2,f1{i}))
                if verbose
                    disp(sprintf('found a new field in d1 that is not present in d2: %s',f1{i}))
                end
                %add nans for undefined field in the future (the future is d1)
                command=sprintf('d2.%s=nan(size(d2.date));',f1{i});
                try
                    eval(command);
                catch
                    disp(command);
                    e=lasterr;
                    e
                    error('problem with this command')
                end
            end
        end

        f2=fields(d2); %redo because new terms may have been added....
        if any(strcmp(f2,'info'))
            f2(find(strcmp(f2,'info')))=[];
        end

        %add the entries from d2 into d1 (from d2 into combined)
        combined=d1;
        for i=1:length(f2)
            numNewTrials=length(newIndices);
            command=sprintf('combined.%s(end+1:end+numNewTrials)=d2.%s(newIndices);',f2{i},f2{i});
            try
                eval(command)
            catch
                disp(command);
                e=lasterr;
                e
                error('problem with this command')
            end
        end

        %actually both should have info in them and should get joined...
        combined.info.subject=unique([d1.info.subject d2.info.subject]);
        if any(ismember({'sessionIDs','trialManagerClass','stimManagerClass','station'},fields(combined.info))) %could switch any to all
            combined.info.sessionIDs= unique([d1.info.sessionIDs d2.info.sessionIDs]);
            combined.info.station=unique([d1.info.station d2.info.station]);
            combined.info.trialManagerClass=unique([d1.info.trialManagerClass d2.info.trialManagerClass]);
            combined.info.stimManagerClass=unique([d1.info.stimManagerClass d2.info.stimManagerClass]);
            %combined.info.numTrials=size(combined.date,2); %this is redundant and easy to recompute...PMM
        end

        if strcmp(d1.info.subject, d2.info.subject)
            combined.info.subject=d1.info.subject;
        else
            d1.info.subject
            d2.info.subject
            switch class(d1.info.subject)
                case 'cell' %they both have to be cells

                case 'char'
            end
            %error('trying to combine smallData from two different subjects')
        end
    end
end



