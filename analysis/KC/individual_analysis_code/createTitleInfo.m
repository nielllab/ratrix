function [date,subjName] = createTitleInfo(sessionFile,subjData)
% This function take in sessionFile & subjData info (created by
% the function 'loadStage2SubjSessVars()') and uses them to generate 
% figure title info (date, subjName)

    % FIG TITLES

    % mouse ID
    subjName = subjData{1,1}.name;

    % date 
    [filepath,name,ext] = fileparts(sessionFile);
    datePart = name(1:8);
    year = datePart(1:4);
    month = datePart(5:6);
    day = datePart(7:8);
    date = sprintf('%s ', month, day, year);

    display(date)
    display(subjName)

end