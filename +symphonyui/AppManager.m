classdef AppManager < handle
    
    events
        OpenedExperiment
        ClosedExperiment
        BeganEpochGroup
        EndedEpochGroup
        SetRigList
        SetProtocolList
        SelectedRig
        SelectedProtocol
        StateChange
    end
    
    properties (SetAccess = private)
        preferences
        experiment
        rigList
        protocolList
        rig
        protocol
        controller
    end
    
    methods
        
        function obj = AppManager(preferences)
            if nargin < 1
                preferences = symphonyui.preferences.AppPreferences();
                preferences.setToDefaults();
            end
            
            obj.preferences = preferences;
            addlistener(preferences, 'rigSearchPaths', 'PostSet', @obj.onSetRigSearchPaths);
            addlistener(preferences, 'protocolSearchPaths', 'PostSet', @obj.onSetProtocolSearchPaths);
            
            obj.controller = symphonyui.models.Controller();
            addlistener(obj.controller, 'state', 'PostSet', @(h,d)notify(obj, 'StateChange'));
            
            obj.onSetProtocolSearchPaths();
            obj.onSetRigSearchPaths();
        end
        
        function openExperiment(obj, path, purpose, source)
            if obj.hasExperiment
                error('An experiment is already open');
            end
            
            e = symphonyui.models.Experiment(path, purpose, source);
            e.open();
            obj.experiment = e;
            notify(obj, 'OpenedExperiment');
        end
        
        function closeExperiment(obj)
            if ~obj.hasExperiment
                error('No experiment open');
            end
            
            obj.experiment.close();
            obj.experiment = [];
            notify(obj, 'ClosedExperiment');
        end
        
        function tf = hasExperiment(obj)
            tf = ~isempty(obj.experiment);
        end
        
        function beginEpochGroup(obj, label, source, keywords, attributes)
            if ~obj.hasExperiment
                error('No experiment');
            end
            
            obj.experiment.beginEpochGroup(label, source, keywords, attributes);
            notify(obj, 'BeganEpochGroup');
        end
        
        function endEpochGroup(obj)
            if ~obj.hasEpochGroup
                error('No epoch group');
            end
            
            obj.experiment.endEpochGroup();
            notify(obj, 'EndedEpochGroup');
        end
        
        function tf = hasEpochGroup(obj)
            tf = obj.hasExperiment && ~isempty(obj.experiment.epochGroup);
        end
        
        function i = getRigIndex(obj, className)
            i = find(ismember(obj.rigList, className));
        end
        
        function selectRig(obj, index)
            if index == obj.getRigIndex(class(obj.rig))
                return;
            end
            className = obj.rigList{index};
            constructor = str2func(className);
            obj.rig = constructor();
            obj.rig.initialize();
            obj.reloadProtocol();
            notify(obj, 'SelectedRig');
        end
        
        function i = getProtocolIndex(obj, className)
            i = find(ismember(obj.protocolList, className), 1);
        end
        
        function selectProtocol(obj, index)
            if index == obj.getProtocolIndex(class(obj.protocol))
                return;
            end
            className = obj.protocolList{index};
            constructor = str2func(className);
            obj.protocol = constructor();
            obj.protocol.rig = obj.rig;
            notify(obj, 'SelectedProtocol');
        end
        
        function reloadProtocol(obj)
            constructor = str2func(class(obj.protocol));
            obj.protocol = constructor();
            obj.protocol.rig = obj.rig;
            notify(obj, 'SelectedProtocol');
        end
        
        function run(obj)
            obj.controller.runProtocol(obj.protocol);
        end
        
        function pause(obj)
            obj.controller.pause();
        end
        
        function stop(obj)
            obj.controller.stop();
        end
        
        function s = state(obj)
            s = obj.controller.state;
        end
        
        function [valid, msg] = validate(obj)
            [valid, msg] = obj.controller.validateProtocol(obj.protocol);
        end
        
    end
    
    methods (Access = private)
        
        function onSetRigSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            obj.rigList = search(obj.preferences.rigSearchPaths, 'symphonyui.models.Rig');
            obj.rigList = ['symphonyui.models.NullRig' obj.rigList];
            notify(obj, 'SetRigList');
            obj.selectRig(1);
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.utilities.*;
            obj.protocolList = search(obj.preferences.protocolSearchPaths, 'symphonyui.models.Protocol');
            obj.protocolList = ['symphonyui.models.NullProtocol' obj.protocolList];
            notify(obj, 'SetProtocolList');
            obj.selectProtocol(1);
        end
        
    end
    
end

