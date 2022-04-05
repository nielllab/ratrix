% CDF only

% figure
% formatSpec = 'area %1.f, duration %1.f, con %1.f'
% titleText = sprintf(formatSpec,visArea,durat,cont)
% suptitle(titleText)

% [cdf_vector] = cdfplot(lo_dthithCthNth_pkDfEachTrial)
% hold on
% cdfplot(hi_dthithCthNth_pkDfEachTrial)

xlim(xLimit)
legend('stat','run')

% 1 x #sessions nested cell array w/df for every trial, all conditions
% trails at one con, all sess (variable length)
%%lo_dthithCthNth_pkDfEachTrial = [lo_dthithCthNth_pkDfEachTrial,loRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];

figure

% this is still one contrast at a time...
h_lo = histogram(lo_dthithCthNth_pkDfEachTrial,edges,'Normalization','probability');
% should be same size as 'lo_dthithCthNth_pkDfEachTrial'
input_vals_to_histo_lo = h_lo.Data;
% probabillity values for each bin (should be equal to the number of bins)
barHeight_lo = h_lo.Values; 

% this is still one contrast at a time...
h_hi = histogram(hi_dthithCthNth_pkDfEachTrial,edges,'Normalization','probability');
% should be same size as 'lo_dthithCthNth_pkDfEachTrial'
input_vals_to_histo_hi = h_hi.Data;
% probabillity values for each bin (should be equal to the number of bins)
barHeight_hi = h_hi.Values; 

[h,p] = kstest2(barHeight_lo,barHeight_hi,'Alpha',alf)

%[h,p] = kstest2(x1,x2,'Alpha',alf)

%% cdf y's

