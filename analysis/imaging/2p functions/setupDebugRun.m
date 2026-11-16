% setupDebugRun.m — sets up one debugging run of sbxOctoNeural
rng(0)                        % makes the "random cells" figure repeatable
clear Opt

Opt.SaveFigs    = 1;
Opt.psfile      = fullfile(tempdir, 'TempFigs.pdf');
Opt.selectCrop  = 1;
Opt.Resample_dt = 0.1;
Opt.sub_noise   = 1;
Opt.zbinning    = 0;
Opt.nclust      = 5;
Opt.selectPts   = 0;

Opt.fSbx  = '081326_berryi_ASW150E15_000_007.sbx';       Opt.pSbx  = 'D:\projects\2p_functional_imaging\sindbis_gcamp\AAASW150E15\';
Opt.fStim = 'acq7.mat';       Opt.pStim = 'D:\projects\2p_functional_imaging\sindbis_gcamp\AAASW150E15\';