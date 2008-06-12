function compileTrialRecords(recompile,fieldNames)
subjectDirectory='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects\';
compiledRecordsDirectory='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords\';

recompile = false;
fieldNames={'trialNumber',...
    'date',...
    'response',...
    'correct',...
    ...%'trialManagerClass',...
    ...%'stimManagerClass',...
    ...%'stimDetails',...
    'step',...
    'correctionTrial'};

storageMethod='vector'; %'structArray' 

%loading structArray or cell is 100x slower than vector of same size!!!
% n=3;
% d=10000;
% x=rand(n,d);
% tic;save('test.mat','x');toc
% tic;load('test.mat');toc
% 
% b=num2cell(x,1);
% all(all(x==[b{:}]))
% tic;save('test.mat','b');toc
% tic;load('test.mat');toc
% 
% a=struct('x',b);
% all(all(x==[a.x]))
% tic;save('test.mat','a');toc
% tic;load('test.mat');toc



subjectFiles={};
ranges={};
names={};
d=dir(subjectDirectory);
for i=1:length(d)
    if d(i).isdir && ~ismember(d(i).name,{'.','..'})
        [subjectFiles{end+1} ranges{end+1}]=getTrialRecordFiles(fullfile(subjectDirectory,d(i).name));
        names{end+1}=d(i).name;
    end
end

