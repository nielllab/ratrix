% STATS STUFF - OLD

% STATISTICS FIGS - OLD

% % NEW?/EST 032322
% 
% [hiBehState_meanDthCRFacrossSess,loBehState_meanDthCRFacrossSess] = plotCompareBehState_CRF2(loRun_allSessAllPtsAllDurs_CRF,hiRun_allSessAllPtsAllDurs_CRF,durat,yMax,yMin,yLimit,x_axis,xMax,xMin,xLimit,stateLegend,uniqueContrasts,reigons,nGroup)

% next is for comparing fist contrast value to be equal or greater than max df (100% contrast) response...

% NEW 031422
% get max DF in loBehState = mean DF for 100% contrast in lo beh state sessions
visArea = 1;
durat = 1;
cont = 7; % max cont

mnDFcon100loBehState = mean(squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))');
mnDFcon100loBehState

% get mn CRF across sessions for 1 vis area, hi beh state
mn_hiRun_allSessOnePtsAllDurs_CRF = mean(squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,:,visArea,:))',1)

% Find lowest Con where DF hiBehState > DF mnDFcon100loBehState
conWhereHiStateGreaterOrEqualToLoMax = uniqueContrasts(min(find(mn_hiRun_allSessOnePtsAllDurs_CRF >= mnDFcon100loBehState)))
dfAt_ConWhereHiStateGreaterOrEqualToLoMax = hiRun_allSessAllPtsAllDurs_CRF(min(find(mn_hiRun_allSessOnePtsAllDurs_CRF >= mnDFcon100loBehState)))

% NOTE: COULD PLOT THIS AS ONE POINT PER VIS AREA ON ONE PLOT
maxLoStateCon = 1;
y = [maxLoStateCon, conWhereHiStateGreaterOrEqualToLoMax]
figure
bar(y)
title('Contrast where DF hiBehState (R) exceeds maxDFLoBehState (L)')

% NEW 031521

% LO BEH STATE

% What is the lowest con w/sig diff in DF from c=0?

% dur x con x point x sessions
sizeloRunAllSessAllPtsAllDurs_CRF = size(loRun_allSessAllPtsAllDurs_CRF)

% GET response DIST across SESSIONS for EACH CON -  LO BEH STATE

% paired t-test is for comparing distributions of 2 
% samples, not a mean vs a theoretical normal distribution)

format long g % no sci notation

visArea = 1;
durat = 1;
cont = 1; % max cont

% the mean dF at C = n, for all sessions, one point & dur
% 1 x # sessions
mnDfs_con1onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con1onePtOneDursAcrossSess = mean(mnDfs_con1onePtOneDursAllSess)

cont = 2 
mnDfs_con2onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con2onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 3 
mnDfs_con3onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con3onePtOneDursAcrossSess = mean(mnDfs_con3onePtOneDursAllSess)

cont = 4 
mnDfs_con4onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con4onePtOneDursAcrossSess = mean(mnDfs_con4onePtOneDursAllSess)

cont = 5
mnDfs_con5onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con5onePtOneDursAcrossSess = mean(mnDfs_con5onePtOneDursAllSess)

cont = 6
mnDfs_con6onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con6onePtOneDursAcrossSess = mean(mnDfs_con6onePtOneDursAllSess)

cont = 7
mnDfs_con7onePtOneDursAllSess = squeeze(loRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con7onePtOneDursAcrossSess = mean(mnDfs_con7onePtOneDursAllSess)

% t-test of mean df across sessions for each con

n_cons = 7 % # contrasts 
denom = n_cons-1 % # comparisons w/zero contrast
alf = 0.05/denom % bonferroni correction for multiple comparisons


% GET DIST across SESSIONS for EACH CON -  LO BEH STATE
% paired T-TEST needs range of samples (one for each session, a vector) not just individual variables:

% could do this in loop but doing long way here 
[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con2onePtOneDursAllSess,'Alpha',alf)

[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con3onePtOneDursAllSess,'Alpha',alf)

[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con4onePtOneDursAllSess,'Alpha',alf)

[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con5onePtOneDursAllSess,'Alpha',alf)

[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con6onePtOneDursAllSess,'Alpha',alf)

[h,p] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con7onePtOneDursAllSess,'Alpha',alf)


