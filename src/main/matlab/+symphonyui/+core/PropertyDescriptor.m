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
        
        function p = findByName(array, name)
            p = [];
            for i = 1:numel(array)
                if strcmp(name, array(i).name)
                    p = array(i);
                    return;
                end
            end
        end
        
    end
    
end

