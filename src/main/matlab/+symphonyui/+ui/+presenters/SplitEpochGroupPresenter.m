classdef SplitEpochGroupPresenter < appbox.Presenter
    
    properties (Access = private)
        log
        documentationService
        initialGroup
    end
    
    methods
        
        function obj = SplitEpochGroupPresenter(documentationService, initialGroup, view)
            if nargin < 2
                initialGroup = [];
            end
            if nargin < 3
                view = symphonyui.ui.views.SplitEpochGroupView();
            end            
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
            obj.initialGroup = initialGroup;
        end
        
    end
    
    methods (Access = protected)

        function willGo(obj, ~, ~)
            obj.populateGroupList();
            obj.populateBlockList();
            obj.selectGroup(obj.initialGroup);
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedGroup', @obj.onViewSelectedGroup);
            obj.addListener(v, 'Split', @obj.onViewSelectedSplit);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateGroupList(obj)
            groups = obj.documentationService.getExperiment().getAllEpochGroups();
            
            names = cell(1, numel(groups));
            for i = 1:numel(groups)
                group = groups{i};
                names{i} = [group.label ' (' group.source.label ') [' datestr(group.startTime, 15) ']'];
            end
            
            if numel(groups) > 0
                obj.view.setGroupList(names, groups);
            else
                obj.view.setGroupList({'(None)'}, {[]});
            end
            obj.view.enableSelectGroup(numel(groups) > 0);
        end
        
        function selectGroup(obj, group)
            obj.view.setSelectedGroup(group);
            obj.populateBlockList();
            obj.updateStateOfControls();
        end
        
        function populateBlockList(obj)
            group = obj.view.getSelectedGroup();
            blocks = group.getEpochBlocks();
            
            names = cell(1, numel(blocks));
            for i = 1:numel(blocks)
                block = blocks{i};
                split = strsplit(block.protocolId, '.');
                names{i} = [appbox.humanize(split{end}) ' [' datestr(block.startTime, 13) ']'];
            end
            
            if numel(blocks) > 0
                obj.view.setBlockList(names, blocks);
            else
                obj.view.setBlockList({'(None)'}, {[]});
            end
            obj.view.enableSelectBlock(numel(blocks) > 0);
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableSplit()
                        obj.onViewSelectedSplit();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedGroup(obj, ~, ~)
            obj.selectGroup(obj.view.getSelectedGroup());
        end
        
        function onViewSelectedSplit(obj, ~, ~)
            obj.view.update();
            
            group = obj.view.getSelectedGroup();
            block = obj.view.getSelectedBlock();
            try
                split = obj.documentationService.splitEpochGroup(group, block);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.result = split;
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

        function updateStateOfControls(obj)
            blockList = obj.view.getBlockList();
            hasBlock = ~isempty(blockList{1});

            obj.view.enableSplit(hasBlock);
        end
        
    end
    
end

