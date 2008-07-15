function et=setSessionFileName(et,name)

if isstr(name)
    et.sessionFileName=name;
else
    name=name
    error('sessionFileName is not a str')
end