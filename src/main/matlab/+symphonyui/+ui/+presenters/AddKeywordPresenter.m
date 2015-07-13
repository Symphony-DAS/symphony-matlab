classdef AddKeywordPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        entities
    end

    methods

        function obj = AddKeywordPresenter(entities, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddKeywordView();
            end
            if ~iscell(entities)
                entities = {entities};
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.entities = entities;
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
            switch event.key
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
                for i = 1:numel(obj.entities)
                    obj.entities{i}.addKeyword(keyword);
                end
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
