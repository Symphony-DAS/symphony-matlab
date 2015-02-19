classdef Controller < symphonyui.mixin.Observer
    
    events
        OpenedExperiment
        ClosedExperiment
        BeganEpochGroup
        EndedEpochGroup
        ChangedRigClassNames
        ChangedProtocolClassNames
        SelectedRig
        SelectedProtocol
        ChangedState
    end
    
    properties (SetAccess = private)
        experiment
        rig
        protocol
        state
    end
    
    properties (Access = private)
        acquirer
        rigDiscoverer
        protocolDiscoverer
    end
    
    methods
        
        function obj = Controller()
            import symphonyui.*;
            
            obj.acquirer = models.Acquirer();
            obj.rigDiscoverer = app.Discoverer('symphonyui.models.Rig');
            obj.protocolDiscoverer = app.Discoverer('symphonyui.models.Protocol');
            
            obj.addListener(obj.acquirer, 'state', 'PostSet', @(h,d)notify(obj, 'ChangedState'));
            obj.addListener(app.Settings.general, 'rigSearchPaths', 'PostSet', @obj.onSetRigSearchPaths);
            obj.addListener(app.Settings.general, 'protocolSearchPaths', 'PostSet', @obj.onSetProtocolSearchPaths);
            
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
        
        function n = getRigClassNames(obj)
            % Always include a NullRig so something is guaranteed to be selectable. 
            n = ['symphonyui.models.NullRig' obj.rigDiscoverer.classNames];
        end
        
        function selectRig(obj, index)
            className = obj.getRigClassNames{index};
            constructor = str2func(className);
            obj.rig = constructor();
            obj.reloadProtocol();
            notify(obj, 'SelectedRig');
        end
        
        function selectRigByClassName(obj, className)
            index = ismember(obj.getRigClassNames, className);
            if ~any(index)
                error(['''' className ''' is not a member of the rig class names']);
            end
            obj.selectRig(index);
        end
        
        function n = getProtocolClassNames(obj)
            % Always include a NullProtocol so something is guaranteed to be selectable. 
            n = ['symphonyui.models.NullRig' obj.protocolDiscoverer.classNames];
        end
        
        function selectProtocol(obj, index)
            className = obj.getProtocolClassNames{index};
            constructor = str2func(className);
            obj.protocol = constructor();
            obj.protocol.rig = obj.rig;
            notify(obj, 'SelectedProtocol');
        end
        
        function selectProtocolByClassName(obj, className)
            index = ismember(obj.getProtocolClassNames, className);
            if ~any(index)
                error(['''' className ''' is not a member of the protocol class names']);
            end
            obj.selectProtocol(index);
        end
        
        function reloadProtocol(obj)
            constructor = str2func(class(obj.protocol));
            obj.protocol = constructor();
            obj.protocol.rig = obj.rig;
            notify(obj, 'SelectedProtocol');
        end
        
        function record(obj)
            obj.acquirer.recordProtocol(obj.protocol, obj.experiment);
        end
        
        function preview(obj)
            obj.acquirer.previewProtocol(obj.protocol);
        end
        
        function pause(obj)
            obj.acquirer.pause();
        end
        
        function stop(obj)
            obj.acquirer.stop();
        end
        
        function s = get.state(obj)
            s = obj.acquirer.state;
        end
        
        function [tf, msg] = validate(obj)
            [tf, msg] = obj.protocol.isValid;
        end
        
    end
    
    methods (Access = private)
        
        function onSetRigSearchPaths(obj, ~, ~)
            paths = symphonyui.util.strToCell(symphonyui.app.Settings.general.rigSearchPaths);
            obj.rigDiscoverer.setPaths(paths);
            obj.rigDiscoverer.discover();
            notify(obj, 'ChangedRigClassNames');
            
            % Try to default to a non-null rig.
            try
                obj.selectRig(2);
            catch
                obj.selectRig(1);
            end
        end
        
        function onSetProtocolSearchPaths(obj, ~, ~)
            paths = symphonyui.util.strToCell(symphonyui.app.Settings.general.protocolSearchPaths);
            obj.protocolDiscoverer.setPaths(paths);
            obj.protocolDiscoverer.discover();
            notify(obj, 'ChangedProtocolClassNames');
            
            % Try to default to a non-null protocol.
            try
                obj.selectProtocol(2);
            catch
                obj.selectProtocol(1);
            end
        end
        
    end
    
end

