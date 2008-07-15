function setupMaleRoom()

rackID=1;
addStationsForRack(rackID);
r=addRatsForRack(rackID,'pmm');
setPermanentStorePath(r,getSubDirForRack(rackID));

setProtocolPR({'243','244','245','246','247','248'});
setProtocolDFP('male room',{'225','226','239','240','241','242'}) %removed '223','224'
setupPMM %still persisting Adam's rats

testSubjects={'l','r'};
setProtocolPR(testSubjects);

