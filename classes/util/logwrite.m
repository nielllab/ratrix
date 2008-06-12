function logwrite(str)
f=fopen('cmdLog.txt','a');
fprintf(f,'%s: %s\n',datestr(now),str);
fclose(f);