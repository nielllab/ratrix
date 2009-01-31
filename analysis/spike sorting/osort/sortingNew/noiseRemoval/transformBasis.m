%
%transforms the original waveforms onto an other basis,defined by the
%autocorrelation matrix, such that datapoints are uncorrelated.
%
%covar is the inverse of the covariance matrix
%
%see pouzat et al 2003, J Neurosci methods
%see Kay, vol1, pp 94-95 for pre-whitening
%
%urut/nov04
function [transformedSpikes, back, Rinv] = transformBasis2 ( newSpikesNegative, covar)
[R]=chol(covar);
transformedSpikes = R * newSpikesNegative' ;  %project to new basis

%transformedSpikes = inv(R) * newSpikesNegative' ;  %project to new basis

transformedSpikes=transformedSpikes';

Rinv=(R);

back=transformedSpikes*Rinv;

%transformedSpikes=newSpikesNegative*Tinv;  %project to new basis
%back=transformedSpikes*T;

