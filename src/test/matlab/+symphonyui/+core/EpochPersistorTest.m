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
        
        function testEntityProperties(obj)
            entity = obj.persistor.experiment;
            
            expected = containers.Map();
            expected('uint16') = uint16(12);
            expected('uint16v') = uint16([1 2 3 4 5]);
            expected('uint16m') = uint16([1 2 3; 4 5 6; 7 8 9]);
            expected('double') = 3.5;
            expected('doublev') = [1 2 3 4];
            expected('doublem') = [1 2 3; 4 5 6; 7 8 9];
            expected('string') = 'hello world!';
            
            keys = expected.keys;
            for i = 1:numel(keys)
                entity.addProperty(keys{i}, expected(keys{i}));
            end
            
            obj.verifyEqual(entity.propertiesMap, expected);
        end
        
        function testEntityKeywords(obj)
            entity = obj.persistor.experiment;
            
            expected = {'zam', 'pow', 'taco!', '_+zoooom'};
            
            for i = 1:numel(expected)
                entity.addKeyword(expected{i});
            end
            
            obj.verifyEqual(entity.keywords, expected);
        end
        
        function testNotes(obj)
            entity = obj.persistor.experiment;
            
            time1 = datetime('now', 'TimeZone', 'America/Denver');
            text1 = 'Hi, this is a note about this entity and it is cool';
            entity.addNote(text1, time1);
            
            time2 = datetime('now', 'TimeZone', 'Asia/Seoul');
            text2 = 'Another note. This one in Asia!';
            entity.addNote(text2, time2);
            
            note1 = entity.notes{1};
            obj.verifyDatetimesEqual(note1.time, time1);
            obj.verifyEqual(note1.text, text1);
            
            note2 = entity.notes{2};
            obj.verifyDatetimesEqual(note2.time, time2);
            obj.verifyEqual(note2.text, text2);
        end
        
        function testExperiment(obj)
            experiment = obj.persistor.experiment;
            obj.verifyEqual(experiment.purpose, obj.TEST_PURPOSE);
            
            dev1 = obj.persistor.addDevice('dev1', 'man');
            dev2 = obj.persistor.addDevice('dev2', 'man');
            obj.verifyCellsAreEquivalent(experiment.devices, {dev1, dev2});
            
            src1 = obj.persistor.addSource('src1');
            src2 = obj.persistor.addSource('src2');
            obj.verifyCellsAreEquivalent(experiment.sources, {src1, src2});
            
            grp1 = obj.persistor.beginEpochGroup('grp1', src1);
            obj.persistor.endEpochGroup();
            grp2 = obj.persistor.beginEpochGroup('grp2', src2);
            obj.verifyCellsAreEquivalent(experiment.epochGroups, {grp1, grp2});
        end
        
    end
    
    methods
        
        function verifyDatetimesEqual(obj, actual, expected)
            obj.verifyEqual(actual.Year, expected.Year);
            obj.verifyEqual(actual.Month, expected.Month);
            obj.verifyEqual(actual.Day, expected.Day);
            obj.verifyEqual(actual.Hour, expected.Hour);
            obj.verifyEqual(actual.Minute, expected.Minute);
            obj.verifyEqual(actual.Second, expected.Second);
            obj.verifyEqual(actual.Minute, expected.Minute);
            
            actual.Format = 'ZZZZZ';
            expected.Format = 'ZZZZZ';
            obj.verifyEqual(char(actual), char(expected));
        end
        
        function verifyCellsAreEquivalent(obj, actual, expected)
            obj.verifyEqual(numel(actual), numel(expected));
            
            for i = 1:numel(actual)
                equal = zeros(1, numel(expected));
                for j = 1:numel(expected)
                    equal(j) = isequal(actual{i}, expected{j});
                end
                obj.verifyTrue(any(equal));
            end     
        end
        
    end
    
end
