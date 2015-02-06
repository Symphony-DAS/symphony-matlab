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
            if nargin < 1
                preferences = symphonyui.preferences.AppPreferences();
                preferences.setToDefaults();
            end
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
        
        function tf = hasExperiment(obj)
            tf = ~isempty(obj.experiment);
        end
        
        function setExperiment(obj, experiment)
            obj.experiment = experiment;
            notify(obj, 'SetExperiment');
        end
        
        function i = getRigIndex(obj, rig)
            if nargin < 2
                if isempty(obj.rig)
                    i = [];
                    return;
                end
                rig = class(obj.rig);
            end
            i = ismember(obj.rigList, rig);
            i = find(i, 1);
        end
        
        function setRig(obj, index)
            if isempty(index)
                return;
            end
            
            className = obj.rigList{index};
            constructor = str2func(className);
            obj.rig = constructor();
            obj.setProtocol(obj.getProtocolIndex());
            notify(obj, 'SetRig');
        end
        
        function i = getProtocolIndex(obj, protocol)
            if nargin < 2
                if isempty(obj.protocol)
                    i = [];
                    return;
                end
                protocol = class(obj.protocol);
            end
            i = ismember(obj.protocolList, protocol);
            i = find(i, 1);
        end
        
        function setProtocol(obj, index)
            if isempty(index)
                return;
            end
            
            className = obj.protocolList{index};
            constructor = str2func(className);
            obj.protocol = constructor();
            obj.protocol.rig = obj.rig;
            notify(obj, 'SetProtocol');
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
            notify(obj, 'SetRigList');
            
            try
                obj.setRig(2);
            catch
                obj.setRig(1);
            end
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            obj.protocolList = search(obj.preferences.protocolSearchPaths, 'symphonyui.models.Protocol');
            obj.protocolList = ['symphonyui.models.NullProtocol' obj.protocolList];
            notify(obj, 'SetProtocolList');
            
            try
                obj.setProtocol(2);
            catch
                obj.setProtocol(1);
            end
        end
        
    end
    
end

