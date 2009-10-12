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

whichArrowsShifted=[]; %discover from 4th arg of arrow



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
    doCurve=doCurve*ones(length(names.subjects),length(names.conditions));
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
    doCorrectLine=doCorrectLine;
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
        %[subInd,condInd,hitInd];
        %size(stats)
        hitRate= stats(subInd,condInd,hitInd);
        faRate=1-stats(subInd,condInd,crInd);
        if doCurve(subInd,condInd)
            dpr = norminv(hitRate)-norminv(faRate);
            % dpr = sqrt(2) * (erfinv((2*hitRate - 1)) + erfinv((1-2*faRate))) %checked assumptions.... is the same
            % dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR - FA)/numNoSigs)); %what I use (from code)
            %             [dprMesh cr h f]=getDprMesh(501);
            %             [cs,hh] = contour(f,h,dprMesh,[dpr dpr]);
            %             set(hh, 'LineColor', colors(condInd,:));

            cr =-(norminv(hitRate)+norminv(faRate))/2;
            [dprHandle crHandle ] = getDprCurve(51, dpr, cr, 1);
            set(dprHandle, 'Color', colors(condInd,:));
            set(crHandle, 'Color', colors(condInd,:));
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
                dataGraphic(j)=hci(j);
            case 2
                %plot dot
                pt(j)=plot(faRate, hitRate,'.','MarkerSize',20,'color',colors(condInd,:));
                dataGraphic(j)=pt(j);
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
                elseif all(colors(condInd,:)==0)
                    colorString='k';
                else
                    colorString='b';
                    disp('no found color match for elipse')
                end
                fnplt(ellipse,1,colorString);
                dataGraphic(j)=ellipse;
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
            if  all(ismember({'dprimeMCMC','criterionMCMC'},names.stats))
                dprInd=find(strcmp('dprimeMCMC',names.stats));
                critInd=find(strcmp('criterionMCMC',names.stats));
                hasDprNcrit=1;
            elseif all(ismember({'dpr','crit'},names.stats))
                dprInd=find(strcmp('dpr',names.stats));
                critInd=find(strcmp('crit',names.stats));
                hasDprNcrit=1;
            else
                hasDprNcrit=0;
            end
            
            if size(arrowFromAtoB,2)>2
                arrowType=arrowFromAtoB{j,3}(1);
            else
                arrowType=1;
            end
            
            doArrows(x,y,arrowType);
            
            
            if size(arrowFromAtoB,2)>3
                arrowShift=arrowFromAtoB{j,4}(1);
                if arrowShift
                    whichArrowsShifted=unique([whichArrowsShifted j]);
                end
            else
                arrowShift=false;
            end
            
            
            
            if arrowShift
                if  hasDprNcrit
                    base=[.45 .3];
                    doArrows([base(1) base(1)+x(2)-x(1)],[base(2) base(2)+y(2)-y(1)],arrowType);
                    
                    base2=[.75 .6];
                    %get std measures
                    dpr=[stats(subInd,Aind,dprInd ) stats(subInd,Bind,dprInd )];
                    crit=[stats(subInd,Aind,critInd ) stats(subInd,Bind,critInd )];
                    %add an arbitrary scale, consistent across all plots...
                    crScale=1/2;
                    dprScale=1/8;
                    crit=crit*crScale;
                    dpr=dpr*dprScale;
                    %rotate axis 45deg
                    x2=-(dpr+crit);
                    y2=dpr-crit;
                    doArrows([base2(1) base2(1)+x2(2)-x2(1)],[base2(2) base2(2)+y2(2)-y2(1)],arrowType);
                    
                else
                    base=[.45 .3];
                    doArrows([base(1) base(1)+x(2)-x(1)],[base(2) base(2)+y(2)-y(1)],arrowType);
                    base2=[0 0];
                end
            end
            
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
    legend(dataGraphic,conditions,'Location','SouthEast')
end
set(gca,'YTickLabel',[0 .5 1])
set(gca,'YTick',[0 .5 1])
ylabel('Hit Rate'); xlabel('False Alarm Rate');



