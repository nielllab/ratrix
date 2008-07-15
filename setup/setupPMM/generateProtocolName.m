function nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)
numSteps=size(nameOfShapingStep,2);
string=sprintf('version %s\ndefaultSettingsDate %s',protocolVersion, defaultSettingsDate);
for i=1:numSteps
    string=[string '\n' nameOfShapingStep{i}];
end
nameOfProtocol=string;
