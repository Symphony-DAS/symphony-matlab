classdef Source < symphonyui.core.Entity

    properties (SetAccess = private)
        label
    end

    properties (SetAccess = private, Hidden)
        id
        parent
        children
    end

    methods (Access = ?symphonyui.core.Experiment)

        function obj = Source(id, label, parent)
            obj.id = id;
            obj.label = label;
            obj.parent = parent;
            obj.children = {};
        end

        function addChild(obj, source)
            obj.children{end + 1} = source;
        end

    end

end
