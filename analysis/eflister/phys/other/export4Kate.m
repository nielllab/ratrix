files = {'g01','g02','g03'};

for file=files
    file=file{1}
    load(sprintf('%s compiled data',file))
    spks=(repeatSpikes{2})';
    save(sprintf('%s natural',file),'spks')
    spks=(repeatSpikes{3})';
    save(sprintf('%s white',file),'spks');
end