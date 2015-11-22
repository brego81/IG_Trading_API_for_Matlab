% % IG_Trading_API_for_Matlab for Matlab
% % http://labs.ig.com/rest-trading-api-reference
% % Original version by Matteo Bregonzio - 2015 - https://uk.linkedin.com/in/matteo-bregonzio-b0113325

function out = IG_api(fun, par)
if ~exist('par')
    par = '';
end

URL = 'https://demo-api.ig.com/gateway/deal/';
global IG;

switch upper(fun)
    case 'LOGIN'
        body.identifier = IG.identifier;
        body.password = IG.password;
        [out extras] = IG_web_call('POST',[URL 'session'], IG_header(2), IG_body(body));
        if ~isfield(out, 'errorCode')
            IG.X_SECURITY_TOKEN = extras.firstHeaders.X_SECURITY_TOKEN;
            IG.CST = extras.firstHeaders.CST;
            IG.currentAccountId = out.currentAccountId;
        end
    case 'ACTIVITYHISTORY'
        if isfield(par,'from')
            extended_url = [ '&from='  par.from];
        end
        if isfield(par,'to')
            extended_url = [extended_url '&to=' par.to];
        else
            extended_url = [extended_url '&to=' datestr(now, 'yyyy-mm-dd')];
        end
        if isfield(par,'maxSpanSeconds')
            extended_url = [ extended_url '&maxSpanSeconds=' num2str(par.max)];
        end
        if isfield(par,'pageSize')
            extended_url = [ extended_url '&pageSize=' num2str(par.pageSize)];
        end
        out = IG_web_call('GET',[URL 'history/activity?'], IG_header(2), extended_url);
    case 'TRANSACTIONHISTORY'
        if isfield(par,'type')
            extended_url = ['type=' par.type];
        else
            extended_url = 'type=ALL';
        end
        if isfield(par,'from')
            extended_url = [extended_url '&from='  par.from];
        end
        if isfield(par,'to')
            extended_url = [extended_url '&to=' par.to];
        end
        if isfield(par,'maxSpanSeconds')
            extended_url = [ extended_url '&maxSpanSeconds=' num2str(par.max)];
        end
        if isfield(par,'pageSize')
            extended_url = [ extended_url '&pageSize=' num2str(par.pageSize)];
        end
        out = IG_web_call('GET',[URL 'history/transactions?'], IG_header(2), extended_url);
    case 'UPDATEAPPLICATION'
        out = IG_web_call('PUT',[URL 'operations/application'], IG_header(1), IG_body(par));
    case 'LISTAPPLICATIONS'
        out = IG_web_call('GET',[URL 'operations/application' ], IG_header(1), par);
    case 'RELATEDMARKETS'
        out = IG_web_call('GET',[URL 'clientsentiment/related/' ], IG_header(1), par);
    case 'CLIENTSENTIMENT'
        out = IG_web_call('GET',[URL 'clientsentiment/' ], IG_header(1), par);
    case 'HISTORICPRICE'
        if isfield(par,'resolution')
            extended_url = ['resolution=' par.resolution];
        else
            extended_url = ['resolution=MINUTE'];
        end
        if isfield(par,'from')
            extended_url = [extended_url '&from='  IG_web_date(par.from)];
        end
        if isfield(par,'to')
            extended_url = [extended_url '&to=' IG_web_date(par.to)];
        end
        if isfield(par,'max')
            extended_url = [ extended_url '&max=' num2str(par.max)];
        end
        extended_url = [ extended_url '&pageSize=500']; % 500 samples per page
        out = IG_web_call('GET',[URL 'prices/' par.epic '?'], IG_header(3), extended_url);
        if ~isfield(out,'errorCode')
            totalPages = out.metadata.pageData.totalPages;
            currentPage = out.metadata.pageData.pageNumber;
            
            for p = currentPage + 1 : totalPages %loop on all pages
                p_out = IG_web_call('GET',[URL 'prices/' par.epic '?'], IG_header(3), [extended_url '&pageNumber=' num2str(p)]);
                out.prices = [out.prices p_out.prices];
                p_out = [];
            end
        end
        
    case 'GETDATA'
        out = IG_getdata(par);
    case 'ACCOUNTSETTINGSGET'
        out = IG_web_call('GET',[URL 'accounts/preferences'], IG_header(1), par);
    case 'ACCOUNTSETTINGSUPDATE'
        out = IG_web_call('PUT',[URL 'accounts/preferences'], IG_header(1), IG_body(par));
    case 'ACCOUNTSWITCH'
        [out extras] = IG_web_call('PUT',[URL 'session'], IG_header(1), IG_body(par));
        if ~isfield(out,'errorCode')
            IG.X_SECURITY_TOKEN = extras.firstHeaders.X_SECURITY_TOKEN;
        end
    case 'ACCOUNTDETAILS'
        out = IG_web_call('GET',[URL 'accounts'], IG_header(1), par);
    case 'SPRINTPOSITIONCREATE'
        out = IG_web_call('POST',[URL 'positions/sprintmarkets'], IG_header(1), IG_body(par));
    case 'SPRINTPOSITIONOPENALL'
        out = IG_web_call('GET',[URL 'positions/sprintmarkets'], IG_header(1), par);
    case 'POSITIONOPENALL'
        out = IG_web_call('GET',[URL 'positions'], IG_header(2), par);
    case 'POSITIONOPEN'
        out = IG_web_call('GET',[URL 'positions'], IG_header(2), par);
    case 'POSITIONCREATE'
        out = IG_web_call('POST',[URL 'positions/otc'], IG_header(2), IG_body(par));
    case 'POSITIONCONFIRM'
        out = IG_web_call('GET',[URL 'confirms/'], IG_header(1), par);
    case 'POSITIONCLOSE'
        out = IG_web_call('POST',[URL 'positions/otc'], IG_header(1,'_method:DELETE'), IG_body(par));
    case 'MARKETDETAILS'
        out = IG_web_call('GET',[URL 'markets/'], IG_header(1), par);
    case 'MARKETDETAILSMULTIPLE'
        out = IG_web_call('GET',[URL 'markets?epics='], IG_header(1), par);
    case 'MARKETSEARCH'
        out = IG_web_call('GET',[URL 'markets?searchTerm='], IG_header(1), par);
    case 'MARKETBROWSE'
        out = IG_web_call('GET',[URL 'marketnavigation/'], IG_header(1), par);
    case 'WORKINGORDEROPENALL'
        out = IG_web_call('GET',[URL 'workingorders'], IG_header(2), par);
    case 'WORKINGORDERCREATE'
        out = IG_web_call('POST',[URL 'workingorders/otc'], IG_header(2), IG_body(par));
    case 'WORKINGORDEREDIT'
        dealId = par.dealId;
        par = rmfield(par,'dealId');
        out = IG_web_call('PUT',[URL 'workingorders/otc/' dealId], IG_header(2), IG_body(par));
    case 'WORKINGORDERDELETE'
        out = IG_web_call('POST',[URL 'workingorders/otc/' par], IG_header(1, '_method:DELETE'), '{}');
    case 'LOGOUT'
        out = IG_web_call('POST',[URL 'session'], IG_header(1, '_method:DELETE'), par);
    otherwise
        disp('Unknown method.');
        out = -1;
