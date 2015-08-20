classdef Protocol < handle
    
    properties (Hidden)
        displayName
        numEpochsPrepared
        numEpochsCompleted
    end
    
    methods
        
        function obj = Protocol()
            split = strsplit(class(obj), '.');
            obj.displayName = symphonyui.core.util.humanize(split{end});
        end
        
        function set.displayName(obj, n)
            validateattributes(n, {'char'}, {'nonempty', 'row'});
            obj.displayName = n;
        end
        
        function setRig(obj, rig)
            
        end
        
        function d = getPropertyDescriptors(obj)
            d = symphonyui.core.util.introspect(obj);
        end
        
        function prepareRun(obj)
            obj.numEpochsPrepared = 0;
            obj.numEpochsCompleted = 0;
        end
        
        function prepareEpoch(obj, epoch)
            obj.numEpochsPrepared = obj.numEpochsPrepared + 1;
        end
        
        function completeEpoch(obj, epoch)
            obj.numEpochsCompleted = obj.numEpochsCompleted + 1;
        end
        
        function tf = continuePreparingEpochs(obj)
            tf = false;
        end
        
        function tf = continueRun(obj)
            tf = false;
        end
        
        function completeRun(obj)
            disp(['Num epochs prepared: ' num2str(obj.numEpochsPrepared)]);
            disp(['Num epochs completed: ' num2str(obj.numEpochsCompleted)]);
        end

        function [tf, msg] = isValid(obj)
            tf = true;
            msg = [];
        end

    end

end
