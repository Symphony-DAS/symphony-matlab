classdef PropertyDescriptor < matlab.mixin.SetGet
    
    properties
        name
        value
        type
        readOnly
    end
    
    methods
        
        function obj = PropertyDescriptor(name, value, varargin)
            obj.name = name;
            obj.value = value;
            if nargin > 2
                obj.set(varargin{:});
            end
        end
        
    end
    
end

