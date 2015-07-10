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
    
%     try
%         dfofMovie([datapathname files(f).gratings4x3y_1data]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).gratings4x3y_1data)
%          errRpt{nerr}=getReport(exc,'extended')
%     end  
%      try
%         dfofMovie([datapathname files(f).DOIgratings4x3y_data]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIgratings4x3y_1data)
%         errRpt{nerr}=getReport(exc,'extended')
%      end
     try
        dfofMovie([datapathname files(f).DOIbackgrounddata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIbackgrounddata)
        errRpt{nerr}=getReport(exc,'extended')
     end
    try
        dfofMovie([datapathname files(f).gratings4x3y_1data]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).gratings4x3y_1data)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).DOIdarknessdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIdarknessdata)
        errRpt{nerr}=getReport(exc,'extended')
    end
    try
        dfofMovie([datapathname files(f).DOIgratings4x3y_1data]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIgratings4x3y_1data)
         errRpt{nerr}=getReport(exc,'extended')
    end  
%     try
%         dfofMovie([datapathname files(f).DOIgratings4x3y_1data]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIgratings4x3y_1data)
%          errRpt{nerr}=getReport(exc,'extended')
%     end
     
     try
        dfofMovie([datapathname files(f).darknessdata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
         errRpt{nerr}=getReport(exc,'extended')
    end  
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
%     try
%         dfofMovie([datapathname files(f).grating5sf4tfdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).grating5sf4tfdata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
%     try
%         dfofMovie([datapathname files(f).grating3x5data]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).grating3x5data)
%         errRpt{nerr}=getReport(exc,'extended')
%     end 
%         try
%         dfofMovie([datapathname files(f).resolutionRightdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).resolutionRightdata)
%         errRpt{nerr}=getReport(exc,'extended')
%         end
    try
        dfofMovie([datapathname files(f).backgrounddata]);
    catch exc
        nerr=nerr+1;
        errmsg{nerr}= sprintf('couldnt do %s',files(f).backgrounddata)
        errRpt{nerr}=getReport(exc,'extended')
    end
%     try
%         dfofMovie([datapathname files(f).gratings2x1ydata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).gratings2x1ydata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
%     try
%         dfofMovie([datapathname files(f).helloworlddata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).helloworlddata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
%      try
%         dfofMovie([datapathname files(f).hellodata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}= sprintf('couldnt do %s',files(f).hellodata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end
% %     try
%         dfofMovie([datapathname files(f).resolutionRightdata]);
%     catch exc
%         nerr=nerr+1;
%         errmsg{nerr}=sprintf('couldnt do %s',files(f).resolutionRightdata)
%         errRpt{nerr}=getReport(exc,'extended')
%     end 
%     

%     for e = 1:nerr
%         errRpt{e}
%     end
    toc
end
 errRpt