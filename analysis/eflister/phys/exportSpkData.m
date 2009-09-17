function exportSpkData

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(pathstr))),'bootstrap'));
setupEnvironment;

recordingID=100;
baseDir='C:\Documents and Settings\rlab\Desktop\';

%exported csv from spreadsheet
csvfile='C:\Documents and Settings\rlab\Desktop\edf phys record.csv';
%use textscan to read this and get paths, times, chan numbers, etc for above recordingID

params=readPhysRecord(csvfile,recordingID);
keyboard

params.baseDir=baseDir;
params.base='164.pen1.2nd';
params.times=[3477 3798];
params.displayType='CRT';
params.pulseType='double';
params.physChan=3;
params.stimChan=1;
params.spkChan=6;
params.spkCode=1;
params.framePulseChan=2;
params.trialPulseChan=-1;

scriptfile=fullfile(baseDir,'tmp.s2s');
datafile=fullfile(baseDir,[params.base '.smr']);

makeTmpScript(scriptfile,params);

[status result]=system(['C:\Spike5\sonview /M "' datafile '" "' scriptfile '"']);
if status~=0
    result
end
delete(scriptfile);

doWaveforms(baseDir,params.base,params.spkChan,params.spkCode);
end

function makeTmpScript(fName,params)
lines={};
[fid msg]=fopen('physToTxt.s2s','rt');
if fid==-1
    msg
    error('couldn''t read template script')
else
    while ~feof(fid)
        lines{end+1}=fgetl(fid);
        if lines{end}==-1
            fclose(fid);
            error('got an unexpected eof')
        end
    end
    fclose(fid);
end

[fid msg]=fopen(fName,'wt');
if fid==-1
    msg
    error('couldn''t make tmp script')
else
    top=makeTmpScriptString(params);
    for i=[top lines]
        fprintf(fid,[doubleChar(i{1},{'%','\'}) '\n']);
    end
    fclose(fid);
end
end

function out=makeTmpScriptString(params)
out={};
out{end+1}=sprintf('const base$           := "%s";',params.base);
out{end+1}=sprintf('const sTime           :=  %g ;',params.times(1));
out{end+1}=sprintf('const eTime           :=  %g ;',params.times(2));
out{end+1}=sprintf('const spkChan%%       :=  %d ;',params.spkChan);        %wavemark chan (all will be considered one class, hide any you don't want exported)
out{end+1}=sprintf('const spkCode%%       :=  %d ;',params.spkCode);
out{end+1}=sprintf('const stimChan%%      :=  %d ;',params.stimChan);       %photodiode recording
out{end+1}=sprintf('const framePulseChan%%:=  %d ;',params.framePulseChan);
out{end+1}=sprintf('const physChan%%      :=  %d ;',params.physChan);       %the high fidelity one
out{end+1}=sprintf('const trialPulseChan%%:=  %d ;',params.trialPulseChan); %indicates stimulus/repeats starts (-1 for none)
out{end+1}=sprintf('const expPath$        := "%s";',doubleChar(params.baseDir,{'\'}));
end

function out=doubleChar(in,cs)
out=char([]);
for i=in
    if ismember(i,cs)
        out(end+1)=i;
    end
    out(end+1)=i;
end
end
