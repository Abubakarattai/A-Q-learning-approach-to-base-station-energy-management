function [P_macro, P_sc, P_total] = powerCalculations(lf, num_sc)
% scenario_select_aux = 'Which scenario you would like to run?\n Type 1 for simple scenario and 2 for complex scenario: ';
% scenario_select = input(scenario_select_aux);
%global sys_para;

% all the power calulations are in Watts
% macro BS
P_c_macro = 130;  % static power (W)
delta_p_macro = 4.7;  % load dependent power consumption constant (unitless)
P_max_macro = 20; % maximum transmit power (W)
P_macro = P_c_macro + delta_p_macro*lf(:,1)*P_max_macro;

% small cells
% rrh
P_c_sc_rrh = 84;  % static power (W)
delta_p_sc_rrh = 2.8;  % load dependent power consumption constant (unitless)
P_max_sc_rrh = 20; % maximum transmit power (W)

% micro
P_c_sc_micro = 56;  % static power (W)
delta_p_sc_micro = 2.6;  % load dependent power consumption constant (unitless)
P_max_sc_micro = 6.3; % maximum transmit power (W)

% pico
P_c_sc_pico = 6.8;  % static power (W)
delta_p_sc_pico = 4;  % load dependent power consumption constant (unitless)
P_max_sc_pico = .13; % maximum transmit power (W)

% femto
P_c_sc_femto = 4.8;  % static power (W)
delta_p_sc_femto = 8;  % load dependent power consumption constant (unitless)
P_max_sc_femto = .05; % maximum transmit power (W)
    for sc_idx = 1:num_sc
        if sc_idx < round(num_sc/4) || sc_idx == round(num_sc/4)    % rrh
            if lf(:,sc_idx+1) == 0
                P_sc(:,sc_idx) = 56;   % sleep power
            else
                P_sc(:,sc_idx) = P_c_sc_rrh + delta_p_sc_rrh*lf(:,sc_idx+1)*P_max_sc_rrh;
            end
        elseif (sc_idx > round(num_sc/4) && sc_idx < round(2*num_sc/4)) || sc_idx == round(2*num_sc/4)  % micro
            if lf(:,sc_idx+1) == 0
                P_sc(:,sc_idx) = 39;   % sleep power
            else
                P_sc(:,sc_idx) = P_c_sc_micro + delta_p_sc_micro*lf(:,sc_idx+1)*P_max_sc_micro;
            end
        elseif (sc_idx > round(2*num_sc/4) && sc_idx < round(3*num_sc/4)) || sc_idx == round(3*num_sc/4)    % pico
            if lf(:,sc_idx+1) == 0
                P_sc(:,sc_idx) = 4.3;    % sleep power
            else
                P_sc(:,sc_idx) = P_c_sc_pico + delta_p_sc_pico*lf(:,sc_idx+1)*P_max_sc_pico;
            end
        else    % femto
            if lf(:,sc_idx+1) == 0
                P_sc(:,sc_idx) = 2.9;    % sleep power
            else
                P_sc(:,sc_idx) = P_c_sc_femto + delta_p_sc_femto*lf(:,sc_idx+1)*P_max_sc_femto;
            end
        end
    end
% total power consumption
P_total = P_macro + sum(P_sc,2);
end

