function database=getMiniDatabase(miniDatabasePath)

if ~strcmp(class(miniDatabasePath), 'char')
error('must be a path string');
end

warning('off','MATLAB:dispatcher:nameConflict')
addpath(miniDatabasePath);
warning('on','MATLAB:dispatcher:nameConflict')

success = makeMiniDatabase();
if success
    load('miniDatabase.mat');
else
    error('could not make MiniDabase()');
end

if ~exist('database', 'var')
    database = [];
end