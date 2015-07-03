classdef EpochPersistorTest < matlab.unittest.TestCase
    
    properties
        persistor
    end
    
    properties (Constant)
        TEST_FILE = 'test.h5'
        TEST_PURPOSE = 'for testing purposes';
    end
    
    methods (TestClassSetup)
        
        function classSetup(obj)
            import matlab.unittest.fixtures.PathFixture;
            
            rootPath = fullfile(mfilename('fullpath'), '..', '..', '..', '..', '..', '..');
            
            core = fullfile(rootPath, 'lib', 'Core Framework');
            ui = fullfile(rootPath, 'src', 'main', 'matlab');
            
            obj.applyFixture(PathFixture(core));
            obj.applyFixture(PathFixture(ui));
            
            NET.addAssembly(which('Symphony.Core.dll'));
        end
        
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            cobj = Symphony.Core.H5EpochPersistor.Create(obj.TEST_FILE, obj.TEST_PURPOSE);
            obj.persistor = symphonyui.core.EpochPersistor(cobj);
        end
        
    end
    
    methods (TestMethodTeardown)
        
        function methodTeardown(obj)
            try %#ok<TRYNC>
                obj.persistor.close();
            end
            if exist(obj.TEST_FILE, 'file')
                delete(obj.TEST_FILE);
            end
        end
        
    end
    
    methods (Test)
        
        function testExperiment(obj)
            experiment = obj.persistor.experiment;
            obj.verifyEqual(experiment.purpose, obj.TEST_PURPOSE);
        end
        
        function testEntityProperties(obj)
            entity = obj.persistor.experiment;
            
            expected = containers.Map();
            expected('double') = 3.5;
            expected('doublev') = [1 2 3 4];
            expected('doublem') = [1 2 3; 4 5 6; 7 8 9];
            expected('string') = 'hello world!';
            
            keys = expected.keys;
            for i = 1:numel(keys);
                entity.addProperty(keys{i}, expected(keys{i}));
            end
        end
        
    end
    
end

