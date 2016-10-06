classdef Background < symphonyui.core.persistent.IoBase

    methods

        function obj = Background(cobj)
            obj@symphonyui.core.persistent.IoBase(cobj);
        end

        function [q, u] = getValue(obj)
            v = obj.cobj.Value;
            q = double(System.Decimal.ToDouble(v.Quantity));
            u = char(v.DisplayUnits);
        end

        function [q, u] = getSampleRate(obj)
            s = obj.cobj.SampleRate;
            q = double(System.Decimal.ToDouble(s.Quantity));
            u = char(s.DisplayUnits);
        end
        
        function [q, u] = getData(obj)
            epoch = obj.epoch;
            d = epoch.endTime - epoch.startTime;
            [v, u] = obj.getValue();
            s = double(System.Decimal.ToDouble(obj.cobj.SampleRate.QuantityInBaseUnits));
            q = v * ones(1, round(s * milliseconds(d) / 1000));
        end

    end

end
