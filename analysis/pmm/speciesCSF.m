

%Experimental Facts, could be passed in
    ratTestCpd=0.15; %box at 10 cm, 32 pix/cyc
    ratTestSens=1/((1)*(1/2)); %one over contrast value times linearized range
    humTestCpd=3.3; %box at 215 cm
    humTestSens=1/((1/16)*(2/10)); %one over contrast value times linearized range
    
    
    %settings 
    fontSize=20;
    settings.fontSize=fontSize;

close all
sensRat=[1.75, 3.7, 6, 6.5, 6, 5.7, 4.8, 2.3,1.2];
cpdRat=[.04,.06,.08,.1,.15,.2,.3,.5,.8];
sensHum=[30,70,80,83,40,10,4];
cpdHum=[.5,1,2,4,8,14,20];
loglog(cpdRat, sensRat, 'color',[0 .5 0])
hold on
plot(cpdRat, sensRat, '.', 'MarkerSize', 20,'color',[0 .5 0])
plot(cpdHum, sensHum, 'b')
plot(cpdHum, sensHum, '.b', 'MarkerSize', 20)
axis([.03 50 1 100]);
set(gca, 'XTickLabel', [.1 1 10], 'YTickLabel', [1 10 100],'Box', 'off');
set(gca, 'XTick', [.1 1 10], 'YTick', [1 10 100]);
xlabel('Spatial Frequency (cyc/deg)', 'FontSize', fontSize);
ylabel('Contrast Sensitivity', 'FontSize', fontSize);

addSpeciesLabel=true;
if addSpeciesLabel
    text(0.04,8, 'rat')
    text(.2,80, 'human')
end

cleanUpFigure(gcf, settings)


addTestValue=false;
if addTestValue
    plot(humTestCpd, humTestSens, '.k', 'MarkerSize', 20)
    plot(ratTestCpd, ratTestSens, '.b', 'MarkerSize', 20)
end

addArrow=false; %arrow heads are too annoying on a loglog plot
if addArrow
%     q=quiver(humTestCpd, humTestSens-20,0,20, 'b')
%     quiver(ratTestCpd, ratTestSens-1,0,1, 'k')
%     a=axes
%     q=quiver(humTestCpd-1, humTestSens-20,0,20, 'b')
end

addTestLine=true;
if addTestLine
    plot(humTestCpd([1 1]), [50 80], 'b')
    plot(ratTestCpd([1 1]), [3.5 5.5], 'color',[0 .5 0])
    
    text(humTestCpd, 50, [num2str(humTestCpd) ' cpd'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
    text(ratTestCpd, 3.5, [num2str(ratTestCpd) ' cpd'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
end





