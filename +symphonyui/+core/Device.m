classdef Device < handle
    
    properties (SetAccess = private)
        name
    end
    
    methods
        
        function obj = Device(name)
            obj.name = name;
        end
        
    end
    
end

