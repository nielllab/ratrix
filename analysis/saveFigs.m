function saveFigs(savePath,type,figID,resolution,renderMode)
% note: resolution only applies when using the '-dformat' via the function 'print'
% saveFigs(savePath,type,figID,resolution,renderMode)
%
% resolution=300;  % only applies to -dformat
% type= {'png','jpg','bmp','fig','-dpsc','-depsc2','-dtiffn'} % compare many
% renderer= {'-painters','-zbuffer','-opengl'}  % compare many
% type={'-dtiffn','bmp'};  renderer= {'-opengl'}; resolution=1200; % paper print quality
% saveFigs(savePath,type,gcf,resolution,renderMode)   
    
%%

if ~exist('savePath') || isempty(savePath)
savePath=cd;
end

if ~exist('type') || isempty(type)
type='bmp';
end

if ~exist('resolution') || isempty(resolution)
resolution=150;
end

if ~exist('figID') || isempty(figID)
figID=gcf;
end

if ~exist('renderMode') || isempty(renderMode)
  renderMode={'-painters'}; % must be one or many of these: {'-painters','-zbuffer','-opengl'} 
end

for i=1:length(figID)
    figure(figID(i));
    
    for r=1:length(renderMode)
        if length(renderMode)==1
            filename=sprintf('paperFig_%d',figID(i));  % don't add renderer if only one specified
        else
            filename=sprintf('paperFig_%d%s',figID(i),renderMode{r}(1:2)); % if muliple types, specify in name
        end
        fullfileName=fullfile(savePath,filename);
        for j=1:length(type)
            switch type{j}
                case {'png','jpg','bmp','fig'}  %{'png','jpg','bmp','eps','fig','tif','psc2','tiffn','epsc2'}
                    saveas(gcf,fullfileName,type{j})
                case {'-dpsc','-depsc2','-dtiffn','-dbmp'} %{'-dpsc','-depsc2','-dtiffn','-dpng'}
                    print(sprintf('-r%d',resolution),renderMode{r}, type{j}, fullfileName)
                otherwise
                    type{j}
                    error('unsupported save request')
            end
        end
    end
end