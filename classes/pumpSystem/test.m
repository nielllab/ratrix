clear all;clc;close all;format long g;

warning('off','MATLAB:dispatcher:nameConflict')
homedir='C:\Documents and Settings\rlab\Desktop\ratrix\classes\pumpSystem';%'C:\eflister\pumpSystem\';
addpath(genpath(homedir));
rmpath(genpath([homedir 'old\']));
warning('on','MATLAB:dispatcher:nameConflict')

pportAddr={'0378','B888'};

p = pump('COM1',...             %serPortAddr
    9.65,...                    %mmDiam
    500,...                     %mlPerHr
    logical(0),...              %doVolChks
    {pportAddr{2},int8(11)},... %motorRunningBit   %%%WEIRD -- B888's pin 15 is stuck hi???
    {pportAddr{1},int8(13)},... %infTooFarBit
    {pportAddr{1},int8(10)},... %wdrTooFarBit
    1.0,...                     %mlMaxSinglePump
    1.0,...                     %mlMaxPos
    0.1,...                     %mlOpportunisticRefill
    0.05);                      %mlAntiRock

eqDelay=0.3; %seems to be lowest that will work
valveDelay=0.02;

%         rezSensorBit             reservoirValveBit        toStationsValveBit       fillRezValveBit         valveDelay  equalizeDelay
zLow=zone({pportAddr{2},int8(13)}, {pportAddr{1},int8(2)},  {pportAddr{1},int8(4)},  {pportAddr{2},int8(4)}, valveDelay, eqDelay);
zMid=zone({pportAddr{2},int8(12)}, {pportAddr{1},int8(6)},  {pportAddr{1},int8(3)},  {pportAddr{2},int8(3)}, valveDelay, eqDelay);
zHi =zone({pportAddr{2},int8(10)}, {pportAddr{1},int8(5)},  {pportAddr{2},int8(5)},  {pportAddr{2},int8(2)}, valveDelay, eqDelay);

sys=pumpSystem(p,{zLow,zMid,zHi});
%fclose(instrfind); %why did we need this?  failing on []


% try
%     closeAllValves(sys);
%     [p durs]=openPump(p);
%     p=emptyRez(zLow,p);
%     p=closePump(p);
%     closeAllValves(sys);
% catch ex
%     closeAllValves(sys);
%     fprintf('closing pump due to error\n');
%     %p=closePump(p);
%     fclose(instrfind);
%     rethrow(ex)
% end




try
    %sys=doPumps(sys,[1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2],0.02);
    %sys=doPumps(sys,[2],5);
    %sys=doPumps(sys,[],0.015); %.025 looks like the amount to subtract due to rocking

    vol = .015;
    numTests=10;
    
    %keys=num2str([ones(1,numTests) 2*ones(1,numTests) 3*ones(1,numTests)]);
    keys=repmat(num2str([3]),1,numTests);
    %keys=[];
    
    sys=doOpportunisticRefillPumps(sys,vol,keys);
    %sys=doPumps(sys,2*ones(1,500),0.03);
catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    %ex.stack.file
    %ex.stack.line
end



% ZONE		MEANING		BOMB    LINE                PIN
%
% input (status):
% pump		running		botom                       15
% pump		inf too far	top     left lick           13
% pump		wdr too far	top     center lick     	10

% bottom	full		bottom  left lick           13
% middle	full		bottom  right lick          12
% top 		full		bottom  center lick         10


% output (data):
% pump		cond		bottom                      7

% bottom	draw		top     valve 1             2
% middle	draw		top     valve 5             6
% top       draw		bottom  valve 4             5

% bottom	out         top     valve 3             4
% middle	out         top     valve 2             3
% top       out         top     valve 4             5

% bottom	fill		bottom  valve 3             4
% middle    fill		bottom  valve 2             3
% top       fill		bottom  valve 1             2

% valve		unused		bottom  valve 5             6