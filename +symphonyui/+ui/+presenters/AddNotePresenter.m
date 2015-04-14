classdef AddNotePresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entity
    end

    methods

        function obj = AddNotePresenter(entity, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddNoteView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.entity = entity;
        end

    end

    methods (Access = protected)

        function onGo(obj)
            obj.view.requestTextFocus();
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

            try
                obj.entity.addNote(obj.view.getText());
            catch x
                obj.log.debug(x.message, x);
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
