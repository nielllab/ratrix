function r = updateRatrix(r, ratrixParameters)
% takes existing standAlonePath version ratrix and sets the other fields from old style ratrix

r.serverDataPath = ratrixParameters.serverDataPath;
r.dbpath = ratrixParameters.dbpath;
r.subjects = ratrixParameters.subjects;
r.boxes = ratrixParameters.boxes;
r.assignments = ratrixParameters.assignments;
r.creationDate = ratrixParameters.creationDate;
r.standAlonePath = [];

saveDB(r, 0);

end