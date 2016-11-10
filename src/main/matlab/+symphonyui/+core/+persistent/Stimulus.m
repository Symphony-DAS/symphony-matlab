classdef Stimulus < symphonyui.core.persistent.IoBase

    properties (SetAccess = private)
        stimulusId
        units
        parameters
        duration
    end

    methods

        function obj = Stimulus(cobj, factory)
            obj@symphonyui.core.persistent.IoBase(cobj, factory);
        end

        function i = get.stimulusId(obj)
            i = char(obj.cobj.StimulusID);
        end

        function u = get.units(obj)
            u = char(obj.cobj.Units);
        end

        function p = get.parameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Parameters);
        end

        function d = get.duration(obj)
            d = obj.cobj.Duration.TotalSeconds;
        end

        function [q, u] = getSampleRate(obj)
            s = obj.cobj.SampleRate;
            q = double(System.Decimal.ToDouble(s.Quantity));
            u = char(s.DisplayUnits);
        end

        function [q, u] = getData(obj)
            import Symphony.Core.*;
            d = obj.cobj.Data;
            if d.IsSome
                q = double(Measurement.ToQuantityArray(d.Item2));
                u = char(Measurement.HomogenousDisplayUnits(d.Item2));
            else
                s = obj.regenerate();
                [q, u] = s.getData();
            end
        end

        function s = regenerate(obj)
            constructor = str2func(obj.stimulusId);
            generator = constructor(obj.parameters);
            s = generator.generate();
        end

    end

end
