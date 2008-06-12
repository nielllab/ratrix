function frameChangeTimes=getFrameChangeTimes(t)

A =t.framesTargetOnOff;
B =t.framesFlankerOnOff;


%test
% A=int8([1 6])
% B=int8([2 6]);

frameChangeTimes = unique([A B]);

