
function [linearizedCLUT g]=fitGammaAndReturnLinearized(sent, measured, l_range, sensorRange, gamutRange, colorMapSize,plotOn)
%[linearizedCLUT g]=fitGamma(sent, measured, [0.02 0.2] ,256)
% Finds the best fitting gamma function and then creates a colormap [1 x colorMapSize]
% that produces a linear range of values between l_range min and max where
% 0 = black and 1=the brighest value you measured
    %PARAMETERS
    %sent= the sentValue, like N numbers between 0-255
    %measured= measuredDeviceOutput, like N numbers around 0.005 from the photometer
    %l_range= the linear range of the output that you want to use 
        %[0.02 0.2] is from 2% to 20% of max output
    %colorMapSize=256, unless you have a fancy monitor
%sample from pmm 1/2007, lower left of Trinitron,
    %sent=    [ 0      16     32     48     64     80     96     112    128    144    160   176   192   208   224   240  ];
    %measured=[ 0.0032 0.0035 0.0039 0.0048 0.0064 0.0087 0.0117 0.0157 0.0208 0.0262 0.033 0.042 0.050 0.060 0.072 0.084];
%%sample from IF 6/2001
    %sent=[1 31 61 91 121 151 181 211 241 252];
    %measured=[.3 .9 5.9 17.8 37.8 67.1 106 156 218 255];
    
    
if min(sent)~=0
    warning('should send a 0 for a good darkValue estimate');
end

if ~(max(sent)==colorMapSize || max(sent)==1)
    warning('the brightest value tested may not be the brightest your system makes, thus your requested linear range may be smaller than you think');
end
    
maxSent=max(sent);
maxMeasured=max(measured);
sent = (sent-gamutRange(1))/abs(gamutRange(2) - gamutRange(1));
measured= (measured-sensorRange(1))/abs(sensorRange(2) - sensorRange(1));

%get the best fitting gamma function
%NOTE:  psychtoolbox has a function fit gamma with more options and uses fminuc

%edf wonders about the implications of minimizing error vs. options available in curve fittings toolbox that allow weighting, speedups, noise dependency, etc.
%and if fminbnd isn't a good choice
%note matlab docs say: fminsearch is not the preferred choice for solving problems that are sums of squares
%Instead use the lsqnonlin function, which has been optimized for problems of this form.
%http://www.mathworks.com/access/helpdesk/help/toolbox/optim/ug/fminsearch.html (notes section)

%x is 3 params          %the fit               %measured  %mse
GammaError=@(x) sum((  x(1)*(sent.^x(2))+x(3)  -measured ).^2);
g=[1 2.5 0.05];  %starting estimate
g=fminsearch(GammaError, g);
 
if g(3) > l_range(2)
    error('requested brightest value must be larger than darkValue estimate = g(3)');
end

if g(3) > l_range(1)
    warning('requested dimmest value must be larger than darkValue estimate = g(3), replacing with dimmest possible');
    l_range(1)=g(3)
end

%the range of luminance values desired
Y_desired=linspace(l_range(1), l_range(2), colorMapSize);   %desired device Output

%calculate inverse Gamma
iGamma=@(x)((x-g(3))/g(1)).^(1/g(2));
send_required=iGamma(Y_desired);

if plotOn
    plot([zeros(size(send_required)); send_required], [Y_desired; Y_desired ],'color',[0.7 0.7 0.7]);
    hold on; 
    plot([send_required; send_required], [zeros(size(Y_desired)); Y_desired ],'m');
    plot([0 iGamma(l_range(1))], [l_range(1) l_range(1) ],'r');
    plot([0 iGamma(l_range(2))], [l_range(2) l_range(2) ],'r');
    plot(sent, measured, 'ko', sent, g(1)*(sent.^g(2))+g(3), 'b'); 
    hold off
    title('GammaFit and Linearized CLUT')
    xlabel('Sent Value (normalized)');
    ylabel('Device Output (normalized)');
end

Y_test=g(1)*(send_required.^g(2))+g(3);
MSError=sum((Y_test-Y_desired).^2);
if MSError > 10^-20
    Y_test(end)
    Y_desired(end)
    error('There is a problem with the inverse mapping of Gamma');
   
end

linearizedCLUT=send_required;

%odd thing done by IF2006      
    %Y_vals=linspace(l_range(1)+g(3), l_range(2), 256);   %the gun_values at each lum 
    %step.gun_v=round(spline( g(1)*(sent.^g(2))+g(3), sent, Y_desired)); 

    %temp.pwdir=pwd;ans=inputdlg(pwd, 'Where do you want to save yourcolormap', 1, cellstr(pwd));cell2struct(ans, 'dir',1);
    %cd(ans.dir);
    %clrmap=repmat(gun_v, 3, 2)';
    %clrmap=(clrmap./255)'
    %save clrmap