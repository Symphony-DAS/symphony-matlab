classdef Test < symphonyui.core.Protocol
    
    properties
        numberOfAverages = uint16(5)    % Number of epochs
    end
    
    methods
        
        function tf = continuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = continueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
    end
    
end

