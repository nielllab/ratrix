function [outv] = downsamplebin(invec,dimnum,amount)
  %%% courtesy patrick mineault
  %%% http://xcorr.net/2008/03/13/binning-in-matlab-a-one-liner/
  
  sizebefore = size(invec);
    sizemiddle = [sizebefore(1:dimnum-1),amount,sizebefore(dimnum)/amount,sizebefore(dimnum+1:length(sizebefore))];
    sizeafter = sizebefore;
    sizeafter(dimnum) = sizeafter(dimnum)/amount;
    outv = reshape(sum(reshape(invec,sizemiddle),dimnum),sizeafter);