% HI BEH STATE

% dur x con x point x sessions
sizehiRunAllSessAllPtsAllDurs_CRF = size(hiRun_allSessAllPtsAllDurs_CRF)

% GET DIST across SESSIONS for EACH CON - HI BEH STATE

format long g % no sci notation

visArea = 1;
durat = 1;

% the mean dF at C = n, for all sessions, one point & dur
% 1 x # sessions
cont = 1; % max cont
mnDfs_con1onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con1onePtOneDursAcrossSess = mean(mnDfs_con1onePtOneDursAllSess)

cont = 2 
mnDfs_con2onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con2onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 3 
mnDfs_con3onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con3onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 4 
mnDfs_con4onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con4onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 5
mnDfs_con5onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con5onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 6
mnDfs_con6onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con6onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

cont = 7
mnDfs_con7onePtOneDursAllSess = squeeze(hiRun_allSessAllPtsAllDurs_CRF(durat,cont,visArea,:))'
%mnDf_con7onePtOneDursAcrossSess = mean(mnDfs_con2onePtOneDursAllSess)

% t-test of mean df across sessions for each con

n_cons = 7 % # contrasts 
denom = n_cons-1 
alf = 0.05/denom % bonferroni correction for multiple comparisons

format long g

[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con2onePtOneDursAllSess,'Alpha',alf)

[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con3onePtOneDursAllSess,'Alpha',alf)

[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con4onePtOneDursAllSess,'Alpha',alf)

[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con5onePtOneDursAllSess,'Alpha',alf)

[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con6onePtOneDursAllSess,'Alpha',alf)

[h,p,ci,stats] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con7onePtOneDursAllSess,'Alpha',alf)


% comparing c=0 to c=0 as a sanity check
[h,p,] = ttest(mnDfs_con1onePtOneDursAllSess,mnDfs_con1onePtOneDursAllSess,'Alpha',alf)

% pseudo code - using group CRF matricies
% get CRF from group beh state matrix
% do t test between c=0... ???

% for each beh state,
% for each duration (only 1 tho),
% for each visual area, 
% take the mean df at each contrast across all sessions/mice (mean of mean)
% for each con, use t test to compare mean df between c = 0 and cth con
% collect in 1 x 7 output vector for each beh state

% for each beh state,
% for cons where h = 1
% collect cont ('c') value

% scatter plot - like CRF but w/asterisks
% series (red vs blue = beh states)
% y = df value
% x = con
% asterisk = sig from zero

% categorical - bar or scatter plot w/2 asterisks?
% for each beh state,
% plot mean of 1st sig diff con (needs 1 x 2 matrix with mean 1st sig diff con 
% for lo beh state & same for hi beh state)
% y = mean con of 1st sig diff con
% x = 2 categories: lo Beh State vs Hi Beh State
% plot mean 1st sig df con 


% NEW 031622

visArea = 1:length(groupRoundXpts{1,n})
%visArea = 1 % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

%durat = 1:length(uniqueDurations)
durat = 1 % ( durat = 1 means 100 ms in final set of expts)

cont = 1:length(uniqueContrasts)
%cont = 7;


% NEEDS COLLECT STDEV THO FOR ERROR BAR PLOTTING!
% get mean CRF across sessions (a previous function does this then plots it, this function just does it and gives output var)
% I'm going to plot stats results as asterisks over these across session CRFs
% loRun 
[mnCRF_acrossSess_AllDurAllPts_loBehState] = mean_CRF_AcrossSessions(loRun_allSessAllPtsAllDurs_CRF,visArea,durat,cont);
% gives 1 x contrast
size(mnCRF_acrossSess_AllDurAllPts_loBehState)

