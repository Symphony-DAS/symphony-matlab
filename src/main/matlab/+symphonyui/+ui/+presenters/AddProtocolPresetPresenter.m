classdef AddProtocolPresetPresenter < appbox.Presenter

    properties (Access = private)
        log
        acquisitionService
    end

    methods

        function obj = AddProtocolPresetPresenter(acquisitionService, view)
            if nargin < 2
                view = symphonyui.ui.views.AddProtocolPresetView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.acquisitionService = acquisitionService;
        end

    end

    methods (Access = protected)
        
        function willGo(obj)
            obj.populateProtocolId();
        end

        function didGo(obj)
            obj.view.requestNameFocus();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)
        
        function populateProtocolId(obj)
            id = obj.acquisitionService.getSelectedProtocol();
            obj.view.setProtocolId(id);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();

            name = obj.view.getName();
            try
                preset = obj.acquisitionService.addProtocolPreset(name);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.result = preset;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
