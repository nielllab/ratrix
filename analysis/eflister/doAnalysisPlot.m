function doAnalysisPlot(compiledFileDir,subjectID,type,filter,filterVal,filterParam,includeKeyboard)

compiledFile=fullfile(compiledFileDir,[subjectID '.compiledTrialRecords.*.mat']);
d=dir(compiledFile);
records=[];
for i=1:length(d)
    if ~d(i).isdir
        [rng num er]=sscanf(d(i).name,[subjectID '.compiledTrialRecords.%d-%d.mat'],2);
        if num~=2
            d(i).name
            er
        else
            fprintf('loading file')
            t=GetSecs();
            ctr=load(fullfile(compiledFileDir,d(i).name));
            fprintf('\ttime elapsed: %g\n',GetSecs-t)
            records=ctr.compiledTrialRecords;
        end
    end
end
% 
% switch filter
%     case 'all'
%     case 'first'
%     case 'last'
%     otherwise
%         error('bad filter')
% end
% 
% switch filterParam
%     case 'days'
%     case 'trials'
%     case 'all'
%     otherwise
%         error('bad filterParam')
% end

if strcmp(type,'weight')

    gotConn=false;
    while ~gotConn
        try
            conn=dbConn; %calling this too rapidly throws connection exception: ORA-12516, TNS:listener could not find available handler with matching protocol stack
            gotConn=true;
        catch ex
            ple(ex)
        end
    end
    %[weights dates] = getBodyWeightHistory(conn,subjectID); %this is fast
    [weights dates thresholds] = getBodyWeightHistory(conn,subjectID); %need a faster solution, see: http://132.239.158.177/trac/rlab_hardware/ticket/129
    %thresholds=.85*thresholds;
    closeConn(conn);
    plot(dates,[weights thresholds]);
    if range(dates)>50
        set(gca,'XTick',fliplr([ceil(max(dates)):-30:floor(min(dates))]));
    elseif range(dates)>8
        set(gca,'XTick',fliplr([ceil(max(dates)):-7:floor(min(dates))]));
    else
        set(gca,'XTick',fliplr([ceil(max(dates)):-1:floor(min(dates))]));
    end
    xlim([floor(min(dates)) ceil(max(dates))]);
    datetick('x','mm/dd','keeplimits','keepticks')

else

    if ~isempty(records)
        storageMethod='vector'; %'structArray'

        switch storageMethod
            case 'structArray'

                fprintf('converting records')
                t=GetSecs();

                processedRecords.response=zeros(1,length(records));
                processedRecords.correctionTrial=zeros(1,length(records));
                processedRecords.date=zeros(1,length(records));
                processedRecords.correct=zeros(1,length(records));
                processedRecords.step=zeros(1,length(records));

                for i=1:length(records)
                    %records(i).stimDetails
                    if ismember('orientations',fields(records(i).stimDetails))
                        processedRecords.step(i)=length(records(i).stimDetails.orientations);
                    else
                        processedRecords.step(i)=0;
                        %warning('unknown step')
                    end
                    resp=find(records(i).response);
                    if length(resp)~=1 || ischar(records(i).response)
                        processedRecords.response(i)=-1;
                    else
                        processedRecords.response(i)=resp(1);
                    end
                    processedRecords.date(i)=datenum(records(i).date);
                    if ismember('correctionTrial',fields(records(i).stimDetails))
                        processedRecords.correctionTrial(i)=records(i).stimDetails.correctionTrial;
                    else
                        processedRecords.correctionTrial(i)=false;
                    end
                end
                processedRecords.correct=[records.correct];

                fprintf('\ttime elapsed: %g\n\n',GetSecs-t)

            case 'vector'

                %do filtering:
                switch filter
                    case 'all'
                        processedRecords=records;
                    case 'last'
                        switch filterParam
                            case 'days'
                                processedRecords=removeSomeSmalls(records, records.date<now-filterVal);
                            case 'trials'
                                processedRecords=removeSomeSmalls(records, records.trialNumber<records.trialNumber(end)-filterVal+1);
                            otherwise
                                error('bad filterParams')
                        end
                    case 'first'
                        switch filterParam
                            case 'days'
                                processedRecords=removeSomeSmalls(records, records.date>records.date(1)+filterVal);
                            case 'trials'
                                processedRecords=removeSomeSmalls(records, records.trialNumber>filterVal);
                            otherwise
                                error('bad filterParams')
                        end
                    otherwise
                        filter
                        error ('bad filter type')
                end

            otherwise
                error('unrecognized storage method')
        end
        processedRecords.info.subject={subjectID};

        switch type
            case 'trials per day'
                doPlot('plotTrialsPerDay',processedRecords,[],[],[],[],[],~includeKeyboard,true);
            case 'performance'
                doPlot('percentCorrect',processedRecords,[],[],[],[],[],~includeKeyboard);
            case 'bias'
                doPlot('plotBias',processedRecords,[],[],[],[],[],~includeKeyboard);
            case 'trial rate'
                doPlot('plotRatePerDay',processedRecords,[],[],[],[],[],~includeKeyboard);
            case 'all'
                warning('not implemented')
            otherwise
                error('bad type')
        end

    else
        subjectID
        if isempty(d)
            compiledFile
            dir(compiledFile)
            dir(compiledFileDir)
            fprintf('can''t seem to dir %s\nyou should make sure you can see this directory\ntry to open it in your file system-- you may be prompted for authentication, which may solve this problem\n',compiledFileDir)
        end
        d.name
        warning('didn''t find any records')
    end
end
