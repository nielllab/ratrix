run('C:\Documents and Settings\rlab\Desktop\ratrix\analysis\analysisScripts\sampleAnalysisParameters')
subjectID = '257';
%% Rat Number 257
%cellBoundary={'trialRange',[1 2]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[3 6]} % 6X8 binary checkerboard
%:obviously visually modulated.....getting CRFTRF from area.
%==========================================================================
%cellBoundary={'trialRange',[7]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[8 11]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 9::cell visually modulated by TRF..8 onwards
%==========================================================================
%cellBoundary={'trialRange',[12 13]} % orGr: 8 orientations.  waveform: sine.
%:trial 12::oriented gratings...12
%==========================================================================
%cellBoundary={'trialRange',[14 18]} % spatGr: 9 spatFreqs.  waveform: sine.
%:visually modulated
%==========================================================================
%cellBoundary={'trialRange',[19]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[20 26]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[27 32]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 31::getting SF gratings wit lens....31
%==========================================================================
%cellBoundary={'trialRange',[33 34]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 33::TRF 33
%==========================================================================
%cellBoundary={'trialRange',[35 36]} % orGr: 8 orientations.  waveform: sine.
%:visual hash
%==========================================================================
%cellBoundary={'trialRange',[37 53]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 47::visual hash
%==========================================================================
%cellBoundary={'trialRange',[54]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[55 57]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[58 68]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[69]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[70 79]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[80 113]} % 3X4 binary checkerboard
%:trial 105::bursty cell in the bkgd
%==========================================================================
%cellBoundary={'trialRange',[114 127]} % 6X8 binary checkerboard
%:trial 115::6X8 drives cell well...maybe able to get STRF
%==========================================================================
%cellBoundary={'trialRange',[128 129]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[130 131]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 131::added lens and changed height
%==========================================================================
%cellBoundary={'trialRange',[132]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[133 148]} % ffgwn
%:hipp cell
%==========================================================================
%cellBoundary={'trialRange',[149 150]} % orGr: 8 orientations.  waveform: sine.
%:trial 149::i thought cell was not visual...but seems to be modulated by oriented stimuil 
%==========================================================================
%cellBoundary={'trialRange',[151 156]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[157 181]} % 3X4 binary checkerboard
%:trial 171::changed position
%==========================================================================
%cellBoundary={'trialRange',[182 197]} % 6X8 binary checkerboard
%:trial 196::cell goes through multiple states.....fires on some trials...does not do as well on others
%==========================================================================
%cellBoundary={'trialRange',[198 199]} % 12X16 binary checkerboard
%:back again
%==========================================================================
%cellBoundary={'trialRange',[200]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[201 202]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[203 211]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[212]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[213 220]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[221 264]} % 6X8 binary checkerboard
%:trial 252::applied cortical lidocaine....~1% in LRS
%==========================================================================
%cellBoundary={'trialRange',[265 269]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[270 278]} % 3X4 binary checkerboard
%:maybe new cell?
%==========================================================================
%cellBoundary={'trialRange',[279]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[280 286]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[287 313]} % 3X4 binary checkerboard
%:trial 293::LCO was at 10 till now
%==========================================================================
%cellBoundary={'trialRange',[314]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[315 323]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[324 350]} % 3X4 binary checkerboard
%:trial 339::added lidocaine
%==========================================================================
%cellBoundary={'trialRange',[351 361]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[362]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[363 371]} % ffgwn
%:trial 363::lidocaine is washed
%==========================================================================
%cellBoundary={'trialRange',[372 386]} % 3X4 binary checkerboard
%:hipp cell
%==========================================================================
%cellBoundary={'trialRange',[387]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[388 398]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[399 423]} % 3X4 binary checkerboard
%:trial 412::added lidocaine on 411
%==========================================================================
%cellBoundary={'trialRange',[424 436]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[437]} % orGr: 8 orientations.  waveform: sine.
%:trial 437::maybe visual? checking
%==========================================================================
%cellBoundary={'trialRange',[438 454]} % ffgwn
%:large cell and obviously visually modulated
%==========================================================================
%cellBoundary={'trialRange',[455]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[456 466]} % ffgwn
%:trial 460::has too variable firing speed.
%==========================================================================
%cellBoundary={'trialRange',[467 472]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 471::468 and 471 crftrf work well
%==========================================================================
%cellBoundary={'trialRange',[473 474]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 473::473 SF gratings seems to go well
%==========================================================================
%cellBoundary={'trialRange',[475 476]} % orGr: 8 orientations.  waveform: sine.
%:washing out lidocaine
%==========================================================================
%cellBoundary={'trialRange',[477 488]} % ffgwn
%:trial 486::cells seems bursty
%==========================================================================
%cellBoundary={'trialRange',[489 490]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[491 492]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams, ... 
 spikeSortingParams,timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,plottingParams)