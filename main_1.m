clc
clear all;

%load data
R = csvread('C:\Users\ATTAI PC\Dropbox\Figs\RevMax\clust_data_20.csv');

%% Parameters & Initialization
num_sc = 8; % number of small cells
lf = R(:,1:num_sc+1);  
N_each = num_sc/4; % number of each type of small cell
N_rh = 0.75.*ones(1,N_each);
N_mi = 0.50.*ones(1,N_each);
N_pi = 0.25.*ones(1,N_each);
N_fe = 0.15.*ones(1,N_each);
N_rb = [N_rh N_mi N_pi N_fe]; % capacity scaling factor for remote radio head, micro, pico and femto cells
lf = [lf(:,1) (lf(:,2:end).*(N_rb))]; % scaled load factor according to capacities of BSs
num_rep = 1; % number of repetitions for averaging purposes
duration = 144; % Duration of the simulations (minute)

    for rep = 1:num_rep     % for number of repetations (for averaging purposes)
        fprintf('\nRepetition = %d\n',rep);
        rng(rep);
        
        %--------------------------------------------------------------------------
        %-------------------------exhaustive search starts-------------------------
               
                tic;
                disp('Exhaustive search is running...');
                [Ps_optEs, idx_bin, es_exceed] = exhaustive_search_1(num_sc,lf,duration);
                es_num_cap_exceed(rep) = es_exceed;
                Ps_es(:,rep) = Ps_optEs;
                Idx_bin_es = idx_bin;
                Idx_dec_es = bi2de(Idx_bin_es);
                disp('Exhaustive search is completed.');
                toc;
               
        %------------------------exhaustive search ends----------------------------
        %--------------------------------------------------------------------------
        
        
        %--------------------------------------------------------------------------
        %--------------------------Q-learning starts-------------------------------
        %Q-learning
                tic;
                disp('Q-learning is running...');
                [P_opt, ql_exceed] = q_learning_R(duration, lf, num_sc);
                ql_num_cap_exceed(rep) = ql_exceed;
                Ps_ql(:,rep) = P_opt;
                disp('Q-learning is completed.');
                toc;
        %--------------------------Q-learning ends---------------------------------
        %--------------------------------------------------------------------------
        
        %--------------------------------------------------------------------------
        %--------------------------Q-learning starts-------------------------------
        %Q-learning
%                 tic;
%                 disp('All_ON is running...');
%                 [~, ~, P_ON] = PCalc_allon(lf, num_sc);
%                 P_allON(:,rep) = P_ON;
%                 disp('All is completed.');
%                 toc;
                
        %--------------------------Q-learning ends---------------------------------
        %--------------------------------------------------------------------------
       
    end

%% Results
Ps_es_avg = mean(Ps_es,2);
Ps_ql_avg = mean(Ps_ql,2);
%P_ON_avg = mean(P_allON,2);
Result_compare = [Ps_es_avg Ps_ql_avg];
%%
a = 1:144;
plot(a, Ps_es_avg);
hold on
plot(a, Ps_ql_avg);
legend('es', 'ql');
%csvwrite('C:\Users\ATTAI PC\Dropbox\Figs\RevMax\P_set_M.csv', Result_compare)
%Ps_data = [lf Ps_ql_avg];
%csvwrite('C:\Users\2309848A\Dropbox\Figs\VFA\Result_compare.csv',Result_compare);
