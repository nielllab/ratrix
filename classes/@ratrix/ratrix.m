function r=ratrix(varargin)
% RATRIX  class constructor.
% r = ratrix('path to database directory',replaceExistingDB,[permanentStorePath])

r.serverDataPath = ''; % The path of the serverData folder
r.dbpath = ''; % Where the ratrix db.mat is stored locally
r.subjects = {}; % List of subjects
r.boxes = {};
r.assignments = {}; %this will have an entry at i for each box id i, whose value is:
r.permanentStorePath = ''; % Where to permanently store trial records
r.creationDate = ''; % The date the ratrix db was initially created
% {{stationRecs} {subjectIDs}}
%stationRecs is numStations by 2, col 1 is stations, col 2 is running

r = class(r,'ratrix');

switch nargin
    case 0
        % if no input arguments, create a default object

        %         r.serverDataPath = '';
        %         r.dbpath = '';
        %         r.subjects = {};
        %         r.boxes = {};
        %         r.assignments = {};


    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'ratrix'))
            r = varargin{1};
        else
            error('Input argument is not a ratrix object')
        end

    case 2
        % create object using specified values
        %         if ischar(varargin{1})



        %             r = class(r,'ratrix');

        r = establishDB(r,varargin{1},varargin{2});


        %             [pathstr, name, ext, versn] = fileparts(varargin{1});
        %
        %             if ~isempty(pathstr) && isempty(name)
        %                 fileStr = 'db.mat';
        %                 r.dbpath = [pathstr filesep fileStr];
        %
        %
        %
        %                 currdir = pwd;
        %
        %                 if checkPath(pathstr)
        %
        %                     cd(pathstr);
        %
        %                     if strcmp(pwd,pathstr)
        %                         found=dir(fileStr);
        %
        %                         if length(found)==0
        %                             %save(fileStr,'r');
        %                             saveDB(r,0);
        %                         elseif length(found)==1
        %                             if varargin{2}
        %                                 disp('found existing db, replacing')
        %                                 %                        [status,message,messageid] = movefile(fileStr,['./replacedDBs/replaced.' datestr(now,30) '.' fileStr]);
        %                                 %                         if status
        %                                 %                             save(fileStr,'r');
        %                                 %                         else
        %                                 %                             error('couldn''t replace existing db: %s, %s',message,messageid)
        %                                 %                         end
        %                                 saveDB(r,1);
        %                             else
        %                                 disp('loading existing db')
        %                                 startTime=GetSecs();
        %                                 saved=load(fileStr,'-mat');
        %                                 disp(sprintf('done loading ratrix db: %g s elapsed',GetSecs()-startTime))
        %
        %                                 r=saved.r;
        %                             end
        %                         else
        %                             error('unknown error -- found got %d matches',length(found))
        %                         end
        %
        %                     else
        %                         error('could not find specified directory')
        %                     end
        %                     cd(currdir);
        %                 else
        %                     error('could not make specified directory')
        %                 end
        %             else
        %                 error('must provide a fully resolved path to a new or existing data base directory')
        %             end

        %         else
        %             error('Input argument should be a fully resolved path string')
        %         end

    case 3
         r = establishDB(r,varargin{1},varargin{2});
         r = setPermanentStorePath(r,varargin{3});
        
    otherwise
        error('Wrong number of input arguments')
end