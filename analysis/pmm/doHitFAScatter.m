function doHitFAScatter(stats,CI,names,params,subjects,conditions,doLegend,doCurve,doYesLine,doCorrectLine,sideText,doErrorBars,arrowFromAtoB)
%first get the stats, then pass the values to the plotter
%[stats CI names params]=getFlankerStats({'231'},'allRelativeTFOrientationMag',{'hits','CRs'},'14',[1 now]);
%doHitFAScatter(stats,CI,names,params)

if ~exist('subjects','var') || isempty(subjects)
    subjects=names.subjects;
end

if ~exist('conditions','var') || isempty(conditions)
    conditions=names.conditions;
end

if ~exist('doLegend','var') || isempty(doLegend)
    doLegend=1;
end

if ~exist('doCurve','var') || isempty(doCurve)
    doCurve=1;
end

if ~exist('doYesLine','var') || isempty(doYesLine)
    doYesLine=0;
end

if ~exist('doCorrectLine','var') || isempty(doCorrectLine)
    doCorrectLine=0;
end

if ~exist('doErrorBars','var') || isempty(doErrorBars)
    doErrorBars=1;
end
if ~exist('drawDiag','var') || isempty(drawDiag)
    drawDiag=1;
end

if ~exist('sideText','var') || isempty(sideText)
    sideText=1;
end

if ~exist('arrowFromAtoB','var') || isempty(arrowFromAtoB)
    arrowFromAtoB=[];
    %arrowFromAtoB={'changeFlank','colin'};
end

% if ~exist('measureLabels','var') || isempty(measureLabels)
%     addMeasureLabel=0;
% else
%     if isa(addMeasureLabel,'cell')
%     addMeasureLabel=1;
%     else
%         error('must be a cell array of strings')
%     end
% end


numArrowsPerSubject=size(arrowFromAtoB,1);

%temp
ciwidth=3;
colors=params.colors;

%error check
if ~(sum(ismember(names.stats,{'hits', 'CRs'}))==2)
    error('must have hits and CRs to do ths analaysis')
end
hitInd=find(strcmp('hits',names.stats));
crInd=find(strcmp('CRs',names.stats));


%make settings per subject per condition
if size(doCurve)==[1 1];
    doCurve=doCurve*ones(length(names.subjects),length(names.conditions))
else
    doCurve=doCurve;
end

if size(doYesLine)==[1 1];
    doYesLine=doYesLine*ones(length(names.subjects),length(names.conditions));
else
    doYesLine=doYesLine;
end

if size(doCorrectLine)==[1 1];
    doCorrectLine=doCorrectLine*ones(length(names.subjects),length(names.conditions));
else
    doCorrectLine=doCurve;
end

if drawDiag
    plot([0 1], [0 1],'k')
end
hold on;
axis([0 1 0 1])
axis square;

%draw context lines
for i=1:length(subjects)
    subInd=find(strcmp(subjects(i),names.subjects));
    for j=1:length(conditions)
        condInd=find(strcmp(conditions(j),names.conditions));
        [subInd,condInd,hitInd]
        size(stats)
        hitRate= stats(subInd,condInd,hitInd);
        faRate=1-stats(subInd,condInd,crInd);
        if doCurve(subInd,condInd)
            dpr = sqrt(2) * (erfinv((2*hitRate - 1)) + erfinv((1-2*faRate))); %check assumptions....
            % dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR - FA)/numNoSigs)); %what I use (from code)
            [dprMesh h f]=getDprMesh;
            [cs,hh] = contour(f,h,dprMesh,[dpr dpr]);
            set(hh, 'LineColor', colors(condInd,:));
        end
        if doYesLine(subInd,condInd)
            plot([faRate (hitRate+faRate)./2], [hitRate (hitRate+faRate)./2],'-','color', colors(condInd,:)); % %yes diagonal line
        end
        if doCorrectLine(subInd,condInd)
            plot([0 1-hitRate+faRate], [hitRate-faRate 1],'-','color',colors(condInd,:)); % %correct diagonal line
            plot([faRate 0], [hitRate hitRate],'-','color',colors(condInd,:)); % %hit line
            plot([faRate faRate], [hitRate 0],'-','color',colors(condInd,:)); % %FA line
        end
    end
end


for i=1:length(subjects)
    subInd=find(strcmp(subjects(i),names.subjects));
    for j=1:length(conditions)
        condInd=find(strcmp(conditions(j),names.conditions));
        %get relevant stats
        hitRate= stats(subInd,condInd,hitInd);
        faRate=1-stats(subInd,condInd,crInd);
        hitPci= reshape(CI(subInd,condInd,hitInd,:),1,2);
        faPci=1-reshape(CI(subInd,condInd,crInd ,:),1,2);
    

        %plot cross
        switch doErrorBars
            case 0
                %nothing
            case 1
                %errorBars
                hci(j)=plot([faPci(1) faPci(2)],[hitRate hitRate],'color',colors(condInd,:)); %horizontal error bar
                vci=plot([faRate faRate],[hitPci(1) hitPci(2)],'color',colors(condInd,:)); %vert error bar
                set(hci, 'LineWidth',ciwidth)
                set(vci, 'LineWidth',ciwidth)
            case 2
                %plot dot
                pt(j)=plot(faRate, hitRate,'.','MarkerSize',20,'color',colors(condInd,:));
            case 3
                %ellipse
                ellipse = fncmb(fncmb(rsmak('circle'),[diff(faPci)/2 0;0 diff(hitPci)/2]),[faRate;hitRate]);

                %switch num2str(colors(condInd,:))
                %case num2str([1 0 0])
                if colors(condInd,1)>colors(condInd,2) & colors(condInd,1)>colors(condInd,3) & colors(condInd,2)==colors(condInd,3)
                    colorString='r';
                    %case num2str([0 1 1])
                elseif colors(condInd,2)>colors(condInd,1) & colors(condInd,3)>colors(condInd,1) & colors(condInd,2)==colors(condInd,3)
                    colorString='c';
                    %otherwise
                else
                    colorString='b';
                    disp('no found color match for elipse')
                end
                fnplt(ellipse,1,colorString);
            otherwise
                doErrorBars
                error('bad')
        end


        for j=1:numArrowsPerSubject
            %do arrows
            %Aind=arrowFromAtoB(j,1);
            %Bind=arrowFromAtoB(j,2);

            Aind=find(ismember(names.conditions,arrowFromAtoB{j,1}));
            Bind=find(ismember(names.conditions,arrowFromAtoB{j,2}));

            x=1-[stats(subInd,Aind,crInd ) stats(subInd,Bind,crInd )];
            y=  [stats(subInd,Aind,hitInd) stats(subInd,Bind,hitInd)];
            %[fx,fy] = dsxy2figxy(gca, x, y);
            %a=annotation('arrow',fx,fy,'HeadStyle','cback1','HeadWidth',5,'HeadLength',5,'Color',colors(Bind,:));
            %arrow('Start',[x(1) y(1)],'Stop',[x(2) y(2)],'Length',9,'Width',1) % good for full size plot
            arrow('Start',[x(1) y(1)],'Stop',[x(2) y(2)],'Length',4,'Width',0.5) % good for half size subplot

        end

        if sideText
            if ifYesIsLeftRat(subjects{i})
                text(.5,.2,'Y=L');
            else
                text(.5,.2,'Y=R');
            end
        end
    end
end


    %labels
    if doLegend
        legend(pt,conditions,'Location','SouthEast')
    end
    set(gca,'YTickLabel',[0 .5 1])
    set(gca,'YTick',[0 .5 1])
    ylabel('Hit Rate'); xlabel('False Alarm Rate');



