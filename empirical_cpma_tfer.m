% empirical-cpma-tfer model evaluates the actual CPMA transfer function using a triangular model.
% Author: Arash Naseri, 2023-01-29
% 
% Inputs:
%   m_star      CPMA mass set point in fg
%   Rm          CPMA resolution            
%   Q           CPMA flow rate in LPM
%   m           Particle mass in fg
%   ~           Placeholder for CPMA voltage 
%   ~           Placeholder for CPMA rotational speed 
% Outputs:
%   Omega_cpma   CPMA transfer function for specified particle mas m at 
%                give CPMA configurations
% Requirement: ".json" is required for running this function.
%=========================================================================%

function [Omega_cpma] = empirical_cpma_tfer(m,m_star,Rm,Q)

    if m_star<10^-10  
        error("Insert CPMA mass set point in fg.")
    elseif m_star<0.05 || m_star>100  
         warning("Warning! m* is out of experimentally range (m* in [0.05,100] fg)!")
    end
    
    if Rm<2 || Rm>15  
        warning("Warning! R_m is out of range (R_m in[2,15])!")
    end
    
    
    %% Importing .json file for empirical coefficients
    coeff = jsondecode(fileread('tri_coef.json')); % read json file 
    m_tilde = m./m_star; 
    Beta =1/Rm;

    %% defining a function for width and height factors
    % Width factor
    
    func_width= @(coef_w, m_star, Rm, Q)(coef_w(1).*Q+coef_w(2).*Rm.^coef_w(3)+coef_w(4))./...
        (1+exp((coef_w(5).*Q+coef_w(6)).*(log10(m_star)+coef_w(7).*Q+coef_w(8))));

    % Height factor
    func_height = @(coef_h,m_star, Rm, Q)(coef_h(1).*Rm.^3+coef_h(2).*Rm.^2+coef_h(3).*Rm+coef_h(4))./...
        (1+exp(-(coef_h(5).*Rm+coef_h(6)).*(log10(m_star)+(coef_h(7).*exp(coef_h(8).*Rm)+coef_h(9)))));
    

    %% defining a non idealized-triangular transfer function

  
    tri_tfer=@(mu, eta, m_tilde, Beta) (eta.*mu )./(2.*Beta).*(...
        abs(m_tilde-(1+Beta./mu))+abs(m_tilde-(1-Beta./mu))-2.*abs(m_tilde-1)...
        );
    
    %% Evaluation of empirical trasnfer function at a given configurration

    mu = func_width(coeff.c_width, m_star, Rm, Q);

    if Q > 8 || Q < 0.3
        error("Error: Extrapolation is not allowed! Please consider a flow rate in [0.3,8] LPM")

    elseif Q == 0.3
        coef_h = coeff.c_height.Q03;
        eta1 = func_height(coef_h, m_star, Rm, Q);
        Omega_cpma = tri_tfer(mu, eta1, m_tilde, Beta);


    elseif 0.3< Q && Q < 1.5
        coef_h = coeff.c_height.Q03;
        eta1 = func_height(coef_h, m_star, Rm, Q);
        coef_h = coeff.c_height.Q15;
        eta2 = func_height(coef_h, m_star, Rm, Q);


        Omega_cpma1 = tri_tfer(mu, eta1, m_tilde, Beta);
        Omega_cpma2 = tri_tfer(mu, eta2, m_tilde, Beta); 

         Omega_cpma= interp1([0.3,1.5],[Omega_cpma1,Omega_cpma2],Q,"linear");


    elseif Q == 1.5
        coef_h = coeff.c_height.Q15;
        eta1 = func_height(coef_h, m_star, Rm, Q);

        Omega_cpma = tri_tfer(mu, eta1, m_tilde, Beta);

    elseif 1.5 < Q && Q < 4
        coef_h = coeff.c_height.Q15;
        eta1 = func_height(coef_h, m_star, Rm, Q);
        coef_h = coeff.c_height.Q4;
        eta2 = func_height(coef_h, m_star, Rm, Q); 

        Omega_cpma1 = tri_tfer(mu, eta1, m_tilde, Beta);
        Omega_cpma2 = tri_tfer(mu, eta2, m_tilde, Beta); 


        Omega_cpma= interp1([1.5,4],[Omega_cpma1,Omega_cpma2],Q,"linear");
                   
    elseif Q == 4 
        coef_h = coeff.c_height.Q4;
        eta1 = func_height(coef_h, m_star, Rm, Q);   
        Omega_cpma = tri_tfer(mu, eta1, m_tilde, Beta);

    elseif 4 < Q && Q < 8
        coef_h = coeff.c_height.Q03;
        eta1 = func_height(coef_h, m_star, Rm, Q);
        coef_h = coeff.c_height.Q8;
        eta2 = func_height(coef_h, m_star, Rm, Q);  

        Omega_cpma1 = tri_tfer(mu, eta1, m_tilde, Beta);
        Omega_cpma2 = tri_tfer(mu, eta2, m_tilde, Beta); 

         Omega_cpma= interp1([4,8],[Omega_cpma1,Omega_cpma2],Q,"linear");

    elseif Q == 8
        coef_h = coeff.c_height.Q03;
        eta1 = func_height(coef_h, m_star, Rm, Q);
        Omega_cpma = tri_tfer(mu, eta1, m_tilde, Beta);

    end


end




