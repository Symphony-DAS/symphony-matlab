classdef Session < handle
    
    properties (SetObservable)
        rig
        protocol
        persistor
        modules
    end
    
    properties (SetAccess = private)
        controller
    end
    
    properties (Constant)
        NULL_RIG = symphonyui.app.NullRig();
        NULL_PROTOCOL = symphonyui.app.NullProtocol();
    end
    
    methods
        
        function obj = Session(controller)
            if nargin < 1
                controller = symphonyui.core.Controller();
            end
            obj.rig = obj.NULL_RIG;
            obj.protocol = obj.NULL_PROTOCOL;
            obj.controller = controller;
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

