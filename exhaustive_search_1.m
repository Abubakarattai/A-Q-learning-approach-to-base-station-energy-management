function [Ps_opt, idx_opt, exceed] = exhaustive_search_1(num_sc,lf,duration)
num_episode = duration;
%rng(4);
lf_bkp = lf;
lf_aux = lf_bkp;
%N_each = num_sc/4; % number of each type of small cell
% N_rh = 0.75.*ones(1,N_each);
% N_mi = 0.50.*ones(1,N_each);
% N_pi = 0.25.*ones(1,N_each);
% N_fe = 0.15.*ones(1,N_each);
% N_rb = [N_rh N_mi N_pi N_fe]; % capacity scaling factor for remote radio head, micro, pico and femto cells
% lf = [lf(:,1) (lf(:,2:end).*(N_rb))];
possible_actions_dec = 0:2^num_sc-1;    % all possible actions in decimal
possible_actions_bin_aux = dec2bin(possible_actions_dec);   % all possible actions in binary (char)
possible_actions_bin = zeros(2^num_sc, num_sc);
% convert binary values to a matrix with 0s and 1s
for i = 1:2^num_sc
    possible_actions_bin(i,possible_actions_bin_aux(i,:) == '1') = 1;
end
Ps_opt = NaN(num_episode, 1);
for episode = 1:num_episode    % for each episode
    P_total_aux = zeros(length(possible_actions_bin),1);
    P_t = zeros(length(possible_actions_bin),1);
    
    for search = 1:length(possible_actions_bin) % for each option
        lf_aux = lf(episode,2:end);
        lf_aux = lf_aux.*possible_actions_bin(search,:);
        lf_zeros = find(lf_aux == 0);
        lf_zeros = lf_zeros + 1;
        s = sum(lf(episode,lf_zeros));
        lf_aux = [lf(episode,1) + s, lf(episode,2:end)];
        
        % macro capacitiy check
        if lf_aux(1) > 1
            P_total_aux(search) = inf;
            P_t(search) = inf;
            continue;
        else
            [P_macro, P_sc, ~] = powerCalculations(lf_aux,num_sc);
            P_total_aux(search) = P_macro + sum(P_sc);
            
%             [P_macro_on_aux, P_sc_on_aux, ~] = PCalc_allon(lf(episode,:), num_sc);
%             P_ON_aux = P_macro_on_aux + sum(P_sc_on_aux);
%             
%             P_save_aux = P_ON_aux - P_total_aux;
        end
    end
    [P_t, idx] = min(P_total_aux);
    
%     lf_aux = lf(episode,2:end);
%     lf_aux = lf_aux.*possible_actions_bin(idx,:);
%     lf_zeros = find(lf_aux == 0);
%     lf_zeros = lf_zeros + 1;
%     s = sum(lf(episode,lf_zeros));
%     lf_aux = [lf(episode,1) + s, lf_aux];
    
    Ps_opt(episode) = P_t;
    %lf(episode,:) = lf_aux;
    idx_opt(episode,:) = possible_actions_bin(idx,:);
end
exceed = numel(find(lf(:,1)>1));
%tput_es = tput_calc(lf);
fprintf('Number of instances macro capacity exceeded = %d\n',exceed);
end