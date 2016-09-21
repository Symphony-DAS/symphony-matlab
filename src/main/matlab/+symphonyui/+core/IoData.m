classdef IoData < symphonyui.core.CoreObject
    % IoData represents data elements in the Symphony input/output pipelines.
    %
    % IoData Methods:
    %   getData     - Gets a vector of the data
    
    properties (SetAccess = private)
        sampleRate  % Sample rate of this data (Measurement)
    end
    
    properties (Access = private)
        dataCache
    end
    
    methods
        
        function obj = IoData(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function m = get.sampleRate(obj)
            m = symphonyui.core.Measurement(obj.cobj.SampleRate);
        end
        
        function [q, u] = getData(obj)
            % Gets a vector of the data
            
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

