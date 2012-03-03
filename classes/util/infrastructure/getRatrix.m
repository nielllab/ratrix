function r=getRatrix
%get the default ratrix

dbPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData','ServerData');
d=dir(dbPath);
if length(d)>1
    if ismember('db.mat',{d.name})
        disp('loading default db.mat...')
        tic
        disp(dbPath)
        load(fullfile(dbPath,'db.mat'))
        disp(sprintf('done loading db.mat (took %3.3f sec)',toc))
    else
        error('no db.mat there! path exists however...')
    end
else
    error('no db yet! there is no file path to the default location')
end