classdef ParameterType < handle
    
    properties
        primitiveType
        shape
        domain
    end
    
    methods
        
        function obj = ParameterType(type, shape, domain)
            if nargin < 3
                domain = [];
            end
            
            obj.primitiveType = type;
            obj.shape = shape;
            obj.domain = domain;
        end
        
    end
    
end

