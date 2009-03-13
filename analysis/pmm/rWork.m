function out=rWork()

% quickStart should load in past leapFrogValue for that subject and that condition
% --but this is currently erroring probably because the condition used to be stored as a string when it should be stored as a cell array... the first thing to do is to open up quickStart.mat, after it is generated (set quickStart = 0, to make it) 
% 
% the search method works exploding and shrinking sucessfully for single values, and all three values yoked together by a single scalar. Double check the plots to make sure (especially when they say variable names: 1 2 3) 
% 
% The plotter has been started but never tested, not sure if plotting works yet for logistic functions. Consider running a weibull... careful accepting leapFrogValues from the wrong functional class... ! Just take care with the quickStart. 
% 
% A bunch of parameters are still hack defined inside of plotPsychometric... these should be passed in. 
% 
% A policy for saving records for each rat and condition: 
% New analyses will overwrite old analyses, regardless of parameters set.
% Basically only trust a bunch of data after a batch analysis on many rats and conditions, but if you want to compare multiple function types, etc. handle that with logic of some outside function. (maybe by passing special condition names)
% 
% Have not validated if: 
% 	quickStart.mat works
% 	searchHistory(not used but saved) really is correct
% 	
% Next up:
%   generate a single record (could use rWorkResult.mat)
%   generate a plot
% 	generate a bunch of records 
% 	masterplotter function calls basic plotter, but organizes condition logic
% 	check priors 
% 	collect thresholds
% 	look at flanker data
%   figure out the acceptance history - shouldn't there be 4 number one for each final run?

%-pmm 10/31/08
	


if ~exist('difficulty','var') || ~exist('pctCorrect','var') || ~exist('numAttepted','var') || ~exist('conditionNames','var')
    %normally these would get passed in to the function, but using flankers to
    %test it in place

    subjectID='233'; % 231
    conditionType='allOrientations'; % simple
    conditionType='colin+3'; % interesting
    trialFilter='12';
    [stats plotParams]=flankerAnalysis(getSmalls(subjectID),conditionType,'performancePerContrastPerCondition', 'pctCor',trialFilter);
    close(gcf);

    numAttempted=stats.numAttempted(:,:,1,2); %only when flankers are present
    numCorrect=stats.numCorrect(:,:,1,2);    %only when flankers are present
    pctCorrect=numCorrect./numAttempted; 
    difficulty=plotParams.featureVals.contrasts;
    conditionNames=plotParams.conditionNames;
    
    %user puts whatever source material they want saved
    source.name=[subjectID ' ' conditionType];  % only required field used for title
    source.subjectID=subjectID;
    source.conditionType=conditionType;
    source.trialFilter=trialFilter;
    source.dateRange=[0 now]; %all to now
    
    p.plPrior='beta';
    
    %p.plPriorParameters=[2,10]; % lapse
    %p.plPriorParameters=[600,4000]; % lapse [numWrong,numAttept] for easy task
    d=getSmalls(subjectID); d=removeSomeSmalls(d,d.step~=8); goods=getGoods(d,'withoutAfterError'); lapseParams=[sum(~d.correct(goods)) sum(goods)]
    %doPlotPercentCorrect(d); %using these trials to set priors on lapse
    p.plPriorParameters=lapseParams;
    p.t1Prior='gamma';
    p.t1PriorParameters=[2,4]; %location
    p.t2Prior='lognormal';
    p.t2PriorParameters=[1,1]; %width (actually slope in case of weibull)
    p.type = 'weibull';

end

if ~exist('quickStart', 'var')
    quickStart=0;
end


%error check inputs
numConditions=length(conditionNames);
if ~(size(pctCorrect,2)==numConditions && size(numAttempted,2)==numConditions)
    error('size(pctCorrect,2) and size(numAttempted,2) must match numConditions')
end
if ~(size(pctCorrect,1)==length(difficulty) && size(numAttempted,1)==length(difficulty))
    error('size(pctCorrect,1) and size(numAttempted,1) must match length(difficulty)')
end

%software install check
checkForR()

%set priors
% p.plPrior='beta';
% p.plPriorParameters=[2,50];
% p.t1Prior='normal';
% p.t1PriorParameters=[1,10]; %location
% p.t2Prior='lognormal';
% p.t2PriorParameters=[2,1]; %width
% p.type = 'logistic';


