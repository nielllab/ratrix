function [outv] = downsamplebin(invec,dimnum,amount,usemean)
  %%% courtesy patrick mineault
  %%% http://xcorr.net/2008/03/13/binning-in-matlab-a-one-liner/
  %%% inputs = data, dimension to reduce, bin factor, option to use nanmean (gets rid of nans, but normalizes) 
  sizebefore = size(invec);
    sizemiddle = [sizebefore(1:dimnum-1),amount,sizebefore(dimnum)/amount,sizebefore(dimnum+1:length(sizebefore))];
    sizeafter = sizebefore;
    sizeafter(dimnum) = sizeafter(dimnum)/amount;
   if exist('usemean','var') & usemean==1
       outv = reshape(nanmean(reshape(invec,sizemiddle),dimnum),sizeafter);
   else
       outv = reshape(sum(reshape(invec,sizemiddle),dimnum),sizeafter);
   end