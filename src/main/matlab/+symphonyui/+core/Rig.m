classdef Rig < handle
    
    properties
        sampleRate
    end
    
    properties (SetObservable, SetAccess = private)
        state = symphonyui.core.RigState.STOPPED
    end
    
    properties (Access = private)
        controller
        currentProtocol
        currentPersistor
    end
    
    properties (Access = private)
        listeners
    end
    
    methods
        
        function obj = Rig(description)
            obj.controller = symphonyui.core.Controller(description.daqController);
            
            devs = description.devices;
            for i = 1:numel(devs)
                obj.controller.addDevice(devs{i});
            end
            
            obj.sampleRate = description.sampleRate;
            
            obj.listeners = {};
            obj.listeners{end + 1} = addlistener(obj.controller, 'Started', @onControllerStarted);
            obj.listeners{end + 1} = addlistener(obj.controller, 'RequestedStop', @onControllerRequestedStop);
            obj.listeners{end + 1} = addlistener(obj.controller, 'Stopped', @onControllerStopped);
            obj.listeners{end + 1} = addlistener(obj.controller, 'CompletedEpoch', @onControllerCompletedEpoch);
            obj.listeners{end + 1} = addlistener(obj.controller, 'DiscardedEpoch', @onControllerDiscardedEpoch);
        end
        
        function delete(obj)
            delete(obj.controller);
        end
        
        function initialize(obj)
            obj.controller.daqController.initialize();
        end
        
        function close(obj)
            obj.controller.daqController.close();
        end
        
        function set.sampleRate(obj, r)
            daq = obj.controller.daqController; %#ok<MCSUP>
            if isprop(daq, 'sampleRate')
                daq.sampleRate = r;
            end
            devs = obj.controller.devices; %#ok<MCSUP>
            for i = 1:numel(devs)
                devs{i}.sampleRate = r;
            end
            obj.sampleRate = r;
        end
        
        function runProtocol(obj, protocol, persistor)
            obj.currentProtocol = protocol;
            obj.currentPersistor = persistor;
            
            obj.controller.startAsync(persistor);
            
            while protocol.continueQueuing()
                epoch = symphonyui.core.Epoch(Symphony.Core.Epoch(class(protocol)));
                protocol.prepareEpoch(epoch);
                obj.controller.enqueueEpoch(epoch);
            end
            
            while obj.controller.isRunning
                pause(0.01);
            end
        end
        
        function requestStop(obj)
            obj.controller.requestStop();
        end
        
        function [tf, msg] = isValid(obj)
            tf = true;
            msg = [];
        end
        
    end
    
    methods (Access = private)
        
        function onControllerStarted(obj, ~, ~)
            if isempty(obj.currentPersistor)
                obj.state = symphonyui.core.RigState.VIEWING;
            else
                obj.state = symphonyui.core.RigState.RECORDING;
            end
        end

        function onControllerRequestedStop(obj, ~, ~)
            obj.state = symphonyui.core.RigState.STOPPING;
        end

        function onControllerStopped(obj, ~, ~)
            obj.state = symphonyui.core.RigState.STOPPED;
        end

        function onControllerCompletedEpoch(obj, ~, event)
            epoch = event.data;
            obj.currentProtocol.completeEpoch(epoch);
            if ~obj.currentProtocol.continueRun()
                obj.requestStop();
            end
        end

        function onControllerDiscardedEpoch(obj, ~, ~)
            obj.requestStop();
        end
        
    end
    
end

