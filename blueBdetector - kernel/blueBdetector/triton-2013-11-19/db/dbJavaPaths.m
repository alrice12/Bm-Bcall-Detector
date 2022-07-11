function dbJavaPaths
% Make sure Java classes on path

% We look for the Java classes in two possible directories:
% 1 - a 'client-java' subdirectory of this file's grandparent directory
% 2 - a 'java' subdirectory of this file's parent directory

basedir = fileparts(fileparts(which(mfilename)));

dirs  = struct('name', {'client-java', 'java'}, ...
               'level', {-1, 0});  % depth relative to basedir

existing = javaclasspath('-dynamic');  % what's already there...
paths = {};   
for didx = 1:length(dirs)
    % Find path to dirs(didx).name
    pathto = basedir;
    for pidx = dirs(didx).level:1:-1
        pathto = fileparts(pathto);  % parent directory
    end
    jdir = fullfile(pathto, dirs(didx).name);
    


    if exist(jdir, 'dir')
        % directory exists, add it to path
        if ~onpath(jdir, existing)
            paths{end+1} = jdir;
        end
        
        % Include any direct subdirectories
        listing = dir(jdir);
        for lidx=1:length(listing)
            if listing(lidx).isdir
                switch listing(lidx).name
                    case {'.', '..'}
                        % ignore current & parent directories
                    otherwise
                        newpath = fullfile(jdir, listing(lidx).name);
                        if ~onpath(newpath, existing)
                            paths{end+1} = newpath;
                        end
                end
            end
        end
        
        % Handle special cases
        switch dirs(didx).name
            case 'client-java'
                % There may be a bin subdirectory that needs to be
                % added to the path
                targets = fullfile(jdir, 'classes');
                if exist(targets)
                    paths{end+1} = targets;
                end
            case 'java'
                % Matlab installation
                targets = fullfile(jdir, 'TethysJavaClient', 'classes');
                if exist(targets)
                    paths{end+1} = targets;
                end                
        end
        
        % Add any java archive files in this direcory as they
        % must appear directly on the path
        javajars = dbFindFiles({'*.jar'}, {jdir}, true);
        if ~ isempty(javajars)
            remove = false(length(javajars), 1);
            for jidx=1:length(javajars)
                remove(jidx) = onpath(javajars{jidx}, existing);
            end
            javajars(remove) = [];
            
            paths(end+1:end+length(javajars)) = javajars;
        end
    end
end


if ~ isempty(paths)
    javaaddpath(paths);
end

function boolean = onpath(name, path)
% Checks if name is a component of the path
% Looks for exact comparisons, will fail when mutliple path names
% resolve to the same file or directory.
boolean = sum(strcmp(name, path)) > 0;

