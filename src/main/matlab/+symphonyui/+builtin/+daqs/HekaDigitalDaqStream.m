classdef HekaDigitalDaqStream < symphonyui.core.DaqStream
    
    methods
        
        function obj = HekaDigitalDaqStream(cobj)
            obj@symphonyui.core.DaqStream(cobj);
        end
        
        function setBitPosition(obj, device, bit)
            obj.tryCore(@()obj.cobj.BitPositions.Add(device.cobj, bit));
        end
        
    end
    
end

