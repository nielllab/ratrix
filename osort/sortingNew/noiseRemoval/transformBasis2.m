%transformBasis2.m
%
%this is the same as transformBasis.m, but it inverts the covariance
%matrix after taking the cholesky factorization. sometimes this seems
%to be numericaly stable whereas transformBasis.m isnt.
%
%
%transforms the original waveforms onto an other basis,defined by the
%autocorrelation matrix, such that datapoints are uncorrelated.
%
%covar is the covariance matrix
%
%see pouzat et al 2003, J Neurosci methods
%see Kay, vol1, pp 94-95 for pre-whitening
%
%urut/nov04
function [transformedSpikes, back, Rinv] = transformBasis ( newSpikesNegative, covar)
R=chol(covar);
%transformedSpikes = R * newSpikesNegative' ;  %project to new basis

transformedSpikes=newSpikesNegative*inv(R);  %project to new basis




Rinv=(R);

back=transformedSpikes*Rinv;

%transformedSpikes=newSpikesNegative*Tinv;  %project to new basis
%back=transformedSpikes*T;