% hiRun
[mnCRF_acrossSess_AllDurAllPts_hiBehState] = mean_CRF_AcrossSessions(hiRun_allSessAllPtsAllDurs_CRF,visArea,durat,cont);
size(mnCRF_acrossSess_AllDurAllPts_hiBehState)


%% good stuff

% NEW 032422

[loRun_mnCRF_acrossSess_AllDurAllPts,loRun_stdErrCRF_acrossSess_allPts] = mean_CRF_AcrossSessions(loRun_allSessAllPtsAllDurs_CRF,visArea,durat,cont);

size_loRun_mnCRF_acrossSess_AllDurAllPts = size(loRun_mnCRF_acrossSess_AllDurAllPts)
size_loRun_stdErrCRF_acrossSess_allPts = size(loRun_stdErrCRF_acrossSess_allPts)

% Getting mean across sessions CRF's & std err's
[hiRun_mnCRF_acrossSess_AllDurAllPts,hiRun_stdErrCRF_acrossSess_allPts] = mean_CRF_AcrossSessions(hiRun_allSessAllPtsAllDurs_CRF,visArea,durat,cont);

size_hiRun_mnCRF_acrossSess_AllDurAllPts = size(hiRun_mnCRF_acrossSess_AllDurAllPts)
size_hiRun_stdErrCRF_acrossSess_allPts = size(hiRun_stdErrCRF_acrossSess_allPts)

% picking an alpha value (correct for mult. comparisons)
n_cons = 7 % # contrasts 
denom = n_cons-1 % # comparisons
alf = 0.05/denom % bonferroni correction for multiple comparisons

% STATS - collecting stats params for each comparison

% FOR LO BEH STATE

% making matrix with all stats for all pairs of c=0 and other c's for each area & duration
clear h_p_cil_cih_AllPairs_AllPts_AllDurs

% for each duration
clear d
for d = durat 
    
    % new comparisons for each duration
    clear h_p_cil_cih_AllPairs_AllPts

    % for each visual area
    clear i
    for i = visArea
        
        % new contrast comparison for each vis area
        clear h_p_cil_cih_AllPairs

        % for each contrast * except c = 0 (cuz will get N/A)
        clear c
        for c = cont(2:end)
            
            % check for sig diff between cth contrast & c = 0 
            [h,p,ci] = ttest(mean(squeeze(loRun_allSessAllPtsAllDurs_CRF(1,1,i,:))',1),mean(squeeze(loRun_allSessAllPtsAllDurs_CRF(1,c,i,:))',1),'Alpha',alf);
            
            h_p_cil_cih_AllPairs(1,c-1) = h; % c-1 so index doesn't start at 2
            h_p_cil_cih_AllPairs(2,c-1) = p;
            h_p_cil_cih_AllPairs(3,c-1) = ci(1,1);
            h_p_cil_cih_AllPairs(4,c-1) = ci(1,2);
            
        end % end contrast loop
        
        % collect stats x contrast grid for each point
        h_p_cil_cih_AllPairs_AllPts(:,:,i) = h_p_cil_cih_AllPairs;
        
    end % end points loop
    
    h_p_cil_cih_AllPairs_AllPts_AllDurs(:,:,:,d) = h_p_cil_cih_AllPairs_AllPts;
    
end % end dur loop
        
% stats param x comparison contrast x points
loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs = h_p_cil_cih_AllPairs_AllPts_AllDurs;
size(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)


% FOR HI BEH STATE

% collecting stats params for each comparison

% making matrix with all stats for all pairs of c=0 and other c's for each area & duration
clear h_p_cil_cih_AllPairs_AllPts_AllDurs

