function dbRemoveDetectionDoc(queries, user, docid)
% result = dbRemoveDetectionDoc(queries, user, docid)
% Remove a specified database detection document for a user.
% queries - database query handle returned by dbInit()
% user - user id
% docid - XML document id
%
% Example:
% 
% queries = dbInit();
% % find detections submitted by TestUser
% dbUserEffort(queries, 'TestUser')  
% 
% ans =
% 
% dbxml:///Detections/SOCAL38N_MF_Minke_test
% .. others ...
% % document id follows dbxml:///Detections/    
% dbRemoveDetectionDoc(queries, user, ...
%    'dbxml:///Detections/SOCAL38N_MF_Minke_test')
%

error(nargchk(3,3,nargin))

% Verify that the document exists and is from the user.
doc = queries.Query(sprintf('doc("%s")/Detections/User_ID="%s"', ...
    docid, user));
if doc.compareTo('true') == 0
    [path, base] = fileparts(docid);
    queries.client.execute('removeSpreadsheet', base);
else
    error('No such document by this user');
end
