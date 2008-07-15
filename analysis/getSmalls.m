function smallData=getSmalls(subjectID,dateRange,rack,verbose)

if ~exist('rack','var') | isempty(rack)
    % rack=getRackForSubject ...
    %it might be better to pass in from analysisPlotter rather than keep hitting the oracleDB
    rack=1;
end

if ~exist('verbose','var') | isempty(verbose)
    verbose=1;
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
                fprintf('loading file')
                t=GetSecs();
            end
            ctr=load(fullfile(getCompiledDirForRack(rack),d(i).name));
            %temp hack:
            %ctr=load(fullfile('\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiledbackup4',d(i).name));

            if verbose
                fprintf('\ttime elapsed: %g\n',GetSecs-t)
            end
            smallData=ctr.compiledTrialRecords;
        end
    end
end

if ~isempty(smallData)
    if exist('dateRange','var') && ~isempty(dateRange)
        smallData=removeSomeSmalls(smallData, ~(smallData.date>dateRange(1) & smallData.date<dateRange(2)));
    end
else
    disp('empty data!')
    subject
end

%remove all fields that have no content
f=fields(smallData);
remove=[];
for i=1:length(f)
    if all(isnan(smallData.(f{i})))
        remove=[remove i];
    end
end
smallData=rmfield(smallData,f(remove));

if verbose & ~isempty(remove)
    disp(sprintf('removing %d fields that are full of NaNs',length(remove)))
    fprintf('done-time elapsed since start: %g\n',GetSecs-t)
end

%add name
if strcmp(class(subjectID),'char')
    smallData.info.subject={subjectID};
end

