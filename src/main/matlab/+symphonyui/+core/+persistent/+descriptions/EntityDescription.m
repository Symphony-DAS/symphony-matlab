classdef EntityDescription < symphonyui.core.Description
    % An EntityDescription describes the metadata of an entity within an experiment. For example, you might want a 
    % source to include metadata such as id, sex, age, and weight, and an epoch group to include metadata such as 
    % solution additions, recording technique, and series resistance. There are three types of EntityDescription: 
    % ExperimentDescription, SourceDescription, and EpochGroupDescription.
    %
    % To write a new description:
    %   1. Subclass ExperimentDescription, SourceDescription, or EpochGroupDescription
    %   2. Add properties
    %
    % EntityDescription Methods:
    %   addProperty     - Adds a new property to this description
    %   addResource     - Adds a new resource to this description
    
    properties (Access = private)
        propertyDescriptors
        resources
    end
    
    methods
        
        function obj = EntityDescription()
            obj.propertyDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
            obj.resources = containers.Map();
        end
        
        function addProperty(obj, name, value, varargin)
            % Adds a new property to this description. Additional arguments are passed to the property's
            % PropertyDescriptor constructor.
            
            d = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.propertyDescriptors(end + 1) = d;
        end
        
        function d = getPropertyDescriptors(obj)
            d = obj.propertyDescriptors;
        end
        
        function addResource(obj, name, variable)
            % Adds a new resource to this description
            
            obj.resources(name) = variable;
        end
        
        function v = getResource(obj, name)
            v = obj.resources(name);
        end
        
        function n = getResourceNames(obj)
            n = obj.resources.keys;
        end
        
        function t = getType(obj)
            t = class(obj);
        end
        
    end
    
end

