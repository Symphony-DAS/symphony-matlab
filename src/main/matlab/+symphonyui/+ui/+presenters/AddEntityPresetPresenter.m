classdef AddEntityPresetPresenter < appbox.Presenter

    properties (Access = private)
        log
        documentationService
        entitySet
    end

    methods

        function obj = AddEntityPresetPresenter(documentationService, entitySet, view)
            if nargin < 3
                view = symphonyui.ui.views.AddEntityPresetView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
            obj.entitySet = entitySet;
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populateEntityType();
            obj.populateDescriptionType();
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

        function populateEntityType(obj)
            type = obj.entitySet.getEntityType();
            obj.view.setEntityType(type);
        end

        function populateDescriptionType(obj)
            type = obj.entitySet.getDescriptionType();
            obj.view.setDescriptionType(type);
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
                preset = obj.entitySet.createPreset(name);
                obj.documentationService.addEntityPreset(preset);
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
