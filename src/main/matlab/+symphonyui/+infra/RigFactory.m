classdef RigFactory < handle
    
    methods
        
        function r = create(obj)
            r = symphonyui.core.Rig();
        end
        
        function r = load(obj, path)
            rig = symphonyui.core.Rig();
            
            file = load(path);
            rigConfig = file.rig;
            
            daqControllerConfig = rigConfig.daqController;
            rig.daqController = construct(daqControllerConfig.type);
            
            deviceConfigs = rigConfig.devices;
            for i = 1:numel(deviceConfigs)
                c = deviceConfigs{i};
                device = construct(c.type, c.name);
%                 for j = 1:numel(c.binds)
%                     device.bindStream();
%                 end
                rig.addDevice(device);
            end
            
            r = rig;
        end
        
    end
    
end

function o = construct(type, varargin)
    constructor = str2func(type);
    o = constructor(varargin{:});
end