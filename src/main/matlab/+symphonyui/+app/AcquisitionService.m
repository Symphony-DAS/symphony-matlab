classdef AcquisitionService < handle
    
    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
    end
    
    properties (Access = private)
        session
        protocolRepository
        emptyProtocol
    end
    
    methods
        
        function obj = AcquisitionService(session, protocolRepository)
            obj.session = session;
            obj.protocolRepository = protocolRepository;
            obj.emptyProtocol = symphonyui.app.NullProtocol();
        end
        
        function [cn, dn] = getAvailableProtocolNames(obj)
            protocols = obj.protocolRepository.getAll();
            cn = cell(1, numel(protocols));
            dn = cell(1, numel(protocols));
            for i = 1:numel(protocols)
                cn{i} = class(protocols{i});
                dn{i} = protocols{i}.displayName;
            end
        end
        
        function selectProtocol(obj, className)
            if isempty(className)
                protocol = obj.emptyProtocol;
            else
                protocols = obj.protocolRepository.getAll();
                index = strcmp(className, cellfun(@(p)class(p), protocols, 'UniformOutput', false));
                protocol = protocols{index};
            end
            obj.session.setProtocol(protocol);
            notify(obj, 'SelectedProtocol');
        end
        
        function cn = getSelectedProtocol(obj)
            protocol = obj.session.getProtocol();
            if protocol == obj.emptyProtocol
                cn = [];
            else
                cn = class(protocol);
            end
        end
        
        function setProtocolProperty(obj, name, value)
            obj.session.getProtocol().(name) = value;
            notify(obj, 'SetProtocolProperty');
        end
        
        function d = getProtocolPropertyDescriptors(obj)
            d = obj.session.getProtocol().getPropertyDescriptors();
        end
        
        function s = getRigState(obj)
            s = obj.session.getRig().state;
        end
        
        function [tf, msg] = isRigValid(obj)
            [tf, msg] = obj.session.getRig().isValid();
        end
        
        function [tf, msg] = isProtocolValid(obj)
            [tf, msg] = obj.session.getProtocol().isValid();
        end

        function viewProtocol(obj)
            rig = obj.session.getRig();
            protocol = obj.session.getProtocol();
            rig.runProtocol(protocol, []);
        end
        
        function recordProtocol(obj)

        end

        function stopProtocol(obj)

        end

        function [tf, msg] = validate(obj)
            [tf, msg] = obj.session.getProtocol().isValid();
        end
        
    end

end
