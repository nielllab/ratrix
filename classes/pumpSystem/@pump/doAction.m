function [durs t p]= doAction(p,mlVol,action)

if ~ismember(action,{'reset position','infuse','withdrawl'})
    error('urecognized action')
end

durs=[];
doChecks=0;
%override = strcmp(action,'reset position') && mlVol==0;

if mlVol<=p.mlMaxSinglePump && mlVol>=0 %|| override

    if motorRunning(p)
        error('pump motor running before action (or power cut to pump, which tripped motor running bit)')
        %warning('pump motor running before action')
    else

        %[p.currentPosition p.maxPosition]
        if (strcmp(action,'infuse') && p.currentPosition+mlVol>p.maxPosition) || (strcmp(action,'withdrawl') && p.currentPosition-mlVol<p.minPosition)
            action
            p.currentPosition
            mlVol
            p.maxPosition
            error('request will put pump outside max/min position -- reset pump position first')
            % [durs t p]=doAction(p,0,'reset position'); %can't do this automatically cuz caller needs to know it's going to happen so they can set valves correctly
        end

        %             if strcmp(action,'reset position') && mlVol==0
        %                 fprintf('reseting position\n')
        %                 mlVol=abs(p.currentPosition);
        %                 if p.currentPosition>=0
        %                     action='withdrawl';
        %                 else
        %                     action='infuse';
        %                 end
        %             end

        switch action
            case 'infuse'
                if mlVol>0
                    if infTooFar(p)
                        %                         warning('infuse request while sensor indicates infused too far -- probably flickering sensor with flag right at beam -- trying tiny hysteretic infuse')
                        %                         [p durs]= sendCommands(p,{'PHN 1' sprintf('VOL %.4g',p.volumeScaler*p.mlAntiRock) 'RUN 1'});
                        %                         p.currentPosition=p.currentPosition+p.mlAntiRock;
                        %                         if infTooFar(p)
                        %                             error('hysteretic infuse failed')
                        %                         end
                        error('infuse request while sensor indicates infused too far')
                    end
                    fprintf('infusing\n')
                    [p durs]= sendCommands(p,{'PHN 1' sprintf('VOL %.4g',p.volumeScaler*mlVol) 'RUN 1'});
                    p.currentPosition=p.currentPosition+mlVol;
                end
            case 'withdrawl'
                if mlVol>0
                    if wdrTooFar(p)
                        %                         warning('withdrawl request while sensor indicates withdrawn too far -- probably flickering sensor with flag right at beam -- trying tiny hysteretic withdrawl')
                        %                         [p durs]= sendCommands(p,{'PHN 3' sprintf('VOL %.4g',p.volumeScaler*p.mlAntiRock) 'RUN 3'});
                        %                         p.currentPosition=p.currentPosition-p.mlAntiRock;
                        %                         if wdrTooFar(p)
                        %                             error('hysteretic withdrawl failed')
                        %                         end
                        error('withdrawl reqeust while sensor indicates withdrawn too far')
                    end
                    fprintf('withdrawing\n')
                    [p durs]= sendCommands(p,{'PHN 3' sprintf('VOL %.4g',p.volumeScaler*mlVol) 'RUN 3'});
                    p.currentPosition=p.currentPosition-mlVol;
                end
            case 'reset position'
                %dbstack
                fprintf('reseting position\n')
                tempMin=p.minPosition;
                tempMax=p.maxPosition;
                p.minPosition = -inf;
                p.maxPosition = inf;
                while ~infTooFar(p) && wdrTooFar(p)
                    [durs t p]=doAction(p,getMlOpportunisticRefill(p),'infuse');
                end
                while ~wdrTooFar(p)
                    try
                        [durs t p]=doAction(p,getMlOpportunisticRefill(p),'withdrawl');
                    catch ex
                        if strcmp(ex.message,'withdrawl reqeust while sensor indicates withdrawn too far')
                            break %lack of hysteresis on sensor -- it told us that wdrTooFar was false, but then, without moving, decided wdrTooFar was true -- happens when flag is just breaking the beam
                        else
                            rethrow(ex)
                        end
                    end
                end
                [durs t p]=doAction(p,getMlOpportunisticRefill(p),'infuse');
                while wdrTooFar(p) %added this to avoid the issue of lots of repeated infuse/withdrawl cycles when initing pump
                    [durs t p]=doAction(p,getMlOpportunisticRefill(p),'infuse');
                end
                p.currentPosition=0.0;
                p.minPosition = tempMin;
                p.maxPosition = tempMax;
            otherwise
                error('pump received unknown action')
        end

        start=GetSecs();
        pumpRunning = 1;
        t=0;
        while motorRunning(p)
            t=t+1;
        end
        durs=[durs GetSecs()-start];

        if doChecks
            [p durs]= deal(durs, sendCommands(p,{'DIS' 'CLD WDR' 'CLD INF'}));
        end

        %             if strcmp(action,'reset position') && strcmp(action,'withdrawl')
        %                 [dursTemp tTemp p]= doAction(p,p.mlAntiRock,'infuse');
        %                 durs=[durs dursTemp];
        %                 t=[t tTemp];
        %             end

    end
else
    error('request exceeds mlMaxSinglePump or is negative')
end