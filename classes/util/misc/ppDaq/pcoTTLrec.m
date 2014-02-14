function pcoTTLrec
old = cd('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;
cd(old);

if true
    dbstop if error %doesn't seem to slow us down?
end

durMins = 2;
writeDelayMs = 0.5; % if no binning + not pcoraw, must be >[8,14,16] to avoid dma error (grabber<->memory) and frame drops (raid too slow?)
%measured 0.4 at no binning on pcoraw does DMA error/drop, but 0.5 does not.

cams = struct('trig',cellfun(@uint8,{7  5 },'UniformOutput',false), ... % could all share one trig (currently actually do share 7)
    'busy',cellfun(@uint8,{15 11},'UniformOutput',false));
% cams(1)=gondry
% cams(2)=woody

leds = uint8(5);

ttls = [10 12 13];
% [] <- 8   data              i/o indexPulse
% 10 <- 9   data              i/o framePulse
% 12 <- 16  control           i/o phasePulse
% 13 <- 17  control	inv       i/o stimPulse

nCams = length(cams);

addr = hex2dec('0378');

avoidPP = true; % faster when true, but only works on win32
if avoidPP % cache the read/write masks, only use one register each, use lptread/lptwrite
    if any([cams.trig] > 9) || any([cams.trig] < 2)
        error('bad trig pin')
    end
    
    trigFalse = dec2bin(0,8);
    trigFalse(leds      -1) = '1'; % -1 for pins2-9
    trigTrue = trigFalse;
    trigTrue([cams.trig]-1) = '1'; % -1 for pins2-9
    trigFalse = bin2dec(fliplr(trigFalse)); % flip for reasons :)
    trigTrue  = bin2dec(fliplr(trigTrue )); % flip for reasons :)
    
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
    
    readBusy = 8 - [busyRead([cams.busy]).bit]; % 8 - for reasons :)
    readTTLs = 8 - [busyRead(ttls       ).bit]; % 8 - for reasons :)
    busyInv =         [busyRead([cams.busy]).inv];
    ttlsInv = logical([busyRead(ttls       ).inv]); %lame -- if empty, converts to double
end

slow = false;
prof = false;
expectedHz = 20 * 1000; % 300000;
len = expectedHz*durMins*60;
times = nan(1,len); %13GB for 90 mins @ 300kHz

expectedExpHz = 200;
recLen = expectedExpHz*durMins*60;
rec = nan(1+2*nCams,recLen); % [trigT busyHiCam1...busyHiCamN busyLoCam1...busyLoCamN]
recN = 0;

ttlRecLen = length(ttls)*recLen;
ttlRec.time = nan(1,ttlRecLen); %would rather this were a struct array than scalar, but 10x less efficient to do so (in space, dunno bout time)
ttlRec.state = false(1,ttlRecLen);
ttlRec.chan = zeros(1,ttlRecLen,'uint8');
ttlRecN = 0;

exp = false;
trig(false);
newTTLs = readStatus;
currTTLs = newTTLs(1+length(cams):end);
diffTTLs = [];
ttlInd = nan;

i = 1;
GetSecs; %warm
s = '';
m = 0;
f = 0;
wait = nan;

KbName('UnifyKeyNames')
useKbQueue = true; %KbQueue quite a bit faster than KbCheck, but can't ListenChar(2)
if useKbQueue
    k = zeros(1,256);
    k(KbName('q')) = 1;
    % check w/mario if any way to use w/kbqueue...
    % ListenChar(2); % When used on Windows Vista or later (Vista, Windows-7, Windows-8, ...)
    %   with Matlab's Java GUI, you cannot use any KbQueue functions at the same
    %   time, ie., KbQueueCreate/Start/Stop/Check/Wait as well as KbWaitTrigger,
    %   KbEventFlush, KbEventAvail, and KbEventGet are off limits after any call
    %   to ListenChar, ListenChar(1), ListenChar(2), FlushEvents, CharAvail or
    %   GetChar.
    KbQueueCreate([],k);
    KbQueueStart;
    KbQueueCheck; %warm
else
    k = KbName('q');
    ListenChar(2);
    [keyDown, ~, keyCode] = KbCheck;
end

fprintf('recording for %g mins (hit q to quit early)\n',durMins);

p = Priority(MaxPriority('GetSecs','KbQueueCheck','KbCheck'));

if prof
    profile on
end

times(i) = GetSecs;
endT = times(i) + durMins*60;
last = times(i);

while ((useKbQueue && ~KbQueueCheck) || ~(useKbQueue || (keyDown && keyCode(k)))) && times(i) < endT %KbQueueCheck is bottleneck, about 4x longer than GetSecs, more than half in IsOSX, ask mario if can speed up
    i = i + 1;
    if i > len
        error('exceded prealloc')
    else
        times(i) = GetSecs;
    end
    
    busy = readStatus;
    newTTLs = busy(1+length(cams):end);
    busy = busy(1:length(cams));
    
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
    
    if true
        diffTTLs = find(newTTLs ~= currTTLs);
        if ~isempty(diffTTLs)
            ttlRecN = ttlRecN + (1:length(diffTTLs)); %wow parens necessary: 1 + 1:1 = [] !!
            if ttlRecN(end) > ttlRecLen
                error('exceded prealloc')
            end
            ttlRec.time(ttlRecN) = times(i);
            ttlRec.state(ttlRecN) = newTTLs(diffTTLs);
            ttlRec.chan(ttlRecN) = ttls(diffTTLs);
            ttlRecN = ttlRecN(end);
        end
    else
        for ttlInd = find(newTTLs ~= currTTLs)
            ttlRecN = ttlRecN + 1;
            if ttlRecN <= ttlRecLen
                ttlRec.time(ttlRecN) = times(i);
                ttlRec.state(ttlRecN) = newTTLs(ttlInd);
                ttlRec.chan(ttlRecN) = ttls(ttlInd);
            else
                error('exceded prealloc')
            end
        end
    end
    currTTLs = newTTLs;
    
    if times(i) - last > 5
        m = (endT - times(i))/60;
        f = floor(m);
        
        if false
            %is there a flush or something?  these aren't coming out cuz of priority?
            
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
    
    if ~useKbQueue
        [keyDown, ~, keyCode] = KbCheck;
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

    function out = readStatus
        if avoidPP
            out = fastDec2Bin(lptread(addr + 1));
            out = out([readBusy readTTLs]) == '1';
            out([busyInv ttlsInv]) = ~out([busyInv ttlsInv]);
        else
            out = pp([[cams.busy] ttls],[],slow,[],addr);
        end
    end

if prof
    profile off
end

% turn off LED
if avoidPP
    lptwrite(addr,0);
else
    pp(leds,false,slow,[],addr);
end

Priority(p);

if useKbQueue
    KbQueueStop;
    KbQueueRelease;
    % ListenChar(0);
else
    ListenChar(0);
end

rec = rec(:,1:recN) - times(1);
times = times(1:i) - times(1);
ttlRec = ttlRec(1:ttlRecN);

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
save(f,'cams','rec','times','writeDelayMs','ttlRec','-v7.3'); % >=7.3 req for >2GB
toc

if prof
    profile viewer
end

plotPCOttlRec(f);
end