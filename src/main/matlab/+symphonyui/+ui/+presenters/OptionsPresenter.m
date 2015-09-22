classdef OptionsPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        options
    end

    methods

        function obj = OptionsPresenter(options, view)
            if nargin < 2
                view = symphonyui.ui.views.OptionsView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.options = options;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateFileDetails();
            obj.populateSearchPathDetails();
            obj.populateLoggingDetails();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'AddSearchPath', @obj.onViewSelectedAddSearchPath);
            obj.addListener(v, 'RemoveSearchPath', @obj.onViewSelectedRemoveSearchPath);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateFileDetails(obj)
            obj.view.setFileDefaultName(char(obj.options.fileDefaultName));
            obj.view.setFileDefaultLocation(char(obj.options.fileDefaultLocation));
        end
        
        function populateSearchPathDetails(obj)
            path = obj.options.searchPath();
            dirs = strsplit(path, ';');
            for i = numel(dirs)
                obj.view.addSearchPath(dirs{i});
            end
        end
        
        function populateLoggingDetails(obj)
            obj.view.setLoggingConfigurationFile(char(obj.options.loggingConfigurationFile));
            obj.view.setLoggingLogDirectory(char(obj.options.loggingLogDirectory));
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedApply();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            index = obj.view.getSelectedNode();
            obj.view.setCardSelection(index);
        end
        
        function onViewSelectedAddSearchPath(obj, ~, ~)
            path = obj.view.showGetDirectory('Select Path');
            if isempty(path)
                return;
            end
            obj.view.addSearchPath(path);
        end
        
        function onViewSelectedRemoveSearchPath(obj, ~, ~)
            index = obj.view.getSelectedSearchPath();
            if isempty(index)
                return;
            end
            obj.view.removeSearchPath(index);
        end

        function onViewSelectedApply(obj, ~, ~)
            obj.view.update();
            
            function out = parse(in)
                out = in;
                if isempty(in)
                    return;
                end
                if in(1) == '@'
                    try %#ok<TRYNC>
                        out = str2func(in);
                    end
                end
            end
            
            obj.options.fileDefaultName = parse(obj.view.getFileDefaultName());
            obj.options.fileDefaultLocation;
            obj.options.searchPath;
            obj.options.loggingConfigurationFile;
            obj.options.loggingLogDirectory;
            
            try
                obj.options.save();
            catch x
                
            end
            
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
