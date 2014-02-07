function plotPCOttlRec(f)
dbstop if error
close all

if ~exist('f','var')
    base = fullfile('C:\','data','pcoTTLrecords');
    d = dir(fullfile(base,'*T*.mat'));
    d = sort({d.name});
    f = fullfile(base,d{end});
end

fprintf('loading %s\n',f);
tic
x = load(f);
toc

k=2;
h=[];

hz = 1./diff(x.times);
xt = x.times*1000;
h(end+1) = subplot(k,1,1);
plot(xt(1:end-1), hz);
title(sprintf('median = %g kHz',median(hz)/1000));
ylabel('hz');
xlabel('ms');

out = nan(length(x.times),length(x.cams)+1);
tn = 1;
b = [max(x.rec(1+(1:length(x.cams)),:),[],1) ; max(x.rec(2+length(x.cams):end,:),[],1)];
for t=1:length(x.times)
    if tn <= size(x.rec,2) %haven't verified this is legit
        if x.times(t) > b(2,tn)
            tn = tn + 1;
        end
        
        if tn <= size(x.rec,2) %haven't verified this is legit
            out(t,1) = x.times(t) >= x.rec(1,tn) && x.times(t) < b(1,tn);
            
            for i=1:length(x.cams)
                out(t,i+1) = x.times(t) >= x.rec(1+i,tn) && x.times(t) < x.rec(1+length(x.cams)+i,tn);
            end
        end
    end
end
out = .7*out + repmat(0:length(x.cams),length(x.times),1);
h(end+1) = subplot(k,1,2);
plot(xt,out,'x-');
xlabel('ms')
title('trig/busy')

linkaxes(h,'x')

f = figure;
k=6;
h=[];

h(end+1) = seriesHist(...
    x.times(1:end-1)/60, ...
    hz, ...
    f,1,k, ...
    sprintf('median = %g kHz',median(hz)/1000), ...
    'hz', ...
    'mins' ...
    );

h(end+1) = subplot(k,2,3);
plot(xt,out,'x-');
xlabel('ms')
title('trig/busy')

hz = 1./diff(x.rec(1,:));
trigs = x.rec(1,:)/60;
h(end+1) = seriesHist( ...
    trigs(1:end-1), ...
    hz, ...
    f,3,k, ...
    sprintf('median = %g hz (%g ms) - %d frames',median(hz),1000/median(hz),size(x.rec,2)), ...
    'hz', ...
    'mins' ...
    );
subplot(k,2,5)
hold on
plot(x.rec(1,[1 end-1])/60,ones(1,2) * size(x.rec,2)/x.times(end))

d = x.rec(1,2:end) - b(2,1:end-1);
for i=1:length(x.cams)
    d(i+1,:) = x.rec(1+i+length(x.cams),1:end-1) - x.rec(1+i,1:end-1);
end
h(end+1) = seriesHist( ...
    trigs(1:end-1), ...
    1000*d', ...
    f,4,k, ...
    'busy/wait durations', ...
    'ms', ...
    'mins' ...
    );

d = [];
for i=1:length(x.cams)
    d(i,:) = x.rec(1+i,:) - x.rec(1,:);
end
h(end+1) = seriesHist( ...
    trigs, ...
    1000*d', ...
    f,5,k, ...
    'ack latencies', ...
    'ms', ...
    'mins' ...
    );

if length(x.cams)==2
    h(end+1) = seriesHist( ...
        trigs, ...
        1000*diff(x.rec(4:5,:)), ...
        f,6,k, ...
        'cam1 vs cam2 busy', ...
        'ms', ...
        'mins' ...
        );
end

if false
    linkaxes(h,'x') %destroys previous y links!  :(  even linkprop won't work cuz the link object is singleton and links properties across all members
end
end