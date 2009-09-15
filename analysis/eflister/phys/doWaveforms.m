function doWaveforms(baseDir,base,chan,code)
f=fullfile(baseDir,[base ' waveforms.txt']);

numLines=getNumLines(f);

format='%% volt %% %u16 %u16 %u16';
C=doScan(f,format,2,chan,1,3,false);
idealRate=C{1}; %coming out like "30" when should be "30120"?
totalPoints=C{2};
prePoints=C{3};

numRecs=(numLines-4)/(2+totalPoints); %4 cuz there's a newline on the end

if ~isNearInteger(numRecs)
    error('numRecs problem')
end

combos=repmat(' \n %f',1,totalPoints);
format=['%% WAVMK %% %f %f %u8 0 0 0' combos ' \n'];
C=doScan(f,format,3,chan,numRecs,3+totalPoints,true);

rate=unique(C{2});
if ~isscalar(rate)
    error('rate error')
else
    tms=cumsum([0 ones(1,totalPoints-1)]*rate)*1000;
end

C=[num2cell(C{1}) num2cell(C{3}) mat2cell([C{4:end}],ones(numRecs,1),totalPoints)];
recs = cell2struct(C,{'time','code','points'},2);

if any(diff([recs.time])<=0)
    error('time error')
end

codes=unique([recs.code]);
if ~ismember(code,codes)
    error('code error')
end
codes=[code setdiff(codes,code)];

%TODO: save file w/ recs, prePoints, rate
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
end