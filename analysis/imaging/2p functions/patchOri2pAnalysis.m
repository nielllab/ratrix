%patchOri2pAnalysis

dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;

orimoviename = 'C:\patchOrientations15min.mat';
%%%info for this movie: contrast=1, phase=random, radius = 20deg, nx/ny=1, sf = 3x, tf= 2x
load(orimoviename);

contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
radiusRange=unique(radius); tfrange=unique(tf); thetarange=unique(theta);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
thetamod = mod(theta,pi)-pi/8;
thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
thetaQuad(1,find(-pi/8<thetamod&thetamod<=pi/8))=1;
thetaQuad(1,find(pi/8<=thetamod&thetamod<=3*pi/8))=2;
thetaQuad(1,find(3*pi/8<=thetamod&thetamod<=5*pi/8))=3;
thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
thetaRange = unique(thetaQuad);
ntrials = min(dt*length(dF)/(isi+duration),length(sf));
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;