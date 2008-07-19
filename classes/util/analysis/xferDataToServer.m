function success=xferDataToServer(distalSourcePath,dataStoragePath,dataStorageIP,sourceIP,subject,loadMethod,loadMethodParams,subjectFoldersInsideDataFolder, verbose)
%this method is not actively used, but simply an example... in current
%version, prefered method is: replicateTrialRecords


switch loadMethod
    case 'singleSession'
        sourcePath=loadMethodParams;
        sessionID=getSessionIDsFromFilePaths(sourcePath);
    otherwise
        error ('that loadMethod is not defined')
end

if isnan(sessionID)
    warning('ignoring a session ID that is still in progress')
    success=0
else

    %method to clear list of connections
    [status result]=system('net use * /delete /yes');
    if status~=0
        switch result
            case 'There are no entries in the list.'
            otherwise
                result
                error ('Problem removing exisitng list of connections.')
        end
    end

    %unmap drives
    %disp('WARNING: File transfer will error if user is already logged on to server with user RODENT.')
    %disp('This is a real concern because somehow copyfile thinks it has completed the copy but it has not.')
    % command = 'net use z: \\132.239.158.181\rlab\Rodent-Data\behavior\rats'  %note RODENT user unnecessary
    if verbose
        warning ('unmapping and remapping network drives y and z willy nilly!')
    end
    command=sprintf('net use y: /delete');
    [status result]=system(command);
    if status~=0
        if size(strfind(result,'The network connection could not be found.'),1)>0
            if verbose
                disp(sprintf('acceptable error: trying to remove a nonexistent drive -- %s ',result(1:42)))
            end
        else
            result
            error ('Problem unmapping network drive')
        end
    end
    command=sprintf('net use z: /delete');
    [status result]=system(command);
    if status~=0
        if size(strfind(result,'The network connection could not be found.'),1)>0
            if verbose
                disp(sprintf('acceptable error: trying to remove a nonexistent drive -- %s ',result(1:42)))
            end
        else
            result
            error ('Problem unmapping network drive')
        end
    end

    if strcmp(dataStorageIP,'132.239.158.181')
        %sourceIP='132.239.158.177';  %OLD!  same as sourceIP='Reinagellab';
        %dataStorageIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu';
        password='1Mouse'; %this is only true for dataStorageIP='132.239.158.181'
    else
        error ('unknown server-can''t find password')
    end

    %map network drive for storage server
    command=sprintf('net use z: \\\\%s%s',dataStorageIP,dataStoragePath);
    %command='net use z: \\132.239.158.181\rlab\Rodent-Data\behavior\rats' %example of what it might look like
    %command=sprintf('net use z: \\\\%s%s %s /user:RODENT',dataStorageIP,dataStoragePath,password) '% 1Mouse /user:Rodent'
    %used to use user:Rodent with 1Mouse, but now this computer must be previously sign on as rlab and therefore needs no pass
    [status result]=system(command);
    if status~=0
        command
        result
        error ('Problem mapping network drive')
    end

    %map network drive for ratrix work station
    %WARNING: for some reason you can NOT map a network drive to either a full
    %path on the local network like this:
    %
    %\\192.168.0.101\c\pmeier\Ratrix\Boxes\box1
    %
    %nor can you map to the IP address itself, like this
    %
    %\\192.168.0.101
    %
    %but you can map to the c drive on the local network and then subsequently
    %specify the full path in the copyfile command - pmm 07/10/19
    password='Pac3111'; %this is true for all ratrix work stations
    drive='c';
    command=sprintf('net use y: \\\\%s\\%s %s /user:rlab',char(sourceIP),drive,password);

    %check to see that the requested drive is actualy c
    if any(strfind(distalSourcePath,'c\')==1) %if path starts with c drive
        distalSourcePath=distalSourcePath(2:end); %remove the c drive
        if verbose
            disp(sprintf('remove the first symbol from the distalSourcePath so it is now: %s', distalSourcePath))
        end
    else
        distalSourcePath
        error ('this code expects you to have the requested drive be c')
    end
    [status result]=system(command);
    if status~=0
        command
        result
        error ('Problem mapping network drive')
    end

    if subjectFoldersInsideDataFolder
        sessionFolder=sprintf('oldSubjectData.%s', datestr(sessionID,30));
        sourceFolder=sprintf('y:%s%s\\%s', distalSourcePath, sessionFolder, subject);
        if verbose
            disp(sprintf('starting transfer of  \\\\%s\\%s%s%s\\%s', char(sourceIP),drive,distalSourcePath, sessionFolder, subject));
        end
    else
        sourceFile=sprintf('y:\\%s', 'trialRecords.mat');
        error ('never tested this yet')
    end

    dataFolder=sprintf('Data.%s',datestr(sessionID,30));
    destinationPath=sprintf('z:\\%s\\%s\\%s',subject, 'largeData', dataFolder);

    %ALTERNATE NAMING CONVENTION AND STORAGE DESTINATION
    %destinationPath=sprintf('z:\\%s\\%s\\%s',subject, 'largeData', dataFolder);
    %destinationPath=sprintf('z:\\%s\\%s\\%s','large', subject, dataFileName);
    %dataFileName=createSavedDataName(); %would need to load in largeData to know its content



    %Confirm file is available
    files=dir(sourceFolder);
    names=[files.name];
    if isempty(strfind(names,'trialRecords'))
        disp(sprintf('going to  delete an empty folder at: %s on %s',sourceFolder,char(sourceIP)))
        sourceExists=0;
    else
        sourceExists=1;
    end

    if sourceExists
        %do MAIN COPY
        [status,message,messageid] = copyfile(sourceFolder,destinationPath,'f');
        if ~status==1 %Don't trust this because user might also be logged in to server... weird error where file does not transfer but copyfile does not error.
            success=0;
            error(sprintf('%s -- %s problem with copying files from %s to %s',message,messageid,sourceFolder,destinationPath))
        else
            %Confirm file is copied
            files=dir(destinationPath);
            names=[files.name];
            if ~isempty(strfind(names,'trialRecords'))
                success=1;
                if verbose
                    disp(sprintf('successful copy of file to server from %s',sourceFolder))
                end
            else
                warning(sprintf('It may be that there is no file in the source directory! check: %s on station IP %s', destinationPath,char(sourceIP)))
                error('file not successfuly transferred. not saved to saveLog yet. try disconnecting windows browser from server and run again.  Or check if the file exists!')
                %you could confirm that the file is not there in the remote
                %folder... but, this means that it is acceptable to have an
                %empty sessionfolder, which its not.  So manually delete it-- pmm
                success=0;
            end
        end
    else %sourceExists=0;

        warning(sprintf('It may be that there is no file in the source directory or something funny! check: %s on station IP %s', destinationPath,char(sourceIP)))
        disp(names)
        sourceFolder
        disp('confirm if you want to delete it! - press a button!')
        pause

        try
            %remove the empty folder
            [succ,MESSAGE,MESSAGEID] = rmdir(sourceFolder); %only removes if its an empty dir...
        catch
            error('failed while removing a supposed empty directory')
        end

        if succ %at removing it
            disp('successfully removed an empty folder')
        else
            MESSAGE=MESSAGE
            MESSAGEID=MESSAGEID
            error('failed while removing a supposed empty directory')
        end

        success=0; %at copying it to destination
        %when set to zero, will prevent savelog addititon

    end

    %unmap drives
    command=sprintf('net use y: /delete');
    [status result]=system(command);
    if status~=0
        command
        result
        error ('Problem unmapping network drive')
    end
    command=sprintf('net use z: /delete');
    [status result]=system(command);
    if status~=0
        command
        result
        error ('Problem unmapping network drive')
    end
end


