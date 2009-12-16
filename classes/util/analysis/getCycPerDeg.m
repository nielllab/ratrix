function cycPerDeg=getCycPerDeg(pixPerCyc,monitorDiagInches,monitorRez,distanceToEyeCM)
%this whole calulation assumes sqaurePixel, which is true for FE992 at [1024 768]
%cycPerDeg=getCycPerDeg([4 8 16 32 64 128],17.8,[1024 768],10) % box - to screen tangent
%cycPerDeg=getCycPerDeg([4 8 16 32 64 128],17.8,[1024 768],14) % box - to screen center
%cycPerDeg=getCycPerDeg([4 8 16 32 64 128],17.8,[1024 768],16) % cockpit -to screen tangent
%
% note: these cpd are true when the stimulus is in the center of the
% screen.
% if the stimulus is way to the side, its farther away (up to twice as far
% in a standard box) and the monitor is not tangent, so will have additional
% compression (which is dependant on orienation and screen position) -pmm

cmPerIn = 2.54;

monitorDiagMM = monitorDiagInches * cmPerIn * 10;

mmPerPix = monitorDiagMM*sqrt(1/sum(monitorRez.^2));


%imageSizeCalculatedCm=monitorRez*mmPerPix/10

degPerPix = 2*atand((mmPerPix/2)/(distanceToEyeCM * 10));

cycPerDeg = 1./(degPerPix*pixPerCyc);


%notes: hand measurements and physical settings
% monitor dot pitch
% Dec 2007 pmm
% 
% monitor:FE992
% screen size: (inch)	    14 3/8  x 10 3/4
%                 (cm)	    36.51	x 27.31
% screen image (cm)         36   	x 27
% ptb thinks screen (mm)    360	x 270   %confirmed 2 work(note, had to restart windows)
% resolution (pix)          1024	x 768
% pixels size (mm)          0.3516 x 0.3516
% expected 64 ppc grating   2.25 cm
% measured 64 ppc grating   2.25 +/-0.02 (as good as I can measure! looks perfect)
% size settings:            34, 75
% position settings:        44, 58
% ATI graphics card
% 
% measuring a monitor diagonal with a ruler, we once got 17.4
% however, putting in 17.8 gets us a better fit to to the more accurately
% hand measured values of the horizonal and vertical image