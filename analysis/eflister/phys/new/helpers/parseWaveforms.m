function t=parseWaveforms(txtFile,targPth,chan,force)
[garbage name ext]=fileparts(txtFile);
if ~strcmp(ext,'.txt')
    error('f error')
end

t=fullfile(targPth,[name '.mat']);
if exist(t,'file') && ~force
    %pass
else
    
    fprintf('parsing waveforms from %s...\n',txtFile)
    
    tic
    
    fprintf('\tcounting lines...\n')
    numLines=getNumLines(txtFile);
    
    
    format='%% volt %% %u16 %u16 %u16';
    C=doScan(txtFile,format,2,chan,1,3,false);
    idealRate=C{1}; %coming out like "30" when should be "30120"?
    totalPoints=C{2};
    prePoints=C{3};
    
    numRecs=(numLines-3)/(2+double(totalPoints)); %that 3 used to be a 4 with a note that it was for the newline on the end, but now that seems to be wrong, not sure why -- could either be switch to osx or new whitespace arg to doScan (hopefully the latter)
    
    if ~isNearInteger(numRecs)
        error('numRecs problem')
    end
    
    fprintf('\tparsing %g waveforms...\n',numRecs)
    
    % combos=repmat(' \n %f',1,totalPoints);
    combos=repmat(' %f',1,totalPoints);
    format=['%% WAVMK %% %f %f %u8 0 0 0' combos]; % ' \n'];
    C=doScan(txtFile,format,3,chan,numRecs,3+totalPoints,true,[' \b\t\n\r']);
    
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
    
    fprintf('\tsaving matted waveform file...\n')
    
    save(t,'idealRate','totalPoints','prePoints','rate','tms','recs')
    
    toc
    
end
end