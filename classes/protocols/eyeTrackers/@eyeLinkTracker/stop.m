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
if ~status==0
    status=status
    fileName=fileName
    destination=getEyeDataPath(et)
    error('error receicving eyelink session datafile')
end

Eyelink('Shutdown')

et=setIsTracking(et, false);