for d = 1
    
    for i = 1
        
        for c = 1:length(uniqueContrasts)
            
            % get df for each trial vector across all sessions, one
            % contrast at a time
            
            clear lo_dthithCthNth_pkDfEachTrial
            lo_dthithCthNth_pkDfEachTrial = []; 
        
            clear hi_dthithCthNth_pkDfEachTrial
            hi_dthithCthNth_pkDfEachTrial = [];
                
            clear n
            for n = sess
  
                % get values for 1st sesson, cth dth ith trials
                lo_dthithCthNth_pkDfEachTrial = [lo_dthithCthNth_pkDfEachTrial,loRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
                hi_dthithCthNth_pkDfEachTrial = [hi_dthithCthNth_pkDfEachTrial,hiRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
            end % end n loop - now have all mean peak df values for each trial, all sessions pooled
            % but for only 1 con

            figure
            
            % one con at a time at first
            hiBeh_cdf_handle = cdfplot(hi_dthithCthNth_pkDfEachTrial);
            
            hold on
            
            loBeh_cdf_handle = cdfplot(lo_dthithCthNth_pkDfEachTrial);
            
            %hiBeh_cdf_xvals = hiBeh_cdf_handle.XData;
            hiBeh_cdf_yvals = hiBeh_cdf_handle.YData;
            
            %loBeh_cdf_xvals = loBeh_cdf_handle.XData;
            loBeh_cdf_yvals = loBeh_cdf_handle.YData;

            [h,p] = kstest2(loBeh_cdf_yvals,hiBeh_cdf_yvals,'Alpha',alf)
            
            [h,p] = kstest2(lo_dthithCthNth_pkDfEachTrial,hi_dthithCthNth_pkDfEachTrial)
            
        end % end contrast loop
        
        %hp_allCons(1,c-1) = h;
        %hp_allCons(2,c-1) = p;
        
    end % end i loop
    
end % end d loop

%% histo y's

for d = 1
    
    for i = 1
        
        for c = 1:length(uniqueContrasts)
            
            % get df for each trial vector across all sessions, one
            % contrast at a time
            
            clear lo_dthithCthNth_pkDfEachTrial
            lo_dthithCthNth_pkDfEachTrial = []; 
        
            clear hi_dthithCthNth_pkDfEachTrial
            hi_dthithCthNth_pkDfEachTrial = [];
                
            clear n
            for n = sess
  
                % get values for 1st sesson, cth dth ith trials
                lo_dthithCthNth_pkDfEachTrial = [lo_dthithCthNth_pkDfEachTrial,loRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
                hi_dthithCthNth_pkDfEachTrial = [hi_dthithCthNth_pkDfEachTrial,hiRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
            end % end n loop - now have all mean peak df values for each trial, all sessions pooled
            % but for only 1 con

            figure
            
            % this is still one contrast at a time...
            h_lo = histogram(lo_dthithCthNth_pkDfEachTrial,edges,'Normalization','probability');
            % should be same size as 'lo_dthithCthNth_pkDfEachTrial'
            input_vals_to_histo_lo = h_lo.Data;
            % probabillity values for each bin (should be equal to the number of bins)
            barHeight_lo = h_lo.Values; 

            hold on
            % this is still one contrast at a time...
            h_hi = histogram(hi_dthithCthNth_pkDfEachTrial,edges,'Normalization','probability');
            % should be same size as 'lo_dthithCthNth_pkDfEachTrial'
            input_vals_to_histo_hi = h_hi.Data;
            % probabillity values for each bin (should be equal to the number of bins)
            barHeight_hi = h_hi.Values; 

            %[h,p] = kstest2(barHeight_lo,barHeight_hi,'Alpha',alf)
            [h,p] = kstest2(barHeight_lo,barHeight_hi)
            
        end % end contrast loop
        
        %hp_allCons(1,c-1) = h;
        %hp_allCons(2,c-1) = p;
        
    end % end i loop
    
end % end d loop

%% kstat w/ (non-binned) trial vectors

clear h_kstat
clear p_kstat

clear h_kstat_AllPts
clear p_kstat_AllPts

clear h_kstat_AllPts_AllDurs
clear p_kstat_AllPts_AllDurs

figure

for d = 1
    
    for i = 1
        
        %for c = 1
        for c = 1:length(uniqueContrasts)
            
            % get df for each trial vector across all sessions, one
            % contrast at a time
            
            clear lo_dthithCthNth_pkDfEachTrial
            lo_dthithCthNth_pkDfEachTrial = []; 
        
            clear hi_dthithCthNth_pkDfEachTrial
            hi_dthithCthNth_pkDfEachTrial = [];
                
            clear n
            for n = sess
  
                % get values for 1st sesson, cth dth ith trials
                lo_dthithCthNth_pkDfEachTrial = [lo_dthithCthNth_pkDfEachTrial,loRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
                hi_dthithCthNth_pkDfEachTrial = [hi_dthithCthNth_pkDfEachTrial,hiRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
            end % end n loop - now have all mean peak df values for each trial, all sessions pooled
            % but for only 1 con

            subplot(2,4,c)
            
            % one con at a time at first
            cdfplot(hi_dthithCthNth_pkDfEachTrial)
            
            hold on
            
            cdfplot(lo_dthithCthNth_pkDfEachTrial)
            
            [h,p] = kstest2(lo_dthithCthNth_pkDfEachTrial,hi_dthithCthNth_pkDfEachTrial,'Alpha',alf);
            
            h_kstat(1,c) = h; % c-1 so index doesn't start at 2
            p_kstat(1,c) = p';
            
            title(sprintf('c=%1.0f, va=%1.0f, h=%1.0f, p=%0.4f',c,i,h,p))
            
            axis square
            
        end % end contrast loop
        
        h_kstat_AllPts(:,:,i) = h_kstat;
        p_kstat_AllPts(:,:,i) = p_kstat;
    end % end i loop
    
    h_kstat_AllPts_AllDurs(:,:,:,d) = h_kstat_AllPts;
    p_kstat_AllPts_AllDurs(:,:,:,d) = p_kstat_AllPts;
    
end % end d loop
h_kstat_AllPts_AllDurs = h_kstat_AllPts_AllDurs';
p_kstat_AllPts_AllDurs = p_kstat_AllPts_AllDurs';
size(h_kstat_AllPts_AllDurs)
size(p_kstat_AllPts_AllDurs)

%% 2 sample t test on trial vectors

figure

for d = 1
    
    for i = 1
        
        %for c = 1
        for c = 1:length(uniqueContrasts)
            
            % get df for each trial vector across all sessions, one
            % contrast at a time
            
            clear lo_dthithCthNth_pkDfEachTrial
            lo_dthithCthNth_pkDfEachTrial = []; 
        
            clear hi_dthithCthNth_pkDfEachTrial
            hi_dthithCthNth_pkDfEachTrial = [];
                
            clear n
            for n = sess
  
                % get values for 1st sesson, cth dth ith trials
                lo_dthithCthNth_pkDfEachTrial = [lo_dthithCthNth_pkDfEachTrial,loRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
                hi_dthithCthNth_pkDfEachTrial = [hi_dthithCthNth_pkDfEachTrial,hiRun_allSess_allConsAllPtsAllDurs_pkDfEachTrial{1,n}{1,d}{1,i}{1,c}];
                
            end % end n loop - now have all mean peak df values for each trial, all sessions pooled
            % but for only 1 con

            subplot(2,4,c)
            
            % one con at a time at first
            cdfplot(hi_dthithCthNth_pkDfEachTrial)
            
            hold on
            
            cdfplot(lo_dthithCthNth_pkDfEachTrial)
            
            [h,p,ci,t_stats] = ttest2(lo_dthithCthNth_pkDfEachTrial,hi_dthithCthNth_pkDfEachTrial,'Alpha',alf)
            
            title(sprintf('c=%1.0f, va=%1.0f, h=%1.0f, p=%0.4f',c,i,h,p))
            
            axis square
            
            h_p_cil_cih__tstats_AllPairs(1,c-1) = h; % c-1 so index doesn't start at 2
            h_p_cil_cih__tstats_AllPairs(2,c-1) = p;
            h_p_cil_cih__tstats_AllPairs(3,c-1) = ci(1,1);
            h_p_cil_cih__tstats_AllPairs(4,c-1) = ci(1,2);
            h_p_cil_cih__tstats_AllPairs(5,c-1) = tstat;
            h_p_cil_cih__tstats_AllPairs(6,c-1) = df;
            h_p_cil_cih__tstats_AllPairs(7,c-1) = sd;
            
        end % end contrast loop
        
        % collect stats x contrast grid for each point
        h_p_cil_cih__tstats_AllPairs_AllPts(:,:,i) = h_p_cil_cih__tstats_AllPairs;
        
        %hp_allCons(1,c-1) = h;
        %hp_allCons(2,c-1) = p;
        
    end % end i loop
    
    h_p_cil_cih__tstats_AllPairs_AllPts_AllDurs(:,:,:,d) = h_p_cil_cih__tstats_AllPairs_AllPts;
    
end % end d loop

% stats param x comparison contrast x points
size(h_p_cil_cih__tstats_AllPairs_AllPts_AllDurs)


 