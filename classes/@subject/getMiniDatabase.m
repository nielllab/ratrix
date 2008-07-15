function database=getMiniDatabase(subject)
% this is an access function not defined for the subject but moved to
% 'setup/setupPMM'

error('defunct script getMiniDatabase')


% warning('off','MATLAB:dispatcher:nameConflict')
% addpath(subject.miniDatabasePath);
% warning('on','MATLAB:dispatcher:nameConflict')
% 
% success = makeMiniDatabase();
% if success
%     load('miniDatabase.mat');
% else
%     error('could not make MiniDabase()');
% end
% 
% if ~exist('database', 'var')
%     database = [];
% end