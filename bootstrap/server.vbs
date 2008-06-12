dim updCom
dim runCom
Set WshShell = CreateObject("WScript.Shell")
updCom = "matlab -nosplash -minimize -nodesktop -logfile serverUpdateLog.txt -sd ""C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap"" -r serverCheckForUpdate"
runCom = "matlab -nosplash -minimize -nodesktop -logfile serverLog.txt -sd ""C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap"" -r server"
Do While True
 WshShell.Run updCom, 1, True
 WshShell.Run runCom, 1, True
Loop 