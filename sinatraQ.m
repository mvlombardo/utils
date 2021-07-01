function Q = sinatraQ(citations_file)
% Calculate Sinatra's Q
%
% INPUT
%   citations_file = .csv with counts of citations per each paper of >= n years old (n = 5 or 10)
%

%% Citations per each paper with >=n years (n = 5 or 10)
D = readtable(citations_file, 'ReadVariableNames',false);
C_T = table2array(D);

%% number of citations for each paper over the last n years (C_T)
% add 1 to C_T, then take the log, and average all the log values
cT = mean(log(C_T+1));

%% mu_p
mu_p = 1.48;  % mu_p that is specific to Cognitive Science and Neuroscience
% mu_p = 2.5; % mu_p for other fields like Biology

%% calculate Q
Q = exp(cT - mu_p);
