classdef NullRig < symphonyui.core.Rig

    methods
        
        function obj = NullRig()
            
        end
        
        function [tf, msg] = isValid(obj)
            tf = false;
            msg = 'Empty rig';
        end

    end

end
