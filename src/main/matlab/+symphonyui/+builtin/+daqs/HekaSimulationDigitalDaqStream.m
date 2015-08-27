classdef HekaSimulationDigitalDaqStream < symphonyui.core.DaqStream
    
    methods
        
        function obj = HekaSimulationDigitalDaqStream(cobj)
            obj@symphonyui.core.DaqStream(cobj);
        end
        
        function setBitPosition(obj, device, bit) %#ok<INUSD>
            % Do nothing.
        end
        
    end
    
end

