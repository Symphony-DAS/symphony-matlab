classdef DaqStream < symphonyui.core.CoreObject
    % A DaqStream represents a hardware channel of a DAQ device.
    
    properties (SetAccess = private)
        name    % Name of this stream
        active  % Indicates if this stream has an associated device   
    end
    
    properties
        sampleRate                      % Sample rate of this stream (Measurement)
        measurementConversionTarget     % What is this stream converting Measurements to? (e.g. volts, ohms, etc.) 
    end
    
    methods
        
        function obj = DaqStream(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end
        
        function tf = get.active(obj)
            tf = obj.cobj.Active;
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function set.sampleRate(obj, measurement)
            if isempty(measurement)
                cm = [];
            else
                cm = measurement.cobj;
            end
            obj.cobj.SampleRate = cm;
        end
        
        function t = get.measurementConversionTarget(obj)
            t = char(obj.cobj.MeasurementConversionTarget);
        end
        
        function set.measurementConversionTarget(obj, t)
            obj.cobj.MeasurementConversionTarget = t;
        end
        
    end
    
end

