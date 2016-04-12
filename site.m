function site()
    rootPath = fileparts(mfilename('fullpath'));
    sitePath = fullfile(rootPath, 'src', 'site');
    wikiPath = fullfile(sitePath, 'wiki');
    targetPath = fullfile(rootPath, 'target', 'site');
    [~, ~] = mkdir(targetPath);
    
    markdownFiles = dir(fullfile(wikiPath, '*.md'));
    for i = 1:length(markdownFiles)
        [~, name] = fileparts(markdownFiles(i).name);
        
        inputFile = fullfile(wikiPath, [name '.md']);
        outputFile = fullfile(targetPath, [name '.html']);
        
        command = sprintf('pandoc -c css/bootstrap.min.css -s -f markdown_github "%s" -o "%s"', inputFile, outputFile);
        [status, out] = system(command);
        if status ~= 0
            error(out);
        end
        
        replace(outputFile, '.md', '.html'); 
    end
    
    copyfile(fullfile(sitePath, 'info.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'helptoc.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'resources', 'css'), fullfile(targetPath, 'css'));
end

function replace(file, expression, replacement)
    fid = fopen(file);
    text = fread(fid, inf, '*char')';
    fclose(fid);
    
    text = regexprep(text, expression, replacement);
    
    fid = fopen(file, 'w');
    fwrite(fid, text);
    fclose(fid);
end