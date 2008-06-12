function closeAllSerials
alreadies=instrfind;
if ~isempty(alreadies)
    fprintf('closing and deleting %d serial ports\n',length(alreadies));
    fclose(alreadies)
    delete(alreadies)
end