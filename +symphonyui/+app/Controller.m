classdef Controller < symphonyui.mixin.Observer
    
    events
        OpenedExperiment
        ClosedExperiment
        BeganEpochGroup
        EndedEpochGroup
        ChangedRigList
        SelectedRig
        InitializedRig
        ChangedProtocolList
        SelectedProtocol
        ChangedProtocolParameters
        ChangedState
    end
    
    properties (SetAccess = private)
        state
        rigList
        protocolList
    end
    
    properties (Access = private)
        acquirer
        experiment
        rig
        protocol
        presets = symphonyui.app.Presets();
        preferences = symphonyui.app.Preferences.getDefault();
    end
    
    methods
        
        function obj = Controller(acquirer)
            if nargin < 1
                acquirer = symphonyui.models.Acquirer();
            end
            
            obj.acquirer = acquirer;
            obj.addListener(acquirer, 'state', 'PostSet', @obj.onSetControllerState);
            
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
            if nargin < 2
                className = class(obj.rig);
            end
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
            if nargin < 2
                className = class(obj.protocol);
            end
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
        
        function p = getProtocolParameters(obj)
            p = obj.protocol.getParameters();
        end
        
        function setProtocolParameters(obj, parameters)
            for i = 1:numel(parameters)
                p = parameters(i);
                if p.isReadOnly
                    continue;
                end
                obj.protocol.(p.name) = p.value;
            end
            notify(obj, 'ChangedProtocolParameters');
        end
        
        function p = getAllProtocolPresets(obj)
            p = obj.presets.getAllPresets(class(obj.protocol));
        end
        
        function record(obj)
            obj.acquirer.recordProtocol(obj.protocol, obj.experiment);
        end
        
        function run(obj)
            obj.acquirer.runProtocol(obj.protocol);
        end
        
        function pause(obj)
            obj.acquirer.pause();
        end
        
        function stop(obj)
            obj.acquirer.stop();
        end
        
        function [tf, msg] = validate(obj)
            [tf, msg] = obj.protocol.isValid;
        end
        
        function s = get.state(obj)
            s = obj.acquirer.state;
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
            notify(obj, 'ChangedRigList');
            
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
            notify(obj, 'ChangedProtocolList');
            
            % Try to default to a non-null protocol.
            try
                obj.selectProtocol(2);
            catch
                obj.selectProtocol(1);
            end
        end
        
    end
    
end

