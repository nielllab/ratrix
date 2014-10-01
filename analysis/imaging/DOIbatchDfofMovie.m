%DOIbatchDfofMovie
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
    
%     try
%         dfofMovie([datapathname files(f).stepbinarydata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).stepbinarydata)
%          errRpt{nerr}=getReport(exc,'extended')
%     end  

     try
        dfofMovie([datapathname files(f).darknessdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
    try
        dfofMovie([datapathname files(f).topoxreversedata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxreversedata)
        errRpt{nerr}=getReport(exc,'extended')
    end    
    try
        dfofMovie([datapathname files(f).baselinepatchxdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).baselinepatchxdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).topoxslowdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxslowdata)
        errRpt{nerr}=getReport(exc,'extended')
    end 
    
    %DOI passive files
    
        try
        dfofMovie([datapathname files(f).DOItopoxdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOItopoxdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).DOItopoydata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).DOItopoydata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    
%     try
%         dfofMovie([datapathname files(f).DOIstepbinarydata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIstepbinarydata)
%          errRpt{nerr}=getReport(exc,'extended')
%     end  

     try
        dfofMovie([datapathname files(f).DOIdarknessdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIdarknessdata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
    try
        dfofMovie([datapathname files(f).DOItopoxreversedata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOItopoxreversedata)
        errRpt{nerr}=getReport(exc,'extended')
    end    
    try
        dfofMovie([datapathname files(f).DOIbaselinepatchxdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIbaselinepatchxdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).DOItopoxslowdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOItopoxslowdata)
        errRpt{nerr}=getReport(exc,'extended')
    end 
    

%     for e = 1:nerr
%         errRpt{e}
%     end
    toc
end
 errRpt