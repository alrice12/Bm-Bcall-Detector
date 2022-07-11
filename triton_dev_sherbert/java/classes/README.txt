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
 
 
 Note for people having problems importing classes into Matlab:
 We've observed these common problems:

 1.  If one of the support libary jars has not been added to your path,
     when the class is imported it will fail in a way that does not
     suggest that you have a library problem.
     
     e.g. >> import dbxml.xyzzy (made up class name)
     Error using import
     Import argument 'dbxml.xyzzy' cannot be found or cannot be imported.
     
     The real problem may be that class xyzzy imports a library, such as
     the commons-cli-1.2.jar library that some of our classes use.
     It is critical that these be on your java path.
     
     Use:  javaclasspath -dynamic
     to list all of the class directories and java archives (jar) that
     have been added to your path.
     
 2.  The Java class was compiled with the wrong version of the Java
     virtual machine (JVM).  Type "version -java" at the Matlab prompt to
     determine which version of Java your Matlab uses.  
     As of 2013-04-15, we compile with JVM 1.6.  When and if Matlab
     is upgraded to JVM 1.7, this may or may cause a problem.
     
     If you compile the classes on your own, chances are your default
     development kit will be generating 1.7 or later code.  You need
     to adjust it to generate code that matches Matlab's JVM.
     

