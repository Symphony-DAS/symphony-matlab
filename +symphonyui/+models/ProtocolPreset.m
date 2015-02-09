classdef ProtocolPreset < handle
    
    properties (SetAccess = private)
        displayName
        parameters
    end
    
    methods
        
        function obj = ProtocolPreset(displayName, parameters)
            obj.displayName = displayName;
            obj.parameters = parameters;
        end
        
    end
    
end

