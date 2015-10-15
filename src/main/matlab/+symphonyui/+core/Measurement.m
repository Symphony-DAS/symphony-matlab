classdef Measurement < symphonyui.core.CoreObject
    
    properties (Constant)
        UNITLESS = '_unitless_'     % char(Symphony.Core.Measurement.UNITLESS);
        NORMALIZED = '_normalized_' % char(Symphony.Core.Measurement.NORMALIZED);
    end
    
    properties (SetAccess = private)
        quantity
        quantityInBaseUnits
        baseUnits
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
        
        function q = get.quantityInBaseUnits(obj)
            % TODO: This should be changed in the core to be QuantityInBaseUnits (plural)
            q = System.Decimal.ToDouble(obj.cobj.QuantityInBaseUnit);
        end
        
        function u = get.baseUnits(obj)
            % TODO: This should be changed in the core to be BaseUnits (plural)
            u = char(obj.cobj.BaseUnit);
        end 
        
        function u = get.displayUnits(obj)
            % TODO: This should be changed in the core to be DisplayUnits (plural)
            u = char(obj.cobj.DisplayUnit);
        end
        
    end
    
end

