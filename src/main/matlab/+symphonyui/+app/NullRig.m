classdef NullRig < symphonyui.core.Rig

    methods
        
        function obj = NullRig()
            obj@symphonyui.core.Rig(symphonyui.core.descriptions.RigDescription());
        end
        
        function initialize(obj)
        end
        
        function close(obj)
        end
        
        function [tf, msg] = isValid(obj)
            tf = false;
            msg = 'Empty rig';
        end

    end

end
