classdef Response < symphonyui.core.persistent.IoBase

    properties (SetAccess = private)
        inputTime
    end

    methods

        function obj = Response(cobj, factory)
            obj@symphonyui.core.persistent.IoBase(cobj, factory);
        end

        function t = get.inputTime(obj)
            t = obj.datetimeFromDateTimeOffset(obj.cobj.InputTime);
        end

        function [q, u] = getSampleRate(obj)
            s = obj.cobj.SampleRate;
            q = double(System.Decimal.ToDouble(s.QuantityInBaseUnits));
            u = char(s.BaseUnits);
        end

        function [q, u] = getData(obj)
            import Symphony.Core.*;
            d = obj.cobj.Data;
            q = double(Measurement.ToQuantityArray(d));
            u = char(Measurement.HomogenousDisplayUnits(d));
        end

    end

end
