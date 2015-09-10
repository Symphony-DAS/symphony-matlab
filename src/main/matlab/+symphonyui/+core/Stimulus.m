classdef Stimulus < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        sampleRate
        parameters
    end
    
    methods
        
        function obj = Stimulus(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function p = get.parameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Parameters);
        end
        
        function [q, u] = getData(obj)
            import Symphony.Core.*;
            cdur = obj.cobj.Duration;
            if cdur.IsNone()
                q = [];
                u = '';
                return;
            end
            enum = obj.tryCoreWithReturn(@()obj.cobj.DataBlocks(cdur.Item2));
            cblk = obj.cellArrayFromEnumerable(enum);
            d = cblk{1}.Data;
            q = double(Measurement.ToQuantityArray(d));
            u = char(Measurement.HomogenousDisplayUnits(d));
        end
        
    end
    
end

