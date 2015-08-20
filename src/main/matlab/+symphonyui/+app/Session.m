classdef Session < handle
    
    properties (SetObservable)
        rig
        protocol
        persistor
    end
    
    properties (SetAccess = private)
        controller
    end
    
    methods
        
        function obj = Session(controller)
            if nargin < 1
                controller = symphonyui.core.Controller();
            end
            obj.controller = controller;
        end
        
        function close(obj)
            if obj.hasRig()
                obj.rig.close();
            end
            if obj.hasPersistor()
                obj.persistor.close();
            end
        end
        
        function tf = hasRig(obj)
            tf = ~isempty(obj.rig);
        end
        
        function r = getRig(obj)
            if ~obj.hasRig()
                error('No current rig');
            end
            r = obj.rig;
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

