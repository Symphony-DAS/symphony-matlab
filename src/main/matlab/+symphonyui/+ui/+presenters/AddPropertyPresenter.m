classdef AddPropertyPresenter < appbox.Presenter

    properties (Access = private)
        log
        entitySet
    end

    methods

        function obj = AddPropertyPresenter(entitySet, view)
            if nargin < 2
                view = symphonyui.ui.views.AddPropertyView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.entitySet = entitySet;
        end

    end

    methods (Access = protected)

        function didGo(obj)
            obj.view.requestKeyFocus();
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

            key = obj.view.getKey();
            valueStr = obj.view.getValue();
            value = str2num(valueStr); %#ok<ST2NM>
            if isempty(value)
                value = valueStr;
            end
            try
                obj.entitySet.addProperty(key, value);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.result.key = key;
            obj.result.value = value;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
