%%

%this is a figure size test
figure
subplot(2,2,1); plot([.5 .5],[0 1],'lineWidth',2)
subplot(2,2,2); plot([.5 .5],[0 1],'lineWidth',72)
subplot(2,2,3); plot([0 1],[.5 .5],'lineWidth',2)
subplot(2,2,4); plot([0 1],[.5 .5],'lineWidth',72)
text(.5,1,'Helvetica   s1')
xlabel('Helvetica')


set(gcf,'Position',[0 40 800 640])
settings.Units='inches';
settings.PaperPosition=[.5 .5 3.5 3.5];
settings.fontSize=12;
settings.textObjectFontSize=7;
settings.turnOffTics=true;
settings.MarkerSize=2;
settings.box='off';
settings.turnOffLines=1;
%settings.FontName='Helvetica';

cleanUpFigure(gcf,settings)
subplot(2,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(2,2,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(2,2,3); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(2,2,4); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
settings.alphaLabel=[];

savePath='C:\Documents and Settings\rlab\Desktop\tempIn';

% resolution=300;  % only applies to -dformat
% type= {'png','jpg','bmp','fig','-dpsc','-depsc2','-dtiffn'} % compare many
% renderer= {'-painters','-zbuffer','-opengl'}  % compare many
type={'-dtiffn','bmp'};  renderer= {'-opengl'}; resolution=1200; % paper print quality
%saveFigs(savePath,type,gcf,resolution,renderer)


