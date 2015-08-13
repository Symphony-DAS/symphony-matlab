classdef Session < handle
    
    properties (Access = private)
        rig
        protocol
        persistor
    end
    
    methods
        
        function tf = hasRig(obj)
            tf = ~isempty(obj.rig);
        end
        
        function r = getRig(obj)
            if ~obj.hasRig()
                error('No current rig');
            end
            r = obj.rig;
        end
        
        function setRig(obj, r)
            obj.rig = r;
        end
        
        function tf = hasProtocol(obj)
            tf = ~isempty(obj.protocol);
        end
        
        function p = getProtocol(obj)
            if ~obj.hasProtocol()
                error('No current protocol');
            end
            p = obj.protocol;
        end
        
        function setProtocol(obj, p)
            obj.protocol = p;
        end
        
        function tf = hasPersistor(obj)
            tf = ~isempty(obj.persistor);
        end
        
        function p = getPersistor(obj)
            if ~obj.hasPersistor()
                error('No current persistor');
            end
            p = obj.persistor;
        end
        
        function setPersistor(obj, p)
            obj.persistor = p;
        end
        
    end
    
end

