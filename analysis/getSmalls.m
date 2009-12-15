function smallData=getSmalls(subjectID,dateRange,rack,verbose,addLickDataIfAvailableInCTR)

if ~exist('rack','var') | isempty(rack)
    if isHumanSubjectID(subjectID)
        rack=103;
    else
        % rack=getRackForSubject ...
        %it might be better to pass in from analysisPlotter rather than keep hitting the oracleDB
        rack=1;
    end
end

if ~exist('verbose','var') | isempty(verbose)
    verbose=1;
end

if ~exist('addLickDataIfAvailableInCTR','var') | isempty(addLickDataIfAvailableInCTR)
    addLickDataIfAvailableInCTR=false;
end

%get location
compiledFile=fullfile(getCompiledDirForRack(rack),[subjectID '.compiledTrialRecords.*.mat']);
%temp hack:
%compiledFile=fullfile('\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiledbackup4',[subjectID '.compiledTrialRecords.*.mat']);

d=dir(compiledFile);
smallData=[];
for i=1:length(d)
    if ~d(i).isdir
        [rng num er]=sscanf(d(i).name,[subjectID '.compiledTrialRecords.%d-%d.mat'],2);
        if num~=2
            d(i).name
            er
        else
            if verbose
                fprintf(sprintf('loading file for %s\n',subjectID))
                t=GetSecs();
            end
            
            ff=fullfile(getCompiledDirForRack(rack),d(i).name);
            
            %get smallData if its there
            in=load(ff,'smallData');
            if ismember('smallData',fields(in))
                smallData=in.smallData;
                totalSmallTrials=length(smallData.date);
            else
                smallData=[];
                totalSmallTrials=0;
            end
            
            %don't use smallData unless its up to date - will compare to
            %details b/c they are faster to load! (ironically)
            cdet=load(ff,'compiledDetails');
            totalTrials=0;
            for i=1:length(cdet.compiledDetails)
                totalTrials=max([totalTrials max(cdet.compiledDetails(i).trialNums)]); % add all possible new trials
            end
            
            if totalSmallTrials==totalTrials
                if verbose
                    fprintf('...found exisiting smallData up to date\n\ttime elapsed: %g\n',GetSecs-t)
                end         
            else
                ctr=load(ff);
                if verbose
                    fprintf('\ttime elapsed: %g\n',GetSecs-t)
                end
                smallData=ctr.compiledTrialRecords;
            end
            
        end
    end
end

if ~isempty(smallData)
    
    %if LUT and other exists then convert it to the desired format
    if exist('ctr','var') && ismember('compiledDetails',fields(ctr))
        if verbose
            t=GetSecs();
            fprintf(sprintf('converting to double format\n'))
        end
        
        smallData=convertCTR2vectors(ctr.compiledTrialRecords,ctr.compiledLUT,ctr.compiledDetails);
        % save a copy of the small data for faster access next time!
        save(ff,'smallData','-append');
    
        
        if verbose
            fprintf('done converting to double format \ttime elapsed: %g\n',GetSecs-t)
        end
        

    end
    
    %filter date range
    if exist('dateRange','var') && ~isempty(dateRange)
        smallData=removeSomeSmalls(smallData, ~(smallData.date>dateRange(1) & smallData.date<dateRange(2)));
    end
    
    
    %add licks for that date range... they are often too big to "convert"
    if addLickDataIfAvailableInCTR   
        if ~exist('ctr','var') 
            ctr=load(ff);
        end
        if ismember('compiledTrialRecords',fields(ctr)) && isfield(ctr.compiledTrialRecords,{'lickTimes'})
            if min(ctr.compiledTrialRecords.trialNumber)==1 && max(ctr.compiledTrialRecords.trialNumber)>=max(smallData.trialNumber)
                smallData.lickTimes=ctr.compiledTrialRecords.lickTimes(:,smallData.trialNumber);
            else
                error('absence of expected trials')
            end
            if verbose
                fprintf('got the lickData for all %d trials... at least %d have licks\n',size(smallData.lickTimes,2),sum(sum(isnan(smallData.lickTimes))>0))
            end
        else
            % if verbose
            %    warning('failed to find lickTimes in CTR')
            % end
             error('failed to find lickTimes in CTR')
        end
    end
    
    %remove all fields that have no content
    f=fields(smallData);
    f(strcmp('info',f))=[];
    remove=[];
    for i=1:length(f)
        if (isnumeric(smallData.(f{i})) && all(isnan(smallData.(f{i})(1,:) ))) %... % vector of numbers all nan, or matrix all nan in 1st column
                %|| (iscell(smallData.(f{i})) && all(cellfun(@(x) isnan(x(1)),smallData.(f{i}))) ) %cells all nan
            remove=[remove i];
        end
    end
    smallData=rmfield(smallData,f(remove));
    f(remove)=[];
    
    %check all fields are the same length
    expectedNumberOfTrials=length(smallData.date);
     for i=1:length(f)
        if ~length(smallData.(f{i}))==expectedNumberOfTrials
            length(smallData.(f{i}))
            expectedNumberOfTrials
            error('not matching!')
        end
     end
    
    
    
    %add name
    if strcmp(class(subjectID),'char')
        smallData.info.subject={subjectID};
    end
    

    %add yes response if detection
    %can't for all, some rats have problems still unsolved.  138-9
    %     if ismember('targetContrast',fields(smallData)) && any(smallData.targetContrast==0)
    %         [smallData sideType]=addYesResponse(smallData);
    %         smallData.info.sideType=sideType;
    %     end
    
    
    if verbose & ~isempty(remove)
        disp(sprintf('removing %d fields that are full of NaNs',length(remove)))
        fprintf('done-time elapsed since start conversion: %g\n',GetSecs-t)
    end
    
    %     if all(size(smallData.date)==[1 0])
    %         smallData=[]; % %if there are no trials d turns into an empty set
    %     end
    
else
    disp(sprintf('%s: empty data!',subjectID))
    subject
end


