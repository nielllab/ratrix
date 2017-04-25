%% widefield Eyes batch

pathname = '\\angie\Angie_analysis\widefield_data';
n=0;


n=n+1;
files(n).expt = '032917_g62ww2-tt';
files(n).dir = '032917_g62ww2-tt_blue_DOI';
%files(n).movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min'
files(n).cfile = 'g62ww2-tt_run1_detection\03_29_17_g62ww2-tt_detection_2lowcontrasts_DOI_eye'
files(n).detection = 'g62ww2-tt_run1_detection\g62ww2-tt_run1_detectimaps';
files(n).dark = '';
files(n).topox = 'g62ww2-tt_run2_topox\g62ww2-tt_run2_topmaps';
files(n).topoy = 'g62ww2-tt_run3_topoy\g62ww2-tt_run3_topmaps';  
files(n).treatment = 'DOI'; 
files(n).notes = 'good data'; 
files(n).misc = ''; 


n=n+1;
files(n).expt = '032917_g62rr2_tt';
files(n).dir = '032917_g62rr2_tt_blue_DOI';
%files(n).movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min'
files(n).cfile = 'g62rr2_tt_run1_detection_doi\03_29_17_g62rr2-tt_detection_2lowcontrasts_DOI_eye'
files(n).detection = 'g62rr2_tt_run1_detection_doi\g62rr2_tt_run1_detection_dmaps';
files(n).topox = 'g62rr2_tt_run2_topox_doi\g62rr2_tt_run2_topox_dmaps';
files(n).topoy = 'g62rr2_tt_run3_topoy_doi\g62rr2_tt_run3_topoy_dmaps';  
files(n).treatment = 'DOI'; 
files(n).notes = 'good data'; 
files(n).misc = ''; 


n=n+1;
files(n).expt = '032017_g62aaa4-tt';
files(n).dir = '032017_g62aaa4-tt_blue';
%files(n).movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min'
files(n).cfile = 'g62aaa4-tt_run1_detection_2contrasts\03_20_17_g62aaa4-tt_detection_eye'
files(n).detection = 'g62aaa4-tt_run1_detection_2contrasts\g62aaa4-tt_run1_detection_2contrasmaps';
files(n).topox = 'g62aaa4-tt_run2_topox\g62aaa4-tt_run2_topmaps';
files(n).topoy = 'g62aaa4-tt_run3_topoy\g62aaa4-tt_run3_topmaps';  
files(n).treatment = 'Saline'; 
files(n).notes = 'good data'; 
files(n).misc = ''; 

n=n+1;
files(n).expt = '022717_g62rr2_tt';
files(n).dir = '022717_g62rr2_tt_blue';
%files(n).movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min'
files(n).cfile = 'g62rr2_tt_run1_detection_2low_contrasts\022717_g62rr2-tt_detection_2lowcontrasts_eye.mat'
files(n).detection = 'g62rr2_tt_run1_detection_2low_contrasts\g62rr2_tt_run1_detection_2low_contrastsmaps';
% files(n).dark = 'g62rr2-tt_run4_darkness\g62rr2-tt_run4_darknessmaps';
files(n).topox = 'g62rr2-tt_run2_topox\g62rr2-tt_run2_topoxmaps';
files(n).topoy = 'g62rr2-tt_run3_topoy\g62rr2-tt_run3_topoymaps';  
files(n).treatment = 'Saline'; 
files(n).notes = 'good data'; 
files(n).misc = ''; 


% for f = 1:length(files); 
%     files(f).blockDark = {files(f).predark files(f).postdark};
% end

