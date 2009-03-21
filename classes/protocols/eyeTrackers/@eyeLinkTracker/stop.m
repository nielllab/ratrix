function et=stop(et)
%stop recording, receive .edf file from session, turn off tracker object

Eyelink('Stoprecording')
status = Eyelink('CloseFile');
if ~status==0
    status=status
    error('error closing eyelink datafile')
end

fileName=getSessionFileName(et);
lastFile=[];
disp('transfering eyeLink datafile... this could take a few seconds.');

status = Eyelink('ReceiveFile',lastFile, fullfile(getEyeDataPath(et),fileName),0);
disp('done transfer');
%status = Eyelink('ReceiveFile',['filename'], ['dest'], ['dest_is_path'])
%(2.95 receive_data_file in 'EyeLink API Specification.pdf')

% edf thinks this looks wrong -- my original code in "fixationSoundDemo.m" was:
%    status=Eyelink('ReceiveFile',edfFile,pwd,1);
%    if status~=0
%        fprintf('problem: ReceiveFile status: %d\n', status);
%    end
%
% the help says you need to set the third arg to nonzero, so that your path is used.
%
% also looks like i also assumed that status should nominally be 0, but the help says:
% returns: file size if OK, 0 if file transfer was cancelled, negative =  error code
%
% so i think you should be hitting your error every time?
%
% btw, what does 2.95 refer to?

% edf recommends you do the following check:
%if 2==exist(edfFile, 'file')
%     fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
% else
%     disp('unknown where data file went')
% end

if ~status==0
    status=status
    fileName=fileName
    destination=getEyeDataPath(et)
    error('error receicving eyelink session datafile')
end

Eyelink('Shutdown')

et=setIsTracking(et, false);