if 0 %testbed
%%
    i=1
    final_C=[0.1 0.03 0.08];
    searchHistory='from Quickstart';
    disp(sprintf('linearSesnitive Range: %2.2g\t%2.2g\t%2.2g\t\n          using Range: %2.2g\t%2.2g\t%2.2g\t',c,c))
    createNewPsychoFunRFile(p,final_C(i,1:3),700,200,100)
    evaluateRFile
    records=getValuesFromRoutput();  % all files
    saveFileName=fullfile(getRBatchPath('root'),'matOutput',[subjectID '_' conditionType '.mat']);
    save(saveFileName,'records','final_C','searchHistory','difficulty','pctCorrect','numAttempted','conditionNames','source');
    data=load(saveFileName)
    data.records=data.records()
    figure; hold on; plotPsychometricMCMC(data)
%%
end

% create folders if needed
% empty PsychoFun ouput folders
delete(fullfile(getRBatchPath('out'),'*.txt'))
searchNum=0;
for i=1:numConditions

    % empty PsychoFun input folders
    delete(fullfile(getRBatchPath('in'),'*.txt'))

    % populatePyschoFun input
    writeRDataInFile(difficulty,pctCorrect(:,i),numAttempted(:,i),conditionNames{i});

    if quickStart
        final_C(i,1:3)=getQuickStartLeapFrogValues(subjectID, conditionNames{i});
        searchHistory='from Quickstart';
    else
        % find acceptance range for each individually with all low initial values, and very quick leap frog
        searchLeapFrog=20;
        searchNumPts=150
        searchBurnIn=50;
        small=.01;
        range=[.6 .9];
        initialValue=[small,small,small];

        for j=1:3
            searchNum=searchNum+1;
            [c(j) searchHistory{searchNum}]=getPercentileForAcceptanceRange(p,initialValue,j,range,searchLeapFrog,searchNumPts,searchBurnIn);
        end

        % find acceptance range by scalaring all three
        initialValue=c;  %start searching where you left off
        variables=[1:3];
        searchNum=searchNum+1;
        [c searchHistory{searchNum}]=getPercentileForAcceptanceRange(p,initialValue,variables,range,searchLeapFrog,searchNumPts,searchBurnIn);

        % find group acceptance with slower, more accurate values
        initialValue=c;  %matched for joint
        searchLeapFrog=100;
        searchNumPts=700
        searchBurnIn=500;
        searchNum=searchNum+1;
        [final_C(i,1:3) searchHistory{searchNum}]=getPercentileForAcceptanceRange(p,initialValue,variables,range,searchLeapFrog,searchNumPts,searchBurnIn);

        % increase leapFrog
        saveQuickStartLeapFrogValue(subjectID, conditionNames(i), final_C(i,1:3), searchHistory)

    end

    %do it
    disp(sprintf('condition: %s , using linearSesnitive Range: %2.2g\t%2.2g\t%2.2g\n',conditionNames{i},final_C))%\t\n          using Range: %2.2g\t%2.2g\t%2.2g\t',final_C,c))
    createNewPsychoFunRFile(p,final_C(i,1:3),700,200,100)
    evaluateRFile
    disp('done')
  
    %records=getValuesFromRoutput(filename)  % individual files...why bother... do one mat file instead
    %saveFileName=fullfile(getRBatchPath('root'),'matOutput',[subjectID '_' conditionNames{i} '.mat']);
    %save(saveFileName,'records','c','searchHistory');
end

records=getValuesFromRoutput();  % all files
saveFileName=fullfile(getRBatchPath('root'),'matOutput',[subjectID '_' conditionType '.mat']);
save(saveFileName,'records','final_C','searchHistory','difficulty','pctCorrect','numAttempted','conditionNames','source');

data=load(saveFileName)
 figure; hold on;
 plotPsychometricMCMC(data)
    
    
function records=evaluateRFile
%plays through the R file which was made
%[s r]=system(['R --vanilla < play.R']); %erik's old call
%[s r]=system(['C:\R\R-2.8.0\bin\Rterm.exe --vanilla < play.R > out.txt 2>&1']); % current effective call
% The purpose of 2>&1 is to redirect warnings and errors to the same file as normal output.


