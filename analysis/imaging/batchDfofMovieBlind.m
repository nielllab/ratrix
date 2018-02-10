%batchDfofMovieBlind

errmsg= [];errRpt = {};
nerr=0;
redo=1;

for f = 1:length(files)
    f
    tic
    
%     if isfield(files(f),'rignum') && strcmp(files(f).rignum,'rig2')
%         rig =2;
%     else
%         rig=1;
%     end  
%     
%     if redo || isempty([pathname files(f).n5sec_16mw]) || ~exist([pathname files(f).n5sec_16mw],'file')
%         try
%             dfofMovie_Blue([datapathname files(f).n5sec_16mwdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).n5sec_16mwdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).n5sec_16mwdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).n5sec_16mwdata)
%     end   
    
    
    if redo || isempty([pathname files(f).n5sec_3mw]) || ~exist([pathname files(f).n5sec_3mw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n5sec_3mwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n5sec_3mwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n5sec_3mwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n5sec_3mwdata)
    end   
    
    
    if redo || isempty([pathname files(f).n5sec_750uw]) || ~exist([pathname files(f).n5sec_750uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n5sec_750uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n5sec_750uwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n5sec_750uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n5sec_750uwdata)
    end
    
    
    if redo | isempty([pathname files(f).n5sec_375uw]) | ~exist([pathname files(f).n5sec_375uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n5sec_375uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n5sec_375uwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n5sec_375uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n5sec_375uwdata)
    end
    
%     
%     if redo || isempty([pathname files(f).n1sec_16mw]) || ~exist([pathname files(f).n1sec_16mw],'file')
%         try
%             dfofMovie_Blue([datapathname files(f).n1sec_16mwdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).n1sec_16mwdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).n1sec_16mwdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).n1sec_16mwdata)
%     end 
    
    
    if redo || isempty([pathname files(f).n1sec_3mw]) || ~exist([pathname files(f).n1sec_3mw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n1sec_3mwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n1sec_3mwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n1sec_3mwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n1sec_3mwdata)
    end   
    
    
    if redo | isempty([pathname files(f).n1sec_750uw]) | ~exist([pathname files(f).n1sec_750uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n1sec_750uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n1sec_750uwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n1sec_750uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n1sec_750uwdata)
    end
    
    
    
     if redo | isempty([pathname files(f).n1sec_375uw]) | ~exist([pathname files(f).n1sec_375uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n1sec_375uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n1sec_375uwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n1sec_375uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n1sec_375uwdata)
    end
    
    
%     if redo | isempty([pathname files(f).n100msec_16mw]) | ~exist([pathname files(f).n100msec_16mw],'file')
%         try
%             dfofMovie_Blue([datapathname files(f).n100msec_16mwdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).n100msec_16mwdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).n100msec_16mwdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).n100msec_16mwdata)
%     end
%     
    
    if redo || isempty([pathname files(f).n100msec_3mw]) || ~exist([pathname files(f).n100msec_3mw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n100msec_3mwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n100msec_3mwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n100msec_3mwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n100msec_3mwdata)
    end
    
    
    if redo | isempty([pathname files(f).n100msec_750uw]) | ~exist([pathname files(f).n100msec_750uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n100msec_750uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n100msec_750uwdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).n100msec_750uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n100msec_750uwdata)
    end
    


    if redo | isempty([pathname files(f).n100msec_375uw]) | ~exist([pathname files(f).n100msec_375uw],'file')
        try
            dfofMovie_Blue([datapathname files(f).n100msec_375uwdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).n100msec_375uwdata)
            nerr=nerr+1;
            errmsg{nerr}= sprintf('couldnt do %s',files(f).n100msec_375uwdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).n100msec_375uwdata)
    end

    %
    
    %     for e = 1:nerr
    %         errRpt{e}
    %     end
    toc
    
    end
    errRpt
