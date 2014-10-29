function obs = gauss_fit( coeff ,x);
%%% this function just defines a gaussian, to be used with nlinfit   

%%% make sure parameters are in a reasonable range
if coeff(3)<0
    coeff(3)=0;
end
if coeff(2)<0
    coeff(2)=0;
end

obs = coeff(1) + coeff(2) * (exp(-0.5*((x-coeff(3))/coeff(4)).^2));