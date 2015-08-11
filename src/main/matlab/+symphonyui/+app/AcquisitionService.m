classdef AcquisitionService < handle
    
    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
    end
    
    properties (Access = private)
        sessionData
        protocolRepository
        nullProtocol
    end
    
    methods
        
        function obj = AcquisitionService(sessionData, protocolRepository)
            obj.sessionData = sessionData;
            obj.protocolRepository = protocolRepository;
            obj.nullProtocol = symphonyui.app.NullProtocol();
        end
        
        function [cn, dn] = getAvailableProtocolNames(obj)
            protocols = obj.protocolRepository.getAll();
            cn = cell(1, numel(protocols));
            dn = cell(1, numel(protocols));
            for i = 1:numel(protocols)
                cn{i} = class(protocols{i});
                dn{i} = protocols{i}.getDisplayName();
            end
        end
        
        function selectProtocol(obj, className)
            if isempty(className)
                p = obj.nullProtocol;
            else
                protocols = obj.protocolRepository.getAll();
                index = strcmp(className, cellfun(@(p)class(p), protocols, 'UniformOutput', false));
                p = protocols{index};
            end
            obj.sessionData.protocol = p;
            notify(obj, 'SelectedProtocol');
        end
        
        function cn = getSelectedProtocol(obj)
            if obj.getSessionProtocol() == obj.nullProtocol
                cn = [];
            else
                cn = class(obj.getSessionProtocol());
            end
        end
        
        function setProtocolProperty(obj, name, value)
            obj.getSessionProtocol().(name) = value;
            notify(obj, 'SetProtocolProperty');
        end
        
        function d = getProtocolPropertyDescriptors(obj)
            d = obj.getSessionProtocol().getPropertyDescriptors();
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
