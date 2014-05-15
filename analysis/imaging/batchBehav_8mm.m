clear all
close all

pathname = 'G:\compiled behavior\';
datapath = 'd\Widefield (12-10-12+)\data 62713+\';

n=1;
files(n).subj = 'g62c5tt';
files(n).expt = '050914';
files(n).windowsize = '8mm';
files(n).step_binary = '050914 g62c5tt\G62C5-TT_run4_step_binary_50ms_Fstop_8_maps.mat';
files(n).topox =  '050914 g62c5tt\G62C5-TT_run1_2screens(flipped)_topooX_50ms_Fstop_8_maps.mat'; %1 flipped (nasal to temporal)
files(n).topoxreverse =  '050914 g62c5tt\G62C5-TT_run2_2screens(flipped)_topooX_reverse_(temp to nasal)50ms_Fstop_8_maps.mat'; %1 flipped (temporal to nasal)
files(n).topoy = '050914 g62c5tt\G62C5-TT_run2_2screens_topoY_50ms_Fstop_8_maps.mat';
files(n).whisker = '050914 g62c5tt\G62C5-TT_run11_whiskers_50ms_Fstop_8_maps.mat';
%files(n).whisker = '050914 g62c5tt\G62C5-TT_run15_whiskers_50ms_Fstop_8_maps.mat';
files(n).darkness = '050914 g62c5tt\G62C5-TT_run10_darkness_50ms_Fstop_8_maps.mat';
files(n).monitor = '2 screens land';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050914 G62C5-TT 8mm\G62C5-TT_run4_step_binary_50ms_Fstop_8\G62C5-TT_run4_step_binary_50ms_Fstop_8';
files(n).topoxdata =  '050914 G62C5-TT 8mm\G62C5-TT_run1_2screens(flipped)_topooX_50ms_Fstop_8\G62C5-TT_run1_2screens(flipped)_topooX_50ms_Fstop_8';
files(n).topoydata = '050914 G62C5-TT 8mm\G62C5-TT_run3_2screens_topoY_50ms_Fstop_8\G62C5-TT_run2_2screens_topoY_50ms_Fstop_8';
files(n).topoxreversedata = '050914 G62C5-TT 8mm\G62C5-TT_run2_2screens(flipped)_topooX_reverse_(temp to nasal)50ms_Fstop_8\G62C5-TT_run2_2screens(flipped)_topooX_reverse_(temp to nasal)50ms_Fstop_8';
files(n).whiskerdata = '050914 G62C5-TT 8mm\G62C5-TT_run11_whiskers_50ms_Fstop_8\G62C5-TT_run11_whiskers_50ms_Fstop_8';
%files(n).whiskerdata = '050914 G62C5-TT 8mm\G62C5-TT_run15_whiskers_50ms_Fstop_8\G62C5-TT_run15_whiskers_50ms_Fstop_8';
files(n).darknessdata = '050914 G62C5-TT 8mm\G62C5-TT_run10_darkness_50ms_Fstop_8\G62C5-TT_run10_darkness_50ms_Fstop_8';


n=n+1;
files(n).subj = 'g62c5tt';
files(n).expt = '050214';
files(n).windowsize = '8mm';
files(n).step_binary = '050214 g62c5tt\G62C.5-LN_run1_2screens_vert_step_binary_50ms_exp_F8maps.mat';
files(n).topox =  '050214 g62c5tt\G62C.5-LN_run2_2screens_vert_topoX_50ms_exp_F8maps.mat';
files(n).topoy = '050214 g62c5tt\G62C.5-LN_run3_2screens_vert_topoY_50ms_exp_F8maps.mat';
files(n).whisker = '050214 g62c5tt\G62C.5-LN_run8_whisker_50ms_exp_F8maps.mat';
files(n).darkness = '050214 g62c5tt\G62C.5-LN_run12_darkness_50ms_exp_F8maps.mat';
files(n).monitor = '2 screens vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run1_2screens_vert_step_binary_50ms_exp_F8\G62C.5-RN_run1_2screens_vert_step_binary_50ms_exp_F8';
files(n).topoxdata =  '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run2_2screens_vert_topoX_50ms_exp_F8\G62C.5-RN_run2_2screens_vert_topoX_50ms_exp_F8';
files(n).topoydata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run3_2screens_vert_topoY_50ms_exp_F8\G62C.5-RN_run3_2screens_vert_topoY_50ms_exp_F8';
files(n).whiskerdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run8_whisker_50ms_exp_F8\G62C.5-RN_run8_whisker_50ms_exp_F8';
files(n).darknessdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run12_darkness_50ms_exp_F8\G62C.5-LN_run12_darkness_50ms_exp_F8';


