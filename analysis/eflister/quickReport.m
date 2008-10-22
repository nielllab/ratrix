function quickReport
priority(1)
clc
close all

targetDir='C:\Documents and Settings\rlab\Desktop\quickReport';
mkdir(targetDir);

permStores={'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled',...
    '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords',...
    '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords',...
    '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\old style rack 2 records 159-192 08.24.08\compiledRecords'};


% []=balaji
% x=not assigned
% ()=movedTo
%
%         R       O       Y       G       B               V
% 2A      B       B       B       B       [159]           (260)
% 2B      [180]   160     [186]   185x    179             (261)
% 2C      [161]   163     202     203x    204             (262)
%
% 2D
% 2E      B       B       B       B
% 2F
%
% 3A      (178)x   263     264     265x    266(252)        (266)
% 3B      (183)x   189     165     173x    193             255
% 3C      (184)x   190     166     174x    194             256
% 3D      (170)x   191     167     175x    249             257
% 3E      (171)x   (253)   168     176x    250             258
% 3F      (172)x   (254)   177     169x    251             259
%
% 3G                       178     170     252             260
% 3H                       183     171     253             261
% 3I                       184     172     254             262

%special:
%164,185,188,192 headfixed
%175?, 187 tumor sacced
%[159,161,180,186] given to balaji airpuff
%[181x,182x,187x,188x] back from balaji
%[173,174,175,176] dan->balaji, should go to me, 175 tumor sacced?
%[225,226,239,241] males from dan, 241 least far along as of advancment

%         R       O       Y       G       B       V
% 2A      mini    mini    mini    mini    mini    mini     (dots?)
% 2B      smOrien smOrien smOrien XXX     smOrien smOrien  (where looking?)
% 2C      flickr  flickr  flickr  flickr  flickr  flickr   (fullfield gaussian vs. nat)
%
% 3A      flickr  flickr  flickr  flickr  flickr  flickr   (fullfield gaussian vs. nat)
% 3B      block   block   block   block   block   block    (orien w/distractor)
% 3C      cue     cue     cue     cue     cue     cue      (orien w/distractor)
% 3D      XXX     XXX     XXX     XXX     motor   motor    (motor vs. dots?)
% 3E      motor   motor   motor   motor   motor   motor    (motor vs. orien)
% 3F      motor   motor   motor   motor   motor   motor    (motor vs. flicker)

maleXModal={'225' '226' '239' '241'};
headfixed={'185' '188' '164' '192'};

origGoToSide={'202' '203' '204'};
origTubePhys={'161' '160' '163' '159'};
origTubeTrans={'180' '186' '185' '179'};
origBoxTrans={'177' '178' '183' '184'};
origFlicker={'264' '165' '166' '167' '168'};

origXModal={'265' '173' '174' '175' '176' '169' '170' '171' '172'};
femaleXModalDan2Balaji2Me={'173' '174' '176'};

origAttn={'266' '193' '194' '249' '250' '251' '252' '253' '254' '255' '256' '257' '258' '259' '260' '261' '262' '263' '189' '190' '191' '181' '182' '187' '188'};
backFromBalaji={'181' '182' '187' '188'};

rs=unique([maleXModal,headfixed,origGoToSide,origTubePhys,origTubeTrans,origBoxTrans,origFlicker,origXModal,femaleXModalDan2Balaji2Me,origAttn,backFromBalaji]);

% newrs={};
% for i=1:length(rs)
%     if str2num(rs{i})>=225
%     newrs{end+1}=rs{i};
%     end
% end
% rs=newrs;

for g=1:length(rs)
    rats=rs(g);
    tr={};
    for i=1:length(rats)
        fprintf('\ndoing subject %s\n',rats{i});
        found=false;
        for j=1:length(permStores)
            d=dir(fullfile(permStores{j},[rats{i} '.compiledTrialRecords.1-*.mat']));
            switch length(d)
                case 0
                    %nothing
                case 1
                    found=true;
                    fprintf('found a compiled file in %s\n',permStores{j});
                    t=load(fullfile(permStores{j},d(1).name));
                    t=t.compiledTrialRecords;
                    if length(tr)>=i && ~isempty(tr{i})
                        if ~isempty(intersect(t.date,[tr{i}.date]))
                            figure
                            plot([tr{i}.date],'r')
                            hold on
                            plot((1:length(t.date))+length(tr{i}),t.date,'b')
                            error('got overlaps')
                        end
                    end
                    fields={'date','step','response','correct','correctionTrial','didStochasticResponse', 'containedForcedRewards','didHumanResponse'};
                    missing={fields{~ismember(fields,fieldnames(t))}};
                    for k=1:length(missing)
                        switch missing{k}
                            case {'didStochasticResponse','containedForcedRewards','didHumanResponse'}
                                t.(missing{k})=zeros(1,length(t.date));
                                fprintf('\tmissing: %s\n',missing{k});
                            otherwise
                                error('mising required field')
                        end
                    end

                    %                 t=struct('date',num2cell(t.date),...
                    %                     'step',num2cell(t.step),...
                    %                     'response',num2cell(t.response),...
                    %                     'correct',num2cell(t.correct),...
                    %                     'correctionTrial',num2cell(t.correctionTrial),...
                    %                     'didStochasticResponse',num2cell(t.didStochasticResponse),...
                    %                     'containedForcedRewards',num2cell(t.containedForcedRewards),...
                    %                     'didHumanResponse',num2cell(t.didHumanResponse)...
                    %                     );
                    tc={};
                    for k=1:length(fields)
                        tc(:,k)=num2cell(double(t.(fields{k}))); %if don't cast to double, later things like [tr{i}.correctionTrial] take forever if of mixed type (ie logical, double)
                        fprintf('\tdoing %s (%s)\n',fields{k},class(t.(fields{k})));
                    end
                    t=cell2struct(tc,fields,2);
                    if length(tr)<i || length(tr{i})==0
                        tr{i}=t; %matlab sucks, shouldn't be necessary to special case this
                    else
                        tr{i}(end+1:end+length(t))=t;
                    end
                otherwise
                    permStores{j}
                    error('multiple files in one permstore')
            end
        end
        if found
            %    plot([tr{i}.date],[tr{i}.step],'x')
            [garbage order]=sort([tr{i}.date]);
            tr{i}=tr{i}(order);
            %plot([tr{i}.response])
            
            if any([tr{i}.step]<=0)
                warning('found step<=0')
                m=min([tr{i}.step]);
                steps=arrayfun(@(x)x.step-m+1,tr{i});
                
                for p=1:length(tr{i})
                    tr{i}(p).step=steps(p); %how do this vectorized?
                end
                
                %setfield(tr{i},'step',steps);
                %[tr{i}.step]=[tr{i}.step]-min([tr{i}.step])+1;
            end
        else
            warning('none found')
        end
    end
    plotSummary(rats,targetDir,tr);
