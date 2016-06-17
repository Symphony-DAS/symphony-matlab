classdef NullProtocol < symphonyui.core.Protocol
    
    methods
        
        function d = getPropertyDescriptors(obj) %#ok<MANU>
            d = symphonyui.core.PropertyDescriptor.empty(0, 1);
        end
        
        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Cannot run null protocol';
        end
        
    end
    
end

