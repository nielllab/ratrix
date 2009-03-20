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
             disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        end
    end
    %[weights dates] = getBodyWeightHistory(conn,subjectID); %this is fast
    [weights dates thresholds thresholds_90pct ages] = getBodyWeightHistory(conn,subjectID); % 10/30/08 - added 90% IACUC thresholds
    %need a faster solution, see: http://132.239.158.177/trac/rlab_hardware/ticket/129
%     thresholds=.85*thresholds; % 10/20/08 - the thresholds from getBodyWeightHistory are already scaled to 85%
    % 11/4/08 - get free water information as well
    [free_water_dates free_water_amounts free_water_units] = getFreeWaterHistory(conn,subjectID);
    free_water_minutes=[];
    free_water_minutes_dates=[];
    free_water_mls=[];
    free_water_mls_dates=[];
    for i=1:length(free_water_amounts)
        if strcmp(free_water_units{i}, 'min')
            free_water_minutes(end+1) = free_water_amounts(i);
            free_water_minutes_dates(end+1) = free_water_dates(i);
        elseif strcmp(free_water_units{i}, 'mL')
            free_water_mls(end+1) = free_water_amounts(i);
            free_water_mls_dates(end+1) = free_water_dates(i);
        elseif strcmp(free_water_units{i}, 'hr')
            free_water_minutes(end+1) = free_water_amounts(i)*60;
            free_water_minutes_dates(end+1) = free_water_dates(i);
        elseif strcmp(free_water_units{i}, 'day')
            free_water_minutes(end+1) = free_water_amounts(i)*1440;
            free_water_minutes_dates(end+1) = free_water_dates(i);
        else
            free_water_units{i}
            error('unsupported free water unit');
        end
    end
    
    closeConn(conn);
    try
        if ~isempty(free_water_minutes)
            [AX H1 H2] = plotyy(free_water_minutes_dates,free_water_minutes, ...
                dates,[weights thresholds thresholds_90pct]);
            set(AX(1), 'YAxisLocation', 'right');
            set(AX(1),'XTick',[]);
            set(AX(1),'YColor','black');
            set(AX(1),'XColor','black');
            set(H1,'LineStyle','none');
            set(H1,'Marker','x');
            set(H1,'MarkerSize',10);
            set(H1,'Color',[0.6 0 0]);
            ylabel(AX(1), 'free water (min/mL)');
            xlim(AX(1),[floor(min(dates)) ceil(max(dates))]);
        else
            H2 = plot(dates, [weights thresholds thresholds_90pct]);
            AX(2)=gca;
        end
        H3 = plot(free_water_mls_dates,free_water_mls, 'xb');
        % 11/4/08 - added plotting of free water on top of weights
        % 10/22/08 - added legend
        alreadyPlotted = get(gcf,'UserData');
        if isempty(alreadyPlotted) || (~isempty(alreadyPlotted) && ~any(ismember(alreadyPlotted,'weight')))
            if ~isempty(free_water_minutes)
                legendStrs = {'observed weights','85% thresholds', '90% thresholds', 'free water (min)', 'free water (mL)'};
                legend([H2;H1;H3], legendStrs, 'Location','NorthWest','Color','white');
            else
                legendStrs = {'observed weights','85% thresholds', '90% thresholds', 'free water (mL)'};
                legend([H2;H3], legendStrs, 'Location','NorthWest','Color','white');
            end
            alreadyPlotted{end+1}='weight';
            set(gcf,'UserData',alreadyPlotted);
        end  
    catch ex
        %disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        rethrow(ex)
%         plot(0)
%         dates
%         weights
%         thresholds
%         thresholds_90pct
%         size(dates)
%         size(weights)
%         size(thresholds)
%         size(thresholds_90pct)
        warning('weights, dates, and thresholds have different sizes')
    end
    % 11/4/08 - set axes/plot properties with new plotyy architecture

    set(H2(1), 'Color', 'blue');
    set(H2(2), 'Color', 'red');
    set(H2(3), 'Color', [0 0.6 0]);
    set(H3,'LineStyle','none');
    set(H3,'Marker','x');
    set(H3,'MarkerSize',10);
    set(H3,'Color',[0 0.6 0]);
    
    set(AX(2), 'YAxisLocation', 'left');
    ylabel(AX(2), 'weight (g)');
    xlabel(AX(2), 'date');
    
    if range(dates)>50
        set(AX(2),'XTick',fliplr([ceil(max(dates)):-30:floor(min(dates))]));
    elseif range(dates)>8
        set(AX(2),'XTick',fliplr([ceil(max(dates)):-7:floor(min(dates))]));
    else
        set(AX(2),'XTick',fliplr([ceil(max(dates)):-1:floor(min(dates))]));
    end
    
    xlim(AX(2),[floor(min(dates)) ceil(max(dates))]);
    
    % this axes is used to label x-axis with rat ages
    AX(3)=axes('Position',get(AX(2),'Position'),'Color','none','XColor','k','YColor','k');
    set(AX(3),'XAxisLocation','top');
    xlim(AX(3),[floor(min(ages)) ceil(max(ages))]);
    if range(ages)>50
        set(AX(3),'XTick',fliplr([ceil(max(ages)):-30:floor(min(ages))]));
    elseif range(ages)>8
        set(AX(3),'XTick',fliplr([ceil(max(ages)):-7:floor(min(ages))]));
    else
        set(AX(3),'XTick',fliplr([ceil(max(ages)):-1:floor(min(ages))]));
    end
    xlabel(AX(3),'Rat age');
    
    if ~(isempty(free_water_minutes) && isempty(free_water_mls))
        yLimits = [floor(min([free_water_minutes free_water_mls])) ceil(max([free_water_minutes free_water_mls]))];
        % 11/6/08 - if rat has only one free_water value, then set limits to be 30 above and below the single value
        if yLimits(1) == yLimits(2)
            yLimits(1) = min(0, yLimits(1)-30);
            yLimits(2) = yLimits(2)+30;
        end
        ylim(AX(1),[yLimits(1) yLimits(2)]);
        set(AX(1),'YTick', linspace(yLimits(1),yLimits(2),4));
    end
    datetick(AX(2),'x','mm/dd','keeplimits','keepticks')

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
                doPlot('plotTrialsPerDay',processedRecords,[],[],[],[],[],~includeKeyboard);
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
