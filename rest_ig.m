% % IG_Trading_API_for_Matlab for Matlab
% % http://labs.ig.com/rest-trading-api-reference
% % Original version by Matteo Bregonzio - 2015 - https://uk.linkedin.com/in/matteo-bregonzio-b0113325

%============================================%
% Before running this code please update login_details.m 
% This file aims to test all available API functions hence make sure you 
% are connecting to the DEMO environment.  
% In the case of issues please try to replicate the same steps using 
% the API-companion available at 
% http://labs.ig.com/sample-apps/api-companion/index.html
%============================================%

clc;
clear all;
close all;

addpath urlread2/;

STOP_LOST_PERCENTAGE = 0.07;
LIMIT_GAIN_PERCENTAGE = 0.05;

global IG;

%% Login %%
login_details; % load username & password from login_details.m
LOG_IN_FIRST_TIME = 1; % When testing it is better do not login each run
if (LOG_IN_FIRST_TIME == 1)
    out = IG_api('LOGIN');
    if isfield(out, 'errorCode')
        disp('ERROR:  X-IG-API-KEY, identifier or password is incorrect');
    else
        save 'IG.mat' 'IG' 'out';
    end
else
    load 'IG.mat';
end
%% AccountDetails %%
out = IG_api('AccountDetails');
disp(out.accounts{1});

%% AccountSwitch - Move from CFD to spread betting%%
if size(out.accounts,2) > 1
    current_account = IG.currentAccountId;
    % just pick the next account for demo pourpouses
    i = 1;
    while strcmp(out.accounts{i}.accountId, current_account)
        i = i + 1;
    end
    par.accountId = out.accounts{i}.accountId;
    par.defaultAccount = 'false';
    accountInfo = IG_api('AccountSwitch', par);
    disp(accountInfo);
    par.accountId = current_account;
    par.defaultAccount = 'true';
    accountInfo = IG_api('AccountSwitch', par);
end

%% Get Account Settings %%
out = IG_api('AccountSettingsGet');
disp(['trailingStopsEnabled = ', num2str(out.trailingStopsEnabled)] );

%% Update Account Settings %%
parT.trailingStopsEnabled = 'false';
out = IG_api('AccountSettingsUpdate',parT);
disp(out);
parT.trailingStopsEnabled = 'true';
out = IG_api('AccountSettingsUpdate',parT);
disp(out);

%% OpenPositions %%
out = IG_api('PositionOpenAll');

%% Market Search %%
marketSearch = IG_api('MarketSearch', 'US 500');
disp(marketSearch.markets{1});

%% Market Browse %%
marketBrowse = IG_api('MarketBrowse','');
disp(marketBrowse.nodes{8}.name);
marketBrowse = IG_api('MarketBrowse',  marketBrowse.nodes{8}.id);
listMatkets = '';
for m = 1: size(marketBrowse.nodes,2)
    listMatkets = [listMatkets , ' ',  marketBrowse.nodes{m}.name, '[id:' , marketBrowse.nodes{m}.id,']' ];
end
disp(['  ', listMatkets]);

%% Market Details Multiple %%
marketDMultiple = IG_api('MarketDetailsMultiple', 'CC.D.LKD.UNC.IP,CO.D.LKD.FWS2.IP'); % Get coffe spot and future

%% Market Details%%
%symbols = 'CS.D.EURGBP.CFD.IP';
symbols = 'CS.D.BITCOIN.CFD.IP';
marketDetails = IG_api('MARKETDETAILS', symbols);