end
end

function plotSummary(ids,targetDir,tr)
close all
numPlots=3;
conn=dbConn;
for i=1:length(ids)
    [weights dates thresholds] = getBodyWeightHistory(conn,ids{i});
    %thresholds=.85*thresholds;
    figure(i)
    subplot(2,numPlots,1+[0 1]*numPlots)
    plot(dates,[weights thresholds]);
    fixDateAxis(dates);
    s=getSubject(conn,ids{i});
    ylabel('grams')
    str=['rat ' ids{i} ' (' s.owner ' ' s.gender ' ' sprintf('%02.1f',(datenum(now)-s.dob)/30.5) ' months old)'];
    title(str)

    if ~isempty(tr) && ~isempty(tr{i})
        subplot(2,numPlots,2)

        ds=[tr{i}.date];
        dates=floor(min(ds)):ceil(max(ds));
        numSteps=max([tr{i}.step]);
        summary=zeros(length(dates),numSteps);
        oddLabels={'correction trials', 'stochastic', 'keybaord', 'forced', 'bad response'};
        odds=zeros(length(dates),length(oddLabels));
        corrects=zeros(1,length(dates));
        rights=corrects;
        total=corrects;

        a1=[tr{i}.response]>0;
        a2=~[tr{i}.correctionTrial]; %takes forever when i>1 if correctionTrial is of mixed type (logical and double)
        a3=[tr{i}.didHumanResponse];
        if any(isnan(a3))
            warning('got a nan for didhumanresponse')
            a3(isnan(a3))=0;
        end
        a3=~a3;
        goods=a1&a2&a3;

        a4=[tr{i}.didStochasticResponse];
        a5=[tr{i}.containedForcedRewards];

        for j=1:length(dates)
            drg=ds>=dates(j) & ds<dates(j)+1; %bizarre - this was super slow if ds wasn't cached
            if any(drg)
                odds(j,1)=sum(~a2 & drg);
                odds(j,2)=sum(a4 & drg);
                odds(j,3)=sum(~a3 & drg);
                odds(j,4)=sum(a5 & drg);
                odds(j,5)=sum(~a1 & drg);
            end

            inds=drg & goods;
            if any(inds)
                summary(j,1:numSteps) = accumarray([tr{i}(inds).step]',1,[numSteps 1]);
            end
            total(j)=sum(inds);
            corrects(j)=sum([tr{i}(inds).correct]);
            rights(j)=sum([tr{i}(inds).response]==3);
        end
        bar(dates,summary,'stacked')
        fixDateAxis(dates);
        strs={};
        for j=1:numSteps
            strs{j}=sprintf('step %d',j);
        end
        legend(strs);
        title({'good trials','no crtnTrls,kbd,bad rspns'});

        subplot(2,numPlots,5)

        bar(dates,odds,'stacked')
        fixDateAxis(dates);
        legend(oddLabels);
        title('odd trials')


        subplot(2,numPlots,3+[0 1]*numPlots)

        alpha=.05;
        [perfBias.perf.phat perfBias.perf.pci]=binofit(corrects,total,alpha);
        [perfBias.bias.phat perfBias.bias.pci]=binofit(rights,total,alpha);

        c={'r' 'k'};
        makePerfBiasPlot(dates,perfBias,c);
        fixDateAxis(dates);
        title('performance and bias (goods)')

        N=3;
        M=500;
        inds=find([tr{i}.step]>=N & goods);
        stepNOrGreater=length(inds);
        if length(inds)>M
            inds=inds(end-M+1:end);
        end
        M=length(inds);
        stepNOrGreaterCorrect=round(100*sum([tr{i}(inds).correct])/length(inds));
    else
        stepNOrGreater=0;
        N=0;
        stepNOrGreaterCorrect=0;
        M=0;
    end
    saveas(gcf,fullfile(targetDir,[str sprintf(' %06d goodTrialsStep%dorHigher %02d%% ofLast%03dcorrect',stepNOrGreater,N,stepNOrGreaterCorrect,M) '.png']));
end
closeConn(conn);
end

function fixDateAxis(dates)
if range(dates)>50
    set(gca,'XTick',fliplr([ceil(max(dates)):-30:floor(min(dates))]));
elseif range(dates)>8
    set(gca,'XTick',fliplr([ceil(max(dates)):-7:floor(min(dates))]));
else
    set(gca,'XTick',fliplr([ceil(max(dates)):-1:floor(min(dates))]));
end
xlim([floor(min(dates)) ceil(max(dates))]);
datetick('x','mm/dd','keeplimits','keepticks')
rotateticklabel(gca,60);
end