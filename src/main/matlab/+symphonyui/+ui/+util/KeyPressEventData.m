classdef KeyPressEventData < event.EventData
    
    properties (SetAccess = private)
        key
        modifier
    end
    
    properties (Access = private)
        keyData
    end
    
    methods
        
        function obj = KeyPressEventData(keyData)
            obj.keyData = keyData;
        end
        
        function k = get.key(obj)
            k = obj.keyData.Key;
        end
        
        function m = get.modifier(obj)
            m = obj.keyData.Modifier;
        end
        
    end
    
end