end
end

function [out, extras]= IG_web_call(method, url, header, body)
global IG;
extras = [];
if strcmp(method, 'GET')
    url = [url body];
    body = '';
end

[output,extras] = urlread2(url, method, body, header);
[out json] = parse_json(output);
if size(out,1) > 0
    out = out{1};
end
end

function out = IG_web_date(date)
out = datestr(date, 'yyyy-mm-dd HH:MM:SS');
out = strrep(out, ' ', 'T');
out = strrep(out, ':', '%3A');
end

function out = IG_body(par)
global IG;
out = [];
bodyattributes = fieldnames(par);
for b = 1 : size(bodyattributes,1)
    val = eval(strcat('par.',bodyattributes{b}));
    if isnumeric(val)
        out = strcat(out, '"', bodyattributes{b}, '":"', num2str(val), '", ' ); % numeric
    else
        if strcmp(val,'null')
            out = strcat(out, '"', bodyattributes{b}, '":null, ' ); % null
        else
            out = strcat(out, '"', bodyattributes{b}, '":"', val, '", ' ); % string
        end
    end
end

out = ['{ ', out(1:end-1),'}'];
end

function out = IG_header(ver,par)
global IG;

out(1).name = 'Content-Type';
out(1).value ='application/json; charset=UTF-8';
out(2).name = 'Accept';
out(2).value ='application/json; charset=UTF-8';
out(3).name = 'X-IG-API-KEY';
out(3).value = IG.X_IG_API_KEY;
out(4).name = 'version';
out(4).value = num2str(ver);
if isfield(IG,'X_SECURITY_TOKEN')
    out(5).name = 'X-SECURITY-TOKEN';
    out(5).value = IG.X_SECURITY_TOKEN;
    out(6).name = 'CST';
    out(6).value = IG.CST;
end
if exist('par') > 0
    out(7).name = '_method';
    out(7).value ='DELETE';
end
end

function out = IG_getdata(par)
storage = par{1};
path_data = par{2};
data_type = par{3};

f = strfind(path_data,'{#}'); % identify if you need to loop
if f > 0
    path_data_1 = path_data(1:f-1);
    path_data_2 = path_data(f+4:end);
    storage_1 =  eval(['storage.' path_data_1]);
    
    switch data_type
        case 'NUM'
            for i = 1:size(storage_1,2)
                out(i) = eval(['storage_1{' num2str(i) '}.' path_data_2]);
            end
        case 'DATE'
            
            for i = 1:size(storage_1,2)
                out(i) = datenum(eval(['storage_1{' num2str(i) '}.' path_data_2]));
            end
        case 'TEXT'
            for i = 1:size(storage_1,2)
                out{i} = eval(['storage_1{' num2str(i) '}.' path_data_2]);
            end
            
        otherwise
            disp('Unknown data type.');
            out = -1;
    end
else
    out = eval('storage.path_data');
end
end

% function out = IG_parse_json(data)
% fields = fieldnames(data{1});
% for  i = 1 :size(data,2)
%     for f = 1: size(fields,1)
%         val = getfield(data{i}, fields{f});
%         if isstruct(val)
%             val = struct2array(val);
%         end
%         P{i,f} = val;
%     end
% end
% out = [fields' ; P];
% end
