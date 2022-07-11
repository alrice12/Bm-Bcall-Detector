function query_h = dbInit(varargin)
% dbInit(optional_args)
% Create a connection to the Tethys database.
% With no arguments, a connection is created to the default server
% defined within this function.
% 
% Optional args:
% 'Server', NameString - name of server or IP address
%           Use 'localhost' if the server is running the
%           same machine as where the client is executing.
% 'Port', N - port number on which server is running
% 'Secure', false|true - make connection over a secure socket
%
% Returns a handle to a query object through which Tethys queries
% are served.

server_name = 'beluga.ucsd.edu';

server_nat_ip = [192 168 0 101];

localhost_ip = '127.0.0.1';
% Used for determining IP when on a NAT network
wan_ip = 'http://roch.sdsu.edu/report_client_ip.shtml?nocache=1';


%defaults
server = server_name;
secure = false;
default_port = 9779;
port = default_port;

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Server'
            server = varargin{vidx+1}; vidx = vidx+2;
        case 'Secure'
            secure = varargin{vidx+1}; vidx = vidx+2;
        case 'Port'
            port = varargin{vidx+1}; vidx = vidx+2;
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end

if (strcmp(server, 'localhost'))
   server = localhost_ip; 
else
   import java.net.*;
   import java.io.*;
   
   

   try  
       % get server name
       server_inet = java.net.InetAddress.getByName(server_name);
       server_ip = char(server_inet.getHostAddress());
       
       % Determine our IP
       my_ip_url = URL(wan_ip);
       in = BufferedReader(InputStreamReader(my_ip_url.openStream()));
       % Read until we hit the first line without an element start tag
       my_ip = char(in.readLine());
       while my_ip(1) == '<'
           my_ip = char(in.readLine());
       end
       
   catch e
       fprintf('Unable to determine IP, assuming local host');
       my_ip = [];
   end
   
   if isempty(my_ip)
       % no network connectivity, assume on local host
       server = localhost_ip;
   else
       
       % Find all IPs associated with this host
       if strcmp(my_ip, server_ip)
           % client and server have the same IP
           % If the server is on a private network using NAT, they
           % might not be the same machine.  Determine whether to
           % use loopback address or the server on the NAT.
           server_nat_inet = java.net.InetAddress.getByAddress(server_nat_ip);
           server_nat_host = server_nat_inet.getHostName();
           
           % pull up one of the local nodes IPs.  As some machines
           % will have multiple interfaces, it might not be the one
           % used to address the database on the local NAT node.
           local_nat_ip = java.net.InetAddress.getLocalHost();
           % Compare host names
           if server_nat_host.compareTo(local_nat_ip.getHostName()) == 0
               % Same node, use loopback
               server = localhost_ip;
           else
               server = sprintf('%d.%d.%d.%d', server_nat_ip);
           end
       else
           server = server_ip;
       end
   end
end

import dbxml.*
% Create a connection to the Tethys database
if secure
    urlstr = sprintf('https://%s:%d', server, port);
else
    urlstr = sprintf('http://%s:%d', server, port);
end
client = Client(urlstr, secure);

% Create a query manager.
% The query manager has some predefined queries and let's us perform
% arbitrary ones as well.
% Queries are written in the XQuery language.
% To learn XQuery, Priscilla Walmsley's book:
%    Walmsley, P. (2006) XQuery. O'Reilly, Farnham.
% is quite helpful.  In addition to the print version, Safari subscribers
% (many university libraries) have electronic subscriptions to this book.
query_h = Queries(client);