if strcmp(marketDetails.snapshot.marketStatus, 'TRADEABLE')
    newPosition.epic = symbols;
    newPosition.expiry =  '-';
    newPosition.direction = 'SELL';
    newPosition.size = 1;
    newPosition.orderType = 'MARKET';
    newPosition.level = 'null';
    newPosition.guaranteedStop = 'false';
    if strcmp(newPosition.direction, 'BUY')
        currentPirce = marketDetails.snapshot.offer;
        newPosition.stopLevel = currentPirce - (currentPirce * STOP_LOST_PERCENTAGE);
        newPosition.stopDistance = 'null'; % optional
        newPosition.limitLevel = currentPirce + (currentPirce * LIMIT_GAIN_PERCENTAGE);
        newPosition.limitDistance = 'null';% optional
    else
        currentPirce = marketDetails.snapshot.bid;
        newPosition.stopLevel = currentPirce + (currentPirce * STOP_LOST_PERCENTAGE);
        newPosition.stopDistance = 'null';% optional
        newPosition.limitLevel = currentPirce - (currentPirce * LIMIT_GAIN_PERCENTAGE);
        newPosition.limitDistance = 'null';% optional
    end
    newPosition.trailingStop = 'false';
    newPosition.trailingStopIncrement = 'null';
    newPosition.forceOpen = 'true';
    newPosition.quoteId = 'null';
    newPosition.currencyCode = marketDetails.instrument.currencies{1}.name;
    disp(newPosition);
    %% Position Create %%
    position_new = IG_api('PositionCreate',newPosition);
    %% Position Confirm %%
    position = IG_api('PositionConfirm',position_new.dealReference);
    
    %% Position Open All%%
    allPositions = IG_api('PositionOpenAll');
    disp(['|====== OPEN POSITION on ' date ' ======|']);
    if size(allPositions.positions,1) > 0
        for p =1: size(allPositions.positions,2)
            disp([allPositions.positions{p}.position.direction ' | ' allPositions.positions{p}.position.currency ' | ' allPositions.positions{p}.market.epic ]);
        end
    end
    %% ClosePosition %%
    closePosition.dealId = position.dealId;
    if strcmp(position.direction,'SELL')
        closePosition.direction = 'BUY';
    else
        closePosition.direction = 'SELL';
    end
    closePosition.size = position.size;
    closePosition.orderType = 'MARKET';
    out = IG_api('PositionClose', closePosition);
else
    newPosition = -1;
    disp(strcat('ERROR:  ', symbols, ' NOT TRADABLE'));
end

%% Position Open All%%
allPositions = IG_api('PositionOpenAll');
disp(['|====== OPEN POSITION on ' date ' ======|']);
if size(allPositions.positions,1) > 0
    for p =1: size(allPositions.positions,2)
        disp([allPositions.positions{p}.position.direction ' | ' allPositions.positions{p}.position.currency ' | ' allPositions.positions{p}.market.epic ]);
    end
end

%% Browse Sprint Market
marketBrowse = IG_api('MarketBrowse','302308');
for m = 1:size(marketBrowse.markets,2)
    disp([ marketBrowse.markets{m}.epic ' | ' marketBrowse.markets{m}.marketStatus ]);
end

%% Sprint Position Create%%
symbol = 'FM.D.KUWAIT.KUWAIT.IP';
%symbol = 'FM.D.TAD.TAD.IP';
marketDetails = IG_api('MARKETDETAILS', symbol);
if strcmp(marketDetails.snapshot.marketStatus, 'TRADEABLE')
    newSprintPosition.epic = symbol;
    newSprintPosition.direction = 'BUY';
    newSprintPosition.size = marketDetails.dealingRules.minDealSize.value + 10;
    newSprintPosition.expiryPeriod = 'TWENTY_MINUTES';
    %   ONE_MINUTE
    %   TWO_MINUTES
    %   FIVE_MINUTES
    %   TWENTY_MINUTES
    %   SIXTY_MINUTES
    
    sprintPosition = IG_api('SprintPositionCreate', newSprintPosition);
    position = IG_api('PositionConfirm',sprintPosition.dealReference);
    
else
    sprintPosition = -1;
    disp(strcat('ERROR:  ', symbol, ' NOT TRADABLE'));
end
%% Open Sprint Position %%
out = IG_api('SprintPositionOpenAll');

%% Open Working Order %%
out = IG_api('WorkingOrderOpenAll');

