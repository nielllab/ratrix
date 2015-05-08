function [ n] = analyze2pSync(files)
dbstop if error
clc
close all

colordef black

if false
files = {
    '\\herzog\C\data\nlab\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\run2_zoom1_gratings2p_50mw_256^2_1ms001.tif'
    '\\herzog\C\data\nlab\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\run2_zoom1_gratings2p_50mw_256^2_1ms001stimrec.mat.mat'
    };
end

tp = '\\herzog\C\data\nlab\ttlRecs';

if exist('files','var')
    [stimRec, tif] = getFiles(files{1},tp,files{2});
    
elseif true
    p  = '\\herzog\C\data\nlab\100114 LP Gcamp6 virus J144\New folder\';
    % the nunmber of runN.mat corresponds to stimN.tif
    % for now, we depend on the names '<something>00N.tif' and 'stim_obj_runN_<something-else>.mat'
    
    key = 8; % ttls: 20141001T214501.mat
    
    % examples:
    %     V1_zoom2_single_image001.tif
    %         V1_zoom2_darkness002.tif
    %      V1_zoom2_step_binary003.tif
    %      V1_zoom2_step_binary004.tif  stim_obj_run4_step_bimary.mat
    % V1_zoom2_Newgratings_full005.tif  stim_obj_run5_newgratings_full.mat
    % V1_zoom5_Newgratings_full006.tif
    % V1_zoom5_Newgratings_full007.tif  stim_obj_run7_zoom4_newgratings_full.mat
    % V1_zoom5_step_binary_full008.tif  stim_obj_run8_zoom4_step_binary_full.mat
    %    V1_zoom5_darkness_full009.tif  stim_obj_run9_zoom4_darkness_full.mat
    
    % stimRec has 0 duration duplicate frame artifacts removed
    % tif has a 4th dimension which is the index into stimRec corresponding to the stim frame for each pixel
    % (0 for pre-stim pixels and after the stim record disagrees with the ttl record)
    [stimRec, tif] = getFiles(p,tp,key);
    
else
    % possible behavior runs
    
    bp = '\\lee\C\Users\nlab\Desktop\';
    
    if false
        tf = '\\herzog\C\data\nlab\080613 gcam25 behavior\place 1 behavior012.tif';
        % \\herzog\C\data\nlab\ttlRecs\20130806T135747.mat
        d = '20130806'
        r = load(fullfile(tp,'20130806T135747.mat'));
        '\\lee\C\Users\nlab\Desktop\ballData\PermanentTrialRecordStore\gcam25rt\trialRecords_1297-1461_20130806T133349-20130806T135720.mat'
        
    else
        tf = '\\herzog\C\data\nlab\050813\2p test gcam 33 tt\gcam33 tt001.tif';
        % \\herzog\C\data\nlab\ttlRecs\20130508T161519.mat
        d = '20130508'
        r = load(fullfile(tp,'20130508T161519.mat'));
        '\\lee\C\Users\nlab\Desktop\ballData\PermanentTrialRecordStore\gcam32tt\trialRecords_516-603_20130508T154737-20130508T161458.mat'
        
    end
    
    ti = getTiff(tf);
    keyboard
    
    x = checkDir(bp,d)
    keyboard
    
    r = r.bin;
    plot(r+.1*repmat(1:size(r,2),size(r,1),1))
end

n = find(max(max(tif(:,:,:,2))),1);

figure
d = 2;
j = (n-1) + (1:d);
for i = j
    h = subplot(d,1,i-j(1)+1);
    imagesc(tif(:,:,i,2),[0 max(max(max(tif(:,:,j,2))))]); % length(stimRec.f)])
    title(num2str(i))
    cellfun(@(x) set(h,[x 'tick'],[]),{'x' 'y'});
end
end

function out = checkDir(in,targ)
% out = [];
fprintf('checking %s\n',in);
maybe = dir(fullfile(in,['*' targ '*.mat']));
out = cellfun(@(x) fullfile(in,x),{maybe.name},'UniformOutput',false);
maybe = dir(in);
maybe = {maybe([maybe.isdir] & ~ismember({maybe.name},{'.' '..' 'replacedDBs' 'backups' 'ratrix' 'Crappyratrix' '.git'})).name};
tmp = cellfun(@(x) checkDir(fullfile(in,x),targ),maybe,'UniformOutput',false);
out = [out tmp{:}];
end

function ti = getTiff(tf)
tfm = [tf '.mat'];

if exist(tfm,'file') % 10x faster than raw
    fprintf('loading pre-read tif...')
    tic
    ti = load(tfm);
    toc
    ti = ti.ti;
