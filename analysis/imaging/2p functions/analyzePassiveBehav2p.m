function [dFout xpos sf theta phase timepts] = analyzePassiveBehav2p(dF,fname,dt);
xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0;
load (fname)
ntrials= min(dt*length(dF)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dF,onsets,dt,timepts);
timepts = timepts - isi+dt;
