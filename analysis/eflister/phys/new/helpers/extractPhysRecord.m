function record=extractPhysRecord(csvfile,dataBase)
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
                if line==-1
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
        if fclose(fid)
            error('fclose error')
        end
        
        if ~strcmp(ex.message,'good')
            getReport(ex)
            rethrow(ex)
        end
    end
    numRecs=numRecs-1;
    record=parsefields(C,numRecs,dataBase);
end
printSummary(record);
end

function printSummary(r)
files=0;
days=0;
times=[];
uniqueZs=0;
lastZ=nan;
lastDate=nan;
for i=1:length(r)
    if ~r(i).dummy
        files=files+1;
        if lastDate~=r(i).date
            days=days+1;
            lastDate=r(i).date;
        end
        for j=1:length(r(i).chunks)
            time=r(i).chunks(j).stop_time-r(i).chunks(j).start_time;
            z=r(i).chunks(j).cell_Z;
            if z==lastZ
                times(end)=times(end)+time;
            else
                uniqueZs=uniqueZs+1;
                lastZ=z;
                times(end+1)=time;
            end
        end
    end
end

fprintf('found %d files with %d putative cells over %d unique days\n',files,uniqueZs,days);
fprintf('total good recording time is %.2f hours (avg %.2f mins/cell)\n',sum(times)/60/60,sum(times)/uniqueZs/60);
end

function m=parsefields(C,n,dataBase)
names={};
fixed={};
stimTimesDone=false;
stimTimes={};
for i=1:length(C)
    line=C{i};
    handled=false;
    if ~isempty(stimTimes) && ~stimTimesDone
        if isempty(line{1}) || ismember(line{1},{'mark > lo > hi > frm > hi > lo > (mark)'})
            stimTimes{end+1}=line(2:end);
            handled=true;
        else
            stimTimesDone=true;
        end
    elseif isempty(line{1})
        error('shouldn''t happen')
    elseif strcmp(line{1},'mark > 2pls > frm > 1pls > (mark > 3pls end)')
        if isempty(stimTimes) && ~stimTimesDone
            stimTimes{end+1}=line(2:end);
            handled=true;
        else
            error('found 2 stim time lines')
        end
    end
    if ~handled
        names{end+1}=subUS(line{1});
        fixed(end+1,:)=parsefield(line{1},line(2:end),n);
    end
end
if isempty(stimTimes)
    error('didn''t find stim times')
end
m=cell2struct(fixed,names); %detects if any fieldname dupes
m=consistencyChecksAndReduce(m,dataBase,stimTimes);
end

function out=maxTime
% spike has (a little more than) 2GB (3.73 hrs) limit (2 chans of 40kHz @ 16bit)
lim=2^31;
nChans=2;
sRate=40000;
bytes=2;
out=lim/(bytes*sRate)/nChans;
end

function out=getStimTimes(st,i)
out={};
done=false;
for j=1:length(st)
    if length(st{j})>=i
        stuff=st{j}{i};
        if isempty(stuff)
            done=true;
        elseif ~done
            [C s]=textscan(stuff,'%f %s');
            if ~all(size(C)==[1 2]) || s~=length(stuff) || ~ismember(C{2},{'sinusoid','off','junk','gaussian','hateren','gaussgrass','rpt/unq','sinusoid(new)','squarefreqs'}) || C{1}<0 || C{1}>maxTime || (~isempty(out) && C{1}<=out{end,1}) || ~isscalar(C{2})
                ~all(size(C)==[1 2])
                s~=length(out)
                ~ismember(C{2},{'sinusoid','off','junk','gaussian','hateren','gaussgrass'})
                C{1}<0
                C{1}>maxTime
                ~isempty(out)
                try
                    C{1}<=out{end,1}
                end
                C{:}
                out
                size(C)
                s
                
                evf;
            end
            out(end+1,1:2)={C{1},C{2}{1}};
        elseif ~isempty(stuff)
            error('noncontiguous stim times')
        end
    else
        done=true;
    end
end
end

function out=inherit(out,template,fields)
e=cellfun(@(x) isempty(template.(x)),fields);
if all(e)
    if length(out)>1
        template=out(end-1);
    else
        error('no previous entry to inherit from')
    end
elseif any(e)
    error('all must be in same state')
end
for i=1:length(fields)
    out(end).(fields{i})=template.(fields{i});
end
end

