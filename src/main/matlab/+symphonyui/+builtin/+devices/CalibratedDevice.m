classdef CalibratedDevice < symphonyui.core.Device
    
    properties
        measurementConversionTarget
    end
    
    methods
        
        function obj = CalibratedDevice(name, measurementConversionTarget, xRamp, yRamp, varargin)
            ip = inputParser();
            ip.addParameter('manufacturer', 'Unspecified');
            ip.parse(varargin{:});
            
            lut = NET.createGeneric('System.Collections.Generic.SortedList', {'System.Decimal', 'System.Decimal'});
            for i = 1:length(xRamp)
                lut.Add(xRamp(i), yRamp(i));
            end
            
            cobj = Symphony.Core.CalibratedDevice(name, ip.Results.manufacturer, Symphony.Core.Measurement(0, measurementConversionTarget), lut);
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

