classdef Map2 < containers.Map & handle
    %MAP2 constructs a Map2 object.
    %   The Map2 object is a subclass of the built-in containers.Map class. 
    %   It is a data structure which contains of key-value pairs. Map2 enhance
    %   the functionality of the built-in containers.Map class. It provides
    %   a few extra methods and allows you to use indexing in order to get
    %   specific values from the container. Also a bidirectional use of 
    %    key-value pairs is supported (like Boost.Bimap library).
    %
    %   Map2 object can be indexed by using curly brackets {range1,range2}. 
	%	It returns a cell array of values or scalar value of Map2 given range 
	%	(range1,range2). range1 refers to position of the value set and 
	%	range2 refers to position inside a value set. range2 can be omitted 
	%	if not needed. 
    %
    %   Look at the built-in containers.Map class documentation for more 
    %   info about how to properly construct a Map2 object and what 
    %   properties/methods it includes.   
    %
    %   Examples:
    %       myMap = Map2({'West Germany','Argentina','Italy','England'},...
    %                                {1,2,3,4}); 
    %       fprintf(1,'The number of coutries is %d\n',myMap.length);
    %       fprintf(1,'The winner is %s\n',myMap.right_at(myMap.right_find(1)))
    %       fprintf(1,'Countries names ordered by their final position:\n')
    %       for k = 1:myMap.length
    %           fprintf(1,'%s)\t%s\n',num2str(myMap{myMap.right_find(k)}),myMap.right_at(myMap.right_find(k)))
    %       end
    %       fprintf(1,['Countries names ordered alphabetically along',...
    %                  ' with their final position:\n']);
    %       for k = 1:myMap.length
    %           fprintf(1,'%s ends in position %s\n',myMap.right_at(k),num2str(myMap{k}))
    %       end
    %
    %       myMap = Map2({'Frequency','Impedance','Phase'},...
    %       {[1 10 1e2 1e3 1e4 1e5],[1 2 4 8 16 32],[90 90 89 85 60 20]});
    %       myMap = myMap.addSets({'Resistance','Inductance'},{[0.2 0.3 0.5 0.7 1.2 1.75],...
    %                             [1.1e-4 1.05e-4 0.9e-4 0.7e-4 0.4e-4 0.1e-4]});
    %       figure(1)
    %       plot(cell2mat(myMap{myMap.find('Frequency'),1:numel(myMap('Frequency'))-2}),...
    %            cell2mat(myMap{3,1:4}),'linew',2);           
    %       xlabel(myMap.right_at(1));
    %       ylabel(myMap.right_at(3));
    %       figure(2)
    %       dataSets = myMap{[4,3]};    
    %       plot(cell2mat(dataSets(:,1)),cell2mat(dataSets(:,2)),'linew',2);           
    %       xlabel(myMap.right_at(4));
    %       ylabel(myMap.right_at(3));
    %
    %
    %		% Calculate the number of all values in the container.
    %       sum(cell2mat(cellfun(@(x) numel(x),myMap{1:myMap.length},'uni',false)))
    %
    %       % Get one element from value set    
    %       elem  = myMap{2,5}
    %       elem  = myMap.right_at(2,3)
    %        
    %   Map2 public properties:
    %       Inherited from containers.Map class:
    %       KeyType     -   Type of key used by this instance of Map.
    %       ValueType   -   Type of value used by this instance of Map.
    %       Count       -   Number of key-value pairs in Map.
    %
    %
    %   Map2 public methods:
    %       clear       -   Removes all the key-values pairs from the data
    %                       structure.
    %       find        -   Return an index of the given key argument. If the key
	%						is not found then index will empty.
    %       addSets     -   Return a new Map2 object which size has been
    %                       increased by the given key-value pairs.
    %       right_find  -   Return an index of the given key argument. Index look up is done
	%						switching key-value pairs (Map(X,Y) => Map(Y,X)). If the key
	%						is not found then index will empty.
	%		right_at	- 	Return an array of values(cell or scalar) of Map2 given range 
	%						(range1,range2). Key-value pairs have been switched (Map(X,Y) => Map(Y,X))  
	%						Where range1 refers to position of the value set and range2 
	%						refers to position inside a value set. range2 can be omitted 
	%						if not needed. 
	%
    %       Inherited from containers.Map class:    
    %       isKey       -   Determine whether Map2 contains given key.
    %       keys        -   Return cell array of keys of Map2.
    %       values      -   Return cell array of values of Map2.
    %       remove      -   Remove key-value pairs from Map2.
    %       size        -   Return size of Map2.
    %       length      -   Return length of Map2.  This is the number of 
    %                       key-value pairs in Map2.
    %       isempty     -   Determine if Map2 contains any data.   
    %
    %
    %   See also containers.Map
    %
    %   Copyright Mikko Leppänen 2013
    %
    %   Version history:
    %       13/02/2013 - first release 
    
    methods
        function obj = Map2(varargin)
            obj = obj@containers.Map(varargin{:});
        end
        function obj = clear(obj)
            obj = obj.remove(obj.keys);
        end
        function ind = find(obj,key)
            ind = find(cell2mat(cellfun(@(x) isequal(x,key),obj.keys,'uni',false)));
        end
        function varargout = subsref(obj,s)
           switch s(1).type
               case '.'
                   if strcmp(s(1).subs,'right')
                       varargout{1} = right_find(varargin);
                   else
                       varargout{1} = subsref@containers.Map(obj,s);
                   end
               case '()'
                   varargout{1} = subsref@containers.Map(obj,s);
               case '{}'
                   if numel(s(1).subs) > 2 || isempty(s(1).subs)
                       varargout{1} = [];
                       return;
                   end
                   if numel(s(1).subs) == 2
                       validateattributes(s(1).subs{1},{'numeric'},{'vector','>',0,'<=',numel(obj.values)});
                       values = {};
                       for k = s(1).subs{1}
                           validateattributes(s(1).subs{2},{'numeric'},{'vector','>',0,'<=',numel(obj.values{k})});
                           if numel(s(1).subs{2}) == 1 && numel(s(1).subs{1}) == 1
                                varargout{1} =  obj.values{k}(s(1).subs{2});
                                return;
                           else
                                values{end+1} = obj.values{k}(s(1).subs{2});
                           end
                       end
                       varargout{:} = values;
                   else
                       validateattributes(s(1).subs{:},{'numeric'},{'vector','>',0,'<=',numel(obj.values)});
                       if numel(s(1).subs{:}) == 1
                           varargout{1} = obj.values{s(1).subs{:}};
                       else
                           varargout{:} = {obj.values{s(1).subs{:}}};
                       end
                   end
           end 
        end
        
        function obj = addSets(obj,keySet,valueSet)
            obj = [obj;containers.Map(keySet,valueSet)];
        end
        
        function ind = right_find(obj,key)
            ind = find(cell2mat(cellfun(@(x) isequal(x,key),obj.values,'uni',false)));
        end
        function varargout = right_at(obj,varargin)
            if ~isempty(varargin) && numel(varargin) < 3
                validateattributes(varargin{1},{'numeric'},{'vector','>',0,'<=',numel(obj.values)});
                range1 = varargin{1};
                if numel(varargin) == 2
                   values = {};
                   range2 = varargin{2};
                   for k = range1
                       validateattributes(range2,{'numeric'},{'vector','>',0,'<=',numel(obj.keys{k})});
                       if numel(range2) == 1 && numel(range1) == 1
                            varargout{1} =  obj.keys{k}(range2);
                            return;
                       else
                            values{end+1} = obj.keys{k}(range2);
                       end
                   end
                       varargout{:} = values;
                else
                   if numel(range1) == 1
                       varargout{1} = obj.keys{range1};
                   else
                       varargout{:} = {obj.keys{range1}};
                   end
               end
            else
                varargout{1} = [];
            end  
        end
        function n = numel(varargin)
            n = 1;
        end
    end
end

