classdef AppData < handle
    
    events
        SetExperiment
        SetProtocol
        SetController
        BeganEpochGroup
        EndedEpochGroup
        SetState
    end
    
    properties (SetAccess = private)
        appPreferences
        experiment
        protocol
        controller
    end
    
    properties (Access = private)
        listeners
    end
    
    methods
        
        function obj = AppData(appPreferences)
            obj.appPreferences = appPreferences;
            
            addlistener(obj, 'SetExperiment', @obj.onSetExperiment);
            addlistener(obj, 'SetProtocol', @obj.onSetProtocol);
            addlistener(obj, 'SetController', @obj.onSetController);
            
            obj.listeners.experiment = [];
            obj.listeners.protocol = [];
            obj.listeners.controller = [];
        end
        
        function setExperiment(obj, experiment)            
            obj.experiment = experiment;
            notify(obj, 'SetExperiment');
        end
        
        function setProtocol(obj, protocol)
            obj.protocol = protocol;
            notify(obj, 'SetProtocol');
        end
        
        function setController(obj, controller)
            obj.controller = controller;
            notify(obj, 'SetController');
        end
        
    end
    
    methods (Access = private)
        
        function onSetExperiment(obj, ~, ~)
            while ~isempty(obj.listeners.experiment)
                delete(obj.listeners.experiment{1});
                obj.listeners.experiment(1) = [];
            end
            
            if isempty(obj.experiment)
                return;
            end
            
            obj.listeners.experiment{end + 1} = addlistener(obj.experiment, 'BeganEpochGroup', @(h,d)notify(obj, 'BeganEpochGroup'));
            obj.listeners.experiment{end + 1} = addlistener(obj.experiment, 'EndedEpochGroup', @(h,d)notify(obj, 'EndedEpochGroup'));
        end
        
        function onSetProtocol(obj, ~, ~)
            
        end
        
        function onSetController(obj, ~, ~)
            while ~isempty(obj.listeners.controller)
                delete(obj.listeners.controller{1});
                obj.listeners.controller(1) = [];
            end
            
            if isempty(obj.controller)
                return;
            end
            
            obj.listeners.controller{end + 1} = addlistener(obj.controller, 'state', 'PostSet', @(h,d)notify(obj, 'SetState'));
        end
        
    end
    
end

