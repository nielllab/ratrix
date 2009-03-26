function obj=loadobj(s)
% r = datanet('stim', hostname, data_hostname, data_storepath, [ai_parameters])

obj=datanet('stim',s.host,s.data_hostname,s.storepath,s.ai_parameters);
end