%% Create Working Order %%
symbol = 'CS.D.GBPUSD.CFD.IP';
marketDetails = IG_api('MARKETDETAILS', symbol);
if strcmp(marketDetails.snapshot.marketStatus, 'TRADEABLE') || strcmp(marketDetails.snapshot.marketStatus, 'EDITS_ONLY')
    newWorkingOrder.epic = symbol;
    newWorkingOrder.expiry = '-';
    newWorkingOrder.direction = 'BUY';
    newWorkingOrder.size = marketDetails.dealingRules.minDealSize.value * 2;
    newWorkingOrder.level = marketDetails.snapshot.offer + (marketDetails.snapshot.offer * 0.07);
    newWorkingOrder.forceOpen = 'false';
    newWorkingOrder.type = 'STOP';
    newWorkingOrder.currencyCode = marketDetails.instrument.currencies{1}.name;
    newWorkingOrder.timeInForce = 'GOOD_TILL_CANCELLED';
    newWorkingOrder.goodTillDate = 'null';
    newWorkingOrder.guaranteedStop = 'true';
    newWorkingOrder.stopDistance = 40;
    newWorkingOrder.limitDistance = 'null';
    
    workingOrderRef = IG_api('WorkingOrderCreate', newWorkingOrder);
    if isfield(workingOrderRef, 'errorCode')
        disp(strcat('ERROR:  ', symbols, ' unaviable workingOrderRef'));
    else
        
        workingOrder = IG_api('PositionConfirm',workingOrderRef.dealReference);
        %% Edit Working Order %%
        editWorkingOrder.dealId = workingOrder.dealId;
        editWorkingOrder.timeInForce = 'GOOD_TILL_CANCELLED';
        editWorkingOrder.goodTillDate = 'null';
        editWorkingOrder.stopDistance = 45;
        editWorkingOrder.limitDistance = 'null';
        editWorkingOrder.type = 'STOP';
        editWorkingOrder.level = marketDetails.snapshot.offer + (marketDetails.snapshot.offer * 0.05);
        
        workingOrderRef = IG_api('WorkingOrderEdit', editWorkingOrder);
        workingOrder = IG_api('PositionConfirm', workingOrderRef.dealReference);
        
        %% Delete Working Order %%
        status = IG_api('WorkingOrderDelete', workingOrder.dealId);
    end
else
    workingOrder = -1;
    disp(strcat('ERROR:  ', symbols, ' NOT TRADABLE'));
end

%% HistoricPrice %%
% get latest values %
hsitData.epic = 'IX.D.MIB.IFD.IP';
hsitData.resolution = 'MINUTE';
%     SECOND
%     MINUTE
%     MINUTE_2
%     MINUTE_3
%     MINUTE_5
%     MINUTE_10
%     MINUTE_15
%     MINUTE_30
%     HOUR
%     HOUR_2
%     HOUR_3
%     HOUR_4
%     DAY
%     WEEK
%     MONTH
hsitData.max = 100;
last_100_values = IG_api('HistoricPrice',hsitData);

% plot data
figure(1);
bidPrice = IG_api('GETDATA',{last_100_values, 'prices{#}.closePrice.bid', 'NUM'});
snapshotTime = IG_api('GETDATA',{last_100_values, 'prices{#}.snapshotTime', 'DATE'});
plot(snapshotTime,bidPrice);grid;
datetick('x','keepticks','keeplimits');
title(hsitData.epic);
 
% get values from / to %
hsitData.epic = 'IX.D.MIB.IFD.IP';
hsitData.resolution = 'DAY';
hsitData.from = '2015-07-21 00:00:00';
hsitData.to = '2015-08-21 00:00:00';
%hsitData.max = 100;
hist_values_from_to = IG_api('HistoricPrice',hsitData);

% plot data
figure(2);
bidPrice = IG_api('GETDATA',{hist_values_from_to, 'prices{#}.closePrice.bid', 'NUM'});
snapshotTime = IG_api('GETDATA',{hist_values_from_to, 'prices{#}.snapshotTime', 'DATE'});
plot(snapshotTime,bidPrice,'r');grid;
datetick('x','keepticks','keeplimits');
title(hsitData.epic);

%% Client Sentiment %%
symbol = 'FT100';
clientSentiment = IG_api('ClientSentiment',symbol);

%% Related Markets %%
symbol = 'EURUSD';
relatedMarkets = IG_api('RelatedMarkets',symbol);

%% List Applications %%
listApplications = IG_api('ListApplications');

%% Update Application %%
parU.apiKey = IG.X_IG_API_KEY;
parU.status = 'ENABLED';
parU.allowanceAccountTrading = 400;
parU.allowanceAccountOverall = 900;
updateApplication  = IG_api('UpdateApplication', parU);
disp(updateApplication);

%% Transaction History %%
transPar.type = 'ALL';
%                ALL
%                ALL_DEAL
%                DEPOSIT
%                WITHDRAWAL
transPar.from = '2014-07-21';
transPar.to = datestr(now, 'yyyy-mm-dd');
%transPar.maxSpanSeconds = 600;
transPar.pageSize = 20; % -1 = all 
transactionHistory = IG_api('TransactionHistory',transPar);

%% Activity History %%
actPar.from = '2014-07-21';
actPar.to = datestr(now, 'yyyy-mm-dd');
%actPar.maxSpanSeconds = 600;
actPar.pageSize = 20; % -1 = all
activityHistory = IG_api('ActivityHistory',actPar);

%% Log out %%
%IG_api('LOGOUT'); % Not needed in testing mode.