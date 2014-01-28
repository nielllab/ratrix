function pcoTTLrec
old = cd('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;
cd(old);
dbstop if error

durMins = .5;
writeDelayMs = 14; % if no binning, must be >[8,14,16] to avoid dma error (grabber<->memory) and frame drops (raid too slow?)

cams = struct('trig',cellfun(@uint8,{7  5 },'UniformOutput',false), ... % could all share one trig
    'busy',cellfun(@uint8,{15 11},'UniformOutput',false));
% cams(1)=gondry
% cams(2)=woody

ttls = []; %5:8;
% 8   data              i/o indexPulse
% 9   data              i/o framePulse
% 16  control           i/o phasePulse
% 17  control	inv     i/o stimPulse

nCams = length(cams);

addr = hex2dec('0378');

avoidPP = true; % faster when true, but only works on win32
if avoidPP % cache the read/write masks, only use one register each, use lptread/lptwrite
    if any([cams.trig] > 9 || any([cams.trig] < 2)) %#ok<BDSCA>
        error('bad trig pin')
    end
    
    trigFalse = 0;
    trigTrue = dec2bin(trigFalse,8);
    trigTrue([cams.trig])='1';
    trigTrue = bin2dec(trigTrue);
    
    busyRead(10).bit = 6;
    busyRead(11).bit = 7;
    busyRead(12).bit = 5;
    busyRead(13).bit = 4;
    busyRead(15).bit = 3;
    
    statusReg = find(~cellfun(@isempty,{busyRead.bit}));
    if any(~ismember([[cams.busy] ttls], statusReg))
        error('bad busy or ttl pin')
    end
    
    [busyRead(:).inv] = deal(false);
    busyRead(11).inv = true;
    
    readBusy = [busyRead([cams.busy]).bit];
    busyInv = [busyRead([cams.busy]).inv];
end

slow = false;
prof = false;
expectedHz = 300000;
len = expectedHz*durMins*60;
times = nan(1,len); %13GB for 90 mins @ 300kHz

expectedExpHz = 200;
recLen = expectedExpHz*durMins*60;
rec = nan(1+2*nCams,recLen); % [trigT busyHiCam1...busyHiCamN busyLoCam1...busyLoCamN]
recN = 0;

ttlRecLen = length(ttls)*recLen;
ttlRec.times = nan(1,ttlRecLen);
ttlRec.state = false(1,ttlRecLen);
ttlRec.chan = zeros(1,ttlRecLen,'uint8');
ttlRecN = 0;
%currTTL = read(ttls);

exp = false;
trig(false);
getBusy; %warm (later use to set currTTL)

i = 1;
GetSecs; %warm
s = '';
m = 0;
f = 0;
wait = nan;

KbName('UnifyKeyNames')
k = zeros(1,256);
k(KbName('q')) = 1;
KbQueueCreate([],k);
KbQueueStart;

fprintf('recording for %g mins (hit q to quit early)\n',durMins);

p = Priority(MaxPriority('GetSecs'));

if prof
    profile on
end

times(i) = GetSecs;
endT = times(i) + durMins*60;
last = times(i);

while ~KbQueueCheck && times(i) < endT
    i = i + 1;
    if i > len
        error('exceded prealloc')
    else
        times(i) = GetSecs;
    end
    
    busy = getBusy;
    if exp
        for c = 1:nCams
            if isnan(rec(1+c,recN))
                if busy(c)
                    rec(1+c,recN) = times(i);
                end
            end
        end
        if ~any(isnan(rec(1+(1:nCams),recN)))
            trig(false);
            exp = false;
        end
    else
        if recN > 0
            for c = 1:nCams
                if isnan(rec(1+nCams+c,recN))
                    if ~busy(c)
                        rec(1+nCams+c,recN) = times(i);
                    end
                elseif busy(c)
                    error('found busy after not busy')
                end
            end
        end
        if ~any(busy)
            if isnan(wait)
                wait = times(i);
            end
            
            if times(i) - wait >= writeDelayMs/1000
                recN = recN + 1;
                if recN > recLen
                    error('exceded prealloc')
                end
                exp = true;
                rec(1,recN) = times(i);
                
                wait = nan;
                trig(true);
            end
        end
    end
    
    if times(i) - last > 5
        m = (endT - times(i))/60;
        f = floor(m);
        
        if false
            %is there a flush or something?  these aren't coming out cuz of priority?
            %fprintf('%d:%d mins remaining\n',f,round((m - f)*60));
            
            %consider disp etc
            s = sprintf('%d:%d remaining\n',f,round((m - f)*60));
            fprintf('%s',s);
            disp(s)
            s
            
            %drawnow %possibly big performance hit
            drawnow update %possibly faster than drawnow
        end
        
        last = times(i);
    end
end

    function trig(s)
        if avoidPP
            if s
                lptwrite(addr,trigTrue);
            else
                lptwrite(addr,trigFalse);
            end
        else
            pp([cams.trig],repmat(s,1,length(cams)),slow,[],addr);
        end
    end

    function out = getBusy
        if avoidPP
            out = fastDec2Bin(lptread(addr + 1));
            out = out(readBusy);
            out(busyInv) = ~out(busyInv);
        else
            out = pp([cams.busy],[],slow,[],addr);
        end
    end

if prof
    profile off
end

Priority(p);

KbQueueStop;
KbQueueRelease;

rec = rec(:,1:recN) - times(1);
times = times(1:i) - times(1);

f = fullfile('C:\','data','pcoTTLrecords');
[status,message,messageid] = mkdir(f);
if status~=1
    f
    message
    messageid
    error('couldn''t mkdir')
end
f = fullfile(f,[datestr(now,30) '.mat']);
fprintf('saving as %s\n',f);
tic
save(f,'cams','rec','times','writeDelayMs','-v7.3'); % >=7.3 req for >2GB
toc

if prof
    profile viewer
end

plotPCOttlRec(f);
end