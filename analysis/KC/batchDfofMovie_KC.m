%batchDfofMovie
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
    
    
    %uncomment for topox
    if redo  || isempty([pathname files(f).topox]) || ~exist([pathname files(f).topox],'file')
        try
            dfofMovie([datapathname files(f).topoxdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).topoxdata)
            nerr=nerr+1;
            errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).topox)
    end
    
    %uncomment for topoy
    if redo || isempty([pathname files(f).topoy]) || ~exist([pathname files(f).topoy],'file')
        try
            dfofMovie([datapathname files(f).topoydata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).topoydata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).topoydata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).topoy)
    end
    
    %uncomment for 3x2y
    if redo || isempty([pathname files(f).grating3x2y6sf4tf]) || ~exist([pathname files(f).grating3x2y6sf4tf],'file')
        try
            dfofMovie([datapathname files(f).grating3x2y6sf4tfdata],rig);
        catch exc
            sprintf('couldnt do %s',files(f).grating3x2y6sf4tfdata)
            nerr=nerr+1;
            errmsg{nerr}=sprintf('couldnt do %s',files(f).grating3x2y6sf4tfdata)
            errRpt{nerr}=getReport(exc,'extended')
        end
    else
        sprintf('skipping %s',files(f).grating3x2y6sf4tfdata)
    end
    
    %uncomment for 4x3y
%     if redo || isempty([pathname files(f).grating4x3y5sf3tf_short011315]) || ~exist([pathname files(f).grating4x3y5sf3tf_short011315],'file')
%         try
%             dfofMovie([datapathname files(f).grating4x3y5sf3tf_short011315data],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).grating4x3y5sf3tf_short011315data)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).grating4x3y5sf3tf_short011315data)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).grating4x3y5sf3tf_short011315data)
%     end

%     if redo || isempty([pathname files(f).fourxthreey]) || ~exist([pathname files(f).fourxthreey],'file')
%         try
%             dfofMovie([datapathname files(f).fourxthreeydata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).fourxthreeydata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).fourxthreeydata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).fourxthreey)
%     end
    
%     if redo || isempty([pathname files(f).patchonpatch]) || ~exist([pathname files(f).patchonpatch],'file')
%         try
%             dfofMovie([datapathname files(f).patchonpatchdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).patchonpatchdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).patchonpatchdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).patchonpatch)
%     end
    
%     if redo || isempty([pathname files(f).occlusion]) || ~exist([pathname files(f).occlusion],'file')
%         try
%             dfofMovie([datapathname files(f).occlusiondata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).occlusiondata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).occlusiondata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).occlusion)
%     end
    
%     if redo || isempty([pathname files(f).fullflanker]) || ~exist([pathname files(f).fullflanker],'file')
%         try
%             dfofMovie([datapathname files(f).fullflankerdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).fullflankerdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).fullflankerdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).fullflanker)
%     end

%     if redo || isempty([pathname files(f).patchgratings]) || ~exist([pathname files(f).patchgratings],'file')
%         try
%             dfofMovie([datapathname files(f).patchgratingsdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).patchgratingsdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).patchgratingsdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).patchgratings)
%     end
      
%     
%     if redo || isempty([pathname files(f).darkness]) || ~exist([pathname files(f).darkness],'file')
%         try
%             dfofMovie([datapathname files(f).darknessdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).darknessdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).darknessdata)
%     end    

    
    
% if redo | isempty([pathname files(f).sizeselect]) | ~exist([pathname files(f).sizeselect],'file')
%         try
%             dfofMovie([datapathname files(f).sizeselectdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).sizeselectdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).sizeselectdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).sizeselect)
%     end
    
    
%     
% if redo | isempty([pathname files(f).sizeselect]) | ~exist([pathname files(f).sizeselect],'file')
%         try
%             dfofMovie([datapathname files(f).sizeselectdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).sizeselectdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).sizeselectdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).sizeselect)
%     end
%     
%     
% %     

