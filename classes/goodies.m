%%%%%%%%%%%%%%% send email
setpref('Internet','SMTP_Server','smtp.ucsd.edu')
setpref('Internet','E_mail','ratrix@ucsd.edu')
oldDir=pwd
cd([matlabroot filesep 'toolbox' filesep 'matlab' filesep 'iofun' filesep ])
sendmail('6125015207@tmomail.net','test','hi') 
cd(oldDir)


%%%%%%%%%%%%%%%%%%%% write disable warm poll
 winqueryreg('HKEY_LOCAL_MACHINE', ...
            'SYSTEM\CurrentControlSet\Services\Parport\Parameters', ...
            'DisableWarmPoll')

regFileName = 'temp_write_reg.reg';
fp = fopen(regFileName,'wt');
fprintf(fp,'REGEDIT4\n');
fprintf(fp,'%s\n','[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Parport\Parameters]');
fprintf(fp,'%s\n','"DisableWarmPoll"=dword:00000001');
fclose(fp);

dos(sprintf(['C:\\windows\\regedit.exe /s ' regFileName]));


%%%%%%%%%%%%%%%% send SMS
http://toolbar.google.com/send/sms/index.php
uses http form post