n=n+1;
files(n).subj = 'g62c5tt';
files(n).expt = '050214';
files(n).windowsize = '8mm';
files(n).step_binary = '050214 g62c5tt\G62C.5-LN_run4_2screens_landscape_step_binary_50ms_exp_F8maps.mat';
files(n).topox =  '050214 g62c5tt\G62C.5-LN_run5_2screens_landscape_topoX_50ms_exp_F8maps.mat';
files(n).topoy = '050214 g62c5tt\G62C.5-LN_run6_2screens_landscape_topoY_50ms_exp_F8maps.mat';
files(n).whisker = '050214 g62c5tt\G62C.5-LN_run8_whisker_50ms_exp_F8maps.mat';
%files(n).whisker = '050214 g62c5tt\G62C.5-LN_run11_whiskers_50ms_exp_F8maps.mat';
files(n).darkness = '050214 g62c5tt\G62C.5-LN_run12_darkness_50ms_exp_F8maps.mat';
files(n).monitor = '2 screens land';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run4_2screens_landscape_step_binary_50ms_exp_F8\G62C.5-RN_run4_2screens_landscape_step_binary_50ms_exp_F8';
files(n).topoxdata =  '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run5_2screens_landscape_topoX_50ms_exp_F8\G62C.5-RN_run5_2screens_landscape_topoX_50ms_exp_F8';
files(n).topoydata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run6_2screens_landscape_topoY_50ms_exp_F8\G62C.5-RN_run6_2screens_landscape_topoY_50ms_exp_F8';
files(n).whiskerdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run8_whisker_50ms_exp_F8\G62C.5-RN_run8_whisker_50ms_exp_F8';
%files(n).whiskerdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run11_whiskers_50ms_exp_F8\G62C.5-LN_run11_whiskers_50ms_exp_F8';
files(n).darknessdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run12_darkness_50ms_exp_F8\G62C.5-LN_run12_darkness_50ms_exp_F8';

n=n+1;
files(n).subj = 'g62c5rn';
files(n).expt = '050214';
files(n).windowsize = '8mm';
files(n).step_binary = '050214 g62c5rn\G62C.5-RN_run5_2screens_vertical_step_binary_50ms_exp_F5.6maps.mat';
files(n).topox =  '050214 g62c5rn\G62C.5-RN_run6_2screens_vertical_topoX_50ms_exp_F5.6maps.mat';
files(n).topoy = '050214 g62c5rn\G62C.5-RN_run7_2screens_vertical_topoY_50ms_exp_F5.6maps.mat';
files(n).whisker = '050214 g62c5rn\G62C.5-RN_run9_whisker_50ms_exp_F5.6maps.mat';
%files(n).whisker = '050214 g62c5tt\G62C.5-LN_run11_whiskers_50ms_exp_F8maps.mat';
files(n).darkness = '050214 g62c5rn\G62C.5-RN_run8_darkness_50ms_exp_F5.6maps.mat';
files(n).monitor = '2 screens vert'; 
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run5_2screens_vertical_step_binary_50ms_exp_F5.6\G62C.5-RN_run5_2screens_vertical_step_binary_50ms_exp';
files(n).topoxdata =  '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run6_2screens_vertical_topoX_50ms_exp_F5.6\G62C.5-RN_run6_2screens_vertical_topoX_50ms_exp';
files(n).topoydata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run7_2screens_vertical_topoY_50ms_exp_F5.6\G62C.5-RN_run7_2screens_vertical_topoY_50ms_exp';
files(n).whiskerdata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run9_whisker_50ms_exp_F5.6\G62C.5-RN_run9_whisker_50ms_exp';
%files(n).whiskerdata = '050214 Gcamp6 8mm\G62C.5-TT\G62C.5-LN_run11_whiskers_50ms_exp_F8\G62C.5-LN_run11_whiskers_50ms_exp_F8';
files(n).darknessdata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run8_darkness_50ms_exp_F5.6\G62C.5-RN_run8_darkness_50ms_exp';