% for each duration
clear d
for d = durat 
    
    % new comparisons for each duration
    clear h_p_cil_cih_AllPairs_AllPts

    % for each visual area
    clear i
    for i = visArea
        
        % new contrast comparison for each vis area
        clear h_p_cil_cih_AllPairs

        % for each contrast * except c = 0 (cuz will get N/A)
        clear c
        for c = cont(2:end)
            
            % check for sig diff between cth contrast & c = 0 
            [h,p,ci] = ttest(mean(squeeze(hiRun_allSessAllPtsAllDurs_CRF(1,1,i,:))',1),mean(squeeze(hiRun_allSessAllPtsAllDurs_CRF(1,c,i,:))',1),'Alpha',alf);
            
            h_p_cil_cih_AllPairs(1,c-1) = h; % c-1 so index doesn't start at 2
            h_p_cil_cih_AllPairs(2,c-1) = p;
            h_p_cil_cih_AllPairs(3,c-1) = ci(1,1);
            h_p_cil_cih_AllPairs(4,c-1) = ci(1,2);
            
        end % end contrast loop
        
        % collect stats x contrast grid for each point
        h_p_cil_cih_AllPairs_AllPts(:,:,i) = h_p_cil_cih_AllPairs;
        
    end % end points loop
    
    h_p_cil_cih_AllPairs_AllPts_AllDurs(:,:,:,d) = h_p_cil_cih_AllPairs_AllPts;
    
end % end dur loop
        
% stats param x comparison contrast x points
hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs = h_p_cil_cih_AllPairs_AllPts_AllDurs;
size(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)


visArea = 1:length(groupRoundXpts{1,n})

durat = 1 % ( durat = 1 means 100 ms in final set of expts)

cont = 1:length(uniqueContrasts)


% % PLOT w/asterisk if sig from c=0
% 
% figure
% 
% % for each duration
% clear d
% for d = durat
% 
%     % for each point
%     clear i
%     for i = visArea
%         
%         % Plot the CRF for LO beh state
%         
%         % make a sub plot
%         subplot(2,4,i)
%         x_axis = 1:length(uniqueContrasts);
%         plot(x_axis,mnCRF_acrossSess_AllDurAllPts_loBehState(i,:),'b')
%         
%         hold on
%         
%         % for each comparison, if h ==1, overlay a star (colored)
%         clear com
%         for com = 1:length(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)
%             
%             if loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1
%                 
%                 plot(com+1,mnCRF_acrossSess_AllDurAllPts_loBehState(i,com+1),'b*')
%                 
%                 hold on
%            
%             end % end if statement
%             
%         end % end com loop
%         
%         hold on
%         
%         % plot HI beh state CRF
%         plot(x_axis,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,:),'r')
%         ylim([-0.025 0.1])
%         
%         hold on
%         
%         % for each comparison, if h ==1, overlay a star (colored)
%         clear com
%         for com = 1:length(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)
%             
%             if hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1
%                 
%                 plot(com+1,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,com+1),'r*')
%            
%             end % end if statement
%             
%         end % end com loop
%         
%     end % end i loop
%     
% end % end d loop
%  
%             
% % repeat for hi beh state
% 
% % move to next subplot

% for crf figs
yMax = 0.06;
yMin = -0.01;
yLimit = [yMin yMax];
x_axis = [1:length(uniqueContrasts)];
xMax = max(x_axis);
xMin = min(x_axis);
xLimit = [xMin xMax];

% SAME as above BUT ONE ASTERISK for *1st* con above zero only
% remember, the gorup matricies are seperated by state already

figure

