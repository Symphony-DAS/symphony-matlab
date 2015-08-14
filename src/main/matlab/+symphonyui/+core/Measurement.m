classdef Measurement < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        quantity
        displayUnits
    end
    
    methods
        
        function obj = Measurement(quantity, units)
            if isa(quantity, 'Symphony.Core.Measurement')
                cobj = quantity;
            else
                cobj = Symphony.Core.Measurement(quantity, units);
            end
            
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function q = get.quantity(obj)
            q = System.Decimal.ToDouble(obj.cobj.Quantity);
        end
        
        function u = get.displayUnits(obj)
            u = char(obj.cobj.DisplayUnits);
        end
        
    end
    
end

