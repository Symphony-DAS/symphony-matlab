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
        
        function [cn, dn] = getAvailableProtocols(obj)
            protocols = obj.protocolRepository.getAll();
            
            cn = cell(1, numel(protocols));
            dn = cell(1, numel(protocols));
            for i = 1:numel(protocols)
                cn{i} = class(protocols{i});
                dn{i} = protocols{i}.getDisplayName();
            end
        end
        
        function selectProtocol(obj, className)
            if ~any(strcmp(className, obj.getAvailableProtocols))
                error([className ' is not a member of available protocols']);
            end
            protocols = obj.protocolRepository.getAll();
            index = cellfun(@(p)strcmp(class(p), className), protocols);
            obj.sessionData.protocol = protocols{index};
            notify(obj, 'SelectedProtocol');
        end
        
        function cn = getSelectedProtocol(obj)
            cn = class(obj.getSessionProtocol());
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
