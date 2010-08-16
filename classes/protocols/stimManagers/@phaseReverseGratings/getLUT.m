function [out s updateSM]=getLUT(s,bits)
if isempty(s.LUT) || s.LUTbits~=bits
    updateSM=true;
    s.LUTbits=bits;
%     s=fillLUT(s,'useThisMonitorsUncorrectedGamma');  %TEMP - don't commit
%     s=fillLUT(s,'tempLinearRedundantCode');
    s=fillLUT(s,'2009Trinitron255GrayBoxInterpBkgnd.5');
else
    updateSM=false;
end
out=s.LUT;