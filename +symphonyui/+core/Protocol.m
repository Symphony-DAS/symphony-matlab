classdef Protocol < symphonyui.core.mixin.SetObservable
    
    properties (Hidden)
        rig
    end
    
    methods
        
        function setRig(obj, rig)
            obj.rig = rig;
        end
        
        function [tf, msg] = isValid(obj)
            % Returns true if this protocol is fully configured and ready to run.
            if isempty(obj.rig)
                tf = false;
                msg = 'Rig is not set';
                return;
            end
            
            tf = true;
            msg = [];
        end
        
    end
    
end