n=n+1;
files(n).subj = 'g62c5rn';
files(n).expt = '050214';
files(n).windowsize = '8mm';
files(n).step_binary = '050214 g62c5rn\G62C.5-RN_run1_2screens_landscape_step_binary_50ms_exp_F5.6maps.mat';
files(n).topox =  '050214 g62c5rn\G62C.5-RN_run2_2screens_landscape_topoX_50ms_exp_F5.6maps.mat';
files(n).topoy = '050214 g62c5rn\G62C.5-RN_run3_2screens_landscape_topoY_50ms_exp_F5.6maps.mat';
files(n).whisker = '050214 g62c5rn\G62C.5-RN_run9_whisker_50ms_exp_F5.6maps.mat';
files(n).darkness = '050214 g62c5rn\G62C.5-RN_run8_darkness_50ms_exp_F5.6maps.mat';
files(n).monitor = '2 screens land';  %horizontal
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run1_2screens_landscape_step_binary_50ms_exp_F5.6\G62C.5-RN_run1_2screens_landscape_step_binary_50ms_exp';
files(n).topoxdata =  '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run2_2screens_landscape_topoX_50ms_exp_F5.6\G62C.5-RN_run2_2screens_landscape_topoX_50ms_exp';
files(n).topoydata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run3_2screens_landscape_topoY_50ms_exp_F5.6\G62C.5-RN_run3_2screens_landscape_topoY_50ms_exp';
files(n).whiskerdata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run9_whisker_50ms_exp_F5.6\G62C.5-RN_run9_whisker_50ms_exp';
files(n).darknessdata = '050214 Gcamp6 8mm\G62c.5-RN\G62C.5-RN_run8_darkness_50ms_exp_F5.6\G62C.5-RN_run8_darkness_50ms_exp';

n=n+1;
files(n).subj = 'g62h4rn';
files(n).expt = '050114';
files(n).windowsize = '8mm';
files(n).step_binary = '050114 g62h4rn\G62H.4-RN_run1_2screens_vert_step_binary_50ms_exp_F5.6maps.mat';
files(n).topox =  '050114 g62h4rn\G62H.4-RN_run2_2screens_vert_topoX_50ms_exp_F5.6maps.mat';
files(n).topoy = '050114 g62h4rn\G62H.4-RN_run3_2screens_vert_topoY_50ms_exp_F5.6maps.mat';
files(n).whisker = '050114 g62h4rn\G62H.4-RN_run9_whisker_50ms_exp_F5.6maps.mat';
files(n).darkness = '050114 g62h4rn\G62H.4-RN_run13_darkness_50ms_exp_F5.6maps.mat';
files(n).monitor = '2 screens vert'; 
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run1_2screens_vert_step_binary_50ms_exp_F5.6\G62H.4-RN_run1_2screens_vert_step_binary_50ms_exp';
files(n).topoxdata =  '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run2_2screens_vert_topoX_50ms_exp_F5.6\G62H.4-RN_run2_2screens_vert_topoX_50ms_exp';
files(n).topoydata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run3_2screens_vert_topoY_50ms_exp_F5.6\G62H.4-RN_run3_2screens_vert_topoY_50ms_exp';
files(n).whiskerdata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run9_whisker_50ms_exp_F5.6\G62H.4-RN_run9_whisker_50ms_exp';
files(n).darknessdata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run13_darkness_50ms_exp_F5.6\G62H.4-RN_run13_darkness_50ms_exp';