% for each duration
clear d
for d = durat
    
    % for each point
    clear i
    for i = visArea
        
        % Plot the CRF for LO beh state
        
        % make a sub plot
        subplot(2,4,i)
        
        % plot LO beh state CRF
        x_axis = 1:length(uniqueContrasts);
        %plot(x_axis,mnCRF_acrossSess_AllDurAllPts_loBehState(i,:),'b')
        errorbar(x_axis,mnCRF_acrossSess_AllDurAllPts_loBehState(i,:),loRun_stdErrCRF_acrossSess_allPts(i,:),'-b','LineWidth',0.75) 
        %legend(stateLegend)
        hold on
        
        % plot HI beh state CRF
        %plot(x_axis,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,:),'r')
        errorbar(x_axis,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,:),hiRun_stdErrCRF_acrossSess_allPts(i,:),'r','LineWidth',0.75)
            
        legend(stateLegend)
        
        hold on
        
        % reset asterisk counter for each vis area/beh state:
        counter = 0; % once counter = 1, stop plotting asterisk
         
        % for LO beh state
        % for each comparison, if h ==1, overlay a star (colored)
        clear com
        for com = 1:length(loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)
            
            if counter == 0
            
                if loBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1
                
                    hold on
                    
                    plot(com+1,mnCRF_acrossSess_AllDurAllPts_loBehState(i,com+1),'b*','LineWidth',1.1)
                    %errorbar(com+1,mnCRF_acrossSess_AllDurAllPts_loBehState(i,com+1),loRun_stdErrCRF_acrossSess_allPts(i,com+1),'b*')
                    
                    counter = counter + 1;
                
                end % end plot if statement
               
            end % end counter if statement
            
        end % end com loop
        
        % plot asterisk at c=0 df value
        %plot(1,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,1),'r*')
        % make a line
        %y = mnCRF_acrossSess_AllDurAllPts_hiBehState(i,1);
        %line([0,5],[y,y])
        
        hold on
        
        % set counter to zero again for the hi beh state
        counter = 0;
        
        % for each comparison, if h ==1, overlay a star (colored)
        clear com
        for com = 1:length(hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs)
            
            if counter == 0
            
                if hiBehState_h_p_cil_cih_AllPairs_AllPts_AllDurs(1,com,i) == 1
                
                    hold on
                    
                    plot(com+1,mnCRF_acrossSess_AllDurAllPts_hiBehState(i,com+1),'r*','LineWidth',1.1)
                    %errorbar(com+1,mnCRF_acrossSess_AllDurAllPts_loBehState(i,com+1),loRun_stdErrCRF_acrossSess_allPts(i,com+1),'r*')
                    
                    counter = counter + 1;
           
                end % end if statement
                
            end % end if statement
            
        end % end com loop
        
        axis square
        
        title(reigons{i})
    
        ylim(yLimit) 
        xlim(xLimit)
    
        ylabel('df/f')
        xlabel('contrast (%)')
    
        clear xt
        xt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
        set(gca,'xtick',1:7); 
        set(gca,'xticklabel',xt);
        
        yt = [-0.01 0 0.01 0.02 0.03 0.04 0.05 0.06];
        set(gca,'YTick',yt)
        
    end % end i loop 
    
end % end d loop


% test plot all sessions hi & low (stderr check)

figure

% for each duration
clear d
for d = durat
    
    % for each point
    clear i
    for i = visArea
        
        % Plot the CRF for LO beh state
        
        % make a sub plot
        subplot(2,4,i)
        
        clear sess
        for sess = 1:size(loRun_allSessAllPtsAllDurs_CRF,4) % 1 thru sessions
        
            % plot LO beh state CRF
            x_axis = 1:length(uniqueContrasts);
            plot(x_axis,loRun_allSessAllPtsAllDurs_CRF(d,:,i,sess),'b')
            
            hold on
            
        end 
        
%         hold on
%         
%         clear sess
%         for sess = 1:size(loRun_allSessAllPtsAllDurs_CRF,4) % 1 thru sessions
%             
%             % plot HI beh state CRF
%             x_axis = 1:length(uniqueContrasts);
%             plot(x_axis,hiRun_allSessAllPtsAllDurs_CRF(d,:,i,sess),'b')
%             
%         end
     
        legend(stateLegend)
        
        title(reigons{i})
    
        ylim(yLimit) 
        xlim(xLimit)
    
        ylabel('df/f')
        xlabel('contrast (%)')
    
        clear xt
        xt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
        set(gca,'xtick',1:7); 
        set(gca,'xticklabel',xt);
        
        yt = [-0.01 0 0.01 0.02 0.03 0.04 0.05 0.06];
        set(gca,'YTick',yt)
        
    end % end i loop
    
    
    
end % end d lo