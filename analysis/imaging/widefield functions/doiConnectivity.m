clear all
close all

batchPhilSizeSelect

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%%% choose sessions to analyze
for i =1:length(files);
    hasdarkness(i) = ~isempty(files(i).darkness);
end
alluse = find(  strcmp({files.notes},'good imaging session') & hasdarkness ) 
  
length(alluse)
allsubj = unique({files(alluse).subj})
use = alluse;

printfigs=0; %% save figs to pdf? turning off runs 2x as fast

for i = 1:length(use);
    figLabels{i} = [' ' files(use(i)).inject ' ' files(use(i)).timing];
end


for s= 1:1  %%% can loop over subjects
%%% calculate gradients and regions
clear map merge
x0 =0; y0=0; sz = 128;
doTopography;

%%% get functional connectivity
doCorrelationMap

end

[f p] = uiputfile('*.pdf','save pdf');
if f~=0
    try
        ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
    catch
        display('couldnt generate pdf');
    end
end
delete(psfilename);