function record=doPhys
%%%%%
%setup the following fields to control the analysis
%%%%%
targetBinsPerSec=1000;

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
elseif ismac
    %mountOSX;
    
    analysisBase='/Volumes/Maxtor One Touch II/eflister phys/physDB';
    dataBase='/Volumes/Maxtor One Touch II/eflister phys/phys backup of verified good data/NOT sorted!'; %'/Volumes/rlab/Rodent-Data/physiology/eflister/sorted';
    targetBase='/Volumes/Maxtor One Touch II/eflister phys/phys analysis';
end

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

%%%%%
% setup done, don't edit below here
%%%%%

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(fileparts(pathstr)))),'bootstrap'));
setupEnvironment;

record=doExclusion(extractPhysRecord(fullfile(analysisBase,'phys record.csv'),dataBase),target,exclude);

extractPhysThenAnalyze(record,analysisBase,dataBase,targetBase,targetBinsPerSec);
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