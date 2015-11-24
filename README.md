#IG trading API for Matlab
A simple and intuitive Matlab library designed to interact with ig.com web API. This library allows you to download historical data, monitor multiple markets, manage your positions and submit real-time orders. 

Compared with other alternatives Matlab provides a large selection of ready-to-use algorithms covering statistics, machine learning, finance and optimization. Furthermore, with few lines of code you can have an advance multidimensional data visualization or to read and write in a variety of files formats. Finally, MATLAB Coder provides the ability to auto-generate fast C code. In a nutshell, Matlab appears as a competitive solution when it comes to financial data analysis and processing.

Among different brokers, IG is one of the few providing a fully functioning API and at the same time free accounts with direct access to DEMO and LIVE environment. This means that with a zero initial investment, you can test your ideas in DEMO mode; and only run your validated implementation in LIVE when completely confident.

In terms of available products, IG is a leading provider of contract for difference (CFD) and financial spread betting covering Equities, Forex, Commodities, Indices, Binary options and much more. It should be mentioned that other brokers may offer cheaper commissions.

Full details about the API along with information about how to open an account with IG can be found at http://labs.ig.com/gettingstarted.

The trading API reference is available at http://labs.ig.com/rest-trading-api-reference.

A very handy tool for learning and testing the API is the API-companion available at http://labs.ig.com/sample-apps/api-companion/index.html 

#Related projects
- A Python alternative https://github.com/ig-python/
- This implementation uses urlread2 more info available at http://uk.mathworks.com/matlabcentral/fileexchange/35693-urlread2

#Install and Config
1. Copy all the files and directories in your local folder
2. Edit login_details.m adding your X_IG_API_KEY, identifier and password (the first time make sure you point to the DEMO environment)
3. Run rest_ig.m in order to test all the API functions
4. If it doesn't work, please try to replicate the same steps using the API-companion (http://labs.ig.com/sample-apps/api-companion/index.html) and try to spot the problem.
