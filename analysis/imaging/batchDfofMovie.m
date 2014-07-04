%batchDfofMovie
errmsg= [];errRpt = {};
nerr=0;

for f = 1:length(files)
    f
    tic

%     try
%         dfofMovie([datapathname files(f).topoxdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxdata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
%     try
%         dfofMovie([datapathname files(f).topoydata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).topoydata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
    
    try
        dfofMovie([datapathname files(f).stepbinarydata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).stepbinarydata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
    try
        dfofMovie([datapathname files(f).auditorydata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).auditorydata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
%     try
%         dfofMovie([datapathname files(f).loomdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).loomdata)
%          errRpt{nerr}=getReport(exc,'extended')
%     end
%    end     
    try
        dfofMovie([datapathname files(f).darknessdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
         errRpt{nerr}=getReport(exc,'extended')
    end    
 
    

%     for e = 1:nerr
%         errRpt{e}
%     end
    toc
end
 errRpt