classdef Rig < handle
    
    properties (Constant, Abstract)
        displayName
    end
    
    properties (Access = private)
        daq
    end
    
    methods
        
        function addDevice(obj, device)
            
        end
        
    end
    
    methods (Abstract)
        createDevices(obj);
    end
    
end

