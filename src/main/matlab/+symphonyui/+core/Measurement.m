classdef Measurement < symphonyui.core.CoreObject
    % A Measurements represents a quantity and a unit of measure.

    properties (Constant)
        UNITLESS = '_unitless_'     % char(Symphony.Core.Measurement.UNITLESS);
        NORMALIZED = '_normalized_' % char(Symphony.Core.Measurement.NORMALIZED);
    end

    properties (SetAccess = private)
        quantity                % Quantity of this measurement
        quantityInBaseUnits     % Quantity expressed in base units (e.g. 1 mV would be 1*10^-3 V)
        baseUnits               % SI units of this measurement
        displayUnits            % Display units accounting for exponent (e.g. 1x10^-3 V has base units of 'V' but display units of 'mV')
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
            q = System.Decimal.ToDouble(obj.cobj.QuantityInBaseUnits);
        end

        function u = get.baseUnits(obj)
            u = char(obj.cobj.BaseUnits);
        end

        function u = get.displayUnits(obj)
            u = char(obj.cobj.DisplayUnits);
        end

    end

end
