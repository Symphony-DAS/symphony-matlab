classdef AddKeywordPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entitySet
    end

    methods

        function obj = AddKeywordPresenter(entitySet, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddKeywordView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.entitySet = entitySet;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateTextCompletionList();
        end
        
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
        
        function populateTextCompletionList(obj)
            list = obj.app.config.get(symphonyui.app.Options.KEYWORD_LIST);
            try
                obj.view.setTextCompletionList(list());
            catch x
                obj.log.debug(['Unable to populate completion list from config: ' x.message], x);
            end
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
            
            keyword = obj.view.getText();
            try
                obj.entitySet.addKeyword(keyword);
            catch x
                obj.view.showError(x.message);
                return;
            end

            obj.close();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.close();
        end

    end

end
