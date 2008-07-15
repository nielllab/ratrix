function s=setProtocolVersion(s,protocolVersion)
if ~isstruct(protocolVersion) || ~isfield(protocolVersion,'manualVersion') || ~isfield(protocolVersion,'autoVersion')
    error('Passed in protocol version is invalid')
else
    s.protocolVersion=protocolVersion;
end