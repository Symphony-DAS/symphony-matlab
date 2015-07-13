classdef NullProtocol < symphonyui.core.Protocol

    methods
        
        function n = getDisplayName(obj) %#ok<MANU>
            n = '(None)';
        end

        function [tf, msg] = isValid(obj) %#ok<MANU>
            tf = false;
            msg = 'Empty protocol';
        end

    end
    
    methods (Static)
        
        function p = get(obj)
            persistent singleton;
            if isempty(singleton) || ~isvalid(singleton)
                singleton = symphonyui.app.NullProtocol();
            end
            p = singleton;
        end
        
    end

end
