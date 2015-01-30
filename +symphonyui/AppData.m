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
        rigList
        protocol
        protocolList
        experiment
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
        
        function setRig(obj, index)
            className = obj.rigList{index};
            constructor = str2func(className);
            obj.controller.setRig(constructor());
        end
        
        function setProtocol(obj, index)
            className = obj.protocolList{index};
            constructor = str2func(className);
            obj.protocol = constructor();
            notify(obj, 'SetProtocol');
        end
        
        function tf = hasExperiment(obj)
            tf = ~isempty(obj.experiment);
        end
        
        function setExperiment(obj, experiment)
            obj.experiment = experiment;
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
            obj.rigList = search(obj.preferences.rigSearchPaths, 'symphonyui.models.Rig');
            obj.rigList = ['symphonyui.models.NullRig' obj.rigList];
            obj.setRig(1);
            notify(obj, 'SetRigList');
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            obj.protocolList = search(obj.preferences.protocolSearchPaths, 'symphonyui.models.Protocol');
            obj.protocolList = ['symphonyui.models.NullProtocol' obj.protocolList];
            obj.setProtocol(1);
            notify(obj, 'SetProtocolList');
        end
        
    end
    
end

