

%marv noted a strange fluctuation around 5360 in rat 232
d=getSmalls('232')
maxT=max(d.trialNumber);
numBack=300;
ln=diff(find(diff(d.correctResponseIsLeft(~d.correctionTrial==1 & ~isnan(d.correctResponseIsLeft) & d.trialNumber>(maxT-numBack))==-1)));
hist([ln(1:2:end-1); ln(2:2:end)]')