doSubAxes=1;
if ~isempty(whichArrowsShifted) & doSubAxes
    
    if 0 %for reference aligning
        plot( base([1 1]),base([2 2])+[-.1 +.1],'g')
        plot(base([1 1])+[-.1 +.1],base([2 2]),'g')
        plot( base2([1 1]),base2([2 2])+[-.1 +.1],'g')
        plot(base2([1 1])+[-.1 +.1],base2([2 2]),'g')
        
        plot( base( [1 1])+[ .1 -.1],base( [2 2])+[-.1 .1],'r')
        plot( base( [1 1])+[-.1  .1],base( [2 2])+[-.1 .1],'r')
        plot( base2([1 1])+[ .1 -.1],base2([2 2])+[-.1 .1],'r')
        plot( base2([1 1])+[-.1  .1],base2([2 2])+[-.1 .1],'r')
    end
    
    axis square
    mainAx=gca;
    %make axes
    subAxesWidth=0.20; %sqrt(2); % fit visually
    [fx1 fy1]=dsxy2figxy(base(1)-subAxesWidth*(1.1), base(2)-subAxesWidth*1.25);
    [fx2 fy2]=dsxy2figxy(base(1)-subAxesWidth*(0.08), base(2)-subAxesWidth*1.25);
    [fx3 fy3]=dsxy2figxy(base2(1)-subAxesWidth*(1.42), base2(2)-subAxesWidth*1.25);
    [fx4 fy4]=dsxy2figxy(base2(1)-subAxesWidth*(0.4), base2(2)-subAxesWidth*1.25);
    
            
    for j=1:length(whichArrowsShifted)
        Aind=find(ismember(names.conditions,arrowFromAtoB{whichArrowsShifted(j),1}));
        Bind=find(ismember(names.conditions,arrowFromAtoB{whichArrowsShifted(j),2}));
        cMatrix={[Bind],[Aind]};
        
        diffEdges=[-6:2:6];
        alpha=0.05;
        multiComparePerPlot=false;
        
        a= axes;
        set(a,'position', [fx1 fy1 subAxesWidth subAxesWidth]);
        viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,diffEdges,alpha,false,false,false,multiComparePerPlot)
        xlabel(''); ylabel(''); set(gca,'xTickLabel',''); set(gca,'yTickLabel','');
        set(a,'CameraUpVector', [1 -1 0]);  axis equal
        set(gca,'Visible','off');
        %camroll(sa1, 180-fake45)
        %set(sa1, 'CameraPosition', get(sa1, 'CameraTarget')+[0 0 20])
        %set(sa1, 'CameraUpVector', [0 0 1])
        
        
        a=axes; axis equal
        set(a,'position', [fx2 fy2 subAxesWidth subAxesWidth]);
        viewFlankerComparison(names,params,fliplr(cMatrix),{'yes'},subjects,diffEdges,alpha,false,false,false,multiComparePerPlot)
        xlabel(''); ylabel(''); set(gca,'xTickLabel',''); set(gca,'yTickLabel','');
        set(a,'CameraUpVector', [-1 -1 0]);  axis equal
        set(gca,'Visible','off');
        
        if all(ismember({'dpr','crit'},names.stats))
            diffEdges=[-.4:0.1:.4];
            
            a=axes; axis equal;
            set(a,'position', [fx3 fy3 subAxesWidth subAxesWidth]);
            set(a,'CameraUpVector', [1 1 0]);
            viewFlankerComparison(names,params,cMatrix,{'dpr'},subjects,diffEdges,alpha,false,false,false,multiComparePerPlot)
            xlabel(''); ylabel(''); set(gca,'xTickLabel',''); set(gca,'yTickLabel','');
            set(a,'CameraUpVector', [1 -1 0]);  axis equal
            set(gca,'Visible','off');
            
            diffEdges=diffEdges*(dprScale/crScale);
            a=axes; axis equal;
            set(a,'position', [fx4 fy4 subAxesWidth subAxesWidth]);
            viewFlankerComparison(names,params,cMatrix,{'crit'},subjects,diffEdges,alpha,false,false,false,multiComparePerPlot)
            xlabel(''); ylabel(''); set(gca,'xTickLabel',''); set(gca,'yTickLabel','');
            set(a,'CameraUpVector', [-1 -1 0]);  axis equal
            set(gca,'Visible','off');
            
        end
        
    end
    
    set(gcf,'CurrentAxes',mainAx) % return for further plotting
    
end



function doArrows(x,y,arrowType)
%old sucky:
%[fx,fy] = dsxy2figxy(gca, x, y);
%a=annotation('arrow',fx,fy,'HeadStyle','cback1','HeadWidth',5,'HeadLength',5,'Color',colors(Bind,:));

switch arrowType
    case 1
        arrow('Start',[x(1) y(1)],'Stop',[x(2) y(2)],'Length',9,'Width',1)
    case 2 % thin arrow
        % good for half size subplot
        arrow('Start',[x(1) y(1)],'Stop',[x(2) y(2)],'Length',4,'Width',0.5)
    case 3 %thin grey line
        plot(x,y,'color',[.5 .5 .5])
    case 4 %event thinner arrow 
         arrow('Start',[x(1) y(1)],'Stop',[x(2) y(2)],'Length',2,'Width',0.25)
    otherwise
        arrowType
        error('bad arrowType')
end



