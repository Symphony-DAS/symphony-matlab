classdef GenericDevice < symphonyui.core.Device
    
    properties
        measurementConversionTarget
    end
    
    methods
        
        function obj = GenericDevice(name, manufacturer)
            if nargin < 2
                manufacturer = 'unspecified';
            end
            cobj = Symphony.Core.UnitConvertingExternalDevice(name, manufacturer, Symphony.Core.Measurement(0, 'V'));
            obj@symphonyui.core.Device(cobj);
            
            obj.measurementConversionTarget = 'V';
        end
        
        function t = get.measurementConversionTarget(obj)
            t = char(obj.cobj.MeasurementConversionTarget);
        end
        
        function set.measurementConversionTarget(obj, t)
            obj.cobj.MeasurementConversionTarget = t;
        end        
    end
    
end

