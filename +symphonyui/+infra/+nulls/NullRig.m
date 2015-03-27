classdef NullRig < symphonyui.core.Rig

    properties (Constant)
        displayName = '(None)'
        version = 1
    end

    methods

        function setup(obj) %#ok<MANU>

        end

        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Empty rig';
        end

    end

end
