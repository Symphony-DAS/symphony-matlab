classdef NullProtocol < symphonyui.core.Protocol

    methods

        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Empty protocol';
        end

    end

end
