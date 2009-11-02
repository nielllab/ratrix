function extractPhysThenAnalyze(record,analysisBase,dataBase,targetBase,targetBinsPerSec)
%this is inefficient because it does each chunk in a separate run of spike,
%rather than grouping a file and all its chunks into one run.  thus, you
%pay the cost of opening the file multiple times.  would be more
%complicated, but doable, to do it all at once...

force=false;

fileFiles={'stim','phys','pulse','pokes'};
chunkFiles={'spks','waveforms'};
reduceFiles={'stim','phys'};

for i=1:length(record)
    rec=record(i);
    if ~rec.dummy
        pth=fullfile(rec.rat_id,datestr(rec.date,'mm.dd.yy'));
        
        datafile=fullfile(dataBase,pth,rec.baseFile);
        
        base=hash(rec.baseFile,'SHA1');
        analysisDir=fullfile(analysisBase,pth,base);
        targetDir=fullfile(targetBase,pth,base);
        
        fns=cellfun(@(x) fullfile(analysisDir,[x '.' base '.txt']),fileFiles,'UniformOutput',false);
        
        wavemarkOnly=~strcmp(rec.file,rec.baseFile);

        newTxts=false;
        if ~wavemarkOnly  %CHECK: make sure we really should prevent from calling when wavemarkonly -- for some reason i thought this was wrong for a while
            if force || ~all(cellfun(@(x) exist(x,'file'),fns))
                fprintf('%s\n',datafile)
                resetDir(analysisDir); %pessimistic if any are missing

                rec.chunks=[];
                
                fns{:}
                
                makeEmptyTxtFile(fullfile(analysisDir,['pokes.' base '.txt']));
                tic
                runScript(makeTmpScript('file',analysisDir,rec,base,getLastStop(record,i)),datafile);
                toc
                newTxts=true;
            end
            
            fns=cellfun(@(x) fullfile(targetDir,[x '.' base '.mat']),reduceFiles,'UniformOutput',false);
            if force || ~all(cellfun(@(x) exist(x,'file'),fns)) || newTxts
                resetDir(targetDir);
                for rNum=1:length(fns)
                    reduceTxt(targetDir,analysisDir,base,reduceFiles{rNum},rec.([reduceFiles{rNum} 'Chan']));
                end
            end
        end
        
        cbase=hash(rec.file,'SHA1');
        wavemarkDir=fullfile(analysisBase,pth,cbase);
        datafile=fullfile(dataBase,pth,rec.file);
        
        for j=1:length(record(i).chunks)
            base=['chunk' num2str(j) '.' cbase];
            
            chunkDir=fullfile(analysisBase,pth,cbase,['chunk' num2str(j)]); %this naming scheme fails badly if anyone reorders spreadsheet columns -- need to think of a way to externally verify the data matches up
            cfns=cellfun(@(x) fullfile(chunkDir,[x '.' base '.txt']),chunkFiles,'UniformOutput',false);
            if force || ~all(cellfun(@(x) exist(x,'file'),cfns))
                resetDir(chunkDir);

                rec.chunks=record(i).chunks(j);
                
                cfns{:}
                
                tic
                runScript(makeTmpScript('chunk',chunkDir,rec,base),datafile);
                toc
            end
        end
        
        if wavemarkOnly
            if i==1
                error('first rec was a wavemarkonly')
            end
            if strcmp(rec.baseFile,record(i-1).baseFile) && ~isempty(record(i-1).stimTimes)
                record(i).stimTimes=record(i-1).stimTimes;
            else
                error('wavemarkonly not preceded by rec with matching basefile and some stimtimes')
            end
        end
        
        compilePhysTxt(targetDir,analysisDir,wavemarkDir,record(i),force,targetBinsPerSec);
    end
end

%when reading into .mat's, waveformonly files should refer to the file .txts in their baseDir's filedir
% ~strcmp(record(i).file,record(i).baseFile)

end

function out=getLastStop(r,i)
%BUG: this will miss anyone that hasn't made it through the filter
%SOLUTION: do a fresh extractPhysRecord to get a complete list

%BUG: cuts off pulses at the end of a (sorting) chunk boundary even if a stim goes longer than that -- and we need the end of the stim to catch the right end pulses

mask=strcmp({r.baseFile},r(i).baseFile);

%out=max([r(mask).chunks.stop_time]); %matlab fail: Scalar index required for this type of multi-level indexing.
r=[r(mask).chunks]; %might fail cuz of matlab's lame struct concatenation not able to merge fields unless they are exactly identical AND in the same order
out=max([r.stop_time]); %need to consider stim times too to catch good end of pulses even if sorting didn't go that far
end

function makeEmptyTxtFile(f)
[fid msg]=fopen(f,'wt');
if fid==-1
    msg
    error('couldn''t make empty txt file')
