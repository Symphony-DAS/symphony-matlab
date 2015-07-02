classdef PropertyDescriptor < matlab.mixin.SetGet
    
    properties
        Name
        Domain
        Category
        DisplayName
        Description
        ReadOnly
        Hidden
    end
    
    methods
        
        function obj = PropertyDescriptor(name, varargin)
            obj.Name = name;
            if nargin > 1
                obj.set(varargin{:});
            end
        end
        
    end
    
end

