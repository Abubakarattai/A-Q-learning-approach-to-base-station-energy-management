function [P_opt, exceed] = q_learning_R(duration, lf, num_sc)
num_state = 2;  % Number of states
num_iter = 1000;    % Number of iterations
epsilon = .7;
num_episode = duration; %144 minutes
alpha = .9;    % Q table update parameter
phi = .9;  % Q table update parameter
P_opt = NaN(num_episode, 1);
lf_bkp = lf;
lf_aux = lf_bkp;
% N_each = num_sc/4; % number of each type of small cell
% N_rh = 0.75.*ones(1,N_each);
% N_mi = 0.50.*ones(1,N_each);
% N_pi = 0.25.*ones(1,N_each);
% N_fe = 0.15.*ones(1,N_each);
% N_rb = [N_rh N_mi N_pi N_fe]; % capacity scaling factor for remote radio head, micro, pico and femto cells
% lf = [lf(:,1) (lf(:,2:end).*(N_rb))];

state_t = 1;

possible_actions_dec = 0:2^num_sc-1;    % all possible actions in decimal
possible_actions_bin_aux = dec2bin(possible_actions_dec);   % all possible actions in binary (char)
possible_actions_bin = zeros(2^num_sc, num_sc);

% convert binary values to a matrix with 0s and 1s
for i = 1:2^num_sc
    possible_actions_bin(i,possible_actions_bin_aux(i,:) == '1') = 1;
end
Q = zeros(num_state, length(possible_actions_dec)); % Q-matrix
for episode = 1:num_episode
    if rem(episode,250) == 0
        fprintf('     Episode %d is completed.\n',episode);
    end
    if rem(episode,50) == 0
        Q = zeros(num_state, length(possible_actions_dec)); % Q-matrix
    end
    state_t_plus_1 = state_t;  % Initially starting from the 1st state by default
    epsilon = epsilon*0.8;
    pen_check = NaN(num_iter,1);    % penalty checker (for stopping purposes)
    for it = 1:num_iter
        state_t = state_t_plus_1;
        
        if rand > epsilon
            [~, act_t] = min(Q(state_t, :));
        else
            act_t = randi(length(possible_actions_dec));
        end
                    
        
        lf_aux = lf(episode,2:end);
        lf_aux = lf_aux.*possible_actions_bin(act_t,:);
        lf_zeros = find(lf_aux == 0);
        lf_zeros = lf_zeros + 1;
        s = sum(lf(episode,lf_zeros));
        lf_aux = [lf(episode,1) + s, lf(episode,2:end)];
        
        [P_macro, P_sc, ~] = powerCalculations(lf_aux,num_sc);
        P_total = P_macro + sum(P_sc);
        
        % States
        if lf_aux(1) > 1
            state_t_plus_1 = 1;
            
        else
            state_t_plus_1 = 2;
            
        end
        
        pen = P_total - 10e5*(state_t_plus_1-2);  % penalty
        
        % Update the Q matrix
        [val, ~] = min(Q(state_t_plus_1,:)); % Find the min value in the next action
        Q(state_t,act_t) = Q(state_t,act_t) + alpha*(pen + phi*val - Q(state_t,act_t)); % Update the table
        
        % =================== stopping criteria begins ================== %
        pen_check(it) = pen;
        min_pen = min(pen_check(1:it));
        max_pen = max(pen_check(1:it));
        if it > 10
            if (pen_check(it) - min_pen)/(max_pen - min_pen) <= .05
                break;
            end
        end
        % ==================== stopping criteria ends =================== %
    end
    P_opt(episode) = P_total;
    %lf(episode,:) = lf_aux;
end
exceed = numel(find(lf(:,1)>1));
fprintf('Number of instances macro capacity exceeded = %d\n',exceed);
end