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
        dfofMovie([datapathname files(f).stepbinarydata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).stepbinarydata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
% %     try
% %         dfofMovie([datapathname files(f).auditorydata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).auditorydata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end  
% %     try
% %         dfofMovie([datapathname files(f).loomdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).loomdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end
% %      
% %      try
% %         dfofMovie([datapathname files(f).darknessdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end  
% %     try
% %         dfofMovie([datapathname files(f).gratingdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).gratingdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end 
% %     try
% %         dfofMovie([datapathname files(f).topoxreversedata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxreversedata)
% %         errRpt{nerr}=getReport(exc,'extended')
% %     end
% %      try
% %         dfofMovie([datapathname files(f).darkness_w_maskingdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).darkness_w_maskingdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end     
% %     try
% %         dfofMovie([datapathname files(f).patchxdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}= sprintf('couldnt do %s',files(f).patchxdata)
% %         errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).patchydata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).patchydata)
% %         errRpt{nerr}=getReport(exc,'extended')
% %     end
    try
        dfofMovie([datapathname files(f).grating5sf4tfdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).grating5sf4tfdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).grating3x5data]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).grating3x5data)
        errRpt{nerr}=getReport(exc,'extended')
    end 
        try
        dfofMovie([datapathname files(f).resolutionRightdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).resolutionrightdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
%     try
%         dfofMovie([datapathname files(f).resolutionRightdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).resolutionRightdata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end 
    

%     for e = 1:nerr
%         errRpt{e}
%     end
    toc
end
 errRpt