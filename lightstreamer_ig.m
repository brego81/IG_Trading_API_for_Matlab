% % IG_Trading_API_for_Matlab for Matlab
% % This sample presents a solution for the IG Streaming API (tested on Linux only)
% % To be noted that curl has been used because urlread2 was returning a java error. 

clc;
clear all;

addpath urlread2/;
global IG;

%% Login %%
login_details; % load username & password from login_details.m
out = IG_api('LOGIN');

%% Create a Lightstreame session - create_session.txt
body_LS_curl = ['LS_cid=mgQkwtwdysogQz2BJ4Ji+kOj2Bg&'...
    'LS_password=CST-' IG.CST '%7CXST-' IG.X_SECURITY_TOKEN '&'...
    'LS_user=' IG.currentAccountId '&'...
    'LS_op2=create&'...
    'LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEFAULT'];

body_LS_curl = [' -d ''', body_LS_curl ,''''];
post = [' -X POST ' IG.lightstreamerEndpoint '/lightstreamer/create_session.txt'];
[status, cmdout] = unix(['LD_LIBRARY_PATH=""; curl -s ', '', post,  body_LS_curl]);

if strcmp(cmdout(1:2), 'OK')
    new_line = strfind(cmdout, char(10));
    f = strfind(cmdout, 'SessionId:');
    IG.SessionId = cmdout(f+10:new_line(2)-2);
    f = strfind(cmdout, 'ControlAddress:');
    IG.lightstreamerEndpoint = ['https://' cmdout(f+15:new_line(3)-2)];
else
    disp(cmdout);
end

%% Symbols to be streamed

symbols = {'IX.D.MIB.IFD.IP' 'IX.D.CAC.IFD.IP' 'IX.D.DAX.IFD.IP' 'IX.D.IBEX.IFD.IP'};

symbols_text = ['L1%3A' symbols{1}];
for s = 2 : size(symbols,2)
    symbols_text = [ symbols_text '+L1%3A' symbols{s}];
end

%% Define the lightstreamer control.txt
body_LS_curl_1 = ['LS_mode=MERGE&'...
    'LS_session=' IG.SessionId '&'...
    'LS_Table=1&LS_id=' symbols_text '&' ...
    'LS_op=add&LS_schema=UPDATE_TIME+BID+OFFER+MARKET_STATE' '&' ...
    'LS_polling=true&LS_polling_millis=0&LS_idle_millis=0'];

body_LS_curl_1 = [' -d ''', body_LS_curl_1 ,''''];
post = [' -X POST ' IG.lightstreamerEndpoint '/lightstreamer/control.txt'];
[status,cmdout] = unix(['LD_LIBRARY_PATH=""; curl -s ', post,  body_LS_curl_1]);

%% Request lightstreamer updates bind_session.txt
body_LS_curl_2 = ['LS_session=' IG.SessionId '&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0'];
body_LS_curl_2 = [' -d ''', body_LS_curl_2 ,''''];
post = [' -X POST ' IG.lightstreamerEndpoint '/lightstreamer/bind_session.txt'];

for t =1:20
    [status, cmdout] = unix(['LD_LIBRARY_PATH=""; curl -s ', post, body_LS_curl_2]);
    disp(cmdout(126:end-10));
    pause(0.3);
    % 1,1 -> IX.D.MIB.IFD.IP
    % 1,2 -> IX.D.CAC.IFD.IP
    % 1,3 -> IX.D.DAX.IFD.IP
    % 1,4 -> IX.D.IBEX.IFD.IP
end
