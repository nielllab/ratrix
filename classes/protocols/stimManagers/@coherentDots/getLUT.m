function [out s updateSM]=getLUT(s,bits)
if isempty(s.LUT) || s.LUTbits~=bits
    updateSM=true;
    s.LUTbits=bits;
     s=fillLUT(s,'useThisMonitorsUncorrectedGamma');
    % s=fillLUT(s,'linearizedDefault',[0 1],false);
  %  s=fillLUT(s,'hardwiredLinear',[0 1],false);
else
    updateSM=false;
end
out=s.LUT;