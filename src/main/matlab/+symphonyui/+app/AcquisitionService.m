classdef AcquisitionService < handle
    
    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
    end
    
    properties (Access = private)
        sessionData
        protocolRepository
    end
    
    methods
        
        function obj = AcquisitionService(sessionData, protocolRepository)
            obj.sessionData = sessionData;
            obj.protocolRepository = protocolRepository;
        end
        
        function p = getAvailableProtocols(obj)
            p = obj.protocolRepository.getAll();
        end
        
        function selectProtocol(obj, protocol)
            obj.sessionData.protocol = protocol;
            notify(obj, 'SelectedProtocol');
        end
        
        function p = getSelectedProtocol(obj)
            p = obj.getSessionProtocol();
        end
        
        function setProtocolProperty(obj, name, value)
            obj.getSessionProtocol().(name) = value;
            notify(obj, 'SetProtocolProperty');
        end
        
        function p = getProtocolProperties(obj)
            p = obj.getSessionProtocol().getParameters();
        end

        function viewProtocol(obj)
            obj.getSessionProtocol().viewOnly();
        end
        
        function recordProtocol(obj)
            obj.getSessionProtocol().record();
        end

        function stopProtocol(obj)
            obj.getSessionProtocol().stop();
        end

        function [tf, msg] = validate(obj)
            tf = true;
            msg = '';
            %[tf, msg] = obj.getProtocol().isValid();
        end
        
    end
    
    methods (Access = private)
        
        function p = getSessionProtocol(obj)
            if ~obj.hasSessionProtocol()
                error('No session protocol');
            end
            p = obj.sessionData.protocol;
        end
        
        function tf = hasSessionProtocol(obj)
            tf = ~isempty(obj.sessionData.protocol);
        end
        
    end

end