%%
% this code would be cleaner, but I think theres
% a problem with the spaces in 'Documents and Settings' in ratrix path
% Attempted to put it in single quotes, but that failed too
%   R_scriptPath= fullfile(getRatrixPath,'classes','util','R_files','play.R')
%   R_scriptPath= sprintf(' \''%s'' ',R_scriptPath) % put it in single quotes for windows
% instead cd'ing to the directory and then back to where you were

R_scriptPath= 'play.R';
temp=pwd;
R_scriptPathNoFile= fullfile(getRatrixPath,'classes','util','R_files');
cd(R_scriptPathNoFile);


R_softwarePath='C:\R\R-2.8.0\bin\Rterm.exe';
%cmd=sprintf('%s --vanilla < %s',R_softwarePath,R_scriptPath)
%example: path_to_R\bin\Rterm.exe --no-restore --no-save < %1 > %1.out 2>&1
%cmd=sprintf('%s --vanilla < %s > out.txt 2>&1 ',R_softwarePath,R_scriptPath)
cmd=sprintf('%s --vanilla < %s > %s 2>&1 ',R_softwarePath,R_scriptPath, 'log.txt');
% disp(cmd);
[s r]=system(cmd);

if s~=0 %an error

    %display the output
    fid=fopen('log.txt'); done=0;
    while ~done
        line=fgetl(fid);
        if  line==-1
            done=1;
        else
            disp(line)
        end
    end
    fclose(fid);

    error('something failed')
end
cd(temp)

if nargout==1
    records=getValuesFromRoutput();
end

function createNewPsychoFunRFile(priors,leapFrogValues,numPts,burnIn,numLeapFrog,dataInPath,templatePath,doPlots);
%accepts matlab variables an creates r code for psychoFun by Malte Kuss
%by default always makes a temp file called Play.R which will be evaluated
%by a subsequent call to evaluateRFile

if ~exist('priors', 'var') || isempty(priors)
    p.plPrior='beta';
    p.plPriorParameters=[2,10];
    p.t1Prior='gamma';
    p.t1PriorParameters=[2,4]; %location
    p.t2Prior='lognormal';
    p.t2PriorParameters=[1,1]; %width (actually slope in case of weibull)
    p.type = 'weibull';
    priors=p;
end

if ~exist('leapFrogValues', 'var') || isempty(leapFrogValues)
    leapFrogValues=[.1 .03 .08];
end

if ~exist('numLeapFrog', 'var') || isempty(numLeapFrog)
    numLeapFrog=20;
end

if ~exist('templatePath', 'var') || isempty(templatePath)
    templatePath=fullfile(getRatrixPath,'classes','util','R_files','template.R');
end

if ~exist('dataInPath', 'var') || isempty(dataInPath)
    dataInPath=getRBatchPath('in');
end

if ~exist('numPts', 'var') || isempty(numPts)
    numPts=150;%200;

end

if ~exist('burnIn', 'var') || isempty(burnIn)
    burnIn=50;% 100;
end

if ~exist('doPlots', 'var') || isempty(doPlots)
    doPlots=false;
end

if numPts<=burnIn
    error('numPts must be bigger than burnIn, else you throw out all your data')
end

%copy template to a play file
destination=fullfile(fileparts(templatePath), 'play.R');
copyfile(templatePath, destination);

% extract and overwrite lines with variables in the play file
fid=fopen(destination);
done=0;
fileString='';
while ~done
    line=fgetl(fid);
    switch line
        case 'pth="xx"'
            %backslash interferes with writing file out, switch, which works with R
            dataInPath(strfind(dataInPath,'\'))='/'; %switch em out
            fileString=sprintf('%s\npth="%s"', fileString, dataInPath);
        case 'xxInsertPriorHerexx)'
            fileString=sprintf('%s\n%s)', fileString, convertPriorsToRCode(priors));
        case 'sizeLeapfrog <- c(xx,xx,xx)'
            fileString=sprintf('%s\nsizeLeapfrog <- c(%3.3g, %3.3g, %3.3g)', fileString, leapFrogValues(1), leapFrogValues(2), leapFrogValues(3));
        case 'numLeapfrog <- xx'
            fileString=sprintf('%s\nnumLeapfrog <-%3.3g', fileString, numLeapFrog);
        case 'numPts <- xx'
            fileString=sprintf('%s\nnumPts <-%3.3g', fileString, numPts);
        case '	burnIn <- xx'
            fileString=sprintf('%s\n	burnIn <- %3.3g', fileString, burnIn);
        case 'doplots <- TRUE'
            if doPlots
                logicalString='TRUE';
            else
                logicalString='FALSE';
            end
            fileString=sprintf('%s\ndoplots <-%s', fileString, logicalString);
        otherwise
            if line==-1
                done=1;
            else
                fileString=sprintf('%s\n%s', fileString, line);
            end
    end
end
fclose(fid);

fid=fopen(destination, 'wt');
fprintf(fid, fileString, '%s');
fclose(fid);
% fid=fopen(destination);
% fclose(fid);


function string=convertPriorsToRCode(p)
% converts the matlab structure into the string of R code that makes
% sets up the parameters for psychoFun in R

string='';
f=fields(p);
for i=1:length(f)
    switch f{i}
        case {'plPrior', 't1Prior', 't2Prior','type'} %set strings
            string=[string sprintf('%s="%s",\n', f{i}, p.(f{i}))];
        case {'plPriorParameters', 't1PriorParameters', 't2PriorParameters'} %set 2 parameter arguement
            string=[string sprintf('%s=c(%3.3g,%3.3g),\n', f{i}, p.(f{i})(1), p.(f{i})(2))];
        otherwise
            f{i}
            error('unexpected R variable');
    end
end
string(end-1:end)=[];


function pass=checkForR()
%this checks if R is installed on your computer
%if not, follow these instructions
%
% here are my notes on how to install R and psychoFun package on windows XP
% -pmm 081026
%
% 1. Install R
% you may want to follow up to date instructions at www.r-project.org for new releases
% go to cran.stat.ucla.edu, navigate: windows---> base --> R-2.8.0-win32.exe
% run installer with all default settings except the location
% (do NOT accept default path "Program Files" b/c it has a space in the path)
% instead put it in "C:\R"
% one day this path could be relative to the ratrix, but right now our code depends on it being there
% specifically, it will use: C:/R/R-2.8.0/bin/Rterm.exe
%
% 2.Install PSychoFun (which is a Package that runs in R)
% get newest verison from Malte Kuss's homepage http://www.kyb.mpg.de/bs/people/kuss/PsychoFun.zip
% and extract the files to a folder named 'PsychoFun'
% OR, since they do not do not guarantee backwards-compatibility of releases
% a backup can be found, downloaded on Oct 26, 2008,:
% \\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\backups\software\PsychoFunWindows081026
% copy the folder 'PsychoFun'  into 'C:\R\R-2.8.0\library'
% make sure to rename the folder to be 'PsychoFun' if you copy it from the server
%
% your local help after you install: C:\R\R-2.8.0\doc\html\rw-FAQ.html

path='C:\R\R-2.8.0\bin';
d=dir(path);
pass=any(strcmp('Rterm.exe',{d.name}));

if ~pass
    warning('R does not seem to be installed.  this code will expect it to be here:')
    path
    error('see comments in code for instructions to install R')
end

function path=getRBatchPath(direction)
switch direction
    case 'in'
        folder='dataIn';
    case 'out'
        folder='dataOut';
    case 'root'
        folder=[];
    otherwise
        error('bad')
end
path=fullfile(getRatrixPath,'classes','util','R_files',folder);

function  suc=writeRDataInFile(difficulty,pctCorrect,numAttempt, conditionName)

if size(difficulty,1)==1 && size(difficulty,2)>1
    difficulty=difficulty'; %flip it
end

table=[difficulty pctCorrect numAttempt];
filename=fullfile(getRBatchPath('in'),[conditionName '.dat.txt']);
save(filename,'table','-ascii','-tabs');

% test to load it back in and check values
[a b c]=textread(filename,'%n %n %n');
rndEr=10^6;
if all(abs(difficulty-a)<rndEr) && all(abs(pctCorrect-b)<rndEr) && all(numAttempt==c)
    suc=1;
else
    table
    [a b c]
    table==[a b c]
    error('failed to write and load data as the same values')
end


function [percentile history]=getPercentileForAcceptanceRange(priors,startValue,searchInds,targetRange,searchLeapFrog,searchNumPts,searchBurnIn)


if targetRange(1)>=targetRange(2)
    targetRange
    error('first value in range must be msaller than second')
end

strategy='explodeCollapse';
explodeFactor=10; %exponential grwoth till above range
collapseFactor=2; %go halfway to the anchor each step
i=searchInds;
% assumptions for search: starting point will NOT be above the target range
%
%     strategy='jointCrawl'
%     error('not written')

currentValue=startValue;


try

    switch strategy
        case 'explodeCollapse'
            %run the MCMC
            createNewPsychoFunRFile(priors,currentValue,searchNumPts,searchBurnIn,searchLeapFrog)
            records=evaluateRFile;
            acceptance=records.acceptRate;
            history(1).acceptance=acceptance;

            exploding=1;
            shrinking=0; %this only becomes true on the condition that the explosion reverses
            history(1).value=currentValue(i);
            while exploding

                if (acceptance<targetRange(2) && shrinking==0) || (acceptance>targetRange(1) && shrinking==1)

                    if (acceptance>targetRange(1) && shrinking==0) || (acceptance<targetRange(2) && shrinking==1)
                        doCollapse=0; % already within range
                        exploding=0; %stop exploding
                    else
                        if length(history)<2
                            explodeFactor=1/explodeFactor; %exponentially collapse
                            shrinking=1;
                            warning('expected at least one explosion...code might handle that');
                            %we can allow an exponential shrink (code is
                            %already written) however the problem is we
                            %can't garrantee that this value was the cause
                            %of the acceptance being too low. Normally we
                            %start out with a low leapFrogValue, which
                            %causes a high acceptance, and we explode the
                            %leapFrog to lower the acceptance. If we keep
                            %changing only the selected variable, there
                            %might be no way of returning.
                            disp('reversing direction of explosion, now shrinking');
                        else
                            doCollapse=1; %can move on forward because there is at least one sample below
                            exploding=0; %stop exploding
                        end
                    end
                else
                    %set the search values
                    currentValue(i)=currentValue(i)*explodeFactor;
                    history(end+1).value=currentValue(i); %save for the collapse
                    disp(sprintf('exploding: %s \t prevAcceptance: %g',num2str(currentValue),acceptance));

                    %run the MCMC
                    createNewPsychoFunRFile(priors,currentValue,searchNumPts,searchBurnIn,searchLeapFrog)
                    records=evaluateRFile;
                    acceptance=records.acceptRate;
                    history(end).acceptance=acceptance;
                end
            end

            %narrow in on the range
            while doCollapse


                if acceptance<=targetRange(1)  % is below
                    %OLD: set the anchor above, as close as can be:
                    %anchor=min(history(find(history>currentValue(i))));
                    %then lower current value, by choosing an anchor below:
                    if length(i)==1
                        anchor=max([history(find([history.value]<currentValue(i))).value]);
                    else
                        %same thing with matrices, but more complex b/c of reshaping
                        values=reshape([history.value],length(i),length(history))';
                        contenders=history(find(all(values<repmat(currentValue(i),length(history),1),2))).value
                        anchor=max(reshape(contenders,length(i),size(contenders,1)*size(contenders,2)/length(i))',[],1)
                    end
                elseif acceptance>=targetRange(2) % is above
                    %OLD: set the anchor below, as close as can be:
                    %                 Ranchor=max(history.value(find(history<currentValue(i))));
                    %then raise current value, by choosing an anchor above
                    if length(i)==1

                        anchor=min([history(find([history.value]>currentValue(i))).value]);
                    else
                        values=reshape([history.value],length(i),length(history))';
                        contenders=history(find(all(values>repmat(currentValue(i),length(history),1),2))).value
                        anchor=min(reshape(contenders,length(i),size(contenders,1)*size(contenders,2)/length(i))',[],1)
                    end
                else
                    currentValue=currentValue
                    history=history
                    error('should never happen')
                end


                step=(anchor-currentValue(i))./collapseFactor; % the collapse calulation
                currentValue(i)=currentValue(i)+step; % walk towards the anchor
                history(end+1).value=currentValue(i); %save for the collapse calulation


                disp(sprintf('collapsed: %s \t prevAcceptance: %g anchor: %s step: %s',num2str(currentValue),acceptance, num2str(anchor), num2str(step)));

                %run the MCMC
                createNewPsychoFunRFile(priors,currentValue,searchNumPts,searchBurnIn,searchLeapFrog)
                records=evaluateRFile;
                acceptance=records.acceptRate;
                history(end).acceptance=acceptance;

                if acceptance>targetRange(1) && acceptance<targetRange(2)
                    doCollapse=0; % within range
                end


            end

    end


    percentile=currentValue(i);

    viewingSequence=true;
    if viewingSequence
        %only look at the first value (if there is more than one value, it will scale along with the first value)
        values=reshape([history.value],length(i), length(history))
        viewSequence(values(1,:),[history.acceptance],targetRange,i)
    end

catch ex 
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    disp('error in exploding collapse');
    keyboard
    viewSequence([history.value],[history.acceptance],targetRange,i)
end


function viewSequence(value,acceptances,targetRange,variableNum)
figure
ln=length(acceptances);
plot([1 ln+1],[targetRange(1) targetRange(1)],'-')
hold on
plot([1 ln+1],[targetRange(2) targetRange(2)],'-')
plot(acceptances,'bo')
for i=1:ln
    text (i+.4,acceptances(i),num2str(value(i)))
end
plot(ln,acceptances(ln),'ro'); %found this point
title(sprintf('search variable # %s',num2str(variableNum)))

function [records]=getValuesFromRoutput(filename)
%%

if ~exist('filename','var') || isempty(filename)
    filename='*dat.txt.out.txt'; %return all files there
end

records=struct([]);

indir=getRBatchPath('in');
outdir=getRBatchPath('out');
MCMCexcludedVals=[]; %[128] what does this do?
d=dir(fullfile(outdir,filename));

for i=1:length(d)
    if ~d(i).isdir
        if strcmp(d(i).name(end-15: end), '.dat.txt.out.txt')
            records(end+1).conditionName=d(i).name(1:end-16);
            %              [A len]=textscan(d(i).name,'%[^.].dat.txt.out.txt');
            %             if len==length(d(i).name)
            %                 records(end).condition=A{1}{1};
            %             else
            %                 error('couldn''t parse')
            %             end
            fid=fopen(fullfile(outdir,d(i).name),'r');
            if fid>0
                A={};
                [A len]=textscan(fid,'%*q %n %n %n %n',3,'HeaderLines',1);
                records(end).lapse_theta1_theta2_05=A{1};
                records(end).lapse_theta1_theta2_50=A{2};
                records(end).lapse_theta1_theta2_95=A{3};
                records(end).lapse_theta1_theta2_mean=A{4};

                A={};
                [A len]=textscan(fid,'%*q %n %n %n','HeaderLines',2);
                records(end).samples=A;


                A={};
                [A len]=textscan(fid,'"chance" "%n"',1,'HeaderLines',7);
                records(end).chance=A{1};


                A={};
                [A len]=textscan(fid,'"type" %q',1,'HeaderLines',1);
                records(end).type=A{1}{1};

                A={};
                [A len]=textscan(fid,'"alpha" "%n"',1,'HeaderLines',1);
                records(end).alpha=A{1};

                A={};
                [A len]=textscan(fid,'"1" %n','HeaderLines',2);
                records(end).acceptRate=A{1};
                
                fclose(fid)
            else
                d(i).name
                error('unexpected file');
            end


        else
            fprintf(['error opening ' d(i).name '\n'])

        end
    end
end

%%
function leapFrogValues=getQuickStartLeapFrogValues(subjectID, condition)

useDefault=0;
db=getQuickStartDB;
if ~isempty(db)
    dbID=find(strcmp(subjectID, {db.subjectID}))
    if ~isempty(dbID)
        conditionID=find(strcmp(condition,db(dbID).condition))
        if ~isempty(conditionID)
            leapFrogValues=db(dbID).leapFrogValue{conditionID};
        else
            useDefault=1;
        end
    else
        useDefault=1;
    end

    %     h=db(dbID).searchHistory{conditionID}  %testing to see if it's there
else
    useDefault=1;
end


if useDefault==1
    leapFrogValues=[.1 .03 .08];
end


%%
function saveQuickStartLeapFrogValue(subjectID, condition, c, searchHistory)
db=getQuickStartDB;


%add values
if isempty(db)
    db.subjectID=subjectID;
    db.condition=condition;
    db.leapFrogValue={c};
    db.searchHistory=searchHistory;
else
    dbID=find(strcmp(subjectID, {db.subjectID}));
    if ~isempty(dbID)
        conditionID=find(strcmp(condition, db(dbID).condition))
        if isempty(conditionID)
            conditionID=length(db(dbID).condition)+1;
        end
    else
        dbID=length(db)+1;
    end
    db(dbID).subjectID=subjectID;
    db(dbID).condition{conditionID}=condition;
    db(dbID).leapFrogValue{conditionID}=c;
    db(dbID).searchHistory{conditionID}=searchHistory;
end

path=getRBatchPath('root');
fileName=fullfile(path,'quickStart.mat');
save(fileName, 'db')
%%
function db=getQuickStartDB

path=getRBatchPath('root');
fileName=fullfile(path,'quickStart.mat');
d=dir(path);
if exist(fileName, 'file')
    load(fileName);
else
    db=[];
end


%%
