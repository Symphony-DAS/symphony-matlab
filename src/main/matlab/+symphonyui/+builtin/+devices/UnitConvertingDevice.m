classdef UnitConvertingDevice < symphonyui.core.Device
    
    properties
        measurementConversionTarget
    end
    
    methods
        
        function obj = UnitConvertingDevice(name, measurementConversionTarget, manufacturer)
            if nargin < 3
                manufacturer = 'Unspecified';
            end
            cobj = Symphony.Core.UnitConvertingExternalDevice(name, manufacturer, Symphony.Core.Measurement(0, measurementConversionTarget));
            obj@symphonyui.core.Device(cobj);
            
            obj.measurementConversionTarget = measurementConversionTarget;
        end
        
        function t = get.measurementConversionTarget(obj)
            t = char(obj.cobj.MeasurementConversionTarget);
        end
        
        function set.measurementConversionTarget(obj, t)
            obj.cobj.MeasurementConversionTarget = t;
        end
        
    end
    
end

