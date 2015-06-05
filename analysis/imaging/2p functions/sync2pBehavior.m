function [onsets starts trialRecs] = sync2pBehavior(bData,ttlRecs)
startPhaseSkip = 0;
missedTrials   = 0;
goodRecordingPct = 1;

% if false
% 
%     imData = '\\herzog\C\data\nlab\031115 g62L1LT GTS behavior on 2p\G62l1lt_run1_GTS_behavior_2p\run1_g622l1LT_GTS_behavior001.tif';
%     bData = '\\lee\C\Users\nlab\Desktop\ballData2\PermanentTrialRecordStore\g62l1lt\trialRecords_4644-4763_20150311T143305-20150311T145317.mat';
%     ttlRecs = '\\herzog\C\data\nlab\ttlRecs\20150311T145339.mat';
% else
%     % imData = '\\lorentz\backup\twophoton\042215 g62m9tt 2p GTS behavior\GTS behavior run1 V1 upper visual field 35mw001.tif';
%     imData = 'C:\Users\nlab\Desktop\GTS behavior run1 V1 upper visual field 35mw001.tif';
%     bData = '\\lee\Users\nlab\Desktop\ballData2\PermanentTrialRecordStore\g62m9tt\trialRecords_4143-4289_20150422T121811-20150422T124018.mat';
%     ttlRecs = '\\herzog\C\data\nlab\ttlRecs\20150422T124042.mat';
% end


numPhases = 3;

warning('off','MATLAB:class:LoadInvalidDefaultElement') % why doesn't this suppress?
warning('off','MATLAB:elementsNowStruc')
warning('off','MATLAB:load:classErrorNoCtor')
warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle')
%warning('off')
d = load(ttlRecs);

% warning('query','last')

warning('on')
warning('on','MATLAB:dispatcher:UnresolvedFunctionHandle')
warning('on','MATLAB:load:classErrorNoCtor')
warning('on','MATLAB:elementsNowStruc')
warning('on','MATLAB:class:LoadInvalidDefaultElement')

if isfield(d,'hz')
    fs = d.hz;
else
    fs = 10000;
end

if isfield(d,'state')
    state = d.state;
else
    state = nan;
end

d = d.bin;

d = d(1:floor(size(d,1)*goodRecordingPct),:);

if false
    figure
    n = 2*10^6
    plot(d(1:n,:)+repmat([0 .1],n,1))
    
    keyboard
end

[~,o] = sort(sum(diff(d)>0));
d = d(:,o);

phases = find(diff(d(:,1))>0);
phases = phases((1+startPhaseSkip):end);
class = mod(1:length(phases),numPhases);
trials = phases(class==1);
trigs = phases(class==2);
reinf = phases(class==0);
onsets = trigPlot(trials,trigs,d,fs);

length(trials)

% have to use s = warning('query','last') -- [x,y] = lastwarn gives 'MATLAB:elementsNowStruc'
w = 'MATLAB:dispatcher:UnresolvedFunctionHandle';
% argh why doesn't turning this line off work?
s = warning('off',w); % pco def out of date
w2 = 'MATLAB:elementsNowStruc';
s2 = warning('off',w2);
t = load(bData);
warning(s.state,w);
warning(s2.state,w2);

trialRecs = t.trialRecords((missedTrials+1):end);

n = length(phases) - length(trialRecs) * numPhases;
if n > 0
    phases = phases(1:end-n);
else
    % phases = [phases; nan(abs(n),1)];
    trialRecs = trialRecs(1:end-ceil(abs(n)/numPhases));
    phases = phases(1:(length(trialRecs)*numPhases));
end

% stuff that needs to be factored out of combineTiffs follows
starts = cell2mat(cellfun(@phaseStarts,{trialRecs.phaseRecords}','UniformOutput',false))';

s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1; % wasn't stored as a logcial?

% keyboard
if false
    align(diff(reshape(starts,[1 numel(starts)])),diff(phases)/fs);
end

    function align(bp,tp)
        
        figure
        plot(bp,'r','LineWidth',3)
        
        hold on
        plot(tp,'y')
        
        [x,lags] = xcorr(bp,tp);
        
        figure
        plot(lags,x)
        [~,ind] = max(x);
        % figure out offset from ind/lags...
        
        figure
        plot(bp(ind:end),'r','LineWidth',3)
        
        hold on
        plot(tp,'y')
        
        keyboard
        
        if peak(x)~=middle(lags)
            error('align')
        end
    end

if numPhases ~= size(starts,1)
    error('bad')
end

% starts -> 3 x t abs phase start times from behavior records
% phases -> indices into pulse record of phase transitions
% dp     -> phases reshaped to match starts
% cyc    -> make relative to 2nd phase start time (discrim onset)
% frames -> indices into pulse record of frames
% ft     -> frames for each phase (2nd column is time of corresponding trial's first phase start?)

dp = reshape(phases,[numPhases size(starts,2)]);
% phases = [phases [phases(2:end,1) ; nan]];

dp = cyc(dp');
starts = cyc(starts');

    function out = cyc(in)
        out = [in [in(2:end,1); nan]] - repmat(in(:,2),[1 numPhases+1]);
    end

frames = find(diff(d(:,2))>0);



onsets = onsets(~isnan(onsets));

stim = [trialRecs.stimDetails];
targ = sign([stim.target]);


starts = starts/fs; onsets = onsets/fs;

end

function in = normalize(in)
in = in-min(in(:));
in = in/max(in(:));
end

function offsets = trigPlot(trials,trigs,d,fs)
offsets = nan(1,length(trials));
figure
for i=1:length(trials)-1
    inds = trials(i):trials(i+1)-1;
    offsets(i) = find(diff(d(trigs(i):trials(i+1),2))>0,1,'first')+trigs(i);
    plot(((0:length(inds)-1)-offsets(i)+trials(i))/fs,i+.75*(d(inds,:)+repmat([.1 0],length(inds),1)))
    hold on
end
xlim([-2 3])
end

% stuff that needs to be factored out of combineTiffs follows

function out = phaseStarts(rec)
try
    r = [rec.responseDetails];
    out = [r.startTime];
catch %only some have totalFrames?  why?
    for i=1:length(rec)
        s =  rec(i).responseDetails.startTime;
        if isempty(s)
            s = nan;
        end
        out(i) = s;
    end
end

% rec.dynamicDetails %contains tracks

%almost same as phaseLabel - just has 'reinforcement' instead of 'reinforced'
labels = {rec.phaseType};
expected = {'pre-request', 'discrim', 'reinforced'};
goods = cellfun(@strcmp,labels,expected);
if ~all(goods)
    e = cellfun(@isempty,labels);
    f = find(e,1,'first');
    if all(e(f:end))
        if length(out)>=f
            if all(isnan(out(f:end)))
                out = out(1:f-1);
            else
                error('bad')
            end
        end
        out = [out nan(1,length(labels)-f+1)];
    else
        rec.phaseType
        error('bad phases')
    end
end

if length(out)~=length(expected)
    error('bad')
end
end