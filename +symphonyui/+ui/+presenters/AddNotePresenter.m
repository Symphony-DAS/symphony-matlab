classdef AddNotePresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    methods
        
        function obj = AddNotePresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.AddNoteView();
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.addListener(view, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedCancel);
            
            obj.experiment = experiment;
        end
        
    end
    
    methods (Access = protected)

        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            obj.view.requestTextFocus();
        end

    end
    
    methods (Access = private)

        function onViewWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onViewSelectedAdd();
            elseif strcmp(data.Key, 'escape')
                obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            try
                note = symphonyui.core.Note(obj.view.getText());
                obj.experiment.addNote(note);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

