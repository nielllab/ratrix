function testpumpcomm

pumpSystemPathStr = fileparts(mfilename('fullpath'));
ratrixPathStr = fileparts(fileparts(pumpSystemPathStr));
bootstrapPathStr = fullfile(ratrixPathStr,'bootstrap','');
bootstrapPathStr
addpath(bootstrapPathStr);
setupEnvironment;


% This can test the pump communication with and without end of travel
% sensors
% SCRIPT OPTIONS
NO_SENSORS = true; %
mlVol = 0.020; % 20 microliters to withdrawal and infuse




% Initialize values
pportAddr={'0378','B888'};

p.serialPortAddress='COM1';
p.mmDiameter=9.65;
p.mlPerHour=500.0;
p.doVolChecks=logical(0);
p.motorRunningBit={pportAddr{2},int8(11)};
p.infTooFarBit={pportAddr{1},int8(13)};
p.wdrTooFarBit={pportAddr{1},int8(10)};
p.mlMaxSinglePump=1.0;
p.maxPosition=1.0;
p.mlOpportunisticRefill=0.1;
p.mlAntiRock=0.05;


if p.mmDiameter<=14.0
    p.volumeScaler=1000;
    p.units='UL';
else
    p.units='ML';
    p.volumeScaler=1;
end

p.serialPort=[];
p.pumpOpen=logical(0);
p.currentPosition=0.0;
p.minPosition=0.0;

p.const.motorRunning=int8(1);%'1';

% Do this if only have pump, but no pos sensors
if NO_SENSORS
    % Close serial ports
    closeAllSerials();
    mlDefaultVolume=.5;
    
    pumpProgram = ...
        {'*RESET' ...
        sprintf('DIA %.4g ',p.mmDiameter) ...
        'PHN 1' ...
        'FUN RAT' ...
        sprintf('RAT %d MH',p.mlPerHour) ...
        sprintf('VOL %.4g',p.volumeScaler*mlDefaultVolume) ...
        'DIR INF' ...
        'PHN 2' ...
        'FUN STP' ...
        'PHN 3' ...
        'FUN RAT' ...
        sprintf('RAT %d MH',p.mlPerHour) ...
        sprintf('VOL %.4g',p.volumeScaler*mlDefaultVolume) ...
        'DIR WDR' ...
        'PHN 4' ...
        'FUN STP' ...
        'CLD INF' ...
        'CLD WDR' ...
        'DIS' ...
        'PHN 1' ...
        'VOL' ...
        'PHN 3' ...
        'VOL' ...
        'ROM' ...
        'AL'};

    p.serialPort = serial(p.serialPortAddress,'BaudRate',19200,'Terminator',{3,'CR'},'Timeout',1.0);
    fprintf('opening pump serial connection\n');

   % Open the pump and send the program
    try
        fopen(p.serialPort);
        p.pumpOpen=1;
        [p durs]=sendCommands(p,pumpProgram);
    catch ex
        fprintf('closing serial port due to error\n');
        fclose(p.serialPort);
        rethrow(ex)
    end

    % Try a withdrawal and a close
    % Withdrawal
    [p durs]= sendCommands(p,{'PHN 3' sprintf('VOL %.4g',p.volumeScaler*mlVol) 'RUN 3'});
    pause(0.5);
    % Infuse
    [p durs]= sendCommands(p,{'PHN 1' sprintf('VOL %.4g',p.volumeScaler*mlVol) 'RUN 1'});
    % Close the pump
    if ~p.pumpOpen
        warning('pump not open')
    end
    fprintf('closing pump serial connection\n')
    fclose(p.serialPort);
    p.pumpOpen=0;

    closeAllSerials();
    
% Do this if there are position sensors
else
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

    p = openPump(p);
    %[durs t p ] = doAction(p,ml,'reset position');
    [durs t p ] = doAction(p,mlVol,'withdrawal');
    [durs t p ] = doAction(p,mlVol,'infuse');


    closePump(p);
end

function [p durs]=sendCommands(p,cmds)
showWarnings=true;

if p.pumpOpen
    durs=zeros(1,length(cmds));
    for i=1:length(cmds)
        start=GetSecs();

        successfulSend=false;
        while ~successfulSend
            try
                sprintf('sending %s',cmds{i});
                fprintf(p.serialPort,cmds{i});
                try
                    in=fscanf(p.serialPort);
                    if strcmp(in(2:4),'00A')
                        warning('got pump alarm ''%s'' -- trying resend (not cycling pump)',in)
                    else
                        successfulSend=true;
                    end
                catch
                    warning('pump failure on read!  cycling pump!')
                    p=closePump(p);
                    p=openPump(p);
                end
            catch ex
                warning('pump failure on write!  cycling pump!')
                p=closePump(p);
                p=openPump(p);
                %rethrow(ex)
            end
        end
        durs(i)=GetSecs()-start;
        %in %once this was empty!  figure out why?
        if int8(in(1))==2 && int8(in(end))==3
            in=in(2:end-1);
            switch cmds{i}
                case 'DIS'
                    if strcmp(in(1:3),'00S') && ...
                            ... %(strcmp(in(4:15),sprintf('I%4.3fW%4.3f',volume,volume)) || strcmp(in(4:15),'I0.000W0.000')) && ...
                            strcmp(in(16:17),p.units)
                        if showWarnings
                            warning('unchecked pump response to [%s]: [%s i:%s w:%s %s]',cmds{i},in(1:3),in(5:9),in(11:15),in(16:17))
                        end
                    else
                        error(sprintf('unexpected pump response to [%s]: [%s]',cmds{i},in))
                    end
                case 'VOL'
                    if strcmp(in(1:3),'00S') && strcmp(in(9:10),p.units) %&& strcmp(in(4:8),sprintf('%4.3f',volume))
                        if showWarnings
                            warning('unchecked pump response to [%s]: [%s %s %s]',cmds{i},in(1:3),in(4:8),in(9:10))
                        end
                    else
                        error(sprintf('unexpected pump response to [%s]: [%s]',cmds{i},in))
                    end
                case 'RUN 1'
                    checkStr(in,'00I',cmds{i});
                case 'RUN 3'
                    checkStr(in,'00W',cmds{i});
                case {'ROM' 'AL' 'DIR'}
                    if showWarnings
                        warning(sprintf('unchecked pump response to [%s]: [%s]',cmds{i},in))
                    end
                    %need to fill these in
                otherwise
                    checkStr(in,'00S',cmds{i});
            end
        else
            error('response from pump doesn''t have correct initiator/terminator')
        end
    end
else
    error('pump not open')
end

function checkStr(resp,pred,cause)
if ~strcmp(resp,pred)
    error(sprintf('pump responded to [%s] with [%s], should have responded [%s]',cause,resp,pred))
end

function closeAllSerials()
alreadies=instrfind;
if ~isempty(alreadies)
    fprintf('closing and deleting %d serial ports\n',length(alreadies));
    fclose(alreadies)
    delete(alreadies)
end