else
    fprintf(fid,'\n');
    if fclose(fid)
        error('fclose error')
    end
end
end

function fName=makeTmpScript(type,analysisDir,rec,base,lastStop)
fName=fullfile(analysisDir,'tmp.s2s');

params.baseDir=analysisDir;
if params.baseDir(end)~=filesep
    params.baseDir(end+1)=filesep;
end
params.base=base;

params.physChan=-1;
params.stimChan=-1;
params.framePulseChan=-1;
params.indexPulseChan=-1;
params.phasePulseChan=-1;
params.stimPulseChan=-1;
params.spkChan=-1;
params.spkCode=-1;

    function out=neg(out)
        if ischar(out) && strcmp(out,'none')
            out=-1;
        elseif ~isinteger(out) || out<=0
            error('should be strictly positive integers or ''none''')
        end
    end

switch type
    case 'file'
        if ~isempty(rec.chunks)
            error('don''t supply chunks for file script')
        end
        rec
        
        params.times=[rec.stimTimes{1,1} lastStop];
        
        params.physChan=rec.physChan;
        params.stimChan=rec.stimChan;
        
        params.framePulseChan=neg(rec.framePulseChan);
        params.indexPulseChan=neg(rec.indexPulseChan);
        params.phasePulseChan=neg(rec.phasePulseChan);
        params.stimPulseChan =neg(rec.stimPulseChan);
        
    case 'chunk'
        if ~isscalar(rec.chunks)
            error('scalar chunk required for chunk script')
        end
        rec.chunks
        
        params.times=[rec.chunks.start_time rec.chunks.stop_time];
        
        params.spkChan=rec.chunks.spkChan;
        params.spkCode=rec.chunks.spkCode;
    otherwise
        error('unknown type')
end

lines={};
[fid msg]=fopen('physToTxt.s2s','rt');
if fid==-1
    msg
    error('couldn''t read template script')
else
    while ~feof(fid)
        lines{end+1}=fgetl(fid);
        if lines{end}==-1
            if fclose(fid)
                warning('fclose error')
            end
            error('got an unexpected eof')
        end
    end
    if fclose(fid)
        error('fclose error')
    end
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
    if fclose(fid)
        error('fclose error')
    end
end
end

function out=makeTmpScriptString(params)
pList=cellfun(@(x) double(params.([x 'PulseChan'])),{'frame','index','phase','stim'});
pList=pList(pList>0);
n=length(pList);

out={};
out{end+1}=sprintf('const base$           := "%s";',params.base);
out{end+1}=sprintf('const expPath$        := "%s";',doubleChar(params.baseDir,{'\'}));
out{end+1}=sprintf('const sTime           :=  %g ;',params.times(1));
out{end+1}=sprintf('const eTime           :=  %g ;',params.times(2));

out{end+1}=sprintf('const stimChan%%      :=  %d ;',params.stimChan);       %photodiode recording
out{end+1}=sprintf('const physChan%%      :=  %d ;',params.physChan);       %the high fidelity one
out{end+1}=sprintf('var   pulses%%[%d]           ;',n+1);
out{end+1}=sprintf('pulses%%[0]           :=  %d ;',n);
for i=1:length(pList)
    out{end+1}=sprintf('pulses%%[%d]      :=  %d ;',i,pList(i));
end

%out{end+1}=sprintf('const framePulseChan%%:=  %d ;',params.framePulseChan);
%out{end+1}=sprintf('const indexPulseChan%%:=  %d ;',params.indexPulseChan);
%out{end+1}=sprintf('const phasePulseChan%%:=  %d ;',params.phasePulseChan);
%out{end+1}=sprintf('const stimPulseChan%% :=  %d ;',params.stimPulseChan);

out{end+1}=sprintf('const spkChan%%       :=  %d ;',params.spkChan);        %wavemark chan (all codes will be considered one class, so we hide those we don't want exported)
out{end+1}=sprintf('const spkCode%%       :=  %d ;',params.spkCode);
end

function runScript(scriptfile,datafile)
[status result]=system(['C:\Spike5\sonview /M "' datafile '" "' scriptfile '"']);

if status~=0
    result
end
delete(scriptfile);
end

function resetDir(d)
a=false;
while ~a %ah, windows...
    [a b c]=rmdir(d,'s');
    if ~a
        if ~strcmp(c,'MATLAB:RMDIR:NotADirectory')
            {b,c,d}
            %getting     'No directories were removed.'    'MATLAB:RMDIR:NoDirectoriesRemoved'
            %might be if someone is looking at dir remotely...
            WaitSecs(.1);
        else
            a=true;
        end
    end
end

[a b c]=mkdir(d);
if ~a
    b
    c
    error('couldn''t mkdir')
end
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