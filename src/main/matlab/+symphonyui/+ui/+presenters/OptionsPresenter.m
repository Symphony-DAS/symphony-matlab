classdef OptionsPresenter < appbox.Presenter

    properties (Access = private)
        log
        options
    end

    methods

        function obj = OptionsPresenter(options, view)
            if nargin < 2
                view = symphonyui.ui.views.OptionsView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.options = options;
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populateDetails();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'AddSearchPath', @obj.onViewSelectedAddSearchPath);
            obj.addListener(v, 'RemoveSearchPath', @obj.onViewSelectedRemoveSearchPath);
            obj.addListener(v, 'Save', @obj.onViewSelectedSave);
            obj.addListener(v, 'Default', @obj.onViewSelectedDefault);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)
        
        function populateDetails(obj)
            obj.populateFileDetails();
            obj.populateSearchPathDetails();
            obj.populateLoggingDetails();
        end

        function populateFileDetails(obj)
            obj.view.setFileDefaultName(char(obj.options.fileDefaultName));
            obj.view.setFileDefaultLocation(char(obj.options.fileDefaultLocation));
        end
        
        function populateSearchPathDetails(obj)
            obj.view.clearSearchPaths();
            path = obj.options.searchPath();
            if isempty(path)
                return;
            end
            dirs = strsplit(path, ';');
            for i = 1:numel(dirs)
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
                    obj.onViewSelectedSave();
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
            [~, name] = fileparts(path);
            if strncmp(name, '+', 1)
                obj.view.showError(['Cannot add package directories (directories starting with +) to the ' ...
                    'search path. Add the root directory containing the package instead.']);
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

        function onViewSelectedSave(obj, ~, ~)
            obj.view.update();
            
            function out = parse(in)
                out = in;
                if ~isempty(in) && in(1) == '@'
                    out = str2func(in);
                end
            end
            
            try
                fileDefaultName = parse(obj.view.getFileDefaultName());
                fileDefaultLocation = parse(obj.view.getFileDefaultLocation());
                searchPath = strjoin(obj.view.getSearchPaths(), ';');
                loggingConfigurationFile = parse(obj.view.getLoggingConfigurationFile());
                loggingLogDirectory = parse(obj.view.getLoggingLogDirectory());
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.options.fileDefaultName = fileDefaultName;
            obj.options.fileDefaultLocation = fileDefaultLocation;
            obj.options.searchPath = searchPath;
            obj.options.loggingConfigurationFile = loggingConfigurationFile;
            obj.options.loggingLogDirectory = loggingLogDirectory;
            
            try
                obj.options.save();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.stop();
        end
        
        function onViewSelectedDefault(obj, ~, ~)
            result = obj.view.showMessage( ...
                'Are you sure you want to reset options to default values?', ...
                'Reset Options', ...
                'Cancel', 'Reset');
            if ~strcmp(result, 'Reset')
                return;
            end
            
            try
                obj.options.reset();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.populateDetails();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
