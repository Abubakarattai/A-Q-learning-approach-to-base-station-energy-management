function [P_macro_on, P_sc_on, P_ON] = PCalc_allon(lf, num_sc)

% macro BS
P_c_macro = 130;  % static power (W)
delta_p_macro = 4.7;  % load dependent power consumption constant (unitless)
P_max_macro = 20; % maximum transmit power (W)
Ntx_ma = 1; % no. of transcievers in the macro BS
P_macro_on = Ntx_ma*(P_c_macro + delta_p_macro*lf(:,1)*P_max_macro);

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
Ntx_sc = 1; % no. of transcievers in the SC
    
for sc_idx = 1:num_sc
    if sc_idx <= round(num_sc/4)
        P_sc_on(:,sc_idx) = Ntx_sc*(P_c_sc_rrh + delta_p_sc_rrh*lf(:, sc_idx+1)*P_max_sc_rrh);
        
    elseif (sc_idx > round(num_sc/4) && sc_idx <= round(2*num_sc/4))
        P_sc_on(:,sc_idx) = Ntx_sc*(P_c_sc_micro + delta_p_sc_micro*lf(:, sc_idx+1)*P_max_sc_micro);
        
    elseif (sc_idx > round(2*num_sc/4) && sc_idx <= round(3*num_sc/4))
        P_sc_on(:,sc_idx) = Ntx_sc*(P_c_sc_pico + delta_p_sc_pico*lf(:, sc_idx+1)*P_max_sc_pico);
        
    elseif (sc_idx > round(3*num_sc/4) && sc_idx <= round(4*num_sc/4))
        P_sc_on(:,sc_idx) = Ntx_sc*(P_c_sc_femto + delta_p_sc_femto*lf(:, sc_idx+1)*P_max_sc_femto);
    end
end
P_ON = P_macro_on  + sum(P_sc_on,2);
end


 