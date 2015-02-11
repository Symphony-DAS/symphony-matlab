classdef AppController < symphonyui.mixin.Observer
    
    events
        OpenedExperiment
        ClosedExperiment
        BeganEpochGroup
        EndedEpochGroup
        SetRigList
        SelectedRig
        InitializedRig
        SetProtocolList
        SelectedProtocol
        ChangedState
    end
    
    properties (SetAccess = private)
        experiment
        rigList
        rig
        protocolList
        protocol
        state
    end
    
    properties (Access = private)
        controller
        preferences = symphonyui.app.Preferences.getDefault();
    end
    
    methods
        
        function obj = AppController(controller)
            if nargin < 1
                controller = symphonyui.models.Controller();
            end
            
            obj.controller = controller;
            obj.addListener(controller, 'state', 'PostSet', @obj.onSetControllerState);
            
            rigPref = obj.preferences.rigPreferences;
            obj.addListener(rigPref, 'searchPaths', 'PostSet', @obj.onSetRigSearchPaths);
            
            protocolPref = obj.preferences.protocolPreferences;
            obj.addListener(protocolPref, 'searchPaths', 'PostSet', @obj.onSetProtocolSearchPaths);
            
            obj.onSetProtocolSearchPaths();
            obj.onSetRigSearchPaths();
        end
        
        function openExperiment(obj, path, purpose, source)
            if obj.hasExperiment
                error('An experiment is already open');
            end
            exp = symphonyui.models.Experiment(path, purpose, source);
            exp.open();
            obj.experiment = exp;
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
            obj.reloadProtocol();
            notify(obj, 'SelectedRig');
        end
        
        function initializeRig(obj)
            obj.rig.initialize();
            notify(obj, 'InitializedRig');
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
        
        function [tf, msg] = validate(obj)
            [tf, msg] = obj.protocol.isValid;
        end
        
        function s = get.state(obj)
            s = obj.controller.state;
        end
        
    end
    
    methods (Access = private)
        
        function onSetControllerState(obj, ~, ~)
            notify(obj, 'ChangedState');
        end
        
        function onSetRigSearchPaths(obj, ~, ~)
            import symphonyui.util.search;
            pref = obj.preferences.rigPreferences;
            list = search(pref.searchPaths, 'symphonyui.models.Rig');
            obj.rigList = ['symphonyui.models.NullRig' list];
            notify(obj, 'SetRigList');
            
            % Try to default to a non-null rig.
            try
                obj.selectRig(2);
            catch
                obj.selectRig(1);
            end
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            import symphonyui.util.search;
            pref = obj.preferences.protocolPreferences;
            list = search(pref.searchPaths, 'symphonyui.models.Protocol');
            obj.protocolList = ['symphonyui.models.NullProtocol' list];
            notify(obj, 'SetProtocolList');
            
            % Try to default to a non-null protocol.
            try
                obj.selectProtocol(2);
            catch
                obj.selectProtocol(1);
            end
        end
        
    end
    
end

