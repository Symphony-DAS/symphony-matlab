classdef PropertyDescriptor < matlab.mixin.SetGet
    
    properties
        Name
        Description
    end
    
    methods
        
        function obj = PropertyDescriptor(varargin)
            obj.set(varargin{:});
        end
        
    end
    
end

