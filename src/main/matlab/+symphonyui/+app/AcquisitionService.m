classdef AcquisitionService < handle
    
    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
        ControllerChangedState
    end
    
    properties (Access = private)
        session
        protocolRepository
    end
    
    methods
        
        function obj = AcquisitionService(session, protocolRepository)
            obj.session = session;
            obj.protocolRepository = protocolRepository;
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
            protocols = obj.protocolRepository.getAll();
            index = strcmp(className, cellfun(@(p)class(p), protocols, 'UniformOutput', false));
            obj.session.protocol = protocols{index};
            notify(obj, 'SelectedProtocol');
        end
        
        function cn = getSelectedProtocol(obj)
            cn = class(obj.session.getProtocol());
        end
        
        function d = getProtocolPropertyDescriptors(obj)
            d = obj.session.getProtocol().getPropertyDescriptors();
        end
        
        function setProtocolProperty(obj, name, value)
            obj.session.getProtocol().(name) = value;
            notify(obj, 'SetProtocolProperty');
        end

        function viewProtocol(obj)
            protocol = obj.session.getProtocol();
            controller = obj.session.getController();
            controller.runProtocol(protocol, []);
        end
        
        function recordProtocol(obj)
            protocol = obj.session.getProtocol();
            persistor = obj.session.getPersistor();
            controller = obj.session.getController();
            controller.runProtocol(protocol, persistor);
        end

        function stopProtocol(obj)
            obj.session.getController().requestStop();
        end
        
        function s = getControllerState(obj)
            s = obj.session.getController().state;
        end
        
        function [tf, msg] = validate(obj)
            [tf, msg] = obj.session.getProtocol().isValid();
        end
        
    end

end
