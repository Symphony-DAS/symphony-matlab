classdef EntitySetTest < symphonyui.TestBase
    
    properties
    end
    
    methods (Test)
        
        function testEntitySetProperties(obj)
            m1 = containers.Map();
            m1('one') = 1;
            m1('two') = 'two';
            m1('three') = [1 2 3];
            e1.propertyMap = m1;
            
            m2 = containers.Map();
            m2('one') = 'one';
            m2('three') = [1 2 3];
            e2.propertyMap = m2;
            
            set1 = symphonyui.core.persistent.collections.EntitySet({e1, e2});
            obj.verifyCellsAreEquivalent(set1.propertyMap.keys, {'one', 'three'});
            obj.verifyEqual(set1.propertyMap('one'), []);
            obj.verifyEqual(set1.propertyMap('three'), [1 2 3]);
            
            m3 = containers.Map();
            m3('one') = 1;
            m3('two') = 'second';
            e3.propertyMap = m3;
            
            set2 = symphonyui.core.persistent.collections.EntitySet({e1, e2, e3});
            obj.verifyCellsAreEquivalent(set2.propertyMap.keys, {'one'});
            obj.verifyEqual(set1.propertyMap('one'), []);
        end
        
    end
    
end

