classdef NullProtocol < symphonyui.models.Protocol
    
    properties (Constant)
        displayName = '(None)'
    end
    
    methods
        
        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Empty protocol';
        end
        
    end
    
end

