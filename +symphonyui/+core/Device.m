classdef Device < handle
    
    properties (SetAccess = private)
        name
    end
    
    properties (Access = private)
        background
    end
    
    methods
        
        function obj = Device(name)
            obj.name = name;
            obj.setBackground(0, 'V');
        end
        
        function [q, u] = getBackground(obj)
            q = obj.background.quantity;
            u = obj.background.units;
        end
        
        function setBackground(obj, quantity, units)
            if nargin < 3
                units = obj.background.units;
            end
            obj.background.quantity = quantity;
            obj.background.units = units;
        end
        
    end
    
end

