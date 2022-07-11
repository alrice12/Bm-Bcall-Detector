Java dbxml client

Usage with Matlab:

Add class to javaclasspath, e.g. if variable HOME is defined
and the root of this project is $HOME/eclipse/dbxmlJavaClient:
javaaddpath(fullfile(getenv('HOME'), 'eclipse/dbxmlJavaClient/bin'));

In addition, the apache-xml JAR files must be added to the path.  
Example of adding them:
% add user Java jar files contained in specified directories
for directory = {'eclipse/dbxmlJavaClient/bin/apache-xmlrpc-3.1.2/lib/'}
  dirname = fullfile(HomeDir, directory{1});
  jarfiles = dir(fullfile(dirname, '*.jar'));
  for idx=1:length(jarfiles)
    javaaddpath(fullfile(dirname, jarfiles(idx).name));
  end
end


In Matlab:

% make classes available
import dbxml.*

% example with server running on local host using loopback address
% and plaintext transmission
secure = false;
% create a client interface when the server is running locally
client = Client('http://127.0.0.1:9779', secure)
queries = Queries(client);
 
