classdef Response < symphonyui.core.CoreObject
    % A Response represents a single response (i.e. the input from a single device) during an epoch.
    %
    % Response Methods:
    %   getData     - Gets a vector of the data of this response
    
    properties (SetAccess = private)
        sampleRate  % Sample rate of this response (Measurement)
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
            % Gets a vector of the data of this response
            
            if ~isempty(obj.dataCache)
                q = obj.dataCache.q;
                u = obj.dataCache.u;
                return;
            end
            cdata = obj.tryCoreWithReturn(@()obj.cobj.Data);
            if NET.invokeGenericMethod('System.Linq.Enumerable', 'Any', {'Symphony.Core.IMeasurement'}, cdata)
                q = double(Symphony.Core.Measurement.ToQuantityArray(cdata));
                u = char(Symphony.Core.Measurement.HomogenousDisplayUnits(cdata));
            else
                q = [];
                u = '';
            end
            obj.dataCache = struct('q', q, 'u', u);
        end
        
    end
    
end

