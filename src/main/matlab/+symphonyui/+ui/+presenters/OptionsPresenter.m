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
            obj.addListener(v, 'BrowseStartupFile', @obj.onViewSelectedBrowseStartupFile);
            obj.addListener(v, 'BrowseFileDefaultLocation', @obj.onViewSelectedBrowseFileDefaultLocation);
            obj.addListener(v, 'BrowseLoggingConfigurationFile', @obj.onViewSelectedBrowseLoggingConfigurationFile);
            obj.addListener(v, 'BrowseLoggingLogDirectory', @obj.onViewSelectedBrowseLoggingLogDirectory);
            obj.addListener(v, 'AddSearchPath', @obj.onViewSelectedAddSearchPath);
            obj.addListener(v, 'RemoveSearchPath', @obj.onViewSelectedRemoveSearchPath);
            obj.addListener(v, 'ShowExcludeHelp', @obj.onViewSelectedShowExcludeHelp);
            obj.addListener(v, 'Save', @obj.onViewSelectedSave);
            obj.addListener(v, 'Default', @obj.onViewSelectedDefault);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateDetails(obj)
            obj.populateGeneralDetails();
            obj.populateFileDetails();
            obj.populateSearchPathDetails();
            obj.populateLoggingDetails();
        end

        function populateGeneralDetails(obj)
            obj.view.setStartupFile(char(obj.options.startupFile));
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
            obj.view.setSearchPathExclude(char(obj.options.searchPathExclude));
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

        function onViewSelectedBrowseStartupFile(obj, ~, ~)
            file = obj.view.showGetFile('Select Startup File', '*.m');
            if isempty(file)
                return;
            end
            obj.view.setStartupFile(file);
        end

        function onViewSelectedBrowseFileDefaultLocation(obj, ~, ~)
            location = obj.view.showGetDirectory('Select Default Location');
            if isempty(location)
                return;
            end
            obj.view.setFileDefaultLocation(location);
        end

        function onViewSelectedBrowseLoggingConfigurationFile(obj, ~, ~)
            file = obj.view.showGetFile('Select Configuration File', '*.xml');
            if isempty(file)
                return;
            end
            obj.view.setLoggingConfigurationFile(file);
        end

        function onViewSelectedBrowseLoggingLogDirectory(obj, ~, ~)
            directory = obj.view.showGetDirectory('Select Log Directory');
            if isempty(directory)
                return;
            end
            obj.view.setLoggingLogDirectory(directory);
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

        function onViewSelectedShowExcludeHelp(obj, ~, ~)
            obj.view.showMessage(sprintf([ ...
                'Exclude is a regular expression or expressions (separated by semicolons) that is evaluated against ', ...
                'the full name (e.g. my.package.ClassName) of each class in the Symphony search path. If the expression ', ...
                'results in a match, the class is excluded and will not be display in Symphony popup menus.\n\n', ... 
                'Examples:\n', ...
                'Pulse\t\t - Excludes all classes with "Pulse" in its full class name.\n', ...
                'protocols.bill\t\t - Excludes all classes with "protocols.bill" in its full class name.\n', ...
                'Pulse; protocols.bill\t - Excludes all classes with "Pulse" or "protocols.bill" in its full class name.']), ...
                'Exclude', 'OK', [], [], 1, 600);
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
                startupFile = parse(obj.view.getStartupFile());
                fileDefaultName = parse(obj.view.getFileDefaultName());
                fileDefaultLocation = parse(obj.view.getFileDefaultLocation());
                searchPath = strjoin(obj.view.getSearchPaths(), ';');
                searchPathExclude = obj.view.getSearchPathExclude();
                loggingConfigurationFile = parse(obj.view.getLoggingConfigurationFile());
                loggingLogDirectory = parse(obj.view.getLoggingLogDirectory());
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            if ~isequal(startupFile, obj.options.startupFile)
                obj.options.startupFile = startupFile;
            end
            if ~isequal(fileDefaultName, obj.options.fileDefaultName)
                obj.options.fileDefaultName = fileDefaultName;
            end
            if ~isequal(fileDefaultLocation, obj.options.fileDefaultLocation)
                obj.options.fileDefaultLocation = fileDefaultLocation;
            end
            if ~isequal(searchPath, obj.options.searchPath)
                obj.options.searchPath = searchPath;
            end
            if ~isequal(searchPathExclude, obj.options.searchPathExclude)
                obj.options.searchPathExclude = searchPathExclude;
            end
            if ~isequal(loggingConfigurationFile, obj.options.loggingConfigurationFile)
                obj.options.loggingConfigurationFile = loggingConfigurationFile;
            end
            if ~isequal(loggingLogDirectory, obj.options.loggingLogDirectory)
                obj.options.loggingLogDirectory = loggingLogDirectory;
            end

            try
                obj.options.save();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.view.showMessage( ...
                'Options saved. Most values will not apply until the app is restarted.', ...
                'Options Saved', ...
                'OK');

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
