classdef ParameterEventData < handle
    
    properties (SetAccess = private)
        parameter
    end
    
    methods
        
        function obj = ParameterEventData(parameter)
            obj.parameter = parameter;
        end
        
    end
    
end

