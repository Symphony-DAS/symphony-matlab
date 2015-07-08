classdef Stimulus < symphonyui.core.persistent.IoBase
    
    properties (SetAccess = private)
        stimulusId
        units
        parameters
        duration
    end
    
    methods
        
        function obj = Stimulus(cobj, entityFactory)
            obj@symphonyui.core.persistent.IoBase(cobj, entityFactory);
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
            u = char(s.DisplayUnit);
        end
        
        function [q, u] = getData(obj)
            import Symphony.Core.*;
            d = obj.cobj.Data;
            if d.HasValue
                q = double(Measurement.ToQuantityArray(d));
                u = char(Measurement.HomogenousDisplayUnits(d));
            else
                q = [];
                u = [];
            end
        end
        
    end
    
end

