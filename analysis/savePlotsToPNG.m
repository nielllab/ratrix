function  savePlotsToPNG(savePlots,handles,who,savePath)


if size(handles)~=size(savePlots)
    error('must specify whether or not to save every handle')
end

todayDate=datestr(now,29);
fileOut=sprintf('%s_%s_%s',todayDate,who,'fig')
for i=1:size(handles,2)
    if savePlots(i)==1
        %figure(handles(i))
        saveas(handles(i),[savePath fileOut num2str(i)],'png')
        
        disp(sprintf('saving figureid: %d',i))
    end
end