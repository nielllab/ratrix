function [lo_yi_interpedConsCurve_allPtsAllSess,lo_xi_isDf_higherRes_allPtsAllSess,lo_C50_allPtsAllSess,lo_df_at_C50_allPtsAllSess,hi_yi_interpedConsCurve_allPtsAllSess,hi_xi_isDf_higherRes_allPtsAllSess,hi_C50_allPtsAllSess,hi_df_at_C50_allPtsAllSess] = makeC50_test(loRun_allSessAllPtsAllDurs_CRF,hiRun_allSessAllPtsAllDurs_CRF)

% this fcn takes in takes in group matrix and does one C50 per session CRF, storing C50 
% for each sess to later take mean & stdev
% outputs all C50s (each sess), & interp x & y for each sess

    global sess
    for n = sess
        
        clear lo_yi_interpedConsCurve_allPts{}
        clear lo_xi_isDf_higherRes_allPts{} 
        clear lo_C50_allPts
        clear lo_df_at_C50_allPts

        clear hi_yi_interpedConsCurve_allPts{}
        clear hi_xi_isDf_higherRes_allPts{} 
        clear hi_C50_allPts
        clear hi_df_at_C50_allPts

        global durat
        for d = durat

            global visArea
            for i = visArea

                % need to output c50 for each session, input group matrix
                % 'loRun_allSessAllPtsAllDurs_CRF', which is dur x con x pt x
                % sess martix

                % take the nth dth ith CRF
                lo_nthdthith_CRF = loRun_allSessAllPtsAllDurs_CRF(d,:,i,n); %(1 x 7 x 5 x 3)
                hi_nthdthith_CRF = hiRun_allSessAllPtsAllDurs_CRF(d,:,i,n);

                % now we are on the CRF for 1st session, only durat, ith vis area
                % let's take the C50 for this session & vis Area 

                % INTERP - LO beh state

                % x is df vector
                x_is_df = lo_nthdthith_CRF;
                % resolution of interpolation 
                higherRes = 1/1000; 
                lo_xi_isDf_higherRes = min(x_is_df):higherRes:max(x_is_df);
                % the y input to inpterp() is the thing you want interpolated according to the resolution set above
                global uniqueContrasts
                y_is_cons = uniqueContrasts;
                % interpolate contrast
                lo_yi_interpedConsCurve = interp1(x_is_df,y_is_cons,lo_xi_isDf_higherRes);

                % find con associated 1/2 max df/range value
                % find 1/2 max df
                % take the range of df (max df - min df)
                range = max(lo_nthdthith_CRF)-min(lo_nthdthith_CRF);
                %range = max(lo_nthdthith_CRF)-0; % range from zero (c = 1) to whatever max df response is
                % divide range by 2
                halfOf_range = range/2;
                % subtract 1/2 of range from max df to get the yvalue we want to query the interpolated contrast for
                lo_df_at_C50 = max(lo_nthdthith_CRF)-halfOf_range;

                % find C50 on interpolated curve
                % find first higher res df value greater than df_at_C50
                idx_df_lo_Res_aboveC50 = min(find(lo_xi_isDf_higherRes>lo_df_at_C50));
                % use index to find associated interped CON value
                lo_C50 = lo_yi_interpedConsCurve(1,idx_df_lo_Res_aboveC50);

                % COLLECT LO VARS to plot
                lo_yi_interpedConsCurve_allPts{i,:} = lo_yi_interpedConsCurve;
                lo_xi_isDf_higherRes_allPts{i,:} = lo_xi_isDf_higherRes;
                lo_C50_allPts(i,:) = lo_C50;
                lo_df_at_C50_allPts(i,:) = lo_df_at_C50;

                % INTERP - HI beh state

                % x is df vector
                x_is_df = hi_nthdthith_CRF;
                % resolution of interpolation 
                higherRes = 1/1000; 
                hi_xi_isDf_higherRes = min(x_is_df):higherRes:max(x_is_df);
                % the y input to inpterp() is the thing you want interpolated according to the resolution set above
                y_is_cons = uniqueContrasts;
                % interpolate contrast
                hi_yi_interpedConsCurve = interp1(x_is_df,y_is_cons,hi_xi_isDf_higherRes);
                % find con associated 1/2 max df/range value
                % find 1/2 max df
                % take the range of df (max df - min df)

                range = max(hi_nthdthith_CRF)-min(hi_nthdthith_CRF);
                % divide range by 2
                halfOf_range = range/2;
                % subtract 1/2 of range from max df to get the yvalue we want to query the interpolated contrast for
                hi_df_at_C50 = max(hi_nthdthith_CRF)-halfOf_range;

                % find C50 on interpolated curve
                % find first higher res df value greater than df_at_C50
                idx_df_hiRes_aboveC50 = min(find(hi_xi_isDf_higherRes>hi_df_at_C50));
                % use index to find associated interped cCON value
                hi_C50 = hi_yi_interpedConsCurve(1,idx_df_hiRes_aboveC50);

                % COLLECT VARS to plot
                hi_yi_interpedConsCurve_allPts{i,:} = hi_yi_interpedConsCurve;
                hi_xi_isDf_higherRes_allPts{i,:} = hi_xi_isDf_higherRes;
                hi_C50_allPts(i,:) = hi_C50';
                hi_df_at_C50_allPts(i,:) = hi_df_at_C50;

            end % end i loop

        end % end d loop

        lo_yi_interpedConsCurve_allPtsAllSess{:,:,n} = lo_yi_interpedConsCurve_allPts;
        lo_xi_isDf_higherRes_allPtsAllSess{:,:,n} = lo_xi_isDf_higherRes_allPts;
        lo_C50_allPtsAllSess(:,:,n) = lo_C50_allPts;
        lo_df_at_C50_allPtsAllSess(:,:,n) = lo_df_at_C50_allPts;

        hi_yi_interpedConsCurve_allPtsAllSess{:,:,n} = hi_yi_interpedConsCurve_allPts;
        hi_xi_isDf_higherRes_allPtsAllSess{:,:,n} = hi_xi_isDf_higherRes_allPts;
        hi_C50_allPtsAllSess(:,:,n) = hi_C50_allPts;
        hi_df_at_C50_allPtsAllSess(:,:,n) = hi_df_at_C50_allPts;

    end % end n loop
    
end % end function

% return lo_yi_interpedConsCurve_allPtsAllSess
% return lo_xi_isDf_higherRes_allPtsAllSess
% return lo_C50_allPtsAllSess
% return lo_df_at_C50_allPtsAllSess
% 
% return hi_yi_interpedConsCurve_allPtsAllSess
% return hi_xi_isDf_higherRes_allPtsAllSess
% return hi_C50_allPtsAllSess
% return hi_df_at_C50_allPtsAllSess

