% string info.subject
% datenum date
% int response
% logical correct
% logical correctionTrial
% double actualRewardDuration
% int step
% double responseTime
% int numRequestLicks
%
% switch plotType
%     case 'allTypes'
%         requiredFields={'date','info'};
%     case 'plotTrialsPerDay'
%         requiredFields={'response','correctionTrial','correct'};
%     case 'percentCorrect'
%         requiredFields={'correct','step','correctionTrial'};
%     case 'plotTheBodyWeights'
%         requiredFields={'date'};
%     case 'plotBiasScatter'
%         requiredFields={'response'};
%     case 'plotBias'
%         requiredFields={'response'};
%     case 'plotRatePerDay' %skips data after the first 2 hours following the first trial of a given date
%         requiredFields={'date'};
function doAnalysisPlot(compiledFileDir,subjectID,type,filter,filterVal,filterParam)
storageMethod='vector'; %'structArray' 


if strcmp(type,'weight')

    lastNdays = 60;
    plotBodyWeights({subjectID},lastNdays);
    
    %old:
%     conn=dbConn('132.239.158.177','1521','dparks','pac3111');
%     [weights dates thresholds] = getBodyWeightHistory(conn,subjectID);
%     closeConn(conn);
%     plot(dates,[weights thresholds]);
        
else
if ~isdeployed
%    addpath('C:\Documents and Settings\rlab\Desktop\phil analysys');
end

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

    if ~isempty(records)

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
                doPlot('plotTrialsPerDay',processedRecords);
            case 'performance'
                doPlot('percentCorrect',processedRecords);
            case 'bias'
                doPlot('plotBias',processedRecords);
            case 'trial rate'
                doPlot('plotRatePerDay',processedRecords);
            case 'all'
                warning('not implemented')
            otherwise
                error('bad type')
        end



    else
        if isempty(d)
            dir(compiledFileDir)
            fprintf('can''t seem to dir %s\nyou should make sure you can see this directory\ntry to open it in your file system-- you may be prompted for authentication, which may solve this problem\n',compiledFileDir)
        end
        d.name
        warning('didn''t find any records')
    end
end
