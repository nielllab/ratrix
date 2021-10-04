%batchDfofMovie_Blue
errmsg= [];errRpt = {};
nerr=0;
redo=0;
for f = 1:length(files)
    f
    tic
    
    if isfield(files(f),'rignum') && strcmp(files(f).rignum,'rig2')
        rig =2;
    else
        rig=1;
    end   
    
   % uncomment for topox
    if redo  || isempty([pathname files(f).topox]) || ~exist([pathname files(f).topox],'file')
        try
            dfofMovie_Blue([datapathname files(f).topoxdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).topoxdata)
            nerr=nerr+1;
            errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).topox)
    end
    
% uncomment for topoy
    if redo || isempty([pathname files(f).topoy]) || ~exist([pathname files(f).topoy],'file')
        try
            dfofMovie_Blue([datapathname files(f).topoydata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).topoydata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).topoydata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).topoy)
    end
    
% uncomment for thresh
    if redo || isempty([pathname files(f).thresh]) || ~exist([pathname files(f).thresh],'file')
        try
            dfofMovie_Blue([datapathname files(f).threshdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).threshdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).threshdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).threshdata)
    end
    
    %     for e = 1:nerr
    %         errRpt{e}
    %     end
    toc
    
end
errRpt