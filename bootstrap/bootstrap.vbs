dim runCom
Set WshShell = CreateObject("WScript.Shell")
runCom = "matlab -nosplash -minimize -logfile clientLog.txt -r ""cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap');fprintf('%s\n',pwd);bootstrap"""
Do While True
 WshShell.Run runCom, 1, True 
Loop 