else
    t = imfinfo(tf);
    
    ti = zeros(unique([t.Height]),unique([t.Width]),length(t),['uint' num2str(unique([[t.BitDepth] [t.BitsPerSample]]))]);
    fprintf('loading tif from scratch')
    tic
    arrayfun(@loadTiff ,1:length(t));
    fprintf('\n')
    toc
    
    fprintf('saving pre-read tif...')
    tic
    save(tfm,'ti');
    toc
end

    function loadTiff(i)
        ti(:,:,i) = imread(tf,'Index',i);
        fprintf('.')
    end

if false
    figure
    for i=1:size(ti,3)
        imagesc(ti(:,:,i));
        drawnow
    end
end

end

function [m, ti] = getFiles(p,tp,key)

dp = dir(p);

if isnumeric(key)
    checkDD(dp);
    
    x = arrayfun(@parse,dp);
    inds = find(cellfun(@(k)(k==key),{x.id}));
    
    if length(inds)~=2 || ~all(ismember('tm',[x(inds).type]))
        error('can''t find .mat and .tif for that key')
    end
    
    mat = dp(inds([x(inds).type] == 'm'))
    tif = dp(inds([x(inds).type] == 't'))
    
    x(inds).s
    dp(inds).date
    
    ti = getTiff(fullfile(p,tif.name));
    m = load(fullfile(p,mat.name));
else
    p
    key
    ti = getTiff(p);
    inds = 1;
    m = load(key);
end

targ = [dp(inds).datenum];

dtp = dir(fullfile(tp,'*.mat'));
dtp = dtp(~[dtp.isdir]);
[~,o] = sort([dtp.datenum]);
dtp = dtp(o);

checkDD(dtp);

    function checkDD(in)
        if any([in.datenum] ~= cellfun(@datenum,{in.date}))
            error('file date and datenum don''t match')
        end
    end

nameDates = cellfun(@getNameDate,{dtp.name});
    function t = getNameDate(x)
        [~,name] = fileparts(x);
        t = datenum(name,'yyyymmddTHHMMSS'); % ugh we really can't datenum(.) or even datenum(.,30)?
    end

d = datevec(max(abs([dtp.datenum] - nameDates)));

if any(d(1:5) ~= 0) || d(end)>1
    error('name/datenum mismatch')
end

[~,o] = sort(nameDates);
if any(o ~= 1:length(o))
    error('names out of order')
end

