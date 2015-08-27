classdef Response < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        sampleRate
    end
    
    properties (Access = private)
        dataCache
    end
    
    methods
        
        function obj = Response(cobj)
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
        
        function [q, u] = getData(obj)
            if ~isempty(obj.dataCache)
                q = obj.dataCache.q;
                u = obj.dataCache.u;
                return;
            end
            cdata = obj.tryCoreWithReturn(@()obj.cobj.Data);
            q = double(Symphony.Core.Measurement.ToQuantityArray(cdata));
            u = char(Symphony.Core.Measurement.HomogenousDisplayUnits(cdata));
            obj.dataCache = struct('q', q, 'u', u);
        end
        
    end
    
end

