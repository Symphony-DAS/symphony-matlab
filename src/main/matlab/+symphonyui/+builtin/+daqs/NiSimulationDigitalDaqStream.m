classdef NiSimulationDigitalDaqStream < symphonyui.core.DaqStream
    
    methods
        
        function obj = NiSimulationDigitalDaqStream(cobj)
            obj@symphonyui.core.DaqStream(cobj);
        end
        
        function setBitPosition(obj, device, bit) %#ok<INUSD>
            % Do nothing.
        end
        
        function tf = supportsContinuousSampling(obj) %#ok<MANU>
            tf = true;
        end
        
    end
    
end

