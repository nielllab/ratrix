%batchDfofMovie
errmsg= [];errRpt = {};
nerr=0;

for f = 1:length(files)
    f
    tic

    try
        dfofMovie([datapathname files(f).topoxdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).topoydata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).topoydata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).loomdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).loomdata)
         errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).gratingdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).gratingdata)
         errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).auditory]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).auditory)
         errRpt{nerr}=getReport(exc,'extended')
    end       
    try
        dfofMovie([datapathname files(f).darkness]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).darkness)
         errRpt{nerr}=getReport(exc,'extended')
    end    
    try
        dfofMovie([datapathname files(f).stepbinary]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).stepbinary)
         errRpt{nerr}=getReport(exc,'extended')
    end  
    

%     for e = 1:nerr
%         errRpt{e}
%     end
    toc
end
 errRpt