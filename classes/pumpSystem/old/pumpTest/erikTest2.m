function erikTest
clear all;clc;close all;

diameter = 9.65;%4.69; %14.43; % Diameter of syringe barrel in millimeters
rate = 500;%190; %1250%1250; %750; %1250; %1802; % Maximum pumping rate in milliliters/hour
volume = .05; % Volume dispensed per run of pump in milliliters

numReps=100;
numZones=2; %lo is low, hi is high

zones=1+mod(floor(10*rand(1,numReps)),numZones); 
zones = [1 1 1 1    2 1 2 1 2 1 2 1      2 2 2 2      1 2 1 2 1 2 1 2];
volumes = volume*ones(1,length(zones));

verbose=0;
doPumps=1;
volUpdates=1;
doClears=0;
doChecks=0;
doFill=1;
doWithdraws=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parPortAddress='0378';
    valveOff = 0;
    valveOn = 1;

    reservoirValveBit = [5 3];
    toStationsValveBit = [2 6];
    fillRezBit = [7 4];

    rezSensor = [5 2];
    sensorBlocked = '0';

    motorRunningBit = 3;
    motorRunning = '1';

    % Timing Delays in program (in seconds)
    valveDelay = 0.02; %0.05; % How long to wait after changing the valve state
    runDelay = 0.02; %0.15; % waiting to equalize pressure

    % At startup close valves
    for i=1:numZones
        lptwritebit(hex2dec(parPortAddress), reservoirValveBit(i), valveOff);
        lptwritebit(hex2dec(parPortAddress), toStationsValveBit(i), valveOff);
        lptwritebit(hex2dec(parPortAddress), fillRezBit(i), valveOff);
    end    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output={};
numerrs=0;

if diameter<=14.0
    volumes=volumes*1000;
    units='UL';
else
    units='ML';
end

