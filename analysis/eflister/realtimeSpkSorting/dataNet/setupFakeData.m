function setupFakeData
clc

baseDir='/Users/eflister/Desktop/dataNet';

dates={'03.04.09','04.04.09','04.08.09'};
subjects={'test1','demo1','test3'};

dateFormat='mm.dd.yy';

physDir=fullfile(baseDir,'physiology');
mkdir(physDir);
for j=subjects
    j=j{1};
    subDir=fullfile(physDir,j);
    mkdir(subDir);    
    for i=dates
        i=i{1};
        %elapsed=dhms(i,dateFormat)
        dateDir=fullfile(subDir,i);
        mkdir(dateDir);
        for k=1:round(rand*3)+1
            for m=1:round(rand*10)+1
                save(makeChunk);
            end
        end
    end
end