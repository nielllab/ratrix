function combineTiffs
dbstop if error

p = mfilename('fullpath');
addpath(fullfile(fileparts(fileparts(fileparts(p))),'bootstrap'))
setupEnvironment;

if ~ispc
    error('win only for now')
end

behaviorPath = '\\lee\Users\nlab\Desktop\ballData2';
imagingPath = 'C:\Users\nlab\Desktop\data'; %\\landis (accessing local via network path is slow)
imagingPath = 'E:\widefield data';

%%% my understanding of record formt (cmn)
%%% record format - subject name (which suffices to find behavior data'
%%% followed by one cell for each imaging session
%%% {[trial numbers] ... find this from PermanentTrialRecordStore
%%% [trials within this sesion to use]
%%% [imaging path]
%%% [ imaging filenames]
% 
% recs = {
%     {'jbw01' {
%             {[1     192],[36 172],'9-21-12\jbw01 go to grating run 1','jbw01r1'  }
%             {[213   982],[10 670],'9-24-12\jbw01'                    ,'jbw01r1'  } % 54690 (91.15 mins) %timing screws up around 4300th frame/50th trial
%             {[983  1463],[ 1 165],'9-25-12\jbw01'                    ,'jbw01run1'} % 51296 (85.4933 mins) %timing screws up early
%             {[1464 2205],[20 720],'9-26-12\jbw01'                    ,'jbw01r1'  } % 32136 (53.56 mins) %timing screws up around 4270
%         }
%     }
%     
%     {'jbw03' {
%             {[1   665],[],'9-24-12\jbw03','jbw03r1'} % 63882 (106.47 mins)
%             {[667 962],[],'9-25-12\jbw03','jbw03r1'} % 30610 (51.0167 mins)
%         }
%     }
%     
%     {'wg02'  {
%             {[1    511],[     ],'9-24-12\wg2','wg2r1' } % 28631 (47.7183 mins)
%             {[512  815],[1 270],'9-25-12\wg2','wg2r1' } % 26261 (43.7683 mins)
%             {[816 1223],[1 325],'9-26-12\wg2','wg2run'} % 37047 (61.745 mins)
%         }
%     }
% };
% 
% imagingPath = 'E:\widefield data';
% recs = {
%      {'GCam13LN' {     
% %             {[2   194],[],'112012\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data   
%              {[204 474],[],'112112\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data  
%              {[510 577],[],'112212\GCam13LN\r2','GCam13LN'} %originally in landis E:\data  
% %             {[579 785],[],'112312\GCam13LN'   ,'GCam13LN'} %originally in landis E:\data  
% %     
% %             {[786   848],[],'112512\GCam13LN'   ,'GCam13LN'}
% %             {[850   983],[],'112512\GCam13LN\r2','GCam13LN'}            
% %              {[984  1190],[],'112612\GCam13LN'   ,'GCam13LN'}
% %              {[1191 1405],[],'112712\GCam13LN'   ,'GCam13LN'}            
% %             {[1406 1652],[],'112812\GCam13LN'   ,'GCam13LN'}
% %             {[1664 1874],[],'113012\GCam13LN\r3','GCam13LN'}
% %             {[1875 2159],[],'120112\GCam13LN'   ,'GCam13LN'}
% %             {[2160 2423],[],'120212\GCam13LN'   ,'GCam13LN'}
% %             {[2424 2743],[],'120312\GCam13LN'   ,'GCam13LN'}
% %             {[2744 2960],[],'120412\GCam13LN'   ,'GCam13LN'}
%          }
%      }
%     
%     {'GCam13TT' {         
% %             {[8   257],[],'112012\GCam13TT','GCam13TT'} %originally in landis E:\data  
%              {[258 353],[],'112112\GCam13TT','GCam13TT'} %originally in landis E:\data  
%               {[354 496],[],'112212\GCam13TT','GCam13TT'} %originally in landis E:\data  
% %             {[498 621],[],'112312\GCam13TT','GCam13TT'} %originally in landis E:\data  
% %     
% %             {[644   855],[],'112512\GCam13TT'   ,'GCam13TT'} 
% %              {[858  1085],[],'112612\GCam13TT'   ,'GCam13TT'} 
% %              {[1116 1321],[],'112712\GCam13TT\r2','GCam13TT'}
% %             {[1322 1710],[],'112812\GCam13TT\'  ,'GCam13TT'}
% %             {[1712 1816],[],'113012\GCam13TT\'  ,'GCam13TT'}
% %              {[1817 2005],[],'120112\GCam13TT\'  ,'GCam13TT'}
% %             {[2007 2276],[],'120212\GCam13TT\'  ,'GCam13TT'}
% %             {[2277 2584],[],'120312\GCam13TT\'  ,'GCam13TT'}
% %             {[2585 2939],[],'120412\GCam13TT\'  ,'GCam13TT'}
%         }
%     }    
% };
% 
% imagingPath = 'D:\Widefield (12-10-12+)';
% recs = {
%     {'GCam13LN' {      
%             {[3314 3766],[],'022213\gcam13ln\gcam13ln_r1\gcam13ln_r1_e','gcam13ln_r1'}    % expanded from pcoraw          
%         }
%     }
%     
%     {'GCam13TT' {         
%              {[3070 3215],[],'022213\gcam13tt_r1','gcam13tt.r1'}
%              {[3216 3566],[],'022213\gcam13tt_r2\gcam13tt_r2g','gcam13tt_r2'}     % expanded from pcoraw   -- should be first to have long reward stim
%         }
%     }    
% };
% 
% 
% recs = {
%     {'Gcam25RT' {
%     {[117 315],[],'043013\Gcam25-RT_behavior'                   ,'Gcam25-RT_behavior_GTS'}
%     {[319 523],[],'050313\Gcam25-RT_behavior\Gcam25-RT_behavior','Gcam25-RT_behavior_GTS'}
%     }
%     }
%     
%     {'Gcam32LN' {
%     {[1   203],[],'043013\Gcam32-LN_behavior','Gcam32_LN_behavior_GTS'}
%     %             {[204 419],[],'050313\Gcam32-LN_behavior','Gcam32-LN_behavior_GTS'}       %tight filter
%     }
%     }
%     
%     {'Gcam32TT' {
%     %            {[1  61 ],[],'043013\Gcam32-TT_behavior'               ,'Gcam32-TT_behavior_GTS'}
%    % {[62  274],[],'043013\Gcam32-TT_behavior\','Gcam32-TT_behavior_GTS'}
%     {[275 515],[],'050313\Gcam32-TT_behavior\'              ,'Gcam32-TT_behavior_GTS'}
%     }
%     }
%     
% %         {'Gcam17RN' {
% %                 {[1    95],[],'050113\Gcam17-RN_behavior','Gcam17-RN_behavior_HVV'}
% %                 {[102 293],[],'050213\Gcam17-RN_behavior','Gcam17-RN_behavior_HVV'}
% %             }
% %         }
% %     
%         {'Gcam20TT' {
%                 {[1 176],[],'050113\Gcam20-TT_behavior','Gcam20-TT_behavior_HvV'}
%             }
%         }
%     
%         {'Gcam21RT' {
%               %  {[19  155],[],'050113\Gcam21-RT_behavior','Gcam21-RT_behavior_HvV'} % hmm, last trial too few yellow frames
%                 {[156 372],[],'050213\Gcam21-RT_behavior','Gcam21-RT_behavior_HVV'}
%             }
%         }
%     
%         {'Gcam30LT' {
%                 {[1   216],[],'050113\Gcam30-LT_behavior','Gcam30-LT_behavior_HVV'}  % really bad performance
%                 {[217 429],[],'050213\Gcam30-LT_behavior','Gcam30-LT_behavior_HVV'}
%             }
%         }
%     
%         {'Gcam33LT' {
%                 {[1 137],[],'050113\Gcam33-LT_behavior\Gcam33-LT_behavior_HVV','Gcam33-LT_behavior_HVV_2'}
%             }
%         }
%     };

% 
% imagingPath = 'C:\data\imaging';
% recs = {
% %     {'gcam51LN' {
% %     {[36 222],[],'090613 GTS Behavior\G51-LN_r2_behavior_setProtocolGTS_4x4bin_53ms_vertical','G51-LN_r2_behavior_setProtocolGTS_4x4bin_53ms_vertical'}    
% %     }
% %     }
% %     %%% go to stimulus (top=right, bottom=left)
%     
% %     {'g625ln' {
% %     {[61 237],[],'092013 DOI\G62-5-LN_DOI and behavior\G625_LN_Behavior_GoToBlack_DOI_at_start','G625_LN_Behavior_GoToBlack_DOI_at_start'}
% %    
% %     }
% %     }
%     
%       {'g62.8lt' {
%     {[1 157],[],'Behavior data 12-24-13+\122413 G62.8-LT GTS Behavior','G62.8-LT_GTS_50ms_exp_1x1bin'}
%    
%     }
%     }
%    
%     }; %%% black on top = go right, black on bottom = go left
% 

% imagingPath = 'C:\data\imaging';
% recs = {
% 
%       {'g62.8lt' {
%    % {[422 672],[],'021914 G628-LT GTS Behavior','G628-LT_run1_GTS_behavior_15ms_exp'}
%       {[673 896],[],'022014 G628-LT GTS Behavior','022014 G628-LT GTS Behavior'}
%     }
%     }
%    
%     }; %%% black on top = go right, black on bottom = go left
% % 
% imagingPath = 'C:\data\imaging';
% recs = {
% 
%       {'g62b4ln' {
% 
%       {[1 298],[],'022114 G62B.4-LN GTS Behavior','G62B.4-LN_run1_GTS_behavior_15msexp'}
%     }
%     }
%    
%     }; %%% black on top = go right, black on bottom = go left
% % 


% imagingPath = 'C:\data\imaging';
% recs = {
% 
%       {'g62b7lt' {
%  
%      {[1 176],[],'022314 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_Behavior_15msexp','G62B.7-LT_run1_HvV_center_Behavior_15msexp'}
%      %   {[177 469],[],'022514 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_Behavior_15msexp','G62B.7-LT_run1_HvV_center_Behavior_15msexp'}
%   }
%     }
%    
%     }; %%% vert vs hors = left vs right


% imagingPath = 'C:\data\imaging';
% recs = {
% 
%       {'g62b3rt' {
%       {[1 157],[],'022814 G62B.3-RT HvV Behavior\G62B.3-RT_run1_HvV_Behavior_15msexp','G62B.3-RT_run1_HvV_Behavior_15msexp'}
%     }
%     }
%    
%     }; %%% vert vs horiz in either top or bottom
% 
% imagingPath = 'C:\data\imaging';
% recs = {
% 
% %       {'g62b.5lt' {
% %       {[1 198],[1 190],'030114 G62B.5-LT GTS Behavior (Fstop 8)\G62B.5-LT_run1_GTS_behavior_Fstop_8_50msexp','G62B.5-LT_run1_GTS_behavior_Fstop_8_50msexp'}
% %     }
% %     }
% %    
%          {'g62b7lt' {
%       {[470 739],[],'030114 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_behavior_Fstop5.6_50msexp','G62B.7-LT_run1_HvV_center_behavior_Fstop5.6_50msexp'}
%     }
%     }
%          {'g62b3rt' {
%       {[158 340],[],'030114 G62B.3-RT HvV Behavior\G62B.3-RT_run1_HvV_behavior_Fstop_5.6_50msexp','G62B.3-RT_run1_HvV_behavior_Fstop_5.6_50msexp'}
%     }
%     }
%          {'g62b4ln' {
%       {[583 748],[],'030114 G62B.4-LN GTS Behavior (Top Fstop-11)\G62B.4-LN_run4_GTS_Behavior_topFstop-11_30msexp','G62B.4-LN_run4_GTS_Behavior_topFstop-11_30msexp'}
%     }
%     }
%     }; %%% vert vs horiz in either top or bottom

imagingPath = 'G:\Behavior data 12-24-13+';
recs = {


%          {'g6w1lt' {
%          {[1 360],[],'050414 G6W1-LT GTS behavior\G6W1-LT_run1_GTS_behavior_50msexp_fstop5_6','G6W1-LT_run1_GTS_behavior_50msexp_fstop5_6'}
%%          {[361 610],[],'',''}  %bad run - motion artifact (headplate not secure)
%          {[611 855],[],'051614 g6w1LT GTS behavior\g6w1lt_run1_gts_fstop11_exp50ms','g6w1lt_run1_gts_fstop11_exp50ms'}%most likely bad - passive looks weird
%     }
%     }  
%     
%          {'g62.8lt' {
% %      {[1 157],[],'122413 G62.8-LT GTS Behavior','G62.8-LT_GTS_50ms_exp_1x1bin'}     
% %      {[158 159],[],'camera fail 122514'}
% %      {[160 418],[],'122513 G628 GTS Behavior\122513 G62.8-LT GTS Behavior (run 5 after camera fail)','122513 G62.8-LT GTS Behavior'}  %%probably not right file?
% %      {[419 421],[],'021914 '}
% %      {[422 672],[],'021914 G628-LT GTS Behavior','G628-LT_run1_GTS_behavior_15ms_exp0'}
%       {[673 896],[],'022014 G628-LT GTS Behavior','022014 G628-LT GTS Behavior'}
%%not sure whats wrong    {[897 1187],[],'030214 G62.8-LT GTS behavior\G62.8-LT_run1_GTS_behavior_Fstop_5.6_50ms_exposure','G62.8-LT_run1_GTS_behavior_Fstop_5.6_50ms_exposure'}%video writer didnt work
%         {[1188 1436],[],'051515 G628-LT GTS behavior\g628lt_run1_gts_fstop5.6_exp50ms','g628lt_run1_gts_fstop5.6_exp50ms'} 
%%        {[1437 1437],[],'Bad',''} 
%         {[1438 1663],[],'051714 G62.8 GTS Behavior\g62.8_run2_gts_fstop11_exp50ms','g62.8_run2_gts_fstop11_exp50ms'} 
%      }
%      }
%        
%          {'g62b.5lt' {
% %      {[1 198],[],'030114 G62B.5-LT GTS Behavior (Fstop 8)\G62B.5-LT_run1_GTS_behavior_Fstop_8_50msexp','G62B.5-LT_run1_GTS_behavior_Fstop_8_50msexp'}     
%      {[199 381],[],'030614 G62B.5-LT GTS behavior\G62B.5-LT_run1_GTS_behavior_F_4_50msexp','G62B.5-LT_run1_GTS_behavior_F_4_50msexp'}
%       {[382 576],[],'050314 G62B5-LT GTS behavior\G62B5-LT_run1_GTS_behavior_50msexp_Fstop-8','G62B5-LT_run1_GTS_behavior_50msexp_Fstop-8'}
%%        {[577 588],[],'',''}  %G62C.2 ran on these trials (different protocol)
%%        {[589 621],[],'',''}  %Bad run - having trouble with air pressure (no passive viewing)
%%      {[622 655],[],'051514',''}  %Bad run - having trouble with no butt corral (no passive viewing)
%%      {[656 700],[],'052014',''}  %Bad run - having trouble with no butt corral (no passive viewing)
%     }
%     }    
%     
%           {'g62b1lt' {
%       {[1 208],[],'031114 G62B.1-RT HvV Behavior\G62B.1-LT_run1_HvV_behavior_Fstop_5.6_50msexp','G62B.1-LT_run1_HvV_behavior_Fstop_5.6_50msexp'}     
%       {[209 477],[],'050214 G62b.1 LT HvV_vertical behavior\g62b.7lt_run1_HvV_vertical_fstop5.6_exp50ms','g62b.7lt_run1_HvV_vertical_fstop5.6_exp50ms'}
%         {[478 693],[],'050614 G62B.1 LT HvV_Vertical Behavior\G62B.1LT_run1_HvV_Vertical_fstop5.6_exp50ms','G62B.1LT_run1_HvV_Vertical_fstop5.6_exp50ms'}
%         {[694 903],[],'050814 G62B1-LT HvV Behavior\G62B1-LT_run1_HvV_behavior_50ms_Fstop5_6','G62B1-LT_run1_HvV_behavior_50ms_Fstop5_6'}
%         {[904 1195],[],'052014 G62b.1LT HvV_vertical behavior\62b.1lt_run1_hvv_vertical_fstop11_exp50ms','62b.1lt_run1_hvv_vertical_fstop11_exp50ms'}
%     }
%     }    
%     
         {'g62b3rt' {
%       {[1 157],[],'022814 G62B.3-RT HvV Behavior\G62B.3-RT_run1_HvV_Behavior_15msexp','G62B.3-RT_run1_HvV_Behavior_15msexp'}     
%       {[158 340],[],'030114 G62B.3-RT HvV Behavior\G62B.3-RT_run1_HvV_behavior_Fstop_5.6_50msexp','G62B.3-RT_run1_HvV_behavior_Fstop_5.6_50msexp' }
%       {[341 572],[],'030214 G62B.3-RT HvV behavior\G62B.3-RT_run1_HvV_behavior_Fstop8_50msexp','G62B.3-RT_run1_HvV_behavior_Fstop8_50msexp'}
%       {[573 774],[],'030614 G62B.3-RT HvV behavior\G62B.3-RT_run1_HvV_behavior_Fstop4_50msexp','G62B.3-RT_run1_HvV_behavior_Fstop4_50msexp'}
%       {[775 1000],[],'031114 G62B.3-RT HvV Behavior\G62B.3-RT_run1_HvV_behavior_F_4_50msexp','G62B.3-RT_run1_HvV_behavior_F_4_50msexp'}
%%        {[1001 1104],[],'050414 G62b3-RT HvV behavior (movement artifact)\G62b3-rt_run1_HvV_behavior_50msexp_Fstop_8','G62b3-rt_run1_HvV_behavior_50msexp_Fstop_8'}  %%movement artifact(headplate not secure)
%         {[1105 1363],[],'050814 G62b3-rt HvV behavior\G62B3-RT_run1_HvV_behavior_50ms_Fstop_8','G62B3-RT_run1_HvV_behavior_50ms_Fstop_8'}
%         {[1364 1584],[],'051514 G62b.3 RT HvV Behavior\g62b.3rt_run1_HvV_vertical_fstop5.6_exp50ms','g62b.3rt_run1_HvV_vertical_fstop5.6_exp50ms'}
        {[1585 1893],[1585 1885],'051714 G62B.3RT HvV_vertical Behavior','g62b.3rt_run1_hvv_vertical_fstop11_exp50ms'}
    }
    }    
%     
%          {'g62b4ln' {
%       {[1 298],[],'022114 G62B.4-LN GTS Behavior','G62B.4-LN_run1_GTS_behavior_15msexp'}     
%       {[299 558],[],'022414 G62B.4-LN GTS Behavior','G62B.4-LN_run1_GTS_Behavior_15msexp_only_blue_1.5secCorrectStim'} %%light off for first 13 frames
%  %     {[559 572],[],'030114 G62B.4-LN GTS Behavior (Top Fstop-11)\G62B.4-LN_run1_GTS_Behavior_topFstop-11_30msexp_badNoWaterReward','G62B.4-LN_run1_GTS_Behavior_topFstop-11_30msexp'}  % no water reward
%  %    {[573 573],[],'030114 G62B.4-LN GTS Behavior (Top Fstop-11)\G62B.4-LN_run2_GTS_Behavior_topFstop-11_30msexp_bad_LEDtrouble','G62B.4-LN_run2_GTS_Behavior_topFstop-11_30msexp'}  %led trouble (both 0n)
%  %     {[574 582],[],'030114 G62B.4-LN GTS Behavior (Top Fstop-11)\G62B.4-LN_run3_GTS_Behavior_topFstop-11_30msexp_Bad_LEDtrouble','G62B.4-LN_run3_GTS_Behavior_topFstop-11_30msexp'}  %led trouble
%      {[583 748],[],'030114 G62B.4-LN GTS Behavior (Top Fstop-11)\G62B.4-LN_run4_GTS_Behavior_topFstop-11_30msexp','G62B.4-LN_run4_GTS_Behavior_topFstop-11_30msexp'}
%       {[749 1015],[],'050314 G62b4-LN_ GTS behavior\G62B4-LN_run1_GTS_behavior_50ms_exp_fstop_8','G62B4-LN_run1_GTS_behavior_50ms_exp_fstop_8'}
%         {[1016 1254],[],'051914 G62b4-LN GTS behavior\G62b4-ln_GTS_behavior_50ms_Fstop_11','G62b4-ln_GTS_behavior_50ms_Fstop_11'}
%     }
%     }      
%            {'g62b7lt' {
%       {[1 176],[],'022314 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_Behavior_15msexp','G62B.7-LT_run1_HvV_center_Behavior_15msexp'}     
%       {[177 469],[],'022514 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_Behavior_15msexp','G62B.7-LT_run1_HvV_center_Behavior_15msexp'}
%       {[470 739],[],'030114 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_behavior_Fstop5.6_50msexp','G62B.7-LT_run1_HvV_center_behavior_Fstop5.6_50msexp'}
%       {[740 1031],[],'030214 G62B.7-LT HvV_center behavior\G62B.7-LT_run1_HvV_center_behavior_Fstop_8_50msexp','G62B.7-LT_run1_HvV_center_behavior_Fstop_8_50msexp'}
% %      {[1032 1154],[],'030614 G62B.7-LT HvV_center Behavior\G62B.7_run1_HvV_center_behavior_Fstop_4_50msexp','G62B.7_run1_HvV_center_behavior_Fstop_4_50msexp'}
% %     {[1155 1176],[],'030614 G62B.7-LT HvV_center Behavior\G62B.7_run2_HvV_center_behavior_Fstop_4_50msexp','G62B.7_run2_HvV_center_behavior_Fstop_4_50msexp'}
%       {[1177 1451],[],'031114 G62B.7-LT HvV_center Behavior\G62B.7-LT_run1_HvV_center_behavior_Fstop4_50msexp','G62B.7-LT_run1_HvV_center_behavior_Fstop4_50msexp'}
%       {[1452 1558],[],'042214 g62b.7 LT HvV_center_behavior\G62b7lt_run1_HvV_center_fstop5.6_exp50ms_only9999images','G62b7lt_run1_HvV_center_fstop5.6_exp50ms'}   
%       {[1559 1946],[],'042414 G62B.7LT HvV_center Behavior\G62B.7LT_run1_HvV_center_fstop5.6_exp50ms','G62B.7LT_run1_HvV_center_fstop5.6_exp50ms'}
%%       %{[1947 2062],[],'file deleted 042914'}
%%       %{[2063 2063],[],'file deleted 042914'}
%        {[2064 2182],[],'042914 G62B.7 LT Behavior HvV Center\g62b.7lt_run1_hvv_center_fstop5.6_exp50ms','g62b.7lt_run1_hvv_center_fstop5.6_exp50ms'}
%        {[2183 2438],[],'051414 g62B.7LT HvV_center Behavior\g62b.7lt_run1_hvV_center_fstop5.6_exp50','g62b.7lt_run1_hvV_center_fstop5.6_exp50'}
%     }
%     }
%     
%         {'g62b8tt' {
%       {[1 388],[],'041814 G62B.8-tt HvV_center Behavior\G62B.8-TT_run1_HvV_center_50msexp_5.6Fstop','G62B.8-TT_run1_HvV_center_50msexp_5.6Fstop'}     
%       {[389 649],[],'042114 G62B8-TT HvV_center Behavior','G62B8TT_run1_HvV_center_50msexp_5.6fstp'} 
%      {[650 953],[650 775],'042414 G62b.8TT HvV_center Behavior\g62B.8TT_run1_HvV_center_fstop5.6_exp50ms_lightblockconetipperatendoftrial','g62B.8TT_run1_HvV_center_fstop5.6_exp50ms'}  %% light block hat tiped towards end of session
%%multiTiff      {[954 1213],[],'051614 G62b8-TT HvV_center Behavior\G62B8-TT_run1_HvV_center_behavior_50ms_F_11','G62B8-TT_run1_HvV_center_behavior_50ms'}  %MultiTif file *(can we analyze?)
%         {[1214 1675],[],'051714 G62B.8TT HvV_center Behavior\g62B.8TT_run1_hvv_center_fstop11_exp50ms','g62B.8TT_run1_hvv_center_fstop11_exp50ms'}
%    }
%    }      
%     
%         {'g62c.2rt' {
%       {[1 194],[],'031114 G62C.2-RT HvV_center Behavior\G62C.2-RT_run1_HvV_center_behavior_F_4_50msexp','G62C.2-RT_run1_HvV_center_behavior_F_4_50msexp'}  
%%        {[195 195],[],'050414 G62C2_RT HvV_center Behavior\G62C2-RT_run1_HvV_center_behavior_50ms_exp_fstop_8_NO BLUE','G62C2-RT_run1_HvV_center_behavior_50ms_exp_fstop_8'}  %no blue led
%        {[196 415],[196 300],'050414 G62C2_RT HvV_center Behavior\G62C2-RT_run2_HvV_center_behavior_50ms_exp_fstop_8','G62C2-RT_run2_HvV_center_behavior_50ms_exp_fstop_8'}%% light block hat tiped towards end of session
%%         {[416 667],[],'050814 G62c.2 rt HvV_center Behavior\g62c.2rt_run2_HvV_center_fstop5.6_exp50ms','g62c.2rt_run2_HvV_center_fstop5.6_exp50ms'} %green LED left on for all of behavior %error in analysis
%         {[668 876],[],'051614 G62c2-rt HvV_center Behavior\G62c-rt_run1_HvV_center_behavior_50msexp_Fstop_8','G62c-rt_run1_HvV_center_behavior_50msexp_Fstop_8'}
%     }
%     }    
%     
%          {'g62g4lt' {
%       {[1 214],[],'041814 G62G.4-LT HvV_center behavior\041814_G62G4-LT_run1_HvV_center_50ms_F5.6_shadowGreenChannel','041814_G62G4-LT_run1_HvV_center_50ms_F5.6_shadowGreenChannel'}     
%       {[215 383],[],'042114 g62g.4-lt HvV_center behavior\g62g.4lt_run1_HvV_center_50msexp_5.6fstop','g62g.4lt_run1_HvV_center_50msexp_5.6fstop'} 
%        {[384 585],[],'050414 G62G.4 LT HvV_center behavior\g62g.4ln_run1_HvV_center_fstop5.6_exp50ms','g62g.4ln_run1_HvV_center_fstop5.6_exp50ms'} 
%         {[586 806],[],'051614 G62G.4LT HvV Behavior\g62g,4lt_run1_hvv_center_fstop11_exp50ms','g62g,4lt_run1_hvv_center_fstop11_exp50ms'} 
%         {[807 915],[],'051814 g62g.4lt HvV Center behavior\g62g,4lt_run1_hvvcenter_fstop11_exp50ms','g62g,4lt_run1_hvvcenter_fstop11_exp50ms'} 
%     }
%     }   
%     
%         {'g62h1tt' {
%        {[1 151],[],'042414 g62h.1tt HvV_center behavior\G62h.1tt_run1_HvV_center_fstop5.6_exp50ms','G62h.1tt_run1_HvV_center_fstop5.6_exp50ms'}     
%          {[152 330],[],'050614 G62H.1TT HvV Center Behavior\g62h.1tt_run1_HvV_center_fstop5.6_exp50ms','g62h.1tt_run1_HvV_center_fstop5.6_exp50ms'}  
%%hmm        {[331 564],[],'051414 G62H.1TT HvV_center Behavior\g62h.1tt_run1_HvV_center_fstop5.6_exp50ms','g62h.1tt_run1_HvV_center_fstop5.6_exp50ms'} % couldnt analyze?
%     }
%     }     
    
    
    
    
    
 
    }; %%% vert vs horiz in either top or bottom

% dirOverview(imagingPath)

%%% apply function biAnalysis to each
cellfun(@(r)cellfun(@(s)f(r{1},s),r{2},'UniformOutput',false),recs,'UniformOutput',false);
    function f(subj,r)
        close all
        rng = sprintf('%d-%d',r{1}(1),r{1}(2));
        biAnalysis(...
            fullfile(behaviorPath,'PermanentTrialRecordStore',subj,['trialRecords_' rng '_*.mat']),...
            fullfile(imagingPath,r{3},r{4}),...
            [subj '.' rng],...
            r{2}...
            );
    end
end

function biAnalysis(bPath,iPath,pre,goodTrials)
fprintf('doing %s\n',bPath)
dirOverview(fileparts(iPath))
%%keyboard
% if exist(fullfile('C:\Users\nlab\Desktop\analysis',[pre '.sync.png']),'file')
%     fprintf('skipping, already done\n')
%     return
% end

if verLessThan('matlab', '8.1') %2013a
    warning('use 2013a, or else loading tiffs is slow/can''t read bigtiffs (2012b?)')
end

%%% read image data
pr = [iPath '.pcoraw'];
% pr = 'D:\Widefield (12-10-12+)\022213\gcam13ln\gcam13ln_r1\gcam13ln_r1.pcoraw'; %31GB %timestamps screwed up around frame 9600+?
% pr = 'D:\Widefield (12-10-12+)\022213\gcam13tt_r2\gcam13tt_r2.pcoraw'; %12GB %timestamps screwed up after frame ~10k?
doPcoraw = isscalar(dir(pr));
if doPcoraw
    fprintf('imfinfo on pcoraw\n')
    tic
    ids = imfinfo(pr);
    toc
    
    cds = nan(1,length(ids));
    
    sz = cellfun(@(x)unique([ids.(x)]),{'Height','Width'});
    if numel(sz)~=2
        error('bad unique')
    end
    %     sz = cellfun(@(x)t.getTag(x),{'ImageLength' 'ImageWidth'});
else
    warning('pcoraw preferred')
    
    ids = dir([iPath '_*.tif']);
    if isempty(ids)
        %keyboard
        dest = fileparts(iPath);
        b = dest;
        [~,b] = strtok(b,filesep);
        [~,b] = strtok(b,filesep);
        src = ['\\landis\data' b];
        fprintf('copying %s to %s (takes forever)\n',src,dest);
        dirOverview(src);
        [status,message,messageid] = copyfile(src,dest,'f'); %f shouldn't be necessary, but i get a read-only error w/o it
        if status~=1
            status
            message
            messageid
            error('copy fail')
        end
        ids = dir([iPath '_*.tif']);
    end
    
    try
        sz = size(imread([iPath '_0001.tif']));
    catch
        sz = size(imread([iPath '_000001.tif']));
        sz = sz(1:2);
    end
end

bds = dir(bPath);

if ~isscalar(bds)
    error('hmmm...')
end

maxGB = 1;

bytesPerPix = 2;
pixPerFrame = maxGB*1000*1000*1000/length(ids)/bytesPerPix;

stampHeight = 20;
sz(1) = sz(1)-stampHeight;
scale = pixPerFrame/prod(sz);
if scale<1
    sz = round(sqrt(scale)*sz);
end

mfn = [iPath '_' sprintf('%d_%d_%d',sz(1),sz(2),length(ids)) '.mat'];
if exist(mfn,'file')
    fprintf('loading preshrunk\n')
    tic
    f = load(mfn);
    toc
    
    data = f.data;
    t = f.t;
    trialRecs = f.trialRecs;
    stamps = f.stamps;
    drops = f.drops;
    
    clear f
else
    fprintf('reading from scratch\n')
    % fprintf('requesting %g GB memory\n',length(ids)*prod(sz)*bytesPerPix/1000/1000/1000)
    
    data = zeros(sz(1),sz(2),length(ids),'uint16');
    stamps = zeros(stampHeight,300,length(ids),'uint16');
    
    if doPcoraw
        warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
        t = Tiff(pr,'r');
    else
        if ~any(iPath=='.')
            [d,base] = fileparts(iPath);
        else
            [d,base,tmp] = fileparts(iPath);
            base = [base tmp];
        end
    end
    tic
    for i=1:length(ids) %something in this loop is leaking
        if rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,length(ids),100*i/length(ids))
        end
        if doPcoraw
            frame = t.read();
            % have to use Tiff object (faster anyway) -- imread dies on bigtiffs at high frame numbers with:
            % Error using rtifc
            % TIFF library error - 'TIFFFetchDirectory:  Sanity check on directory count failed, this is probably not a valid IFD offset.'
            
            if i < length(ids)
                cds(i) = t.currentDirectory; %wraps around as a uint16
                t.nextDirectory();
            end
        else
            fn = sprintf('%s_%04d.tif',base,i);
            if ~ismember(fn,{ids.name})
                fn = sprintf('%s_%06d.tif',base,i);
                if ~ismember(fn,{ids.name})
                    error('hmmm')
                end
            end
            frame = imread(fullfile(d,fn));
        end
        switch ndims(frame)
            case 3 %converting pcoraw to rgb tiff, but r,g,b all slightly different?
                if i==1
                    warning('need to fix: why aren''t r,g,b all same?')
                end
                %frame = frame(:,:,1);
                frame = sum(double(frame),3); %documented to sum rgb anywhere?  only thing that makes timestamps work...
                if any(frame(:)>intmax('uint16'))
                    error('hmmm')
                else
                    frame = uint16(frame);
                end
            case 2
                %pass
            otherwise
                error('hmmm')
        end
        data(:,:,i) = imresize(frame((stampHeight+1):end,:),sz); %is imresize smart about unity?  how do our data depend on method?  (we use default 'bicubic' -- "weighted average of local 4x4" (w/antialiasing) -- we can specify kernel if desired)
        stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
    end
    toc
    
    %     figure
    %     plot(diff(cds))
    
    if doPcoraw
        if false
            t.close(); %on huge pcoraw this crashes matlab!
        end
        warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
    end
    
    [t,drops] = readStamps(stamps);
    
    f = load(fullfile(fileparts(bPath),bds.name));
    trialRecs = f.trialRecords;
    
    fprintf('saving...\n')
    tic
    save(mfn,'data','t','trialRecs','stamps','drops','-v7.3') %7.3 required for >2GB vars
    toc
end

fig = figure;
plot(diff(drops)-1)
xlabel('frame')
numDrops = drops(end)-length(ids);
lab = sprintf('%d dropped frames',numDrops);
title(lab)
saveFig(fig,[pre '.drops'],[0 0 500 200]); % [left, bottom, width, height]

if ~all(drops' == 1:length(ids))
    warning(lab)
end

clear ids

d = diff(t');

frameDur = median(d);

%very ad hoc -- is this right?
%takes care of when imaging starts before behavior
%but why do we get that first image then -- shouldn't be triggered til behavior starts?
%eg, jbw03 667-962 and wg02 1-511 have d(1)~70
if d(1)>1.5*frameDur
    d = d(2:end);
    t = t(2:end);
    data = data(:,:,2:end);
end

[bRecs, ledInds] = getTrigTimes({trialRecs.pco});
if any(cellfun(@isempty,bRecs))
    error('bad recs')
end

if false %this method no good
    boundary = 5*frameDur;
    trials = [1 1+find(d>boundary)];
    
    figure
    subplot(2,1,1)
    bins = linspace(0,2,200);
    n = hist(d,bins);
    n = log(n);
    n(isinf(n)) = 0;
    plot(bins,n)
    hold on
    plot(boundary*ones(1,2),[0 max(n)],'r')
    plot(frameDur*ones(1,2),[0 max(n)],'b')
    title(sprintf('%d (imaging) vs. %d (behavior)',length(trials),length(trialRecs)))
    xlabel('secs')
    set(gca,'YTick',[])
    
    subplot(2,1,2)
    hold on
    arrayfun(@(x)plot(x*ones(1,2),[0 boundary],'b'),trials)
    plot(diff([bRecs{:}]),'r','LineWidth',3)
    plot(d)
    ylim([0 boundary])
end


% align the times:  apparently some of the requested exposures recorded in
% the trial records don't wind up getting actually saved as tiffs, so d is
% missing some of what bRecs has...

tol = .2*frameDur; %was .05, but 112612\GCam13TT 858-1085 needs more  %%% was 0.15 but 051914 needed more

reqs = diff([bRecs{:}]);
fixed = nan(1,length(reqs)+1);

bad = false;
current = 1;
for i=1:length(d)
  i
  if current <= length(reqs)
        fixer = 0;
        errRec = [];
      % while i>1 && abs(d(i)-sum(reqs(current+(0:fixer)))) > tol
       while i>1 && (d(i)-sum(reqs(current+(0:fixer)))) > tol
           errRec(end+1) = d(i)-sum(reqs(current+(0:fixer)));
            
            fixer = fixer + 1;
            if current + fixer > length(reqs) % || errRec(end) < -tol  %%% errRec can be greater than tol if frame intervals aren't exactly e.g. 10Hz. This happens during inter-trial intervals, so if a frame is dropped right before inter-trial, you'll get bad. but in fact you want to correct with the next frame. (I believe this is correct ... cmn 05/16/14)
                warning('bad')
                
                figure
                plot([errRec' tol*repmat([1 -1],length(errRec),1)])
                
                bad = true;
                break
            end
        end
        if bad
            break
        end
        current = current + fixer;
        fixed(current) = d(i);
        current = current + 1;
    end
end


fig = figure;
hold on
v = .01;

d = {};
bFrames = {};
frameLeds = {};

% bRnew = {};
% for i = 1:length(bRecs)-1  %%% hacky way to remove last record which is sometimes faulty
%     bRnew{i} = bRecs{i};
% end
% bRecs=bRnew; clear bRnew;

for i = 1:length(bRecs)
    reqs = diff(bRecs{i});
    plot(reqs+v*i,'r','LineWidth',3);
    
    d{i} = fixed(length([bRecs{1:i-1}]) + (1:length(bRecs{i})));
    
    plot(d{i}(1:end-1)+v*i)
    
    if ~isempty(find([abs(reqs-d{i}(1:end-1))>tol false] & ~isnan(d{i}) & ~isnan([nan d{i}(1:end-1)]),1,'first'))
        error('bad')
    end
    
    bFrames{i} =   bRecs{i}(~isnan(d{i}));
    frameLeds{i} = ledInds{i}(~isnan(d{i}));
end
ylim(frameDur + [0 v*1.05*length(bRecs)]);
xlim([0 max([cellfun(@length,bRecs) cellfun(@length,d)])]);
saveFig(fig,[pre '.align'],[0 0 1600 800]); % [left, bottom, width, height]

if bad
    %keyboard
end

if length([bFrames{:}]) > size(data,3) %we probably miss the last one
    error('bad')
end

figure
tmp = [bFrames{:}];
len = min(cellfun(@length,{tmp t}));
plot(diff(tmp(1:len))-diff(t(1:len)')) %no one should be off  by more than .5ms (3 for first), but we get a couple dozen per trial, something about correction/alignment above is wrong?
hold on
plot(find(~ismember([bRecs{:}],tmp)),0,'o','Color',[1 .5 0]) %not quite right -- lines them up by bRecs rather than the smaller bFrames, but shows that the errors are always by camera drops

s = [trialRecs.stimDetails];
f = find(arrayfun(@(x)isempty(x.target),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad targets')
end
targ = sign([s.target]);

% trialRecs.stimDetails should have phase/orientation, (orientedGabors saves it)
% but trail (the ball stimManager) doesn't save details from the stimManager it uses...

s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct];

starts = cell2mat(cellfun(@phaseStarts,{trialRecs.phaseRecords}','UniformOutput',false))';
onsets = starts(2,:);

clear trialRecs

f = find(any(isnan(starts)),1,'first');
if ~isempty(f)
    if f~=length(onsets)
        error('bad nans')
    else
        onsets = onsets(1:end-1);
    end
end

if isempty(goodTrials) || true %heh
    trials = [1 length(onsets)];
else
    trials = goodTrials;
end

trials = trials(1):trials(2);

stoppedWithin = 4; %2
respondedWithin = [0.3 0.6]; %[.4 1]; %1
onlyCorrect = true;
noAfterErrors = false;
worstFactor = .7; %.1  %%%???

afterErrors = [false ~correct(1:end-1)];



misses = cellfun(@setdiff,bRecs,bFrames,'UniformOutput',false);

if length([misses{:}]) ~= 1+numDrops %we gurantee one drop at the end? -- verify this...
    %error('drop calculation error')
        warning('drop calculation error') %%% this can also happen if there was a drop before inter-trial intervals, so one drop = lots of misses
    % Gcam21RT [19 155] 050113 has lots of drops at the end that screw this up -- switch to warning seemed ok but i didn't check carefully
end

worsts = cellfun(@(x)max(diff(x)),bFrames,'UniformOutput',false);
d = diff(cellfun(@isempty,worsts));
f = find(d,1);
if ~isempty(f) && any(d(f+1:end)~=0)
    error('bad bFrames')
end
worsts = cell2mat(worsts);

trials = trials(trials<=length(worsts));

d = diff(starts);
trials = trials( ...
    d(1,trials)<=stoppedWithin              & ...
    d(2,trials)<=respondedWithin(2)         & ...
    d(2,trials)>=respondedWithin(1)         & ...
    (~onlyCorrect | correct(trials))        & ...
    (~noAfterErrors | ~afterErrors(trials)) & ...
    cellfun(@isempty,misses(trials))        & ...
    ...% targ(trials)>0                          & ...
    worsts(trials)<=frameDur*(1+worstFactor)  ...
    );

c = getUniformSpectrum(normalize(onsets));

%pts = [-.8 respondedWithin(1)]; %-1.5*frameDur]; %last frame suspect -- if reinforcement phase ends before exposure does, probably turns led off prematurely
pts = [-0.5 respondedWithin(1)+1.3];
pts = linspace(pts(1),pts(2),1+round(diff(pts)/frameDur));

fig = figure;
hold on
for i = 1:length(trials)
    if any(pts<=bFrames{trials(i)}(end)-onsets(trials(i)))
        plot(pts(pts<=bFrames{trials(i)}(end)-onsets(trials(i))),trials(i),'y+')
    end
end

for i=1:length(onsets)
    if i<=length(bRecs)
        plot(bRecs{i}(ledInds{i} == 1)-onsets(i),i,'g.','MarkerSize',1)
        plot(bRecs{i}(ledInds{i} == 2)-onsets(i),i,'b.','MarkerSize',1)
        if ~isempty(misses{i})
            plot(misses{i}-onsets(i),i,'o','Color',[1 .5 0])
        end
    end
    
    s = starts(:,i)-onsets(i);
    plot(s(1),i,'+','Color',c(i,:))
    
    if targ(i)>0
        cm = 'b';
    else
        cm = 'm';
    end
    plot(s(2),i,[cm '+'])
    
    if correct(i)
        cm = 'g';
    else
        cm = 'r';
    end
    plot(s(3),i,[cm '+'])
end
xlims = [-2 3];
xlim(xlims)
ylabel('trial')
xlabel('secs since discrim onset')
saveFig(fig,[pre '.sync'],[0 0 diff(xlims)*200 length(onsets)*5]); % [left, bottom, width, height]

%keyboard

bFrames   =   bFrames(  1:length(correct));
frameLeds = frameLeds(  1:length(correct));
misses    =    misses(  1:length(correct));
targ      =      targ(  1:length(correct));
starts    =    starts(:,1:length(correct));

%last frame suspect -- if reinforcement phase ends before exposure does, turns led off prematurely
if true
    bad = cumsum(cellfun(@length,bFrames));
    
    bFrames   = cellfun(@(x)x(1:end-1),  bFrames,'UniformOutput',false);
    frameLeds = cellfun(@(x)x(1:end-1),frameLeds,'UniformOutput',false);
    
    data(:,:,bad) = [];
    t(bad) = [];
    
    bad = length([bFrames{:}]);
    data(:,:,bad+1:end) = [];
    t(       bad+1:end) = [];
    
    misses; %ok?
    
    %%% only calculate points up to the shortest response
    if ~isempty(trials)
        pts(pts > min(cellfun(@(x,y)x(end)-y,bFrames(trials),num2cell(onsets(trials))))) = [];
    end
end

leds = {'green' 'blue'};

fprintf('clustering leds...\n')
tic
[ledC, fig] = ledCluster(data);
toc
saveFig(fig,[pre '.led'],[0 0 1000 1000]); % [left, bottom, width, height]

flatLEDs = [frameLeds{:}];
problem = flatLEDs ~= ledC;
if any(problem)
    fig = figure;
    plot(find(problem),ledC(problem),'cx')
    hold on
    plot(find(problem),flatLEDs(problem),'rx')
    title('led problems')
    legend({'cluster','record'})
    xlabel('frame')
    set(gca,'YTick',1:length(leds))
    set(gca,'YTickLabel',leds)
    saveFig(fig,[pre '.led.problems'],[0 0 1000 300]); % [left, bottom, width, height]
end


for ind = 1:length(leds)
  lab=leds{ind}; 
    thisBFrames = cellfun(@(x,y)x(y == ind),bFrames,frameLeds,'UniformOutput',false);
    these = flatLEDs == ind;
    thisData = data(:,:,these);
    thisT = t(these);
    [im{ind} dfof{ind}] = widefieldAnalysis(trials,pts,onsets,thisData,thisT,thisBFrames,[pre '.' lab],c,targ,stoppedWithin,respondedWithin,misses,starts,correct);
end



bg = dfof{2}-dfof{1};
bg_im = im{2}-im{1};
 show(nanmedianMW(bg),pts,[pre 'blue-green dfof'],[1 99],@cb);

  show(deconvg6s((nanmedianMW(bg)),0.1),pts,[pre 'blue-green deconv dfof'],[1 99.5],@cb);
 
% [f p] = uiputfile('*.mat','output file');
 save([iPath(1:end-15) 'behav data.mat'],'bg','bg_im','targ','correct','trials','pts','onsets','starts')




end %%% biAnalysis

function [im dfof]= widefieldAnalysis(trials,pts,onsets,data,t,bFrames,pre,c,targ,stoppedWithin,respondedWithin,misses,starts,correct)
%%% my understanding of parameters (cmn)
%%% trials = trial numbers to use, pts = timepts relatvie to stim onset,
%%% onsets = onset time for stim, data = all image frames, t= frametime
%%% bframes=frametimes for each trial, pre = file prefix, c= colormap,
%%% targ = target side(-1 1),

display('starting widefield analysis')
%keyboard
ptLs = numNice(pts,.01);
pts = repmat(pts,length(trials),1)+repmat(onsets(trials)',1,length(pts));
im = nan([size(pts,1) size(pts,2) size(data,1) size(data,2)]); %trials * t * h * w

b = whos('im');
fprintf('target is %gGB\n',b.bytes/1000/1000/1000)

figure
hold on
plot(t-t(1),'r','LineWidth',3)
bs = [bFrames{:}];
plot(bs-bs(1))

display('making movie')
%%% put movie in here
%%% data = movie; subtract off prctile
%%% add patch of color to indicate phases
%%% use immovie

start = min(find(bs-bs(1)>600));
nframes=min(2000,size(data,3)-start-5);

movdata = zeros(size(data,1),size(data,2),3,nframes);
im_med = prctile(double(data(:,:,start:start+nframes-1)),20,3);
for f = 1:nframes
    f
    for col = 1:3
        movdata(:,:,col,f) = (double(data(:,:,f+start)) - im_med)./im_med;
    end
end

movdata = movdata*3+0.2;
movdata(movdata<0)=0; movdata(movdata>1)=1;

t = bs(start+1:start+nframes);

xpos =1:10; ypos=1:10;
for i = 1:length(bFrames);
    frames = find(t>=starts(1,i) & t<starts(2,i));
    movdata(xpos, ypos,:,frames)=0;
    frames = find(t>=starts(2,i) & t<starts(3,i));
    movdata(xpos,ypos,1:2,frames)=1;
    frames = find(t>=starts(3,i) & t<=bFrames{i}(end));
    if correct(i)
        movdata(xpos,ypos,2,frames)=1;
    else
         movdata(xpos,ypos,1,frames)=1;
    end
end
mov = immovie(movdata);

vid = VideoWriter(sprintf('%sdFoFmovie.avi',pre));
vid.FrameRate=15;
open(vid);
writeVideo(vid,mov);
close(vid)


fig = figure;
h = [];
numPix = 50;
pix = reshape(data,[size(data,1)*size(data,2) size(data,3)]);
[~, ord] = sort(rand(1,size(pix,1)));
h(end+1) = subplot(2,1,1);
hold on
alpha = .5;
ms = [misses{:}];
behaviorKey;
title('grey = stopping; yellow=response period; green = correct; red = error')
    function behaviorKey
        arrayfun(@plotPhases,1:length(bFrames))
        arrayfun(@plotMisses,ms)
    end

%%% grey = stopping phase
%%% yellow = response phase
%%% red = error stim phase
%%% green = correct response phase (but duration=0)

    function plotPhases(tNum)
        fillPhase(starts(1,tNum),starts(2,tNum),[1 1 1]);
        fillPhase(starts(2,tNum),starts(3,tNum),[1 1 0]);
        if correct(tNum)
            tc = [0 1 0];
        else
            tc = [1 0 0];
        end
        fillPhase(starts(3,tNum),bFrames{tNum}(end),tc);
    end

    function fillPhase(start,stop,col)
        if stop>start %drops may cause bFrames to not contain frames after a phase start
            fill(([start start stop stop]-bs(1)),2^16*[0 1 1 0],col,'FaceAlpha',alpha)
        end
    end

    function plotMisses(in)
        plot((in-bs(1))*ones(1,2),[0 2^16],'Color',[1 .5 0])
        % can't have alpha on line, and dominates otherwise
        % fillPhase(in,in+.05,[1 .5 0]);
    end

% plot((bs-bs(1))/60,pix(ord(1:numPix),:)) % this line dies sometimes on 2011b?
% xlabel('mins')
% ylabel('pixel values')
% title('raw')

h(end+1) = subplot(2,1,2);
hold on
behaviorKey;
title('after drops and error stim NOT removed') %both cause spikes
bads = false(size(bs));
for i=1:length(ms)
    bads(find((bs-ms(i))>0,1,'first')) = true;
end
% for i=1:length(correct)
%     if ~correct(i)
%         bads(bs >= starts(3,i) & bs <= bFrames{i}(end)) = true;
%     end
% end

pix = double(pix(ord(1:numPix),:));
pix(:,bads) = nan;
plot((bs-bs(1)),pix)
ylim([0 max(pix(:))])

linkaxes(h,'x');

if false
    subplot(3,1,2)
    title('fit')
    
    subplot(3,1,3)
    title('detrended + scaled')
    saveFig(fig,[pre '.detrend'],[0 0 500 1000]); % [left, bottom, width, height]
else
    saveFig(fig,[pre '.detrend'],[0 0 2000 500]); % [left, bottom, width, height]
end

fprintf('permuting...\n')
tic
data = permute(data,[3 1 2]); %possible oom
toc

fig = figure;
bins = linspace(0,double(intmax('uint16')),1000);
for i=1:length(onsets)
    semilogy(bins,hist(reshape(double(data(i,:,:)),[1 size(data,2)*size(data,3)]),bins),'Color',c(i,:))
    hold on %kills log axis if issued earlier
end
xlim([0 max(bins)])
title('pixel values')

x = .92;
h = .8;
% [left, bottom, width, height]
a = axes('Position',[x (1-h)/2 (1-x)/2 h],'Units','normalized');

hold on
for i=1:length(onsets)
    plot([-1 1],(onsets(i)*ones(1,2)-onsets(1))/60,'Color',c(i,:))
end
title('mins')
ylim([0 (onsets(end)-onsets(1))/60])
set(a,'XTickLabel',[])
set(a,'Box','off')
set(a,'YAxisLocation','right')

saveFig(fig,[pre '.pix'],[0 0 500 500]); % [left, bottom, width, height]
% figure
% nrows = ceil(sqrt(length(trials)));
fprintf('interpolating...\n')
tic
for i=1:length(trials)
    frames = length([bFrames{1:trials(i)-1}]) + (1:length(bFrames{trials(i)}));
    if ~isempty(frames)
        im(i,:,:,:) = interp1(bFrames{trials(i)},double(data(frames,:,:)),pts(i,:));
%         subplot(nrows,nrows,i);
% plot(bFrames{trials(i)},double(data(frames,100,100)),'o');
% hold on
% plot(pts(i,:),im(i,:,100,100));
    elseif i~=length(trials)
        error('huh?')
    end
    fprintf('%g%% done\n',100*i/length(trials));
end


toc
%keyboard
if ~isempty(trials)
    % clear data
    
    %need nanmean from fullfile(matlabroot,'toolbox','stats','stats')
    %but \ratrix\analysis\eflister\phys\new\helpers\ is shadowing it...
    
     show(nanmedianMW(im),ptLs,[pre '.all trials (raw)'],[50 99],@cb);
%     show(nanmedianMW(im(targ(trials)>0,:,:,:)) - nanmedianMW(im(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (raw)'],[1 99],@cb);
%     
%     m = squeeze(nanmedianMW(squeeze(nanmedianMW(im)))); %does this order matter?
%     m = permute(repmat(m,[1 1 size(im,1) size(im,2)]),[3 4 1 2]);
%     dfof = (im-m)./m;
%     
% 
%     
%     clear m
%     %clear im
%     
%     show(nanmedianMW(dfof),ptLs,[pre '.all trials (dF/F)'],[1 99],@cb);
%     show(nanmedianMW(dfof(targ(trials)>0,:,:,:)) - nanmedianMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right (dF/F)'],[1 99],@cb);
%     
        % single baseline (20th percentile)
       % baseline = squeeze(prctile(double(data(round(size(data,1)*0.25):end,:,:)),20));
        
        for tr = 1:size(im,1);
        %%% baseline for each trail
            baseline = squeeze(nanmedianMW(im(tr,ptLs<0,:,:),2));
        for fr = 1:size(im,2)
            dfof(tr,fr,:,:) = (squeeze(im(tr,fr,:,:))-baseline)./baseline;
        end
        end
    
            show(nanmedianMW(dfof),ptLs,[pre '.all trials baseline(dF/F)'],[1 99],@cb);
%     show(nanmedianMW(dfof(targ(trials)>0,:,:,:)) ,ptLs,[pre '.left baseline(dF/F)'],[1 99],@cb);
%      
%     ldecon = deconvg6s(nanmedianMW(dfof(targ(trials)>0,:,:,:)),0.1);
%         show(ldecon ,ptLs,[pre '.left deconv(dF/F)'],[1 99.5],@cb);
% 
%         
%     show( nanmedianMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '. right baseline(dF/F)'],[1 99],@cb);
%  rdecon = deconvg6s(nanmedianMW(dfof(targ(trials)<0,:,:,:)),0.1);
%  
%         show(deconvg6s(nanmedianMW(dfof(targ(trials)<0,:,:,:)),0.1) ,ptLs,[pre '.right deconv(dF/F)'],[1 99.5],@cb);
% 
%     show(nanmedianMW(dfof(targ(trials)>0,:,:,:)) - nanmedianMW(dfof(targ(trials)<0,:,:,:)),ptLs,[pre '.left vs right baseline(dF/F)'],[1 99],@cb);
%         show(ldecon - rdecon,ptLs,[pre '.left vs right decon(dF/F)'],[1 99],@cb);

%     for i = 1:length(trials)
%         figure
%         for a=1:size(im,2)
%             subplot(3,4,a)
%             imagesc(squeeze(dfof(i,a,:,:)),[-0.02 0.02])
%         end
%     end
%     
%     %keyboard
    
end

    function cb(in)
        figure
        
        xb = [max(ptLs(1),-stoppedWithin) min(ptLs(end),respondedWithin(1))];
        
        n = 5;
        subplot(n,1,1)
        plotPix(1:length(onsets),'all');
        
        subplot(n,1,2)
        plotPix(trials,'good',true);
        
        subplot(n,1,3)
        al = plotPix(trials(targ(trials)>0),'good lefts',true); %haven't checkec parity of targ
        
        subplot(n,1,4)
        ar = plotPix(trials(targ(trials)<0),'good rights',true); %haven't checkec parity of targ
        
        subplot(n,1,5)
        hold on
        plot(ptLs,[ar-nanmedianMW(ar,2); al-nanmedianMW(ar,2)]','w','LineWidth',2)
        plot(ptLs,al-ar,'r','LineWidth',2)
        plot(ptLs,zeros(1,length(ptLs)),'Color',.5*ones(1,3),'LineWidth',2)
        xlim(xb)
        
        xlabel('seconds since discrim onset')
        
        
        figure        
        subplot(2,2,1);
        plotdF(1:size(dfof,1),'all');
        
  subplot(2,2,2);
  plotdF(targ(trials)<0,'left');
  
  subplot(2,2,3)
  plotdF(targ(trials)>0,'right');
  
  subplot(2,2,4)
  plot(ptLs,nanmedianMW(dfof(targ(trials)<0,:,in(1,2),in(1,1))),'g'); hold on
   plot(ptLs,nanmedianMW(dfof(targ(trials)>0,:,in(1,2),in(1,1))),'r'); 
   plot(ptLs,nanmedianMW(dfof(targ(trials)<0,:,in(1,2),in(1,1))) - nanmedianMW(dfof(targ(trials)>0,:,in(1,2),in(1,1))),'Linewidth',3); 
  
        function plotdF(which,lab);

           plot(ptLs,dfof(which,:,in(1,2),in(1,1))');
            hold on
            plot(ptLs,nanmedianMW(dfof(which,:,in(1,2),in(1,1))),'LineWidth',3);
            title(lab);
        end
            
        function avg = plotPix(which,lab,doAvg)
            hold on
            arrayfun(@(i)plot(bFrames{i}-onsets(i),data(length([bFrames{1:i-1}])+(1:length(bFrames{i})),in(1,2),in(1,1)),'Color',c(i,:)),which);
            xlim(xb)
            
            if exist('doAvg','var') && doAvg
                avg = nanmedianMW(im(ismember(trials,which),:,in(1,2),in(1,1)));
                plot(ptLs,avg,'w','LineWidth',2)
            end
            
            title(lab)
        end
    end
end

function in = normalize(in)
in = in-min(in);
in = in/max(in);
end

function saveFig(f,fn,pos)
targ = 'C:\Users\nlab\Desktop\analysis';
[status,message,messageid] = mkdir(targ);
if status~=1
    error('bad mkdir')
end

set(f,'PaperPositionMode','auto'); %causes print/saveas to respect figure size
set(f,'InvertHardCopy','off'); %preserves black background when colordef black
set(f,'Position',pos) % [left, bottom, width, height]
saveas(f,fullfile(targ,[fn '.png']));

if false
    dpi=300;
    latest = [fn '.' num2str(dpi) '.' sfx];
    % "When you print to a file, the file name must have fewer than 128 characters, including path name."
    % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/print.html#f30-534567
    print(f,'-dpng',['-r' num2str(dpi)],'-opengl',latest); %opengl for transparency -- probably unnecessary cuz seems to be automatically set when needed
end

if isempty(strfind(fn,'trials')) % these take up half a gig each
    saveas(f,fullfile(targ,[fn '.fig']));
end
end

function out = numNice(in,t)
out = round(in/t)*t;
end

function show(m,pts,s,c,cb)
m = permute(m,[3 4 2 1]);
lims = prctile(m(:),c);
limMax = max(abs(lims));
lims=[-limMax limMax];
if ~any(isnan(lims))
    d = ceil(sqrt(size(m,3)));
    fig = figure;
    for i=1:size(m,3)
        subplot(ceil(size(m,3)/d),d,i)
        x = imagesc(m(:,:,i),lims);
        
        set(x,'ButtonDownFcn',@(x,y)cb(round(get(get(x,'Parent'),'CurrentPoint'))))
        
        xlabel(['t = ' num2str(pts(i)) ' s'])
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        axis equal
        axis tight
    end
    colorbar
    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Visible','off','Units','normalized'); %'Box','off','clipping','off'
    text(0.5, .98, ['\bf ' s], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
    
    s = s(~ismember(s,'|\/<>*?":'));
    % commented save
    %    saveFig(fig,s,[0 0 1920 1200]); % [left, bottom, width, height]
    
    m(m<lims(1))=lims(1);
    m(m>lims(2))=lims(2);
    m = (m-lims(1))./diff(lims);
    writeAVI(m,fullfile('C:\Users\nlab\Desktop\analysis',s));%,fps)
else
    fprintf('bailing on %s, tight trial filter?\n',s)
    %keyboard
end
end

function out = phaseStarts(rec)
try
    r = [rec.responseDetails];
    out = [r.startTime];
catch %only some have totalFrames?  why?
    for i=1:length(rec)
        s =  rec(i).responseDetails.startTime;
        if isempty(s)
            s = nan;
        end
        out(i) = s;
    end
end

% rec.dynamicDetails %contains tracks

%almost same as phaseLabel - just has 'reinforcement' instead of 'reinforced'
labels = {rec.phaseType};
expected = {'pre-request', 'discrim', 'reinforced'};
goods = cellfun(@strcmp,labels,expected);
if ~all(goods)
    e = cellfun(@isempty,labels);
    f = find(e,1,'first');
    if all(e(f:end))
        if length(out)>=f
            if all(isnan(out(f:end)))
                out = out(1:f-1);
            else
                error('bad')
            end
        end
        out = [out nan(1,length(labels)-f+1)];
    else
        rec.phaseType
        error('bad phases')
    end
end

if length(out)~=length(expected)
    error('bad')
end
end

function [a,b] = getTrigTimes(pcos)
out = cellfun(@check,cellfun(@get,pcos,'UniformOutput',false),'UniformOutput',false);

[a, b] = cellfun(@split,out,'UniformOutput',false);

    function [a,b]=split(in)
        a = in(1,:);
        b = in(2,:);
    end

    function out=check(in)
        %[timeWanted busySpins timeTrig ackSpins timeAck ledInd]' x n
        want = [3 6];
        spins = in([2 4],:);
        
        if ~any(isnan(spins(:)))
            out = in(want,:);
        else
            ind = find(any(diff(isnan(spins),[],2)));
            if isscalar(ind) && ~any(any(isnan(spins(:,1:ind)))) && all(all(isnan(spins(:,ind+1:end))))
                out = in(want,1:ind);
            else
                error('bad spins')
            end
        end
    end
end