classdef NullProtocol < symphonyui.core.Protocol
    
    properties (Constant)
        displayName = '(None)'
        version = 1
    end
    
    methods
        
        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Empty protocol';
        end
        
    end
    
end