code = ...
    {'*RESET' ...
    sprintf('DIA %.4g ',diameter) ...
    'PHN 1' ...
    'FUN RAT' ...
    sprintf('RAT %d MH',rate) ...
    sprintf('VOL %.4g',volume) ...
    'DIR INF' ...
    'PHN 2' ...
    'FUN STP' ...
    'PHN 3' ...
    'FUN RAT' ...
    sprintf('RAT %d MH',rate) ...
    sprintf('VOL %.4g',volume) ...
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

% Initializing NEPump Serial Communications
s = serial('COM1','BaudRate',19200,'Terminator',{3,'CR'},'Timeout',1.0);
output=addOut(output,{sprintf('Opening Pump Serial Connection\n')});
fopen(s);

try

    % Write NEPump Program through Serial
    output=addOut(output,{sprintf('Writing pump program over serial\n\n')});
    [newOut numerrs]=erikSend(s,code,volume,numerrs,verbose,units);
    output=addOut(output,newOut);

    times=zeros(length(zones),9);

    for i=1:length(zones)

        if doFill
            full=0;
            beeped=0;
            while ~full
                p=dec2bin(lptread(1+hex2dec(parPortAddress)),8);
                if p(rezSensor(zones(i)))==sensorBlocked
                    if ~beeped
                        beep
                        beeped=1;
                        'refilling'
                    end
                    lptwritebit(hex2dec(parPortAddress), fillRezBit(zones(i)), valveOn);
                else
                    lptwritebit(hex2dec(parPortAddress), fillRezBit(zones(i)), valveOff);
                    full=1;
                    if beeped
                        beep
                    end
                end
            end
        end

        %equalize pressure to zone
        lptwritebit(hex2dec(parPortAddress), reservoirValveBit(zones(i)), valveOn);
        WaitSecs(valveDelay);
        pressureEqualizationDelay=.1;
        WaitSecs(pressureEqualizationDelay);
        lptwritebit(hex2dec(parPortAddress), reservoirValveBit(zones(i)), valveOff);
        WaitSecs(valveDelay);


        start=GetSecs();
        rpt = {};
        currT=start;

        if verbose
            output=addOut(output,{sprintf('\n-----------------\ninfusing:\n')});
        end

        lptwritebit(hex2dec(parPortAddress), toStationsValveBit(zones(i)), valveOn);
        WaitSecs(valveDelay);
        times(i,1)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to open destination valve: %g',times(i,1)); currT=GetSecs();

        %WaitSecs(1); % TEMPORARY  %edf: what the hell was this for again?

        r=dec2bin(lptread(1+hex2dec(parPortAddress)),8);
        %p=dec2bin(r,8);
        if r(motorRunningBit)==motorRunning %p(motorRunningBit)==motorRunning
            error('got indication motor running 1')
        end
        if volUpdates
            [newOut numerrs]=erikSend(s,{'PHN 1' sprintf('VOL %.4g',volumes(i)) ...
                ... %'VOL' ...
                ... %'DIR INF' ...
                ... %'DIR' ...
                ... %'PHN 3' sprintf('VOL %.4g',volume) 'VOL' ...
                },volumes(i),numerrs,verbose,units);
            output=addOut(output,newOut);
        end
        if doPumps
            [newOut numerrs]=erikSend(s,{'RUN 1'},volumes(i),numerrs,verbose,units);
            output=addOut(output,newOut);
        end
        times(i,2)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to issue inf command: %g',times(i,2)); currT=GetSecs();



        pumpRunning = 1;
        t=0;
        while pumpRunning
            t=t+1;
            r=lptread(1+hex2dec(parPortAddress));
            p=dec2bin(r,8);
            if (p(motorRunningBit)=='1') ~= bitget(r,6)
                error('mismatch btw erik and dan bitread method 1')
            end
            if p(motorRunningBit)==motorRunning
                pumpRunning=1;
            else
                pumpRunning=0;
            end
        end
        WaitSecs(runDelay);
        times(i,3)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to complete inf: %g',times(i,3)); currT=GetSecs();


        lptwritebit(hex2dec(parPortAddress), toStationsValveBit(zones(i)), valveOff);
        WaitSecs(valveDelay);
        times(i,4)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to close destination valve: %g',times(i,4)); currT=GetSecs();

        if verbose
            output=addOut(output,{sprintf('had to wait %d polls\n',t)});
            output=addOut(output,{sprintf('\nwithdrawing:\n')});
        end


        if doWithdraws

            lptwritebit(hex2dec(parPortAddress), reservoirValveBit(zones(i)), valveOn);
            WaitSecs(valveDelay);
            times(i,5)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to open source valve: %g',times(i,5)); currT=GetSecs();


            r=dec2bin(lptread(1+hex2dec(parPortAddress)),8);
            %p=dec2bin(r,8);
            if p(motorRunningBit)==motorRunning
                error('got indication motor running 2')
            end
            if volUpdates
                [newOut numerrs]=erikSend(s,{ ...%'DIS' 'CLD INF' ...
                    ... %'PHN 1' 'DIR WDR' 'RUN' ...
                    ... %'DIR' 'RUN 1' ...
                    'PHN 3' sprintf('VOL %.4g',volumes(i)) ...
                    },volumes(i),numerrs,verbose,units);
                output=addOut(output,newOut);
            end
            if doPumps
                [newOut numerrs]=erikSend(s,{'RUN 3'},volumes(i),numerrs,verbose,units);
                output=addOut(output,newOut);
            end
            times(i,6)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to issue wdr command: %g',times(i,6)); currT=GetSecs();



            pumpRunning = 1;
            t=0;
            while pumpRunning
                t=t+1;
                r=lptread(1+hex2dec(parPortAddress));
                p=dec2bin(r,8);
                if (p(motorRunningBit)=='1') ~= bitget(r,6)
                    error('mismatch btw erik and dan bitread method 2')
                end
                if p(motorRunningBit)==motorRunning
                    pumpRunning=1;
                else
                    pumpRunning=0;
                end
            end
            WaitSecs(runDelay);
            times(i,7)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to complete wdr: %g',times(i,7)); currT=GetSecs();


            lptwritebit(hex2dec(parPortAddress), reservoirValveBit(zones(i)), valveOff);
            %beep %pressure spike and suction towards reservoir immediately after closing this valve
            WaitSecs(valveDelay);
            times(i,8)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to close source valve: %g',times(i,8)); currT=GetSecs();

            if verbose
                output=addOut(output,{sprintf('had to wait %d polls\n\n',t)});
            end

        else
            beep
            WaitSecs(.2);
        end


        if doChecks && doPumps
            [newOut numerrs]=erikSend(s,{'DIS'},volumes(i),numerrs,verbose,units);
            output=addOut(output,newOut);
            if doClears
                [newOut numerrs]=erikSend(s,{'CLD WDR' 'CLD INF'},volumes(i),numerrs,verbose,units);
                output=addOut(output,newOut);
            end
        end

        times(i,9)=GetSecs()-currT; rpt{end+1}=sprintf('\ntime to do final DIS check: %g',times(i,9)); currT=GetSecs();

        output=addOut(output,rpt);
        output=addOut(output,{sprintf('\ncycle took %g secs\n------------------\n',GetSecs()-start)});


    end

    output=addOut(output,{sprintf('\nClosing Serial Connection\n')});
    fclose(s);

    for i=1:length(output)
        disp(output{i});
    end
    disp(sprintf('\nnum errors: %d\n',numerrs))

    imagesc(times);
    mean(times)
    std(times)
    mean(sum(times'))
    mean(times)./mean(sum(times'))

catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    fclose(s)
end

function s=addOut(s,new)
s(end+1:end+length(new))=new;