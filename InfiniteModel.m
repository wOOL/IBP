close all;
clear all;
rng(1943);

N = 500;
[mut,X] = genData(N);

% Plot
plotF(mut);
plotF(X(randsample(1:500,64),:));

% Initialise
D = size(X,2);
K = 15;

sigma_A = 0.35;
sigma_n = 0.1;
alpha = 1;

nu = rand(N,K);
nu = nu./repmat(sum(nu,2),1,K);
Phi = 0.1 * ones(D,D,K);
phi = rand(K,D);
tau = rand(K,2);

for I = 1:200
    % Update Phi, phi
    for k = 1:K
        Phi(:,:,k) = (1/sigma_A^2 + 1/sigma_n^2 * sum(nu(:,k)))^-1 * eye(D);
        phi(k,:) = 1/sigma_n^2 * nu(:,k)'*(X-nu*phi+nu(:,k)*phi(k,:)) * Phi(1,1,k);
    end
    % Using multinomial approximation (q) for optimisation on E_nu[log(1-prod(v_m))]
    q = zeros(K,K);
    q(1,1) = 1;
    for k = 2:K
        q(k,1) = exp(psi(tau(1,2))-psi(tau(1,1)+tau(1,2)));
        for i = 2:k
            q(k,i) = exp(psi(tau(i,2))+sum(psi(tau(1:i-1,1)))-sum(psi(tau(1:i,1)+tau(1:i,2))));
        end
    end
    q = q./repmat(sum(q,2),1,K);
    % Update tau
    for k = 1:K
        nu_sum = sum(nu);
        tau(k,1) = alpha + sum(nu_sum(k:K)) + (N-nu_sum(k+1:K))*sum(q(k+1:K,k+1:K),2);
        tau(k,2) = 1 + (N-nu_sum(k:K))*q(k:K,k);
    end
    % Update nu
    for k = 1:K
        tmpS = 0;
        if k > 1
            tmpS = fliplr(cumsum(fliplr(q(k,2:k))))*psi(tau(1:k-1,1));
        end
        nu(:,k) = 1./(1+exp(-(...
            sum(psi(tau(1:k,1))-psi(tau(1:k,1)+tau(1:k,2))) ...
            -(q(k,1:k)*psi(tau(1:k,2)) + tmpS - fliplr(cumsum(fliplr(q(k,1:k))))*psi(tau(1:k,1)+tau(1:k,2)) - q(k,1:k)*log(q(k,1:k))')...
            - 0.5/sigma_n^2*(trace(Phi(:,:,k))+phi(k,:)*phi(k,:)')...
            + 1/sigma_n^2*phi(k,:)*(X-nu*phi+nu(:,k)*phi(k,:))')));
    end
end

plotF(phi)