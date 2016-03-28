classdef Session < handle
    
    properties (SetObservable)
        rig
        protocol
        persistor
    end
    
    properties (SetAccess = private)
        controller
        options
        presets
    end
    
    properties (Constant)
        NULL_RIG = symphonyui.app.NullRig();
        NULL_PROTOCOL = symphonyui.app.NullProtocol();
    end
    
    methods
        
        function obj = Session(options, presets)
            obj.rig = obj.NULL_RIG;
            obj.protocol = obj.NULL_PROTOCOL;
            obj.controller = symphonyui.core.Controller();
            obj.options = options;
            obj.presets = presets;
        end
        
        function close(obj)
            obj.rig.close();
            if obj.hasPersistor()
                obj.persistor.close();
            end
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
        
    end
    
end