cell2mat(cellfun(@(x)datevec(min(diff(x))),{[dtp.datenum] nameDates}','UniformOutput',false))

if any(cellfun(@(x)all(datevec(min(diff(x)))<=0),{[dtp.datenum] nameDates}))
    error('at least two files in same second')
end

inds = find(diff([dtp.datenum] < min(targ))) : (1+find(diff([dtp.datenum] > max(targ))));
dtp(inds).date
ind = inds(ceil(2*eps + length(inds)/2)); % we'll guess it's the middle one and lean late (ugh 1 eps isn't enough to lean late!)

ttlRec = dtp(ind)

r = load(fullfile(tp,ttlRec.name));

m = m.stimRec;
r = r.bin;

frames = unique(cellfun(@(x)size(m.(x),1),fields(m)));
if length(frames)~=1
    display('stim rec fields not equal sized'); %%% this is okay since added scalar fields
    frames = max(frames);
end

p = max(m.f);

% something screwed up in stim recs?
% ugly pattern in stim recs (at least for passive):
% f         cond    dur diff(ts)
% ...       x       1 frame
% n - 1     x       1
% n         x       0       % wtf
% n         x       2
% 1         y       1
% ...       y       1
% end       z       0       % wtf
% end       z       -

%     function out = dup(in)
%         out = all(cellfun(@(x) numel(unique(m.(x)(in)))==1,fields(m))); % {'f' 'cond'}
%     end

if true % clean up the above problem by removing 0 dur frames
    inds = find(abs(diff(m.ts)) < eps)
    if ~isempty(inds)
        %       if ~all(arrayfun(@(x)(x == frames && dup(x-[0 1])) || dup(x+[0 1]),inds))
        if ~all(arrayfun(@(x) all(cellfun(@(f) numel(unique(m.(f)(x+[0 1])))==1,fields(m))),inds))
            error('found 0 dur frame that doesn''t fit known weird pattern')
        end
        
        warning('removing those weird zero duration duplicate frames from stim rec')
        
        inds = ~ismember(1:frames,inds);
        
        % lame can't do assingment this way?
        % cellfun(@(x) m.(x) = m.(x)(inds,:),fields(m))
        
        m.ts   = m.ts  (inds  );
        m.f    = m.f   (inds  );
        m.cond = m.cond(inds  );
        m.pos  = m.pos (inds,:); % also verified dup
        
        frames = length(inds(inds));
    end
    
    if any(m.f ~= mod(0:frames-1,p)'+1)
        error('frames nums not as expected')
    end
    
    if any(mod(find(diff(m.cond)),p))
        error('cond changes somewhere off period boundary')
    end
    
else % just live with the weird pattern
    e = nan(frames,1);
    for i = 1:frames % ugh
        if i == 1
            e(i) = 1;
        elseif i == frames
            e(i) = e(i-1);
        elseif e(i-1) < p
            e(i) = e(i-1) + 1;
        elseif e(i-1) == p && e(i-2) == p-1
            e(i) = p;
        else
            e(i) = 1;
        end
    end
    
    if any(m.f ~= e)
        error('frame numbers aren''t the weird pattern we expect')
    end
    
    if any(mod(find(diff(m.cond)),p+1))
        error('cond isn''t the weird pattern we expect')
    end
end

k = 8;
subplot(k,1,1)
plot(diff(m.f)-1)
ylim([-3 3])
title('frame number discrepencies')

subplot(k,1,2)
plot(diff(m.ts))
title('frame duration (stim recs)')

subplot(k,1,3)
plot(m.cond)
title('cond')

subplot(k,1,4)
% plot(m.pos)
% title('pos')
plot(diff(m.pos))
title('running? speed')

subplot(k,1,5)
plot(r+.1*repmat(1:size(r,2),size(r,1),1))
title('ttl')

if any(r(1,:))
    display('looks like stim line was high at beginning') %%% appears stim line can sometimes be high, even before pulses start
end

if any(r(find(r(:,2)==0),1))
    error('bad ttl pattern')
end

d = diff(r(:,1));
t = find(d>0);
subplot(k,1,6)
plot(diff(t))
title('frame duration (ttl) in samples')

f = find(d<0);
n = min(cellfun(@length,{t f}));
f = f(1:n)-t(1:n);
if any(f<0)
    display('huh?') %%%% not sure what this is testing
end
subplot(k,1,7)
plot(f)
ylim([0 20])
title('pulse duration in samples')

g = cellfun(@(x) find(diff(r(:,2))==x), {1 -1},'UniformOutput',false);
if length(g{2}) == length(g{1})-1
    g{2}(end+1) = inf;
elseif length(g{2}) ~= length(g{1})
    error('huh?')
end

s = zeros(size(t));

for i = 1:length(g{1})
    tmp = find(t >= g{1}(i) & t < g{2}(i));
    s(tmp) = i;
    if (~isinf(g{2}(i)) && length(tmp) ~= p) || length(tmp) > p
        display('periods don''t match')
    end
    
    % s{i} = t(t >= g{1}(i) & t < g{2}(i));
    if any(t == g{2}(i))
        error('not sure what to do in this case')
    end
end

subplot(k,1,8)
plot(s)
title('trial number')

% should save the following in ttlRec (is any of it in the tiff?)
fs = 10^4;

%             state.acq.frameRate: 1.4796
% accounts for fill fraction?
% seems to come from   1 / (2.64 * 256 / 1000) = 1.47964015151515
% where 2.64 = state.internal.mirrorDataOutputMsPerLine

frameRate = 1000 / (2.64 * size(ti,1)); % 1.47964015151515;

%             state.acq.linesPerFrame: 256
%             state.acq.pixelsPerLine: 256
%             state.acq.pixelTime: 6.4000e-006
% 1/(0.0000064 * 256^2) = 2.38418579101563

% from vijay (12.17.12)
% Pixels/lines are acquired regularly in time, with a very fixed interval given by the actual ms/line value.
% If you account for the fill fraction, the frame rate should match up perfectly.
% The first sample of the first pixel is collected at the (scan delay + acquisition delay)
% following the start trigger arrival.
% From this, you should be able to determine exactly start time of each subsequent pixel/line
% exactly relative to the trigger time..it's all deterministic.

% these differ by 60ms
secsTIFF = size(ti,3) / frameRate / 2; % why the extra factor of 2 ???
secsTTL  = size(r,1) / fs;

if abs(1 - secsTIFF/secsTTL) > .0002
    error('tiff and ttl record durations seem to disagree')
end
%% 

% is discrepency due to events arriving at a delay?  or scan/acq delay?
% one of the following in state.internal?  what are these units/where are values set?
%     acqDelayConfig: 80
%                    scanDelayConfig: 160
%              fillFractionGUIConfig: 9
%                    msPerLineConfig: 2.6400
%               fillFractionGUIArray: 9
%                      acqDelayArray: 80
%                     scanDelayArray: 160

figure
subplot(2,1,1)
plot(diff(m.ts),'r','LineWidth',3)
hold on
plot(diff(t)/fs,'y','LineWidth',1)
xmax = max(cellfun(@length,{m.ts t}));
xlim([1 xmax])
legend({'stim rec' 'ttl'})
title('frame durations')

ind = min(cellfun(@length,{m.ts t}));
a = (diff(m.ts(1:ind))./(diff(t(1:ind))/fs))-1;

% these guys need high thresh -- really weird artifacts:
% \\herzog\C\data\nlab\imaging\twophoton\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\
% run2_zoom1_gratings2p_50mw_256^2_1ms001.tif
% run2_zoom1_gratings2p_50mw_256^2_1ms001stimrec.mat.mat
thresh = inf; % .065;

bad = find(abs(a)>thresh,1);
if ~isempty(bad)
    if bad/ind < .5
        error('looks like stim rec and ttl''s don''t match -- wrong ttl file?')
    end
    ind = bad;
end
ind = ind - 1; % cuz we're working with diff

subplot(2,1,2)
fill([0 1 1 0]*(ind-1) + 1,[1 1 -1 -1],'b')
hold on
plot([a repmat([-1 1]*thresh,length(a),2)])
xlim([1 xmax])
title('stim rec vs. ttl')

% fn = zeros(1,numel(ti),['uint' num2str(types(find(ceil(log2(frames)) < types,1)))]);

% we'll assume the slop is at the end -- discrepency due to events arriving at delay.
% here we also pretend that the fill fraction fills the whole cycle -- in reality, pixels are at slightly different times
fn = (0:numel(ti)-1) * fs / (2 * frameRate * size(ti,1) * size(ti,2)); % sample number for each pixel -- note that mystery factor of 2...

if abs(1 - fn(end)/size(r,1)) > .0002
    error('bad calculation of sample nums')
end

extra = sum(t(1:ind) > fn(end));
if extra < 0
    error('tiff should always be shorter than ttl rec')
end
fprintf('TTL rec is %d stim frames longer than tiff -- due to delay in events?\n',extra)

% indices into m.f, with 0 entries for "before stim" or "after ttl + stim rec disagree"
% note we assume the ttl pulse going positive means the screen has actually just finished flipping
if false % this is a cool method but OOM's of course
    fn = sum(repmat(fn,ind,1) >= repmat(t(1:ind),1,length(fn)));
    % todo: zero out after last ttl?
else
    last = 1;
    first = 1;
    for i = 1:ind
        while last <= length(fn) && fn(last) < t(i)
            fn(last) = i-1;
            last = last+1;
        end
        
        % fprintf('%d: %d\n',i-1,last-first)
        first = last;
        
        %         new = find(fn(last:end) < t(i),1,'last');
        %         fn(last+(1:new)-1) = i-1;
        %         last = new+1;
        if false && rand>.9
            fprintf('%g%%\n',100*i/ind)
        end
    end
    fn(last:end) = 0;
end

types = 8 * 2.^(0:3);
fn = feval(['uint' num2str(types(find(ceil(log2(ind+1)) <= types,1)))], fn);

% we have to assume scan pattern -- where look up?  for now assuming like reading a book
fn = permute(reshape(fn,[size(ti,2) size(ti,1) size(ti,3)]),[2 1 3]);

if false
    figure
    r = ceil(sqrt(size(fn,3)));
    for i=1:size(fn,3)
        h = subplot(r,r,i);
        imagesc(fn(:,:,i),[0 ind])
        % title(num2str(i))
        cellfun(@(x) set(h,[x 'tick'],[]),{'x' 'y'});
        drawnow
    end
elseif false
    figure
    for i=1:size(fn,3)
        h = subplot(2,1,1);
        imagesc(fn(:,:,i),[0 ind]);
        title(num2str(i))
        cellfun(@(x) set(h,[x 'tick'],[]),{'x' 'y'});
        h = subplot(2,1,2);
        imagesc(fn(:,:,i));
        cellfun(@(x) set(h,[x 'tick'],[]),{'x' 'y'});
        drawnow
    end
elseif true
    figure
    subplot(2,1,1)
    plot(1:size(ti,3),[squeeze(mean(mean(fn))) ind*ones(size(ti,3),1)])
    xlabel('tiff frame num')
    ylabel('stim frame num')
    subplot(2,1,2)
    plot(1:size(ti,3),squeeze(max(max(fn))-min(min(fn))));
    ylabel('num stim frames')
end

if ~strcmp(class(ti),class(fn))
    error('haven''t dealt with case when both aren''t uint16')
end

ti(:,:,:,2) = fn;
end

function out = parse(x)
out.id   = nan;
out.type = nan;
out.s    = nan;
if ~x.isdir
    [~, name, ext] = fileparts(x.name);
    
    switch ext
        case '.tif'
            z = textscan(name,'%[^0]%d');
            out.type = 't';
        case '.mat'
            [~, ~, ext2] = fileparts(name);
            if ~strcmp(ext2,'.tif') % these are our cached tiffs
                z = fliplr(textscan(name,'stim_obj_run%d_%s'));
                out.type = 'm';
            end
    end
end
if ~isnan(out.type)
    out.id = z{2};
    out.s  = z{1}{1};
end
end