classdef NiDigitalDaqStream < symphonyui.core.DaqStream
    
    methods
        
        function obj = NiDigitalDaqStream(cobj)
            obj@symphonyui.core.DaqStream(cobj);
        end
        
        function setBitPosition(obj, device, bit)
            % Associates a bound device with a particular line of a port.
            
            obj.tryCore(@()obj.cobj.BitPositions.Add(device.cobj, bit));
        end
        
        function tf = supportsContinuousSampling(obj)
            tf = obj.cobj.SupportsContinuousSampling;
        end
        
    end
    
end

