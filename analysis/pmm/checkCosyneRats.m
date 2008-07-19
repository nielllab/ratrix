%checkCosyne

addPath(genpath('C:\pmeier\Ratrix\analysis'))

%%
subjects={'rat_134','rat_135','rat_136','rat_137','rat_131'};
for i=1:5
stepUsed=10;
subject=(subjects{i})
dataStorageIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu';
dataStoragePath='\rlab\Rodent-Data\behavior\rats';
dataStorageIPAndPath=fullfile('\\',dataStorageIP,dataStoragePath);
load(fullFile(fullFile(dataStorageIPAndPath, subject),['smallData']) , 'smallData')
peekAtData
end


%%

subject='rat_135'
load(fullFile(fullFile(dataStorageIPAndPath, subject),['smallData']) , 'smallData')
if max(smallData.step)>=12
    stepUsed=12;
    peekAtData
end