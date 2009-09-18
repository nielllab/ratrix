function record=doPhys
%%%%%
%setup the following fields to control the analysis
%%%%%

%directory containing 'phys record.csv' and that will receive output
analysisBase='C:\Documents and Settings\rlab\Desktop\edf analysis';

%directory containing .smr files, in subdirectories ratID\mm.dd.yy\*.smr
dataBase='C:\eflister\phys\sorted';

%indicate what to process
target.rat_ids={};%{'164'};
target.dates={};%{'10.16.08','03.25.09'};
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

extractPhysToText(record,analysisBase,dataBase);

end

function record=doExclusion(record,target,exclude)
mask=ismember({record.rat_id},target.rat_ids) & ismember(arrayfun(@(x) datestr(x,'mm.dd.yy'),[record.date],'UniformOutput',false),target.dates);
if exclude
    mask=~mask;
end
record=record(mask);
for j=1:length(record)
    mask=ismember([record(j).chunks.cell_Z],target.depths);
    if exclude
        mask=~mask;
    end
    record(j).chunks=record(j).chunks(mask);
end
record=record(~cellfun(@isempty,{record.chunks}));
end