function out=fileOnly
%all but fileDec could conceivably vary within file, but let's enforce simplicity
out=subUS({'physChan','stimChan','display type','pulse type','indexPulseChan','phasePulseChan','stimPulseChan','framePulseChan','rat id','date'});
end

function out=pulseFields
f=fileOnly;
out=f(cellfun(@(x) ~isempty(findstr('pulsechan',lower(x))),fileOnly));
end

function out=chanFields
f=fileOnly;
out=f(cellfun(@(x) ~isempty(findstr('chan',lower(x))),fileOnly));
end

function out=chanFieldsEx
out=chanFields;
out(end+1)={'spkChan'};
end

function out=isWaveMarkOnly(f)
out=~strcmp(f.file,f.baseFile);
end

%handles the inheretence of blanks
%this is more complex than i expected, sorry :(  works tho :)
function flist=consistencyChecksAndReduce(out,dataBase,stimTimes)
verbose=true;
        
fileDec=subUS({'rat id','date'}); 
fileOnlySub=setdiff(fileOnly,fileDec);
chanFieldsLoc=chanFields; %cuz no dynamic indexing

flist=[];
lastWasDummy=false;
for i=1:length(out)
    f=out(i).file;
    tStimTimes=getStimTimes(stimTimes,i);
    if ~isempty(f)
        flist(end+1).file=f;
        flist=inherit(flist,out(i),fileDec); %could conceivably inherit separately, but let's enforce that these are always entered together
        flist(end).stimTimes=tStimTimes;
        flist(end).chunks=[];

        for fo=1:length(fileOnlySub)
            %separately inherit each (don't need to all have same state)
            flist=inherit(flist,out(i),fileOnlySub(fo));
        end
        
        chanList=[];

        for c=1:length(chanFieldsLoc)
            tc=flist(end).(chanFieldsLoc{c});
            if ~(ischar(tc) && ismember(tc,{'none','X'}))
                if ~ismember(tc,chanList)
                    chanList(end+1)=tc;
                else
                    error('channel conflict')
                end
            end
        end
        
        switch flist(end).pulse_type
            case {'double','triple','index'}
                test = ~strcmp(flist(end).display_type,'crt');
                need = {'framePulseChan'};
                
                switch flist(end).pulse_type
                    case 'triple'
                        need(end+1:end+2)={'stimPulseChan','phasePulseChan'};
                    case 'index'
                        need=pulseFields;
                end
                
                cant = setdiff(pulseFields,need);
            case 'led'
                test = ~strcmp(flist(end).display_type,'led');
                need = {'indexPulseChan'};
                cant = setdiff(pulseFields,need);
            otherwise
                error('unknown pulse type')
        end
        
        bf=length(flist);
        if any(cellfun(@(x) ischar(flist(end).(x)) && strcmp(flist(end).(x),'X'),chanFields))
            bf=bf-1;
        end
        flist(end).baseFile = flist(bf).file;
        if isWaveMarkOnly(flist(end))
            if any(cellfun(@(x) ~ismember(flist(end).(x),{'X','none'}),chanFields))
                error('if any channel is marked X for wavemark only, all of them must be X or none')
            end
            if ~isempty(tStimTimes)
                error('wavemark only files should not have stimtimes')
            end
        elseif any(test) || any(cellfun(@(x) ~strcmp('none',flist(end).(x)),cant)) || any(cellfun(@(x) ~all(cellfun(@(y) y(flist(end).(x)),{@isscalar,@isinteger})),need)) %ha ha
            flist(end).display_type
            flist(end).pulse_type
            test
            cellfun(@(x) ~strcmp(x,flist(end).(x)),cant)
            cellfun(@(x) ~all(cellfun(@(y) y(flist(end).(x)),{@isscalar,@isinteger})),need)
            error('pulse consistency fail')
        end
        
    elseif ~isempty(tStimTimes)
        error('stimTimes in non-file record')
    elseif any(cellfun(@(x) ~isempty(out(i).(x)),fileOnly))
        out(i)
        error('found file-only content in a chunk')
    elseif lastWasDummy
        error('found a chunk (non-file) entry immediately after a dummy file entry (used just for inheritence purposes) -- if this is correct, please put chunk info in the file record directly.')
    end
    lastWasDummy=false;
    
    z=out(i).cell_Z;
    if isempty(z)
        checkList=subUS({'ref AP','ref ML','ref Z','cell AP','cell ML','electrode mfg','electrode model','electrode lot','electrode params','electrode num','electrode imp MOhm'});
        
        if length(flist(end).chunks)>0
            z=flist(end).chunks(end).cell_Z;
            if isWaveMarkOnly(flist(end))
                error('shouldn''t happen')
            end
        elseif length(flist)>1 && strcmp(flist(end-1).rat_id,flist(end).rat_id) && flist(end-1).date==flist(end).date && all(cellfun(@(lv) isempty(out(i).(lv)),checkList))
            z=flist(end-1).chunks(end).cell_Z;
        else
            if isWaveMarkOnly(flist(end))
                error('shouldn''t happen')
            end
            z=nan;
            lastWasDummy=true;
            if verbose
                warning('got a z dummy')
            end
        end
    elseif isWaveMarkOnly(flist(end))
        error('wavemark only files must inherit')
    end
    flist(end).chunks(end+1).cell_Z=z;
    
    %must not be inherited for any chunk
    if ~isempty(out(i).spkCode)
        flist(end).chunks(end).spkCode=out(i).spkCode;
    else
        lastWasDummy=true;
        if verbose
            warning('got a spkCode dummy')
        end
    end
    
    %inherit only from previous chunk in same file (these are decoupled so that one can have multiple spkChans for the same timerange or v/v)
    try
        flist(end).chunks=inherit(flist(end).chunks,out(i),{'spkChan'});
        if ismember(flist(end).chunks(end).spkChan,chanList)
            error('spkChan conflict')
        end
        flist(end).chunks=inherit(flist(end).chunks,out(i),subUS({'start time','stop time'}));
        if flist(end).chunks(end).start_time>=flist(end).chunks(end).stop_time
            error('start and stop time out of order')
        end
    
    catch ex
        switch ex.message
            case 'no previous entry to inherit from'
                lastWasDummy=true;
                if verbose
                    warning('got a spkChan, start or stop time dummy')
                end
            otherwise
                rethrow(ex)
        end
    end
    
    %this handles case where a file contains no sorted spikes to analyze, and is just present for inheritence purposes (or waiting for someone to do sorting)
    flist(end).dummy=lastWasDummy;
    if lastWasDummy
        if ~isempty(f)
            if length(flist(end).chunks)~=1
                error('a dummy should have exactly one chunk')
            end
        else
            error('a non-file entry failed to find a value for cell_z, spkCode, spkChan, start or stop times')
        end
    end
    
    if ~isempty(flist(end).file) && ~flist(end).dummy && ~isWaveMarkOnly(flist(end)) && isempty(flist(end).stimTimes)
        error('files that aren''t dummy or wavemarkonly must have stimtimes')
    end
end
arrayfun(@doCheck,flist);
    function doCheck(rec)
        if isempty(dataBase)
            warning('running in no-txt-extract mode (no access to .smr files)')
            return
        end
        f=fullfile(dataBase,rec.rat_id,datestr(rec.date,'mm.dd.yy'),rec.file);
        if verbose
            fprintf('checking %s\n',f);
%             rec
%             rec.stimTimes
%             rec.chunks(:)
%             fprintf('\n')
        end
        if ~exist(f,'file')
            [garbage,tmpf]=fileparts(f);
            if strcmp(tmpf,'breakup') %temp hack!
                %pass
            else
            error('can''t find file')
            end
        end
    end
end

% %to avoid error 'Subscripted assignment between dissimilar structures.'
% %holy crap i hate matlab
% %i think we have a matlaby fix for this but i don't have time to look it up
% function s1=endMerge(s1,s2)
%     if ~all(cellfun(@isstruct,{s1,s2}))
%         error('bad inputs');
%     end
%     missing=setdiff(fieldnames(s2),fieldnames(s1));
%     for i=1:length(missing)
%         s1=setfield(s1,missing{i},[]); %s1 supposed to be scalar but hopefully they do scalar expansion?  we probably have no missing field names after the scalar case anyway...? 
%     end
%     s1=orderfields(s1,s2); %omg!
%     s1(end)=s2;
% end

function out=subUS(s)
out=sub(s,' ','_');
end

function out=sub(s,c1,c2)
if iscell(s)
    out=cellfun(@(x) subH(x,c1,c2),s,'UniformOutput',false);
else
    out=subH(s,c1,c2);
end
end

function out=subH(s,c1,c2)
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
            allowed={'balaji','erik','yuli','phil','pam'};
            checkEmpty(out);
            C=textscan(out,'%s','Delimiter',',');
            test=cellfun(@(x) ismember(x,allowed),C{1});
            if any(~test(:))
                evf;
            end
        case 'notebook'
            checkMember(out,{'NB11','NB18'});
        case 'electrode mfg'
            checkMember(out,{'FHC'});
        case 'electrode model'
            checkMember(out,{'UEWMCGLECN3M'});
        case 'electrode lot'
            checkMember(out,{'885191'});
        case 'electrode params'
            checkMember(out,{'20/40/10'});
        case 'electrode num'
            out=getVal(out,'%u8');
        case 'electrode imp MOhm'
            out=getVal(out,'%f',1,[.5 20]);
        case {'ref AP','ref ML','ref Z','cell AP','cell ML','cell Z'}
            out=getVal(out,'%f',1,100*[-1 1]);
        case 'file'
            checkEmpty(out);
            if ~strcmp(out(end-3:end),'.smr')
                evf;
            end
        case 'amp gain'
            %consider adding an 'amp id' field for serial number
            checkMember(out,{'1k','10k'})
        case 'amp locut'
            checkMember(out,{'high','300','100','10','1','0.1','open'});
        case 'amp hicut'
            checkMember(out,{'500','1k','5k','10k','20k','open'});
        case 'amp notch'
            checkMember(out,{'in','out'});
        case 'cell snr'
            out=getVal(out,'%f',1,[0 10]);
        case 'spikes clipped'
            checkMember(out,{'yes','no','rare'});
        case 'stim params'
            %pass
        case {'start time','stop time'}
            out=getVal(out,'%f',1,[0 maxTime]);
        case 'notes'
            %pass
        case 'reason cell lost'
            %pass
        case 'spatial RF eye'
            checkMember(out,{'ipsi','contra','both'});
        case 'spatial RF loc degrees lateral dorsal'
            try
                checkMember(out,{'on screen','center of screen'});
            catch ex
                if strcmp(ex.message,'validation failed')
                    out=getVal(out,'(%f,%f)',2,180*[-1 1]);
                else
                    rethrow(ex)
                end
            end
        case 'spatial RF degrees diameter'
            try
                checkMember(out,{'covers screen'});
            catch ex
                if strcmp(ex.message,'validation failed')
                    out=getVal(out,'%f',1,[0 180]);
                else
                    rethrow(ex)
                end
            end
        case 'ON OFF'
            checkMember(out,{'ON','OFF','both'});
        case 'theta chatter'
            checkMember(out,{'yes','no','rare'});
        case 'bursts'
            checkMember(out,{'yes','no','rare'});
        case 'display type'
            %consider changing to a 'display id' field for serial number
            checkMember(out,{'crt','led'});
        case 'linearization method'
            checkMember(out,{'none'});
        case 'pulse type'
            checkMember(out,{'double','triple','led','index'});
        case 'experiment type'
            checkMember(out,{'passive viewing'});
        case 'anesthesia'
            checkMember(out,{'no'});
        case 'headfixed'
            checkMember(out,{'yes'});
        case chanFieldsEx
            checkEmpty(out);
            if ismember(f,pulseFields) && strcmp(out,'none')
                %pass
            else
                try
                    checkMember(out,{'X'}); %indicates column is for a file that holds wavemarks for a file that was too large to add them
                    if ~ismember(f,chanFields)
                        error('spkChan can''t be X')
                    end
                catch ex
                    if strcmp(ex.message,'validation failed')
                        out=getVal(out,'%u8',1,[1 16]);
                    else
                        rethrow(ex)
                    end
                end
            end
        case 'spkCode'
            out=getVal(out,'%u8',1,[0 10]);
        case 'current sort quality'
            checkMember(out,{'needs resorting','not great','fair','quite good','as good as possible','almost perfect','perfect'});
        case 'absolute sortability'
            checkMember(out,{'multiunit','overlapping clusters','fair','pretty good','quite good','almost perfect','perfect'});
        case 'misc'
            %pass
        otherwise
            f
            error('unrecognized field')
    end
catch ex
    if strcmp(ex.message,'validation failed')
        relax=true;
        if relax && ismember(f,{'electrode mfg','electrode model','electrode lot','electrode params','cell snr','spikes clipped','current sort quality'})
            %edf is bailing on validating these for now (he is in a hurry!)
            %pass
        elseif isempty(out) || (length(out)==1 && out=='?') || prefix(f,out,'probably') || sep(f,out,'or') || sep(f,out,'and')            
            %pass
        else
            f
            out
            rethrow(ex)
        end
    else
        rethrow(ex)
    end
end
end

function out=reify(out)
%groups and rules were an old design for inherting blanks

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

end