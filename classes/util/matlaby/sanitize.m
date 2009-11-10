function in=sanitize(in)
in=in(~ismember(in,['<>/\?:*"|'])); %TODO: check for excluded filename characters on osx