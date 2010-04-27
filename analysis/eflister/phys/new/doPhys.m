function doPhys
%%%%%
%setup the following fields to control the analysis
%%%%%

dbstop if error

targetBinsPerSec=1000;

    function out=split(in,delim)
        out={};
        while ~isempty(in)
            [out{end+1} in]=strtok(in,sprintf(delim));
            out{end}=strtrim(out{end});
            if isempty(out{end})
                out=out(1:end-1);
            end
        end
    end

if IsWin
    %directory containing 'phys record.csv' and that will receive text output
    analysisBase='F:\eflister phys\physDB';
    %'\\132.239.158.180\physDB';
    %'D:\physDB';
    %'C:\Documents and Settings\rlab\Desktop\edf analysis';
    
    %directory containing .smr files, in subdirectories ratID\mm.dd.yy\*.smr
    dataBase='\\132.239.158.180\sorted';
    %'C:\eflister\phys\sorted';
    
    %directory to receive .mat intermediates and figs
    targetBase='F:\eflister phys\phys analysis';
    %'\\132.239.158.179\phys analysis';
    %'C:\Documents and Settings\rlab\Desktop\phys analysis';
    
    volumeName='Maxtor One Touch II';
    
    %would like a general solution for getting drive letter from volume name:
    %http://www.keyongtech.com/2291337-drive-letter-from-volume-name
    %    baseDir='F:';
    
    [a b]=dos('mountvol');
    if a==0
        drives={};
        b=split(b,'\n');
        while length(b{end})==3
            drives{end+1}=b{end};
            b=b(1:end-2);
        end
        
        names={};
        baseDir=[];
        for i=1:length(drives)
            
            [a b]=dos(['vol ' drives{i}(1:2)]);
            if a==0
                if strcmp(b(1:find(b==sprintf('\n'))-1),[' Volume in drive ' drives{i}(1) ' is ' volumeName])
                    if isempty(baseDir)
                        baseDir=drives{i};
                        b
                    else
                        error('multiple volume label matches')
                    end
                end
            else
                if ~strcmp(b,sprintf('\nThe device is not ready.\n'))
                drives{i}
                b
                error('couldn''t call dos ''vol''')
                end
            end
            
        end
        
        if isempty(baseDir)
            error('no volume label match')
        end
    else
        error('couldn''t call dos ''mountvol''')
    end
    
    desktop=fullfile('C:','Documents and Settings','rlab','Desktop');
elseif ismac
    %mountOSX;
    
%    analysisBase='/Volumes/Maxtor One Touch II/eflister phys/physDB';
%    dataBase='/Volumes/Maxtor One Touch II/eflister phys/phys backup of verified good data/NOT sorted!'; %'/Volumes/rlab/Rodent-Data/physiology/eflister/sorted';
%    targetBase='/Volumes/Maxtor One Touch II/eflister phys/phys analysis';
    
%    figureBase='/Users/eflister/Desktop/figures';
%    tmpDir='/Users/eflister/Desktop/analysis tmp/';
    
    baseDir=fullfile('Volumes','Maxtor One Touch II');
    desktop=fullfile('Users','eflister','Desktop');
end

    baseDir=fullfile(baseDir,'a'); %was: 'eflister phys'); -- shortened cuz of windows length limit
    analysisBase=fullfile(baseDir,'physDB');
    dataBase=fullfile(baseDir,'phys backup of verified good data','NOT sorted!');
    targetBase=fullfile(baseDir,'b'); % was: 'phys analysis'); -- shortened cuz of windows length limit
    
    figureBase=fullfile(desktop,'figures');
    tmpDir=fullfile(desktop,'analysis tmp');

[status,message,messageid]=mkdir(tmpDir);
if ~status
    message
    messageid
    error('couldn''t make dir')
end
tmpFile=fullfile(tmpDir,[datestr(now,30),'.tmpFile.mat']); %this is for accumulating quantities for population analysis
init=true;
save(tmpFile,'init'); %so we can always use -append later
diary(fullfile(tmpDir,[datestr(now,30),'.diary.txt']));


    function out=analysisFilt(rec,stimType)
        if ~exist('stimType','var')
            stimType=[];
        end
        %out=ismember(char(stimType),{'gaussian',''}) && isnumeric(rec.indexPulseChan);
        out=true;
    end

%%%%%
% setup done, don't edit below here
%%%%%

if false
    %indicate what to process
    target.rat_ids={};%{'164'};
    
    % 164 done
    % 10.16.08
    % 10.21.08
    % 10.22.08
    % 02.24.09
    % 02.26.09
    % 02.27.09
    % 03.13.09
    % 03.17.09
    % 03.19.09
    
    % 164 todo
    % 03.25.09
    % 04.07.09
    % 04.15.09
    % 04.17.09
    
    % 188 done
    % 04.23.09
    % 04.24.09
    
    % 188 todo
    % 04.29.09 %partial
    % 05.06.09
    % 05.08.09
    
    target.dates={};%{'03.25.09','04.07.09','04.15.09','04.17.09'};
    
    target.depths=[];%[13.24,19.97];
    
    %do all BUT targets
    exclude=true;
end

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(fileparts(pathstr)))),'bootstrap'));
setupEnvironment;

record=extractPhysRecord(fullfile(analysisBase,'phys record.csv'),dataBase);
if false
    record=doExclusion(record,target,exclude);
end

extractPhysThenAnalyze(record,analysisBase,dataBase,targetBase,targetBinsPerSec,figureBase,@analysisFilt,tmpFile);

diary off
end

function record=doExclusion(record,target,exclude)
mask=ismember({record.rat_id},target.rat_ids) & ismember(arrayfun(@(x) datestr(x,'mm.dd.yy'),[record.date],'UniformOutput',false),target.dates);
if exclude
    mask=~mask;
end
record=record(mask);
if false %temp hack
    for j=1:length(record)
        mask=ismember([record(j).chunks.cell_Z],target.depths);
        if exclude
            mask=~mask;
        end
        record(j).chunks=record(j).chunks(mask);
    end
    record=record(~cellfun(@isempty,{record.chunks}));
end
end