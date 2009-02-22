function closeAllSerials
if ~usejava('jvm')
    warning('closeAllSerials can''t call instrfind with no jvm')
    return
end
alreadies=instrfind;
if ~isempty(alreadies)
    fprintf('closing and deleting %d serial ports\n',length(alreadies));
    fclose(alreadies)
    delete(alreadies)
end