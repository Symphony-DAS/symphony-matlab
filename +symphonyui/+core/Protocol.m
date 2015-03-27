classdef Protocol < symphonyui.infra.mixin.Discoverable
    
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
            
%             properties = obj.getAllProperties();
%             for i = 1:numel(properties)
%                 if ~properties(i).isValid
%                     tf = false;
%                     msg = [properties(i).displayName ' is not valid'];
%                     return;
%                 end
%             end
            
            tf = true;
            msg = [];
        end
        
    end
    
end

