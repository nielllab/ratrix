function [waveforms lockout]=doWaveforms(f,chan,code)
tic
codes=unique([recs.code]);
if ~ismember(code,codes)
    error('code error')
end
codes=[code setdiff(codes,code)];

%TODO: save figure
%TODO: compare times to phys file to make sure they are the peaks, not beginnings
%      and verify times are same as spks
%with wavemarks as events, peaks are aligned, and times are peak times (i believe)
%if they are PRE times, they would be offset consistently within file but not across files

figure
col=[0 0 0];
for c=codes
    matches=[recs.code]==c;
    traces=cat(1,recs(matches).points)';
    
    %argh no alpha for lines :(
    
    subplot(2,1,1)
    plot(tms,traces,'Color',col)
    hold on
    
    subplot(2,1,2)
    plot(tms,normalizeByDim(traces,2),'Color',col)
    hold on
    
    col=[1 0 0];
end
allTraces=cat(1,recs.points);
allTraces=allTraces(:);
pT=ones(1,2)*tms(prePoints+1);
for i=1:2
    subplot(2,1,i)
    if i==1
        ys=[min(allTraces) max(allTraces)];
    else
        ys=[0 1];
    end
    plot(pT,ys,'k')
    xlabel('ms')
    %legend({'accepted','rejected'}) %argh legend sucks ass
end
toc
end