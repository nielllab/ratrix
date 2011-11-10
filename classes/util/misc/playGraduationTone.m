function playGraduationTone(subject)
beep;
WaitSecs(.2);
beep;
WaitSecs(.2);
beep;
WaitSecs(1);

[~, stepNum]=getProtocolAndStep(subject);
for i=1:stepNum+1
    beep;
    WaitSecs(.4);
end