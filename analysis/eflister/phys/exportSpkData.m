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

function params=readPhysRecord(csvfile,recordingID)
C={};
numRecs=0;
fid=fopen(csvfile,'rt');
if fid==-1
    msg
    error('couldn''t open csv file')
else
    try
        while ~feof(fid)
            line=fgetl(fid);
            if ~isempty(line)
                if line==1
                    error('unexpected eof')
                else
                    C(end+1)=textscan(line,'%q','Delimiter',',');
                    s=size(C{end},1);
                    if s > numRecs
                        numRecs=s;
                    end
                end
            end
        end
        error('good') %cuz no finally
    catch ex
        fclose(fid);
        if ~strcmp(ex.message,'good')
            getReport(ex)
            rethrow(ex)
        end
    end
    numRecs=numRecs-1;
    fprintf('%g records\n',numRecs);
    model=reify(parsefields(C,numRecs));
    keyboard
    params=[];
end
end

function m=parsefields(C,n)
names={};
fixed={};
for i=1:length(C)
    line=C{i};
    names{end+1}=sub(line{1},' ','_');
    fixed(end+1,:)=parsefield(line{1},line(2:end),n);
end
m=cell2struct(fixed,names); %detects if any fieldname dupes
end

function out=sub(s,c1,c2)
out=s;
out(out==c1)=c2;
end

function out=parsefield(f,v,n)
out=v;
more=n-length(out);
if more<0
    error('too many values')
elseif more>0
    [out{end+1:end+more}]=deal('');
end
out=cellfun(@(x) validatefield(f,x),out,'UniformOutput',false);
end

function checkEmpty(out)
if isempty(out)
    evf;
end
end

function checkMember(out,list)
if ~ismember(out,list)
    evf;
end
end

function v=getVal(out,f,n,r)
if ~exist('n','var') || isempty(n)
    n=1;
end

checkEmpty(out);
[C s]=textscan(out,f);
if ~all(size(C)==[1 n]) || s~=length(out)
    evf;
end
v=cell2mat(C);

if exist('r','var')
    check=arrayfun(@(x) x>=r(1) && x<=r(2),v);
    if ~all(check(:))
        evf;
    end
end
end

function evf
error('validation failed');
end

function out=prefix(f,out,p)
m=length(p)+1;
if length(out)>length(p)+1 && strcmp(out(1:m),[p ' ']) %textscan won't enforce space even w/WhiteSpace=''
    validatefield(f,out(m+1:end));
    out=true;
else
    out=false;
end
end

function out=sep(f,out,s)
s=[' ' s ' '];
inds=findstr(out,s);
if isempty(inds)
    out=false;
else
    %textscan no good for Delimiter=[' ' s ' '] even when WhiteSpace=''
    C={};
    cur=1;
    inds(end+1)=length(out)+1;
    for i=inds
        C{end+1}=out(cur:i-1);
        cur=i+length(s);
    end
    check=cellfun(@(x) validatefield(f,x),C,'UniformOutput',false);
    out=true;
end
end

function out=validatefield(f,out)
try
    switch f
        case 'date'
            out=getVal(out,'%2u8.%2u8.%2u8',3,[1 31]);
            checkMember(out(3),[8,9]);
            out=double(out);
            out=datenum(2000+out(3),out(1),out(2));
        case 'rat id'
            checkMember(out,{'188','164'});
        case 'personnel'
            allowed={'balaji','erik','yuli'};
            checkEmpty(out);
            C=textscan(out,'%s','Delimiter',',');
            test=cellfun(@(x) ismember(x,allowed),C{1});
            if any(~test(:))
                evf;
            end
        case 'notebook'
            checkMember(out,{'NB11'});
        case 'electrode mfg'
            checkMember(out,{'FHC'});
        case 'electrode serial'
            checkMember(out,{'UEWMCGLECN3M'});
        case 'electrode lot'
            checkMember(out,{'885191'});
        case 'electrode imp MOhm'
            out=getVal(out,'%f',1,[.5 20]);
        case {'ref AP','ref ML','ref Z','cell AP','cell ML','cell Z'}
            out=getVal(out,'%f',1,50*[-1 1]);
        case 'file'
            checkEmpty(out);
            if ~strcmp(out(end-3:end),'.smr')
                evf;
            end
        case 'amp gain'
            checkMember(out,{'1k','10k'})
        case 'amp lopass'
            checkMember(out,{'100'});
        case 'amp hipass'
            checkMember(out,{'500','1k'});
        case 'amp notch'
            checkMember(out,{'in','out'});
        case 'cell snr'
            out=getVal(out,'%f',1,[0 10]);
        case 'stim type'
            checkMember(out,{'gaussian','sinusoidal','hateren'});
        case 'stim params'
            %pass
        case {'start time','stop time'}
            %TODO check these are in order
            maxDurHours=2;
            out=getVal(out,'%f',1,[0 maxDurHours*60*60]);
        case 'notes'
            %pass
        case 'display type'
            checkMember(out,{'crt','led'});
        case 'pulse type'
            checkMember(out,{'double'});
        case 'experiment type'
            checkMember(out,{'passive viewing'});
        case 'anesthesia'
            checkMember(out,{'no'});
        case 'headfixed'
            checkMember(out,{'yes'});
        case {'physChan','stimChan','spkChan','framePulseChan','trialPulseChan'}
            %TODO check that these are disjoint
            checkEmpty(out);
            if strcmp(f,'trialPulseChan') && strcmp(out,'none')
                %pass
            else
                out=getVal(out,'%u8',1,[1 10]);
            end
        case 'spkCode'
            out=getVal(out,'%u8',1,[0 10]);
        case 'current sort quality'
            checkMember(out,{'needs resorting','as good as possible','perfect'});
        case 'absolute sortability'
            checkMember(out,{'multiunit','pretty good','perfect isolation'});
        otherwise
            f
            error('unrecognized field')
    end
catch ex
    if (isempty(out) || (length(out)==1 && out=='?') || prefix(f,out,'probably') || sep(f,out,'or')) && strcmp(ex.message,'validation failed')
        %pass
    else
        f
        out
        rethrow(ex)
    end
end
end

function out=reify(out)

groups = {...
    'basic',{'date','rat id'};...
    'electrode',{'electrode mfg','electrode serial','electrode lot','electrode imp MOhm'};...
    'ref coords',{'ref AP','ref ML','ref Z'};...
    'amp',{'amp gain','amp lopass','amp hipass','amp notch'};...
    'setup',{'display type','pulse type','experiment type','anesthesia','headfixed','physChan','stimChan','framesPulseChan','trialPulseChan'};...
    %    'recording',{'cell snr','stim type','stim params','start time','stop time','notes','current sort quality','absolute sortability','spkChan','spkCode'}
    };

rules={...
    {},...
    };

fs=fieldnames(out);
for i=1:length(out)
    for fn=1:length(fs)
        out(i).(fs{fn})
    end
end
end