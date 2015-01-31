classdef AppData < handle
    
    events
        SetExperiment
        SetRigList
        SetRig
        SetProtocolList
        SetProtocol
    end
    
    properties (SetAccess = private)
        preferences
        controller
        experiment
        rigList
        rig
        protocolList
        protocol
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
            
            obj.onSetRigSearchPaths();
            obj.onSetProtocolSearchPaths();
        end
        
        function setRig(obj, index)
            className = obj.rigList{index};
            constructor = str2func(className);
            r = constructor();
            obj.protocol.rig = r;
            obj.rig = r;
            notify(obj, 'SetRig');
        end
        
        function setProtocol(obj, index)
            className = obj.protocolList{index};
            constructor = str2func(className);
            p = constructor();
            p.rig = obj.rig;
            obj.controller.setProtocol(p);
            obj.protocol = p;
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
            try
                obj.setRig(2);
            catch
                obj.setRig(1);
            end
            notify(obj, 'SetRigList');
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            obj.protocolList = search(obj.preferences.protocolSearchPaths, 'symphonyui.models.Protocol');
            obj.protocolList = ['symphonyui.models.NullProtocol' obj.protocolList];
            try
                obj.setProtocol(2);
            catch
                obj.setProtocol(1);
            end
            notify(obj, 'SetProtocolList');
        end
        
    end
    
end

