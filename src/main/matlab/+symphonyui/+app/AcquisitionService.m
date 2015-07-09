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
            obj.setProtocol(protocol);
            notify(obj, 'SelectedProtocol');
        end
        
        function p = getCurrentProtocol(obj)
            p = obj.getProtocol();
        end
        
        function setProtocolProperty(obj, name, value)
            obj.getProtocol().(name) = value;
        end
        
        function p = getProtocolProperties(obj)
            p = struct();
        end

        function viewCurrentProtocol(obj)
            obj.getProtocol().viewOnly();
        end
        
        function recordCurrentProtocol(obj)
            obj.getProtocol().record();
        end

        function stopCurrentProtocol(obj)
            obj.getProtocol().stop();
        end

        function [tf, msg] = validate(obj)
            tf = true;
            msg = '';
            %[tf, msg] = obj.getProtocol().isValid();
        end

    end
    
    methods (Access = private)
        
        function p = getProtocol(obj)
            p = obj.sessionData.protocol;
        end
        
        function setProtocol(obj, protocol)
            obj.sessionData.protocol = protocol;
        end
        
        function tf = hasProtocol(obj)
            tf = ~isempty(obj.sessionData.protocol);
        end
        
    end

end
