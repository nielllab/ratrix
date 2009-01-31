%
%SNR is root mean square divided by std of noise
%
%urut/feb05
function SNR = calcSNR( spike, stdEstimate )
N=size(spike,2);

SNR = norm(spike) / (sqrt(N)*stdEstimate);