n=n+1;
files(n).subj = 'g62h4rn';
files(n).expt = '050114';
files(n).windowsize = '8mm';
files(n).step_binary = '050114 g62h4rn\G62H.4-RN_run5_2screens_landscape_step_binary_50ms_exp_F5.6maps.mat';
files(n).topox =  '050114 g62h4rn\G62H.4-RN_run6_2screens_landscape_topoX_50ms_exp_F5.6maps.mat';
files(n).topoy = '050114 g62h4rn\G62H.4-RN_run8_2screens_landscape_topoY_50ms_exp_F5.6maps.mat';
files(n).whisker = '050114 g62h4rn\G62H.4-RN_run9_whisker_50ms_exp_F5.6maps.mat';
files(n).darkness = '050114 g62h4rn\G62H.4-RN_run13_darkness_50ms_exp_F5.6maps.mat';
files(n).monitor = '2 screens land'; 
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run5_2screens_landscape_step_binary_50ms_exp_F5.6\G62H.4-RN_run5_2screens_landscape_step_binary_50ms_exp';
files(n).topoxdata =  '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run6_2screens_landscape_topoX_50ms_exp_F5.6\G62H.4-RN_run6_2screens_landscape_topoX_50ms_exp';
files(n).topoydata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run8_2screens_landscape_topoY_50ms_exp_F5.6\G62H.4-RN_run8_2screens_landscape_topoY_50ms_exp';
files(n).whiskerdata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run9_whisker_50ms_exp_F5.6\G62H.4-RN_run9_whisker_50ms_exp';
files(n).darknessdata = '050114 Gcamp6 8mm G62H.4-RN\G62H.4-RN_run13_darkness_50ms_exp_F5.6\G62H.4-RN_run13_darkness_50ms_exp';


% n=n+1;
% files(n).subj = 'g62g1ln';
% files(n).expt = '031914';
% files(n).windowsize = '8mm';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).behav = '';
% files(n).grating = '';
% files(n).loom = '';
% files(n).whisker = '';
% files(n).darkness = '';
% files(n).monitor = '2 screens vert';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session'; %some with blinders %not yet analyzed dfoff
% files(n).step_binarydata = '031914 Gcamp6 8mm blinders\G62G.1-LN_run8_step_binary_2screens_50msexp_F_11\G62G.1-LN_run8_step_binary_2screens_50msexp_F_11';
% files(n).whiskerdata = '031914 Gcamp6 8mm blinders\G62G.1-LN_run5_whiskers_w_blinders_50msexp_F_11\G62G.1-LN_run5_whiskers_w_blinders_50msexp_F_11';
% files(n).darknessdata = '';


n=n+1;
files(n).subj = 'g62g1ln';
files(n).expt = '022814';
files(n).windowsize = '8mm';
files(n).step_binary = '022814 g62g1ln\G62G.1-LN_run5_visual_step_binarymaps.mat';
files(n).topox =  '';
files(n).topoy = '';
files(n).behav = '';
files(n).grating = '';
files(n).loom = '';
files(n).whisker = '022814 g62g1ln\G62G.1-LN_run4_whiskersmaps.mat';
files(n).darkness = '022814 g62g1ln\G62G.1-LN_run3_darkness_2_goodmaps.mat';
files(n).monitor = '2 screens vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '022814 Gcamp6 8mm window aud\G62G.1-LN_run5_visual_step_binary\G62G.1-LN_run5_visual_step_binary';
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).behavdata = '';
files(n).gratingdata = '';
files(n).loomdata = '';
files(n).topoxreversedata = '';
files(n).whiskerdata = '022814 Gcamp6 8mm window aud\G62G.1-LN_run4_whiskers\G62G.1-LN_run4_whiskers';
files(n).darknessdata = '022814 Gcamp6 8mm window aud\G62G.1-LN_run3_darkness_2_good\G62G.1-LN_run3_darkness_2';


