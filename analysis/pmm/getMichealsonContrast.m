function c=getMichealsonContrast(linearizedContrast,min,max)
%converts linearized contrast ([1 x numContrasts])to michealson.  good for patterns like
%gabors.  accounts for dark values that are not zero. units pight to be
%candelas unless you KNOW that normalized 0-->1 has NO light for black=0

%en.wikipedia.org/wiki/Michelson_contrast#Formulas




c=(max-min).*linearizedContrast/(max+min)


% mean=(min+max)/2;
% step=(max-min).*linearizedContrast/2;
% lo=mean-step
% hi=mean+step
% c=(hi-lo)./(hi+lo)