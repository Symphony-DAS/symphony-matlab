classdef GenericDevice < symphonyui.core.Device
    
    methods
        
        function obj = GenericDevice(name, manufacturer)
            if nargin < 2
                manufacturer = '';
            end
            cobj = Symphony.Core.UnitConvertingExternalDevice(name, manufacturer, Symphony.Core.Measurement(0, 'V'));
            obj@symphonyui.core.Device(cobj);
        end
        
    end
    
end

