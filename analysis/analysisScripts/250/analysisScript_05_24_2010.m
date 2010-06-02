run('C:\Documents and Settings\rlab\Desktop\ratrix\analysis\analysisScripts\sampleAnalysisParameters')
subjectID = '250';
%% Rat Number 250
%cellBoundary={'trialRange',[1]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[2]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[3]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[4]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[5]} % ffgwn
%:trial 5::very weakly driven by ffgwn
%==========================================================================
%cellBoundary={'trialRange',[6 11]} % h-bars
%:trial 10::anesth check
%==========================================================================
%cellBoundary={'trialRange',[12 15]} % v-bars
%:trial 14::aperiodic response, not obviously visual
%==========================================================================
%cellBoundary={'trialRange',[16]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[17]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[18]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[19]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[20]} % orGr: 8 orientations.  waveform: sine.
%:cell dies
%==========================================================================
%cellBoundary={'trialRange',[21 22]} % 3X4 binary checkerboard
%:looking for LFP with TRF
%==========================================================================
%cellBoundary={'trialRange',[23]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[24]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[25]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[26]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[27]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[28]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[29]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[30]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[31]} % ffgwn
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[32]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[33]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[34]} % tempGr: 4 tempFreqs.  waveform: sine.
%:last TRF
%==========================================================================
%cellBoundary={'trialRange',[35]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[36]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[37]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 37::going up now:TRF remians on, while going up
%==========================================================================
%cellBoundary={'trialRange',[38]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 38::
%==========================================================================
%cellBoundary={'trialRange',[39]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[40]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 40:::
%==========================================================================
%cellBoundary={'trialRange',[41]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[42]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 42::out of brain
%==========================================================================
%cellBoundary={'trialRange',[43]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[44 46]} % 3X4 binary checkerboard
%:trial 45::a few spikes from 3x4 bin
%==========================================================================
%cellBoundary={'trialRange',[47]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[48]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 48::bandpass temporal
%==========================================================================
%cellBoundary={'trialRange',[49]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[50 58]} % ffgwn
%:trial 58::so so temoral STA... might be bad sort, 2 cells cancel?
%==========================================================================
%cellBoundary={'trialRange',[59 68]} % h-bars
%:trial 59::horiz bars does not drive it well
%==========================================================================
%cellBoundary={'trialRange',[69 83]} % v-bars
%:trial 82::vert bars, might have one localized on the left, across 2 bars
%==========================================================================
%cellBoundary={'trialRange',[84]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[85]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[86]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[87]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[88]} % orGr: 16 orientations.  waveform: square.
%:trial 88::pam comes in, some talking and door opening;   notably, the background mean rate is not stationary, and so we should really be interleaving these orientations in big slow stims
%==========================================================================
%cellBoundary={'trialRange',[89]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[90 134]} % 3X4 binary checkerboard
%:trial 133::background firing went up
%==========================================================================
%cellBoundary={'trialRange',[135 171]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[172]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[173]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[174]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[175]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[176]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[177]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[178]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[179 194]} % ffgwn
%:trial 184::rat obs
%==========================================================================
%cellBoundary={'trialRange',[195 203]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[204]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[205 206]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[207]} % 2X2 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[208 278]} % 6X8 binary checkerboard
%:eye is better and a more stable.   CR is on eye bal, not eyelid.  less breathing artifacts
%==========================================================================
%cellBoundary={'trialRange',[279]} % 3X4 binary checkerboard
%:trial 279::3x4 drives it some, but not that much
%==========================================================================
%cellBoundary={'trialRange',[280]} % orGr: 8 orientations.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 280 and stopTrialNumber 280
%==========================================================================
%cellBoundary={'trialRange',[281]} % No param sweep: with annulus. waveform: sine.
%:trial 281::6x8 also drives it some
%==========================================================================
%cellBoundary={'trialRange',[282]} % No param sweep: with annulus. waveform: sine.
%:going to slighly roate the rat to see if one position drives the cell better
%==========================================================================
%cellBoundary={'trialRange',[283]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 283 and stopTrialNumber 283
%==========================================================================
%cellBoundary={'trialRange',[284]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 284 and stopTrialNumber 284
%==========================================================================
%cellBoundary={'trialRange',[285]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 285 and stopTrialNumber 285
%==========================================================================
%cellBoundary={'trialRange',[286]} % No param sweep: with annulus. waveform: sine.
%:trial 286::orients to find a good driving stim
%==========================================================================
%cellBoundary={'trialRange',[287]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 287 and stopTrialNumber 287
%==========================================================================
%cellBoundary={'trialRange',[288]} % No param sweep: with annulus. waveform: sine.
%:trial 284::effect dodn't take place...?
%==========================================================================
%cellBoundary={'trialRange',[289]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[290]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[291]} % No param sweep: with annulus. waveform: sine.
%:trial 291::set annuli and flanker to have the same center [.35 .65], using bigger targets, and slower
%==========================================================================
%cellBoundary={'trialRange',[292]} % ifFeatureGoRightWithTwoFlank
%:target mask was too small (1/16) and too fast (30 40)
%==========================================================================
%cellBoundary={'trialRange',[293]} % No param sweep: with annulus. waveform: sine.
%:trial 293::eye is good
%==========================================================================
%cellBoundary={'trialRange',[294]} % ifFeatureGoRightWithTwoFlank
%:trial 294::flanker is not driving it, even this big (128 ppc, 1/8 std), going to try broader [256], and closer flanks 3 not 5
%==========================================================================
%cellBoundary={'trialRange',[295]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[296]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 296 and stopTrialNumber 296
%==========================================================================
%cellBoundary={'trialRange',[297]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 297 and stopTrialNumber 297
%==========================================================================
%cellBoundary={'trialRange',[298]} % ifFeatureGoRightWithTwoFlank
%:trial 298::OUT OF MEMORY making full field flankers:back:trial 297::back:cell is still there, and still turns off with annulus
%==========================================================================
%cellBoundary={'trialRange',[299]} % ifFeatureGoRightWithTwoFlank
%:trial 299::gaint stim does not drive well... on a spike o the big white square, going to move right and reduce mean
%==========================================================================
%cellBoundary={'trialRange',[300]} % ifFeatureGoRightWithTwoFlank
%:ff flanker does not dirve it, maybe VERY sparsely
%==========================================================================
%cellBoundary={'trialRange',[301]} % No param sweep: with annulus. waveform: sine.
%:trial 301::okay, now flankers dod not use linear monito, butiuncorrected, and mean background is 0.2
%==========================================================================
%cellBoundary={'trialRange',[302]} % ifFeatureGoRightWithTwoFlank
%:trial 302::fires on a very few of them
%==========================================================================
%cellBoundary={'trialRange',[303]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[304]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[305]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[306]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[307]} % No param sweep: with annulus. waveform: sine.
%:cranked up the contrast really high,  also flankers has a background of 0
%==========================================================================
%cellBoundary={'trialRange',[308]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[309]} % bipartiteField
%==========================================================================
%cellBoundary={'trialRange',[310]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[311]} % spatGr: 7 spatFreqs.  waveform: sine.
%:really high contrast with a mean of 0.5 ff flanker did work to drive it... but back background and med grey did not drive it when in mask
%==========================================================================
%cellBoundary={'trialRange',[312]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[313]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[314]} % bipartiteField
%:tried to turn flankers in circular masks (not gaussian)
%==========================================================================
%cellBoundary={'trialRange',[315]} % bipartiteField %% DO NOT USE THIS IS
%REPEAT OF PREVIOUS TRIAL
%==========================================================================
%cellBoundary={'trialRange',[316]} % No param sweep: with annulus. waveform: sine.
%:trial 316::ran out of memory when making flankers (they are much bigger now)
%==========================================================================
%cellBoundary={'trialRange',[317]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 317 and stopTrialNumber 317
%==========================================================================
%cellBoundary={'trialRange',[318]} % ifFeatureGoRightWithTwoFlank
%:trial 318::at this point am using std 1/4, with circ mask at density of 0.02:mask did not take effect
%==========================================================================
%cellBoundary={'trialRange',[319]} % bipartiteField
%:trial 319::this trial could be analyzed for timing
%==========================================================================
%cellBoundary={'trialRange',[320]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[321]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[322]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[323]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[324]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[325 326]} % 4X6 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[327 332]} % h-bars
%:trial 332::ran some h bars while testing:trying again.. circ mask
%==========================================================================
%cellBoundary={'trialRange',[333]} % ifFeatureGoRightWithTwoFlank
%:trial 333::drops quite a lot of frames... white square drives it
%==========================================================================
%cellBoundary={'trialRange',[334]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 334 and stopTrialNumber 334
%==========================================================================
%cellBoundary={'trialRange',[335 350]} % ffgwn
%:trial 349::did some ffgwn, while debugging circ mask
%==========================================================================
%cellBoundary={'trialRange',[351]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[352]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 352 and stopTrialNumber 352
%==========================================================================
%cellBoundary={'trialRange',[353]} % ifFeatureGoRightWithTwoFlank
%:trial 353::trial 353:
%==========================================================================
%cellBoundary={'trialRange',[354]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[355]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[356]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[357]} % No param sweep: with annulus. waveform: sine.
%:trial 357::this RF does fit inside annulus level 5 ==0.3
%==========================================================================
%cellBoundary={'trialRange',[358]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[359]} % bipartiteField
%:going to make it bigger by changing the mask circle to be the whole patch radius (0.001)
%==========================================================================
%cellBoundary={'trialRange',[360]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[361]} % ifFeatureGoRightWithTwoFlank
%:trial 361::some overlab and funny bussiness inverting
%==========================================================================
%cellBoundary={'trialRange',[362]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[363]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[364]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[365]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 365 and stopTrialNumber 365
%==========================================================================
%cellBoundary={'trialRange',[366]} % ifFeatureGoRightWithTwoFlank
%:trying to center the target on the RF by butting stim on the screen center [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[367]} % ifFeatureGoRightWithTwoFlank
%:trial 367::each flanker is 1/2 way on the screen
%==========================================================================
%cellBoundary={'trialRange',[368]} % ifFeatureGoRightWithTwoFlank
%:trial 368::about 300 drops
%==========================================================================
%cellBoundary={'trialRange',[369]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[370]} % ifFeatureGoRightWithTwoFlank
%:trial 370::why do flanker lack black locations now...?
%==========================================================================
%cellBoundary={'trialRange',[371]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[372]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[373]} % ifFeatureGoRightWithTwoFlank
%:trial 373::anesth check
%==========================================================================
%cellBoundary={'trialRange',[374]} % ifFeatureGoRightWithTwoFlank
%:trial 374::philip is stopping to get fooD and balji is doing grating refracting
%==========================================================================
%cellBoundary={'trialRange',[375]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[376]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[377]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[378]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[379]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[380]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[381]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[382]} % spatGr: 11 spatFreqs.  waveform: sine.
%:trial 382::finished optimizing the spatial frequencies (6:0.5:12). getting a sample data point before changing the power of the eye.
%==========================================================================
%cellBoundary={'trialRange',[383]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[384]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[385]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[386]} % spatGr: 11 spatFreqs.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 386 and stopTrialNumber 386
%==========================================================================
%cellBoundary={'trialRange',[387]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 387::388: -16D lens:387: -16D lens. scratch previous note
%==========================================================================
%cellBoundary={'trialRange',[388]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 388::388: no lens
%==========================================================================
%cellBoundary={'trialRange',[389]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 389::389: +16D lens
%==========================================================================
%cellBoundary={'trialRange',[390]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 390::390: no lens
%==========================================================================
%cellBoundary={'trialRange',[391]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 391::391: -12D lend
%==========================================================================
%cellBoundary={'trialRange',[392]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[393]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 393::392: -8D:393: -6D
%==========================================================================
%cellBoundary={'trialRange',[394]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 394::394: 4D
%==========================================================================
%cellBoundary={'trialRange',[395]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 395::395: -2D
%==========================================================================
%cellBoundary={'trialRange',[396]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[397]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 397::396: -1D:397: +1D
%==========================================================================
%cellBoundary={'trialRange',[398]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[399]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[400]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 400::398: +2D:399: +4D
%==========================================================================
%cellBoundary={'trialRange',[401]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[402]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 402::400: +6D:401: +8D:402: +12D
%==========================================================================
%cellBoundary={'trialRange',[403]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 403::403: +16D
%==========================================================================
%cellBoundary={'trialRange',[404]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[405]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[406]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[407]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[408]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[409]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[410]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[411]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[412]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[413]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[414]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 414::added on a 2 lense (+16 +16)=+32
%==========================================================================
%cellBoundary={'trialRange',[415]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[416]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[417]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 417::going to characterize some basic facts
%==========================================================================
%cellBoundary={'trialRange',[418]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[419 431]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[432 465]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[466]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[467]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[468]} % ifFeatureGoRightWithTwoFlank
%:reduced ppc to 256, flanker in same position, but annulus has moved to thje right
%==========================================================================
%cellBoundary={'trialRange',[469]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[470]} % ifFeatureGoRightWithTwoFlank
%:trial 470::moving the annulus to the right was worse... maybe left is better
%==========================================================================
%cellBoundary={'trialRange',[471]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[472]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[473]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[474]} % orGr: 8 orientations.  waveform: sine.
%:going to try annulus and flanker at [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[475]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[476]} % tempGr: 4 tempFreqs.  waveform: sine.
%:oops, did not refresh db, till now
%==========================================================================
%cellBoundary={'trialRange',[477]} % No param sweep: with annulus. waveform: sine.
%:trial 477::annulus knocks it on its ass almost completely, by .2 def by .3
%==========================================================================
%cellBoundary={'trialRange',[478]} % ifFeatureGoRightWithTwoFlank
%:trial 478::flankers drive it!:256 ppc works!
%==========================================================================
%cellBoundary={'trialRange',[479]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[480]} % ifFeatureGoRightWithTwoFlank
%:trial 480::128 drives it too
%==========================================================================
%cellBoundary={'trialRange',[481]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 481 and stopTrialNumber 481
%==========================================================================
%cellBoundary={'trialRange',[482]} % ifFeatureGoRightWithTwoFlank
%:trial 482::made the target smaller, so we know its in the RF, and the flankers are out of it:back:trial 482:
%==========================================================================
%cellBoundary={'trialRange',[483]} % No param sweep: with annulus. waveform: sine.
%:trial 483::a good confirmation of the annulus blocking it
%==========================================================================
%cellBoundary={'trialRange',[484]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[485]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[486]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[487]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
run('C:\Documents and Settings\rlab\Desktop\ratrix\analysis\analysisScripts\sampleAnalysisParameters')
subjectID = '250';
%% Rat Number 250
%cellBoundary={'trialRange',[1]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[2]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[3]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[4]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[5]} % ffgwn
%:trial 5::very weakly driven by ffgwn
%==========================================================================
%cellBoundary={'trialRange',[6 11]} % h-bars
%:trial 10::anesth check
%==========================================================================
%cellBoundary={'trialRange',[12 15]} % v-bars
%:trial 14::aperiodic response, not obviously visual
%==========================================================================
%cellBoundary={'trialRange',[16]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[17]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[18]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[19]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[20]} % orGr: 8 orientations.  waveform: sine.
%:cell dies
%==========================================================================
%cellBoundary={'trialRange',[21 22]} % 3X4 binary checkerboard
%:looking for LFP with TRF
%==========================================================================
%cellBoundary={'trialRange',[23]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[24]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[25]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[26]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[27]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[28]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[29]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[30]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[31]} % ffgwn
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[32]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[33]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[34]} % tempGr: 4 tempFreqs.  waveform: sine.
%:last TRF
%==========================================================================
%cellBoundary={'trialRange',[35]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[36]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[37]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 37::going up now:TRF remians on, while going up
%==========================================================================
%cellBoundary={'trialRange',[38]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 38::
%==========================================================================
%cellBoundary={'trialRange',[39]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[40]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 40:::
%==========================================================================
%cellBoundary={'trialRange',[41]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[42]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 42::out of brain
%==========================================================================
%cellBoundary={'trialRange',[43]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[44 46]} % 3X4 binary checkerboard
%:trial 45::a few spikes from 3x4 bin
%==========================================================================
%cellBoundary={'trialRange',[47]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[48]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 48::bandpass temporal
%==========================================================================
%cellBoundary={'trialRange',[49]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[50 58]} % ffgwn
%:trial 58::so so temoral STA... might be bad sort, 2 cells cancel?
%==========================================================================
%cellBoundary={'trialRange',[59 68]} % h-bars
%:trial 59::horiz bars does not drive it well
%==========================================================================
%cellBoundary={'trialRange',[69 83]} % v-bars
%:trial 82::vert bars, might have one localized on the left, across 2 bars
%==========================================================================
%cellBoundary={'trialRange',[84]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[85]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[86]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[87]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[88]} % orGr: 16 orientations.  waveform: square.
%:trial 88::pam comes in, some talking and door opening;   notably, the background mean rate is not stationary, and so we should really be interleaving these orientations in big slow stims
%==========================================================================
%cellBoundary={'trialRange',[89]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[90 134]} % 3X4 binary checkerboard
%:trial 133::background firing went up
%==========================================================================
%cellBoundary={'trialRange',[135 171]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[172]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[173]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[174]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[175]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[176]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[177]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[178]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[179 194]} % ffgwn
%:trial 184::rat obs
%==========================================================================
%cellBoundary={'trialRange',[195 203]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[204]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[205 206]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[207]} % 2X2 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[208 278]} % 6X8 binary checkerboard
%:eye is better and a more stable.   CR is on eye bal, not eyelid.  less breathing artifacts
%==========================================================================
%cellBoundary={'trialRange',[279]} % 3X4 binary checkerboard
%:trial 279::3x4 drives it some, but not that much
%==========================================================================
%cellBoundary={'trialRange',[280]} % orGr: 8 orientations.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 280 and stopTrialNumber 280
%==========================================================================
%cellBoundary={'trialRange',[281]} % No param sweep: with annulus. waveform: sine.
%:trial 281::6x8 also drives it some
%==========================================================================
%cellBoundary={'trialRange',[282]} % No param sweep: with annulus. waveform: sine.
%:going to slighly roate the rat to see if one position drives the cell better
%==========================================================================
%cellBoundary={'trialRange',[283]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 283 and stopTrialNumber 283
%==========================================================================
%cellBoundary={'trialRange',[284]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 284 and stopTrialNumber 284
%==========================================================================
%cellBoundary={'trialRange',[285]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 285 and stopTrialNumber 285
%==========================================================================
%cellBoundary={'trialRange',[286]} % No param sweep: with annulus. waveform: sine.
%:trial 286::orients to find a good driving stim
%==========================================================================
%cellBoundary={'trialRange',[287]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 287 and stopTrialNumber 287
%==========================================================================
%cellBoundary={'trialRange',[288]} % No param sweep: with annulus. waveform: sine.
%:trial 284::effect dodn't take place...?
%==========================================================================
%cellBoundary={'trialRange',[289]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[290]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[291]} % No param sweep: with annulus. waveform: sine.
%:trial 291::set annuli and flanker to have the same center [.35 .65], using bigger targets, and slower
%==========================================================================
%cellBoundary={'trialRange',[292]} % ifFeatureGoRightWithTwoFlank
%:target mask was too small (1/16) and too fast (30 40)
%==========================================================================
%cellBoundary={'trialRange',[293]} % No param sweep: with annulus. waveform: sine.
%:trial 293::eye is good
%==========================================================================
%cellBoundary={'trialRange',[294]} % ifFeatureGoRightWithTwoFlank
%:trial 294::flanker is not driving it, even this big (128 ppc, 1/8 std), going to try broader [256], and closer flanks 3 not 5
%==========================================================================
%cellBoundary={'trialRange',[295]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[296]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 296 and stopTrialNumber 296
%==========================================================================
%cellBoundary={'trialRange',[297]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 297 and stopTrialNumber 297
%==========================================================================
%cellBoundary={'trialRange',[298]} % ifFeatureGoRightWithTwoFlank
%:trial 298::OUT OF MEMORY making full field flankers:back:trial 297::back:cell is still there, and still turns off with annulus
%==========================================================================
%cellBoundary={'trialRange',[299]} % ifFeatureGoRightWithTwoFlank
%:trial 299::gaint stim does not drive well... on a spike o the big white square, going to move right and reduce mean
%==========================================================================
%cellBoundary={'trialRange',[300]} % ifFeatureGoRightWithTwoFlank
%:ff flanker does not dirve it, maybe VERY sparsely
%==========================================================================
%cellBoundary={'trialRange',[301]} % No param sweep: with annulus. waveform: sine.
%:trial 301::okay, now flankers dod not use linear monito, butiuncorrected, and mean background is 0.2
%==========================================================================
%cellBoundary={'trialRange',[302]} % ifFeatureGoRightWithTwoFlank
%:trial 302::fires on a very few of them
%==========================================================================
%cellBoundary={'trialRange',[303]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[304]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[305]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[306]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[307]} % No param sweep: with annulus. waveform: sine.
%:cranked up the contrast really high,  also flankers has a background of 0
%==========================================================================
%cellBoundary={'trialRange',[308]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[309]} % bipartiteField
%==========================================================================
%cellBoundary={'trialRange',[310]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[311]} % spatGr: 7 spatFreqs.  waveform: sine.
%:really high contrast with a mean of 0.5 ff flanker did work to drive it... but back background and med grey did not drive it when in mask
%==========================================================================
%cellBoundary={'trialRange',[312]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[313]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[314]} % bipartiteField
%:tried to turn flankers in circular masks (not gaussian)
%==========================================================================
%cellBoundary={'trialRange',[315]} % bipartiteField
%==========================================================================
%cellBoundary={'trialRange',[316]} % No param sweep: with annulus. waveform: sine.
%:trial 316::ran out of memory when making flankers (they are much bigger now)
%==========================================================================
%cellBoundary={'trialRange',[317]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 317 and stopTrialNumber 317
%==========================================================================
%cellBoundary={'trialRange',[318]} % ifFeatureGoRightWithTwoFlank
%:trial 318::at this point am using std 1/4, with circ mask at density of 0.02:mask did not take effect
%==========================================================================
%cellBoundary={'trialRange',[319]} % bipartiteField
%:trial 319::this trial could be analyzed for timing
%==========================================================================
%cellBoundary={'trialRange',[320]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[321]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[322]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[323]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[324]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[325 326]} % 4X6 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[327 332]} % h-bars
%:trial 332::ran some h bars while testing:trying again.. circ mask
%==========================================================================
%cellBoundary={'trialRange',[333]} % ifFeatureGoRightWithTwoFlank
%:trial 333::drops quite a lot of frames... white square drives it
%==========================================================================
%cellBoundary={'trialRange',[334]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 334 and stopTrialNumber 334
%==========================================================================
%cellBoundary={'trialRange',[335 350]} % ffgwn
%:trial 349::did some ffgwn, while debugging circ mask
%==========================================================================
%cellBoundary={'trialRange',[351]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[352]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 352 and stopTrialNumber 352
%==========================================================================
%cellBoundary={'trialRange',[353]} % ifFeatureGoRightWithTwoFlank
%:trial 353::trial 353:
%==========================================================================
%cellBoundary={'trialRange',[354]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[355]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[356]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[357]} % No param sweep: with annulus. waveform: sine.
%:trial 357::this RF does fit inside annulus level 5 ==0.3
%==========================================================================
%cellBoundary={'trialRange',[358]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[359]} % bipartiteField
%:going to make it bigger by changing the mask circle to be the whole patch radius (0.001)
%==========================================================================
%cellBoundary={'trialRange',[360]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[361]} % ifFeatureGoRightWithTwoFlank
%:trial 361::some overlab and funny bussiness inverting
%==========================================================================
%cellBoundary={'trialRange',[362]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[363]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[364]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[365]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 365 and stopTrialNumber 365
%==========================================================================
%cellBoundary={'trialRange',[366]} % ifFeatureGoRightWithTwoFlank
%:trying to center the target on the RF by butting stim on the screen center [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[367]} % ifFeatureGoRightWithTwoFlank
%:trial 367::each flanker is 1/2 way on the screen
%==========================================================================
%cellBoundary={'trialRange',[368]} % ifFeatureGoRightWithTwoFlank
%:trial 368::about 300 drops
%==========================================================================
%cellBoundary={'trialRange',[369]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[370]} % ifFeatureGoRightWithTwoFlank
%:trial 370::why do flanker lack black locations now...?
%==========================================================================
%cellBoundary={'trialRange',[371]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[372]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[373]} % ifFeatureGoRightWithTwoFlank
%:trial 373::anesth check
%==========================================================================
%cellBoundary={'trialRange',[374]} % ifFeatureGoRightWithTwoFlank
%:trial 374::philip is stopping to get fooD and balji is doing grating refracting
%==========================================================================
%cellBoundary={'trialRange',[375]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[376]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[377]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[378]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[379]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[380]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[381]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[382]} % spatGr: 11 spatFreqs.  waveform: sine.
%:trial 382::finished optimizing the spatial frequencies (6:0.5:12). getting a sample data point before changing the power of the eye.
%==========================================================================
%cellBoundary={'trialRange',[383]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[384]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[385]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[386]} % spatGr: 11 spatFreqs.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 386 and stopTrialNumber 386
%==========================================================================
%cellBoundary={'trialRange',[387]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 387::388: -16D lens:387: -16D lens. scratch previous note
%==========================================================================
%cellBoundary={'trialRange',[388]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 388::388: no lens
%==========================================================================
%cellBoundary={'trialRange',[389]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 389::389: +16D lens
%==========================================================================
%cellBoundary={'trialRange',[390]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 390::390: no lens
%==========================================================================
%cellBoundary={'trialRange',[391]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 391::391: -12D lend
%==========================================================================
%cellBoundary={'trialRange',[392]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[393]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 393::392: -8D:393: -6D
%==========================================================================
%cellBoundary={'trialRange',[394]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 394::394: 4D
%==========================================================================
%cellBoundary={'trialRange',[395]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 395::395: -2D
%==========================================================================
%cellBoundary={'trialRange',[396]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[397]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 397::396: -1D:397: +1D
%==========================================================================
%cellBoundary={'trialRange',[398]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[399]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[400]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 400::398: +2D:399: +4D
%==========================================================================
%cellBoundary={'trialRange',[401]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[402]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 402::400: +6D:401: +8D:402: +12D
%==========================================================================
%cellBoundary={'trialRange',[403]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 403::403: +16D
%==========================================================================
%cellBoundary={'trialRange',[404]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[405]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[406]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[407]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[408]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[409]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[410]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[411]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[412]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[413]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[414]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 414::added on a 2 lense (+16 +16)=+32
%==========================================================================
%cellBoundary={'trialRange',[415]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[416]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[417]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 417::going to characterize some basic facts
%==========================================================================
%cellBoundary={'trialRange',[418]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[419 431]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[432 465]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[466]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[467]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[468]} % ifFeatureGoRightWithTwoFlank
%:reduced ppc to 256, flanker in same position, but annulus has moved to thje right
%==========================================================================
%cellBoundary={'trialRange',[469]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[470]} % ifFeatureGoRightWithTwoFlank
%:trial 470::moving the annulus to the right was worse... maybe left is better
%==========================================================================
%cellBoundary={'trialRange',[471]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[472]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[473]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[474]} % orGr: 8 orientations.  waveform: sine.
%:going to try annulus and flanker at [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[475]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[476]} % tempGr: 4 tempFreqs.  waveform: sine.
%:oops, did not refresh db, till now
%==========================================================================
%cellBoundary={'trialRange',[477]} % No param sweep: with annulus. waveform: sine.
%:trial 477::annulus knocks it on its ass almost completely, by .2 def by .3
%==========================================================================
%cellBoundary={'trialRange',[478]} % ifFeatureGoRightWithTwoFlank
%:trial 478::flankers drive it!:256 ppc works!
%==========================================================================
%cellBoundary={'trialRange',[479]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[480]} % ifFeatureGoRightWithTwoFlank
%:trial 480::128 drives it too
%==========================================================================
%cellBoundary={'trialRange',[481]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 481 and stopTrialNumber 481
%==========================================================================
%cellBoundary={'trialRange',[482]} % ifFeatureGoRightWithTwoFlank
%:trial 482::made the target smaller, so we know its in the RF, and the flankers are out of it:back:trial 482:
%==========================================================================
%cellBoundary={'trialRange',[483]} % No param sweep: with annulus. waveform: sine.
%:trial 483::a good confirmation of the annulus blocking it
%==========================================================================
%cellBoundary={'trialRange',[484]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[485]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[486]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[487]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[488]} % ifFeatureGoRightWithTwoFlank
%:trial 488::moving the flankers closer
%==========================================================================
%cellBoundary={'trialRange',[489]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 489 and stopTrialNumber 489
%==========================================================================
%cellBoundary={'trialRange',[490]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 490 and stopTrialNumber 490
%==========================================================================
%cellBoundary={'trialRange',[491]} % ifFeatureGoRightWithTwoFlank
%:trial 491::do we have a duplicate of the data from 489-491...?  if so the earlier one is ciclular mask, and the later one is guassian mask
%==========================================================================
%cellBoundary={'trialRange',[492]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[493]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[494]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[495]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[496]} % ifFeatureGoRightWithTwoFlank
%:trial 496::very weak response with 64ppc
%==========================================================================
%cellBoundary={'trialRange',[497]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[498]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[499]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[500]} % ifFeatureGoRightWithTwoFlank
%:back
%==========================================================================
%cellBoundary={'trialRange',[501]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[502]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[503]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[504]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[505]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[506]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[507]} % ifFeatureGoRightWithTwoFlank
%:cell stop
%==========================================================================
%cellBoundary={'trialRange',[508]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[509]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[510]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[511]} % ifFeatureGoRightWithTwoFlank
%:very weakly driven by ffgwn
%==========================================================================
%cellBoundary={'trialRange',[512]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
run('C:\Documents and Settings\rlab\Desktop\ratrix\analysis\analysisScripts\sampleAnalysisParameters')
subjectID = '250';
%% Rat Number 250
%cellBoundary={'trialRange',[1]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[2]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[3]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[4]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[5]} % ffgwn
%:trial 5::very weakly driven by ffgwn
%==========================================================================
%cellBoundary={'trialRange',[6 11]} % h-bars
%:trial 10::anesth check
%==========================================================================
%cellBoundary={'trialRange',[12 15]} % v-bars
%:trial 14::aperiodic response, not obviously visual
%==========================================================================
%cellBoundary={'trialRange',[16]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[17]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[18]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[19]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[20]} % orGr: 8 orientations.  waveform: sine.
%:cell dies
%==========================================================================
%cellBoundary={'trialRange',[21 22]} % 3X4 binary checkerboard
%:looking for LFP with TRF
%==========================================================================
%cellBoundary={'trialRange',[23]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[24]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[25]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[26]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[27]} % tempGr: 4 tempFreqs.  waveform: sine.
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[28]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[29]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[30]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[31]} % ffgwn
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[32]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[33]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[34]} % tempGr: 4 tempFreqs.  waveform: sine.
%:last TRF
%==========================================================================
%cellBoundary={'trialRange',[35]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[36]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[37]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 37::going up now:TRF remians on, while going up
%==========================================================================
%cellBoundary={'trialRange',[38]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 38::
%==========================================================================
%cellBoundary={'trialRange',[39]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[40]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 40:::
%==========================================================================
%cellBoundary={'trialRange',[41]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[42]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 42::out of brain
%==========================================================================
%cellBoundary={'trialRange',[43]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[44 46]} % 3X4 binary checkerboard
%:trial 45::a few spikes from 3x4 bin
%==========================================================================
%cellBoundary={'trialRange',[47]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[48]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 48::bandpass temporal
%==========================================================================
%cellBoundary={'trialRange',[49]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[50 58]} % ffgwn
%:trial 58::so so temoral STA... might be bad sort, 2 cells cancel?
%==========================================================================
%cellBoundary={'trialRange',[59 68]} % h-bars
%:trial 59::horiz bars does not drive it well
%==========================================================================
%cellBoundary={'trialRange',[69 83]} % v-bars
%:trial 82::vert bars, might have one localized on the left, across 2 bars
%==========================================================================
%cellBoundary={'trialRange',[84]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[85]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[86]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[87]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[88]} % orGr: 16 orientations.  waveform: square.
%:trial 88::pam comes in, some talking and door opening;   notably, the background mean rate is not stationary, and so we should really be interleaving these orientations in big slow stims
%==========================================================================
%cellBoundary={'trialRange',[89]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[90 134]} % 3X4 binary checkerboard
%:trial 133::background firing went up
%==========================================================================
%cellBoundary={'trialRange',[135 171]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[172]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[173]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[174]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[175]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[176]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[177]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[178]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[179 194]} % ffgwn
%:trial 184::rat obs
%==========================================================================
%cellBoundary={'trialRange',[195 203]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[204]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[205 206]} % ffbinwn
%==========================================================================
%cellBoundary={'trialRange',[207]} % 2X2 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[208 278]} % 6X8 binary checkerboard
%:eye is better and a more stable.   CR is on eye bal, not eyelid.  less breathing artifacts
%==========================================================================
%cellBoundary={'trialRange',[279]} % 3X4 binary checkerboard
%:trial 279::3x4 drives it some, but not that much
%==========================================================================
%cellBoundary={'trialRange',[280]} % orGr: 8 orientations.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 280 and stopTrialNumber 280
%==========================================================================
%cellBoundary={'trialRange',[281]} % No param sweep: with annulus. waveform: sine.
%:trial 281::6x8 also drives it some
%==========================================================================
%cellBoundary={'trialRange',[282]} % No param sweep: with annulus. waveform: sine.
%:going to slighly roate the rat to see if one position drives the cell better
%==========================================================================
%cellBoundary={'trialRange',[283]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 283 and stopTrialNumber 283
%==========================================================================
%cellBoundary={'trialRange',[284]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 284 and stopTrialNumber 284
%==========================================================================
%cellBoundary={'trialRange',[285]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 285 and stopTrialNumber 285
%==========================================================================
%cellBoundary={'trialRange',[286]} % No param sweep: with annulus. waveform: sine.
%:trial 286::orients to find a good driving stim
%==========================================================================
%cellBoundary={'trialRange',[287]} % 3X4 binary checkerboard
%:choosing the minimum of the eventNumbers for startTrialNumber 287 and stopTrialNumber 287
%==========================================================================
%cellBoundary={'trialRange',[288]} % No param sweep: with annulus. waveform: sine.
%:trial 284::effect dodn't take place...?
%==========================================================================
%cellBoundary={'trialRange',[289]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[290]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[291]} % No param sweep: with annulus. waveform: sine.
%:trial 291::set annuli and flanker to have the same center [.35 .65], using bigger targets, and slower
%==========================================================================
%cellBoundary={'trialRange',[292]} % ifFeatureGoRightWithTwoFlank
%:target mask was too small (1/16) and too fast (30 40)
%==========================================================================
%cellBoundary={'trialRange',[293]} % No param sweep: with annulus. waveform: sine.
%:trial 293::eye is good
%==========================================================================
%cellBoundary={'trialRange',[294]} % ifFeatureGoRightWithTwoFlank
%:trial 294::flanker is not driving it, even this big (128 ppc, 1/8 std), going to try broader [256], and closer flanks 3 not 5
%==========================================================================
%cellBoundary={'trialRange',[295]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[296]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 296 and stopTrialNumber 296
%==========================================================================
%cellBoundary={'trialRange',[297]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 297 and stopTrialNumber 297
%==========================================================================
%cellBoundary={'trialRange',[298]} % ifFeatureGoRightWithTwoFlank
%:trial 298::OUT OF MEMORY making full field flankers:back:trial 297::back:cell is still there, and still turns off with annulus
%==========================================================================
%cellBoundary={'trialRange',[299]} % ifFeatureGoRightWithTwoFlank
%:trial 299::gaint stim does not drive well... on a spike o the big white square, going to move right and reduce mean
%==========================================================================
%cellBoundary={'trialRange',[300]} % ifFeatureGoRightWithTwoFlank
%:ff flanker does not dirve it, maybe VERY sparsely
%==========================================================================
%cellBoundary={'trialRange',[301]} % No param sweep: with annulus. waveform: sine.
%:trial 301::okay, now flankers dod not use linear monito, butiuncorrected, and mean background is 0.2
%==========================================================================
%cellBoundary={'trialRange',[302]} % ifFeatureGoRightWithTwoFlank
%:trial 302::fires on a very few of them
%==========================================================================
%cellBoundary={'trialRange',[303]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[304]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[305]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[306]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[307]} % No param sweep: with annulus. waveform: sine.
%:cranked up the contrast really high,  also flankers has a background of 0
%==========================================================================
%cellBoundary={'trialRange',[308]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[309]} % bipartiteField
%==========================================================================
%cellBoundary={'trialRange',[310]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[311]} % spatGr: 7 spatFreqs.  waveform: sine.
%:really high contrast with a mean of 0.5 ff flanker did work to drive it... but back background and med grey did not drive it when in mask
%==========================================================================
%cellBoundary={'trialRange',[312]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[313]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[314]} % bipartiteField
%:tried to turn flankers in circular masks (not gaussian)
%==========================================================================
%cellBoundary={'trialRange',[315]} % bipartiteField
%==========================================================================
%cellBoundary={'trialRange',[316]} % No param sweep: with annulus. waveform: sine.
%:trial 316::ran out of memory when making flankers (they are much bigger now)
%==========================================================================
%cellBoundary={'trialRange',[317]} % No param sweep: with annulus. waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 317 and stopTrialNumber 317
%==========================================================================
%cellBoundary={'trialRange',[318]} % ifFeatureGoRightWithTwoFlank
%:trial 318::at this point am using std 1/4, with circ mask at density of 0.02:mask did not take effect
%==========================================================================
%cellBoundary={'trialRange',[319]} % bipartiteField
%:trial 319::this trial could be analyzed for timing
%==========================================================================
%cellBoundary={'trialRange',[320]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[321]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[322]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[323]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[324]} % 3X4 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[325 326]} % 4X6 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[327 332]} % h-bars
%:trial 332::ran some h bars while testing:trying again.. circ mask
%==========================================================================
%cellBoundary={'trialRange',[333]} % ifFeatureGoRightWithTwoFlank
%:trial 333::drops quite a lot of frames... white square drives it
%==========================================================================
%cellBoundary={'trialRange',[334]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 334 and stopTrialNumber 334
%==========================================================================
%cellBoundary={'trialRange',[335 350]} % ffgwn
%:trial 349::did some ffgwn, while debugging circ mask
%==========================================================================
%cellBoundary={'trialRange',[351]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[352]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 352 and stopTrialNumber 352
%==========================================================================
%cellBoundary={'trialRange',[353]} % ifFeatureGoRightWithTwoFlank
%:trial 353::trial 353:
%==========================================================================
%cellBoundary={'trialRange',[354]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[355]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[356]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[357]} % No param sweep: with annulus. waveform: sine.
%:trial 357::this RF does fit inside annulus level 5 ==0.3
%==========================================================================
%cellBoundary={'trialRange',[358]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[359]} % bipartiteField
%:going to make it bigger by changing the mask circle to be the whole patch radius (0.001)
%==========================================================================
%cellBoundary={'trialRange',[360]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[361]} % ifFeatureGoRightWithTwoFlank
%:trial 361::some overlab and funny bussiness inverting
%==========================================================================
%cellBoundary={'trialRange',[362]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[363]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[364]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[365]} % bipartiteField
%:choosing the minimum of the eventNumbers for startTrialNumber 365 and stopTrialNumber 365
%==========================================================================
%cellBoundary={'trialRange',[366]} % ifFeatureGoRightWithTwoFlank
%:trying to center the target on the RF by butting stim on the screen center [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[367]} % ifFeatureGoRightWithTwoFlank
%:trial 367::each flanker is 1/2 way on the screen
%==========================================================================
%cellBoundary={'trialRange',[368]} % ifFeatureGoRightWithTwoFlank
%:trial 368::about 300 drops
%==========================================================================
%cellBoundary={'trialRange',[369]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[370]} % ifFeatureGoRightWithTwoFlank
%:trial 370::why do flanker lack black locations now...?
%==========================================================================
%cellBoundary={'trialRange',[371]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[372]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[373]} % ifFeatureGoRightWithTwoFlank
%:trial 373::anesth check
%==========================================================================
%cellBoundary={'trialRange',[374]} % ifFeatureGoRightWithTwoFlank
%:trial 374::philip is stopping to get fooD and balji is doing grating refracting
%==========================================================================
%cellBoundary={'trialRange',[375]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[376]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[377]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[378]} % spatGr: 7 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[379]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[380]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[381]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[382]} % spatGr: 11 spatFreqs.  waveform: sine.
%:trial 382::finished optimizing the spatial frequencies (6:0.5:12). getting a sample data point before changing the power of the eye.
%==========================================================================
%cellBoundary={'trialRange',[383]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[384]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[385]} % spatGr: 11 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[386]} % spatGr: 11 spatFreqs.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 386 and stopTrialNumber 386
%==========================================================================
%cellBoundary={'trialRange',[387]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 387::388: -16D lens:387: -16D lens. scratch previous note
%==========================================================================
%cellBoundary={'trialRange',[388]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 388::388: no lens
%==========================================================================
%cellBoundary={'trialRange',[389]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 389::389: +16D lens
%==========================================================================
%cellBoundary={'trialRange',[390]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 390::390: no lens
%==========================================================================
%cellBoundary={'trialRange',[391]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 391::391: -12D lend
%==========================================================================
%cellBoundary={'trialRange',[392]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[393]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 393::392: -8D:393: -6D
%==========================================================================
%cellBoundary={'trialRange',[394]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 394::394: 4D
%==========================================================================
%cellBoundary={'trialRange',[395]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 395::395: -2D
%==========================================================================
%cellBoundary={'trialRange',[396]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[397]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 397::396: -1D:397: +1D
%==========================================================================
%cellBoundary={'trialRange',[398]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[399]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[400]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 400::398: +2D:399: +4D
%==========================================================================
%cellBoundary={'trialRange',[401]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[402]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 402::400: +6D:401: +8D:402: +12D
%==========================================================================
%cellBoundary={'trialRange',[403]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 403::403: +16D
%==========================================================================
%cellBoundary={'trialRange',[404]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[405]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[406]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[407]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[408]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[409]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[410]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[411]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[412]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[413]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[414]} % spatGr: 9 spatFreqs.  waveform: sine.
%:trial 414::added on a 2 lense (+16 +16)=+32
%==========================================================================
%cellBoundary={'trialRange',[415]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[416]} % spatGr: 9 spatFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[417]} % tempGr: 4 tempFreqs.  waveform: sine.
%:trial 417::going to characterize some basic facts
%==========================================================================
%cellBoundary={'trialRange',[418]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[419 431]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[432 465]} % 6X8 binary checkerboard
%==========================================================================
%cellBoundary={'trialRange',[466]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[467]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[468]} % ifFeatureGoRightWithTwoFlank
%:reduced ppc to 256, flanker in same position, but annulus has moved to thje right
%==========================================================================
%cellBoundary={'trialRange',[469]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[470]} % ifFeatureGoRightWithTwoFlank
%:trial 470::moving the annulus to the right was worse... maybe left is better
%==========================================================================
%cellBoundary={'trialRange',[471]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[472]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[473]} % orGr: 8 orientations.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[474]} % orGr: 8 orientations.  waveform: sine.
%:going to try annulus and flanker at [.5 .5]
%==========================================================================
%cellBoundary={'trialRange',[475]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[476]} % tempGr: 4 tempFreqs.  waveform: sine.
%:oops, did not refresh db, till now
%==========================================================================
%cellBoundary={'trialRange',[477]} % No param sweep: with annulus. waveform: sine.
%:trial 477::annulus knocks it on its ass almost completely, by .2 def by .3
%==========================================================================
%cellBoundary={'trialRange',[478]} % ifFeatureGoRightWithTwoFlank
%:trial 478::flankers drive it!:256 ppc works!
%==========================================================================
%cellBoundary={'trialRange',[479]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[480]} % ifFeatureGoRightWithTwoFlank
%:trial 480::128 drives it too
%==========================================================================
%cellBoundary={'trialRange',[481]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 481 and stopTrialNumber 481
%==========================================================================
%cellBoundary={'trialRange',[482]} % ifFeatureGoRightWithTwoFlank
%:trial 482::made the target smaller, so we know its in the RF, and the flankers are out of it:back:trial 482:
%==========================================================================
%cellBoundary={'trialRange',[483]} % No param sweep: with annulus. waveform: sine.
%:trial 483::a good confirmation of the annulus blocking it
%==========================================================================
%cellBoundary={'trialRange',[484]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[485]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[486]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[487]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[488]} % ifFeatureGoRightWithTwoFlank
%:trial 488::moving the flankers closer
%==========================================================================
%cellBoundary={'trialRange',[489]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 489 and stopTrialNumber 489
%==========================================================================
%cellBoundary={'trialRange',[490]} % ifFeatureGoRightWithTwoFlank
%:choosing the minimum of the eventNumbers for startTrialNumber 490 and stopTrialNumber 490
%==========================================================================
%cellBoundary={'trialRange',[491]} % ifFeatureGoRightWithTwoFlank
%:trial 491::do we have a duplicate of the data from 489-491...?  if so the earlier one is ciclular mask, and the later one is guassian mask
%==========================================================================
%cellBoundary={'trialRange',[492]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[493]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[494]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[495]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[496]} % ifFeatureGoRightWithTwoFlank
%:trial 496::very weak response with 64ppc
%==========================================================================
%cellBoundary={'trialRange',[497]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[498]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[499]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[500]} % ifFeatureGoRightWithTwoFlank
%:back
%==========================================================================
%cellBoundary={'trialRange',[501]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[502]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[503]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[504]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[505]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[506]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[507]} % ifFeatureGoRightWithTwoFlank
%:cell stop
%==========================================================================
%cellBoundary={'trialRange',[508]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[509]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[510]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[511]} % ifFeatureGoRightWithTwoFlank
%:very weakly driven by ffgwn
%==========================================================================
%cellBoundary={'trialRange',[512]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[513]} % tempGr: 4 tempFreqs.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 513 and stopTrialNumber 513
%==========================================================================
%cellBoundary={'trialRange',[514]} % tempGr: 4 tempFreqs.  waveform: sine.
%:choosing the minimum of the eventNumbers for startTrialNumber 514 and stopTrialNumber 514
%==========================================================================
%cellBoundary={'trialRange',[515 529]} % ffgwn
%:another TRF
%==========================================================================
%cellBoundary={'trialRange',[530]} % ifFeatureGoRightWithTwoFlank
%==========================================================================
%cellBoundary={'trialRange',[531 547]} % ffgwn
%:trial 45::a few spikes from 3x4 bin
%==========================================================================
%cellBoundary={'trialRange',[548 553]} % ffbinwn
%:trial 48::bandpass temporal
%==========================================================================
%cellBoundary={'trialRange',[554 557]} % ffgwn
%:trial 59::horiz bars does not drive it well
%==========================================================================
%cellBoundary={'trialRange',[558 568]} % ffbinwn
%:trial 69::maybe sometihng in h bars STA, but not obvious...
%==========================================================================
%cellBoundary={'trialRange',[569]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[570]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[571]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[572]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[573]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[574]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[575]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[576]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[577]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[578 581]} % ffgwn
%:trial 82::vert bars, might have one localized on the left, across 2 bars
%==========================================================================
%cellBoundary={'trialRange',[582 604]} % ffbinwn
%:trial 91::3x4 binary drives 1-2 hz
%==========================================================================
%cellBoundary={'trialRange',[605 608]} % ffgwn
%:trial 113::stopping trials moving rig.   previous session was all one cell in first config (label 2)
%==========================================================================
%cellBoundary={'trialRange',[609]} % tempGr: 4 tempFreqs.  waveform: sine.
%:restarting some characterization
%==========================================================================
%cellBoundary={'trialRange',[610 633]} % ffbinwn
%:trial 133::background firing went up
%==========================================================================
%cellBoundary={'trialRange',[634]} % No param sweep: with annulus. waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[635]} % complex grating stimulus
%==========================================================================
%cellBoundary={'trialRange',[636]} % orGr: 16 orientations.  waveform: square.
%==========================================================================
%cellBoundary={'trialRange',[637]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[638]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[639]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[640]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[641 649]} % ffgwn
%==========================================================================
%cellBoundary={'trialRange',[650]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[651]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[652]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[653]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[654]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[655]} % tempGr: 4 tempFreqs.  waveform: sine.
%==========================================================================
%cellBoundary={'trialRange',[656 657]} % ffgwn
%==========================================================================
analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams, ... 
 spikeSortingParams,timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,plottingParams)