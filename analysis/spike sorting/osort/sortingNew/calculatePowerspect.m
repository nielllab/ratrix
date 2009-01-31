%
%calculate powerspectrum and autocorrelation
%
function [f,Pxxn,tvect,Cxx] = calculatePowerspect(n)

[f,Pxxn,tvect,Cxx] = psautospk(n,1);%1=binsize