for i=1:length(subjectFiles)
    d=dir(fullfile(compiledRecordsDirectory,[names{i} '.compiledTrialRecords.*.mat']));
    compiledFile=[];
    compiledRange=zeros(2,1);
    for k=1:length(d)
        done=false;
        if ~d(k).isdir
            [rng num er]=sscanf(d(k).name,[names{i} '.compiledTrialRecords.%d-%d.mat'],2);
            if num~=2
                d(k).name
                er
            else
                %d(k).name
                if ~done
                    compiledFile=fullfile(compiledRecordsDirectory,d(k).name);
                    if ~recompile
                        compiledRange=rng;
                        done=true;
                    end
                else
                    d.name
                    error('found multiple compiledTrialRecord files')
                end
            end
        end
    end

    compiledTrialRecords=[];
    needToAdd=false;
    for j=1:length(subjectFiles{i})
        %         ranges{i}(:,j)
        %         needToAdd
        if ranges{i}(1,j)==compiledRange(2,end)+1
            if ~needToAdd && ~isempty(compiledFile)
                compiledTrialRecords=loadCompiledTrialRecords(compiledFile,compiledRange,fieldNames);
            end
            needToAdd=true;
            compiledRange(:,end+1)=ranges{i}(:,j);
            tr=load(subjectFiles{i}{j});
            newTrialRecs=tr.trialRecords;
            if ~all([newTrialRecs.trialNumber]==ranges{i}(1,j):ranges{i}(2,j))
                subjectFiles{i}{j}
                ranges{i}(:,j)
                error('found trial record file with incorrect trial numbers')
            else
                fprintf('doing subject: %s, range: %d-%d, fields: {',names{i},ranges{i}(1,j),ranges{i}(2,j))
                for m=1:length(fieldNames)
                    switch storageMethod
                        case 'structArray'
                            [compiledTrialRecords(ranges{i}(1,j):ranges{i}(2,j)).(fieldNames{m})]=newTrialRecs.(fieldNames{m});
                        case 'vector'
                            switch fieldNames{m}
                                case {'trialNumber','correct'}
                                    compiledTrialRecords.(fieldNames{m})(ranges{i}(1,j):ranges{i}(2,j))=[newTrialRecs.(fieldNames{m})];
                                case 'date'
                                    compiledTrialRecords.date(ranges{i}(1,j):ranges{i}(2,j))=datenum(reshape([newTrialRecs.date],6,length(newTrialRecs))');
                                    
%                                     for tr=1:length(newTrialRecs)
%                                             if ranges{i}(1,j)+tr-1 <= ranges{i}(2,j)
%                                                 compiledTrialRecords.response(ranges{i}(1,j)+tr-1)=datenum(newTrialRecs(tr).date);
%                                             else
%                                                 error('should never happen')
%                                             end
%                                     end
                                    
                                case 'response'
                                    compiledTrialRecords.response(ranges{i}(1,j):ranges{i}(2,j))=-1;
                                    for tr=1:length(newTrialRecs)
                                        resp=find(newTrialRecs(tr).response);
                                        if  length(resp)==1 && ~ischar(newTrialRecs(tr).response)
                                            if ranges{i}(1,j)+tr-1 <= ranges{i}(2,j)
                                                compiledTrialRecords.response(ranges{i}(1,j)+tr-1)=resp;
                                            else
                                                error('should never happen')
                                            end
                                        end
                                    end
                                case 'step'
                                    compiledTrialRecords.step(ranges{i}(1,j):ranges{i}(2,j))=0;
                                    for tr=1:length(newTrialRecs)
                                        if ismember('orientations',fields(newTrialRecs(tr).stimDetails))
                                            if ranges{i}(1,j)+tr-1 <= ranges{i}(2,j)
                                                compiledTrialRecords.step(ranges{i}(1,j)+tr-1)=length(newTrialRecs(tr).stimDetails.orientations);
                                            else
                                                error('should never happen')
                                            end
                                        end
                                    end
                                case 'correctionTrial'
                                    compiledTrialRecords.correctionTrial(ranges{i}(1,j):ranges{i}(2,j))=false;
                                    
                                    for tr=1:length(newTrialRecs)
                                        if ismember('correctionTrial',fields(newTrialRecs(tr).stimDetails))
                                            if ranges{i}(1,j)+tr-1 <= ranges{i}(2,j)
                                                compiledTrialRecords.correctionTrial(ranges{i}(1,j)+tr-1)=newTrialRecs(tr).stimDetails.correctionTrial;
                                            else
                                                error('should never happen')
                                            end
                                        end
                                    end
                                    
                                otherwise
                                    fieldNames{m}
                                    error('no converter for field')
                            end

                        otherwise
                            error('unrecognized storage method')
                    end
                    fprintf('%s ',fieldNames{m})
                end
                fprintf('}\n');
            end
            for m=1:length(newTrialRecs)
                if length(newTrialRecs(m).subjectsInBox)~=1 || ~ismember(names{i},newTrialRecs(m).subjectsInBox)
                    names{i}
                    newTrialRecs(m).subjectsInBox
                    error('bad subject')
                end
            end
        elseif needToAdd || any(ranges{i}(:,j)>compiledRange(2,end))
            ranges{i}
            subjectFiles{i}
            compiledRange
            ranges{i}(:,j)
            error('trial record files appear to not be consecutive')
        end
    end

    if ~isempty(compiledTrialRecords) && needToAdd
        if ~isempty(compiledFile)
            delete(compiledFile);
        end

        if any([compiledTrialRecords.trialNumber]~= 1:length([compiledTrialRecords.trialNumber]))
            length(compiledTrialRecords)
            compiledTrialRecords
            error('didn''t wind up with correct trial numbers')
        end
        
        dts=[compiledTrialRecords.date];
        if any(diff(dts)<0)
            figure
            plot(dts)
            hold on
            prob=find(diff(dts)<0);
            plot(prob,dts(prob),'rx')
            text(prob+.05*length(dts),dts(prob),datestr(dts(prob)))
            title(sprintf('dates aren''t monotonic increasing for subject %s',names{i}))
        end
        
%         for m=2:length(compiledTrialRecords)
%             if datenum(compiledTrialRecords(m).date)<=datenum(compiledTrialRecords(m-1).date)
%                 m
%                 
%                 compiledTrialRecords(m-1).date
%                 compiledTrialRecords(m-1).trialNumber
%                 
%                 compiledTrialRecords(m).date
%                 compiledTrialRecords(m).trialNumber
%                 
%                 dofig=true
%                 if dofig
%                     blargh=zeros(1,length(compiledTrialRecords));
%                     for blar=1:length(compiledTrialRecords)
%                         blargh(blar)=datenum(compiledTrialRecords(blar).date);
%                     end
% 
%                     figure
%                     plot(blargh)
%                 end
%                 warning('dates aren''t monotonic increasing')
%             end
%         end
        
        lo=min([compiledTrialRecords.trialNumber]);
        hi=max([compiledTrialRecords.trialNumber]);
        save(fullfile(compiledRecordsDirectory,[names{i} '.compiledTrialRecords.' num2str(lo) '-' num2str(hi) '.mat']),'compiledTrialRecords');
        fprintf('done with %s\n\n',names{i})
    else
        fprintf('nothing to do for %s\n\n',names{i})
    end
end


function compiledTrialRecords=loadCompiledTrialRecords(compiledFile,compiledRange,fieldNames)
fprintf('\nloading %s...\n',compiledFile);
t=GetSecs;
ctr=load(compiledFile);
fprintf('elpased time: %g\n',GetSecs-t)
compiledTrialRecords=ctr.compiledTrialRecords;
trialNums=[compiledTrialRecords.trialNumber];
if ~all(trialNums==compiledRange(1):compiledRange(2)) || compiledRange(1)~=1
    compiledFile
    min(trialNums)
    max(trialNums)
    compiledRange
    error('compiledTrialRecord file found not to contain proper trial numbers')
end
if length(fieldNames)~=length(fields(compiledTrialRecords))
    fieldNames
    fields(compiledTrialRecords)
    error('compiled trial records have different fields than the targets');
end
for m=1:length(fieldNames)
    if ~ismember(fieldNames{m},fields(compiledTrialRecords))
        fieldNames
        fields(compiledTrialRecords)
        error('compiled trial records don''t contain all target fields');
    end
end