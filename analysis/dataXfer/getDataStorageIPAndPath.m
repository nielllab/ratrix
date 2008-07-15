function dataStorageIPAndPath=getDataStorageIPAndPath()
%defined as a constant for the ratrix, probably should become a method on
%ratrix object

dataStorageIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu';
dataStoragePath='\rlab\Rodent-Data\behavior\rats';
dataStorageIPAndPath=fullfile('\\',dataStorageIP,dataStoragePath);