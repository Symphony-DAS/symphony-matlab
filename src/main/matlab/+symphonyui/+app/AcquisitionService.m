classdef AcquisitionService < handle
    
    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
    end
    
    properties (Access = private)
        sessionData
        protocolRepository
        protocolListeners
    end
    
    methods
        
        function obj = AcquisitionService(sessionData, protocolRepository)
            obj.sessionData = sessionData;
            obj.protocolRepository = protocolRepository;
            
            protocol = obj.sessionData.protocol;
            if ~isempty(protocol)
                obj.bindProtocol(protocol);
            end
            
            addlistener(obj.sessionData, 'protocol', 'PostSet', @obj.onSessionSetProtocol);
        end
        
        function close(obj)
            obj.unbindProtocol();
        end
        
        function p = getAvailableProtocols(obj)
            p = [{symphonyui.app.NullProtocol.get()}, obj.protocolRepository.getAll()];
        end
        
        function selectProtocol(obj, protocol)
            if ~any(cellfun(@(p)p == protocol, obj.getAvailableProtocols()))
                error('Protocol is not a member of available protocols');
            end
            obj.sessionData.protocol = protocol;
        end
        
        function tf = hasCurrentProtocol(obj)
            tf = ~isempty(obj.sessionData.protocol);
        end
        
        function p = getCurrentProtocol(obj)
            if ~obj.hasCurrentProtocol()
                error('No current protocol');
            end
            p = obj.sessionData.protocol;
        end
        
        function setProtocolProperty(obj, name, value)
            obj.getCurrentProtocol().(name) = value;
        end
        
        function p = getProtocolProperties(obj)
            p = obj.getCurrentProtocol().getParameters();
        end

        function viewProtocol(obj)
            obj.getCurrentProtocol().viewOnly();
        end
        
        function recordProtocol(obj)
            obj.getCurrentProtocol().record();
        end

        function stopProtocol(obj)
            obj.getCurrentProtocol().stop();
        end

        function [tf, msg] = validate(obj)
            tf = true;
            msg = '';
            %[tf, msg] = obj.getProtocol().isValid();
        end
        
    end
    
    methods (Access = private)
        
        function onSessionSetProtocol(obj, ~, ~)
            obj.unbindProtocol();
            
            protocol = obj.sessionData.protocol;
            if isempty(protocol)
                return;
            end
            
            obj.bindProtocol(protocol);
            notify(obj, 'SelectedProtocol');
        end
        
        function bindProtocol(obj, protocol)
            l = {};
            l{end + 1} = addlistener(protocol, 'SetProperty', @(s,d)notify(obj, 'SetProtocolProperty'));
            obj.protocolListeners = l;
        end
        
        function unbindProtocol(obj)
            while ~isempty(obj.protocolListeners)
                delete(obj.protocolListeners{1});
                obj.protocolListeners(1) = [];
            end
        end
        
    end

end
