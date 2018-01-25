%batchDfofMovie_Enrichment
errmsg= [];errRpt = {};
nerr=0;
redo=0;
for f = 1:length(files)
    sprintf('file %d/%d',f,length(files))
    tic
    
    if isfield(files(f),'rignum') && strcmp(files(f).rignum,'rig2')
        rig =2;
    else
        rig=1;
    end   
    
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
    
    if redo || isempty([pathname files(f).patchgratings]) || ~exist([pathname files(f).patchgratings],'file')
        try
            dfofMovie_Blue([datapathname files(f).patchgratingsdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).patchgratingsdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).patchgratingsdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).patchgratingsdata)
    end
    
    if redo || isempty([pathname files(f).darkness]) || ~exist([pathname files(f).darkness],'file')
        try
            dfofMovie_Blue([datapathname files(f).darknessdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).darknessdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).darknessdata)
    end    

    toc
    
end
errRpt