n=n+1;
files(n).subj = 'g62g1ln';
files(n).expt = '022414';
files(n).windowsize = '8mm';
files(n).step_binary = '022414 g62g1ln\G62G.1-LN_run1_step_binary_2screens_10Hz_15msexpmaps.mat';
files(n).topox =  '022414 g62g1ln\G62G.1-LN_run2_TopoX_2screens_10Hz_15msexpmaps.mat';
files(n).topoy = '022414 g62g1ln\G62G.1-LN_run4_TopoY_2screens_10Hz_15msexpmaps.mat';
files(n).behav = '';
files(n).grating = '';
files(n).loom = '';
files(n).topoxreverse = '022414 g62g1ln\G62G.1-LN_run3_TopoX_reverse_2screens_10Hz_15msexpmaps.mat';
files(n).whisker = '022414 g62g1ln\G62G.1-LN_run9_whisker_stim_10Hz_3000framemaps.mat';
files(n).baseline_patchx = '022414 g62g1ln\G62G.1-LN_run5_baseline_patchX_2screens_10Hz_15msexpmaps.mat';
files(n).baseline_patchy = '022414 g62g1ln\G62G.1-LN_run6_baseline_patchY_2screens_10Hz_15msexpmaps.mat';
files(n).monitor = '2 screens vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).step_binarydata = '022414 8mm window Gcamp6\G62G.1-LN_run1_step_binary_2screens_10Hz_15msexp\G62G.1-LN_run1_step_binary_2screens_10Hz_15msexp';
files(n).topoxdata =  '022414 8mm window Gcamp6\G62G.1-LN_run2_TopoX_2screens_10Hz_15msexp\G62G.1-LN_run2_TopoX_2screens_10Hz_15msexp';
files(n).topoydata = '022414 8mm window Gcamp6\G62G.1-LN_run4_TopoY_2screens_10Hz_15msexp\G62G.1-LN_run4_TopoY_2screens_10Hz_15msexp';
files(n).behavdata = '';
files(n).gratingdata = '';
files(n).loomdata = '';
files(n).topoxreversedata = '022414 8mm window Gcamp6\G62G.1-LN_run3_TopoX_reverse_2screens_10Hz_15msexp\G62G.1-LN_run3_TopoX_reverse_2screens_10Hz_15msexp';
files(n).whiskerdata = '022414 8mm window Gcamp6\G62G.1-LN_run9_whisker_stim_10Hz_3000frame\G62G.1-LN_run9_whisker_stim_10Hz_3000frame';
files(n).baseline_patchxdata = '022414 8mm window Gcamp6\G62G.1-LN_run5_baseline_patchX_2screens_10Hz_15msexp\G62G.1-LN_run5_baseline_patchX_2screens_10Hz_15msexp';
files(n).baseline_patchydata = '022414 8mm window Gcamp6\G62G.1-LN_run6_baseline_patchY_2screens_10Hz_15msexp\G62G.1-LN_run6_baseline_patchY_2screens_10Hz_15msexp';


% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).windowsize = '8mm';
% files(n).step_binary = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).behav = '';
% files(n).grating = '';
% files(n).loom = '';
% files(n).whisker = '';
% files(n).darkness = '';
% files(n).monitor = '';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).step_binarydata = '';
% files(n).topoxdata =  '';
% files(n).topoydata = '';
% files(n).behavdata = '';
% files(n).gratingdata = '';
% files(n).loomdata = '';
% files(n).topoxreversedata = '';
% files(n).whiskerdata = '';



% %%% batch dfofMovie
% datapathname = '...';
% for f = 1:length(files);
%     try
%         dfofMovie([datapathname files(f).topox]);
%     catch
%         sprintf('could do %s',file(f).topox)
%     end
%     try
%         dfofMovie([datapathname files(f).topoy]);
%     catch
%         sprintf('could do %s',file(f).topoy)
%     end
%     try
%         dfofMovie([datapathname files(f).grating]);
%     catch
%         sprintf('could do %s',file(f).grating)
%     end
%     try
%         dfofMovie([datapathname files(f).loom]);
%     catch
%         sprintf('could do %s',file(f).loom)
%     end
% end
   
outpathname = 'G:\compiled behavior\behavior topos\';


%use = find(strcmp({files.monitor},'vert') & strcmp({files.task},'HvV_center')& strcmp({files.notes},'good imaging session'))
use = 1: length(files)


%%% calculate gradients and regions
for f = 1:length(use)
[map{f} merge{f}]= getRegions(files(use(f)),pathname,outpathname);
end




