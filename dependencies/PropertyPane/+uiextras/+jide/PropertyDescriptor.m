classdef PropertyDescriptor < matlab.mixin.SetGet
    
    properties
        Name
        Category
        Description
        IsHidden
        IsEditable
    end
    
    methods
        
        function obj = PropertyDescriptor(varargin)
            if nargin > 0
                obj.set(varargin{:});
            end
        end
        
    end
    
end

