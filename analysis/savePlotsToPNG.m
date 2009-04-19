function  savePlotsToPNG(plotNames,handles,who,savePath)

if ~iscell(plotNames)
    error('plotNames must be in cell mode now, not a logical from old code')
end

todayDate=datestr(now,29);
mkdir(savePath);
fileOut=sprintf('%s_%s_',todayDate,who)
for i=1:size(handles,2)
        saveas(handles(i),fullfile(savePath,[fileOut plotNames{i}]),'png')
        disp(sprintf('saving figureid: %d',i))
    end
end