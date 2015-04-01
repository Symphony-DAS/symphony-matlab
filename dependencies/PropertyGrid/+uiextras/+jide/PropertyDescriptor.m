classdef PropertyDescriptor < matlab.mixin.SetGet
    
    properties
        Name
        Type
        Category
        DisplayName
        Description
        ReadOnly
        Dependent
        Hidden
    end
    
    methods
        
        function obj = PropertyDescriptor(varargin)
            if nargin > 0
                obj.set(varargin{:});
            end
        end
        
    end
    
end

