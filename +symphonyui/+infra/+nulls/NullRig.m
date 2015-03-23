classdef NullRig < symphonyui.core.Rig

    properties (Constant)
        DISPLAY_NAME = '(None)'
        VERSION = 1
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
