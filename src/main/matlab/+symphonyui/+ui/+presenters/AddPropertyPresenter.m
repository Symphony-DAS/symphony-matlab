classdef AddPropertyPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entitySet
    end

    methods

        function obj = AddPropertyPresenter(entitySet, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddPropertyView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.entitySet = entitySet;
        end

    end

    methods (Access = protected)

        function onGo(obj)
            obj.view.requestKeyFocus();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            key = obj.view.getKey();
            value = obj.view.getValue();
            try
                obj.entitySet.addProperty(key, value);
            catch x
                obj.view.showError(x.message);
                return;
            end

            obj.view.hide();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end

    end

end
