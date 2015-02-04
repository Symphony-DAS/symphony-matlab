classdef ParameterType < handle
    
    properties
        primitiveType
        shape
        domain
    end
    
    methods
        
        function obj = ParameterType(type, shape, domain)
            if nargin < 3
                domain = [];
            end
            
            obj.primitiveType = type;
            obj.shape = shape;
            obj.domain = domain;
        end
        
    end
    
    methods (Static)
        
        function obj = autoDiscover(value)
            import symphonyui.models.*;
            obj = ParameterType(ParameterType.autoDiscoverType(value), ParameterType.autoDiscoverShape(value));
        end
        
        function type = autoDiscoverType(value)
            clazz = class(value);
            switch clazz
                case {'logical','char','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                    type = clazz;
                case {'single','double'}
                    if issparse(value)
                        sparsity = 'sparse';
                    else
                        sparsity = 'dense';
                    end
                    if isreal(value)
                        complexity = 'real';
                    else
                        complexity = 'complex';
                    end
                    type = [ sparsity complexity clazz ];
                case 'cell'
                    if iscellstr(value)
                        type = 'cellstr';
                    else
                        error('Cell arrays other than cell array of strings are not supported.');
                    end
                otherwise
                    error('Argument type "%s" is not supported.', class(value));
            end
        end
        
        function shape = autoDiscoverShape(value)
            if ~ismatrix(value)
                error('Dimensions higher than 2 are not supported.');
            end
            if size(value,1) == 1 && size(value,2) == 1
                shape = 'scalar';
            elseif size(value,1) == 1
                shape = 'row';
            elseif size(value,2) == 1
                shape = 'column';
            elseif size(value,1) == 0 && size(value,2) == 0
                shape = 'empty';  % no dimensions
            else
                shape = 'matrix';
            end
        end
        
    end
    
end

