classdef AddNotePresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entitySet
    end

    methods

        function obj = AddNotePresenter(entitySet, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddNoteView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.entitySet = entitySet;
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
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            text = obj.view.getText();
            time = datetime('now', 'TimeZone', 'local');
            try
                note = obj.entitySet.addNote(text, time);
            catch x
                obj.view.showError(x.message);
                return;
            end
            
            obj.result = note;
            
            obj.close();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end

    end

end
