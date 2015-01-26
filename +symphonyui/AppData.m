classdef AppData < handle
    
    events
        SetRig
        SetRigList
        SetProtocol
        SetProtocolList
        SetExperiment
        SetControllerState
    end
    
    properties (SetAccess = private)
        preferences
        controller
        rig
        protocol
        experiment
    end
    
    properties (Access = private)
        rigMap
        protocolMap
    end
    
    methods
        
        function obj = AppData(preferences, controller)
            if nargin < 2
                controller = symphonyui.models.Controller();
            end
            
            obj.preferences = preferences;
            obj.controller = controller;
            
            addlistener(preferences, 'rigSearchPaths', 'PostSet', @obj.onSetRigSearchPaths);
            addlistener(preferences, 'protocolSearchPaths', 'PostSet', @obj.onSetProtocolSearchPaths);
            addlistener(controller, 'rig', 'PostSet', @(h,d)notify(obj, 'SetRig'));
            addlistener(controller, 'state', 'PostSet', @(h,d)notify(obj, 'SetControllerState'));
            
            obj.onSetRigSearchPaths();
            obj.onSetProtocolSearchPaths();
        end
        
        function r = get.rig(obj)
            r = obj.controller.rig;
        end
        
        function setRig(obj, rigName)
            className = obj.rigMap(rigName);
            constructor = str2func(className);
            obj.controller.setRig(constructor());
        end
        
        function r = getRigList(obj)
            r = obj.rigMap.keys;
        end
        
        function n = getProtocolName(obj)
            if isempty(obj.protocol)
                n = '';
            else
                n = symphonyui.utilities.classProperty(class(obj.protocol), 'displayName');
            end
        end
        
        function setProtocol(obj, protocolName)
            className = obj.protocolMap(protocolName);
            constructor = str2func(className);
            obj.protocol = constructor();
            notify(obj, 'SetProtocol');
        end
        
        function p = getProtocolList(obj)
            p = obj.protocolMap.keys;
        end
        
        function setExperiment(obj, e)
            obj.experiment = e;
            notify(obj, 'SetExperiment');
        end
        
        function p = experimentPreferences(obj)
            p = obj.preferences.experimentPreferences;
        end
        
        function p = epochGroupPreferences(obj)
            p = obj.preferences.epochGroupPreferences;
        end
        
    end
    
    methods (Access = private)
        
        function onSetRigSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            
            obj.rigMap = containers.Map();
            
            list = search(obj.preferences.rigSearchPaths, 'symphonyui.models.Rig');
            for i = 1:length(list)
                displayName = classProperty(list{i}, 'displayName');
                obj.rigMap(displayName) = list{i};
            end
            
            notify(obj, 'SetRigList');
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            
            obj.protocolMap = containers.Map();
            
            list = search(obj.preferences.protocolSearchPaths, 'symphonyui.models.Protocol');
            for i = 1:length(list)
                displayName = classProperty(list{i}, 'displayName');
                obj.protocolMap(displayName) = list{i};
            end
            
            notify(obj, 'SetProtocolList');
        end
        
    end
    
end

