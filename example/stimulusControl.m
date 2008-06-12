function stimulusControl(dur)

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath('C:\eflister\Ratrix\Server\'));
warning('on','MATLAB:dispatcher:nameConflict')


format long g

st=station(int8(1),int8([8]),int8([1]),1280,1024,'ptb','parallelPort','C:\eflister\Ratrix\Stations\stimulatorControl\','FFF8',int8(2),int8([]),logical(1));

setValves(st, [1])
disp('starting')
time=GetSecs();
WaitSecs(dur)
time=GetSecs()-time;
setValves(st, [0])
disp(sprintf('gave pulse for %g secs',time))