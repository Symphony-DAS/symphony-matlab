classdef UnitConvertingDevice < symphonyui.core.Device
    
    properties
        measurementConversionTarget
    end
    
    methods
        
        function obj = UnitConvertingDevice(name, measurementConversionTarget, varargin)
            ip = inputParser();
            ip.addParameter('manufacturer', 'Unspecified');
            ip.parse(varargin{:});
            
            cobj = Symphony.Core.UnitConvertingExternalDevice(name, ip.Results.manufacturer, Symphony.Core.Measurement(0, measurementConversionTarget));
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