%     if redo | isempty([pathname files(f).gratingdata4x3yLandscape]) | ~exist([pathname files(f).gratingdata4x3yLandscape],'file')
%         try
%             dfofMovie([datapathname files(f).gratingdata4x3yLandscapedata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).gratingdata4x3yLandscapedata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).gratingdata4x3yLandscapedata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).grating4x3ydata)
%     end
%     
%     if redo | isempty([pathname files(f).behavstim2sf]) | ~exist([pathname files(f).behavstim2sf],'file')
%         try
%             dfofMovie([datapathname files(f).behavstim2sfdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).behavstim2sfdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).behavstim2sfdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).behavstim2sfdata)
%     end
%     
%     if redo | isempty([pathname files(f).behavstim3x4orient]) | ~exist([pathname files(f).behavstim3x4orient],'file')
%         try
%             dfofMovie([datapathname files(f).behavstim3x4orientdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).behavstim3x4orientdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).behavstim3x4orientdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).behavstim3x4orientdata)
%     end
    
    
 %uncomment the 3 above here for behavior passives (+comment out darknessdata)   
    
%     
% 
%     if redo | isempty([pathname files(f).background3x2yBlank]) | ~exist([pathname files(f).background3x2yBlank],'file')
%         try
%             dfofMovie([datapathname files(f).backgroundData],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).backgroundData)
%             nerr=nerr+1;
%             errmsg{nerr}= sprintf('couldnt do %s',files(f).backgroundData)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).backgroundData)
%     end
%     
%     if redo | isempty([pathname files(f).masking]) | ~exist([pathname files(f).masking],'file')
%         try
%             dfofMovie([datapathname files(f).maskingdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).maskingdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).maskingdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).maskingdata)
%     end
%    
%     if redo | isempty([pathname files(f).sizeselect]) | ~exist([pathname files(f).sizeselect],'file')
%         try
%             dfofMovie([datapathname files(f).sizeselectdata],rig);
%         catch exc
%             sprintf('couldnt do %s',files(f).sizeselectdata)
%             nerr=nerr+1;
%             errmsg{nerr}=sprintf('couldnt do %s',files(f).sizeselectdata)
%             errRpt{nerr}=getReport(exc,'extended')
%         end
%     else
%         sprintf('skipping %s',files(f).sizeselectdata)
%     end
   
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
    %     try
    %         dfofMovie([datapathname files(f).DOIbackgrounddata]);
    %     catch exc
    %         nerr=nerr+1;
    %         errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIbackgrounddata)
    %         errRpt{nerr}=getReport(exc,'extended')
    %     end
    %     try
    %         dfofMovie([datapathname files(f).gratings4x3y_1data]);
    %     catch exc
    %         nerr=nerr+1;
    %         errmsg{nerr}= sprintf('couldnt do %s',files(f).gratings4x3y_1data)
    %         errRpt{nerr}=getReport(exc,'extended')
    %     end
    %     try
    %         dfofMovie([datapathname files(f).DOIdarknessdata]);
    %     catch exc
    %         nerr=nerr+1;
    %         errmsg{nerr}= sprintf('couldnt do %s',files(f).DOIdarknessdata)
    %         errRpt{nerr}=getReport(exc,'extended')
    %     end
    %     try
    %         dfofMovie([datapathname files(f).DOIgratings4x3y_1data]);
    %     catch exc
    %         nerr=nerr+1;
    %         errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIgratings4x3y_1data)
    %         errRpt{nerr}=getReport(exc,'extended')
    %     end
    %     %     try
    %         dfofMovie([datapathname files(f).DOIgratings4x3y_1data]);
    %     catch exc
    %         nerr=nerr+1;
    %         errmsg{nerr}=sprintf('couldnt do %s',files(f).DOIgratings4x3y_1data)
    %          errRpt{nerr}=getReport(exc,'extended')
    %     end
    
    
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