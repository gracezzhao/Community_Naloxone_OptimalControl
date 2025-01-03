clear all
close all
clc

T=90;


test = -1;

delta = 0.001;
M = T;
tvec=linspace(0,T,M+1)';

x=zeros(M+1,5);
lambda=zeros(M+1,5);
u=zeros(M+1,1);

C1 = 15; % Low cost
C2 = (4.465/2.856)*326.69+750;
C3 = 1;
epsilon = 0.00001;
beta = 0.000392;
mu = 0.52;
gamma = 0.697;
delta_param = 0.357;
sigma = 0.138;
theta = 0.24;
a = -0.313;
theta_u=(1+a*u)*theta;
alpha=1-(1+a*u)*theta;

param=[C1,C2,C3,epsilon,beta,mu,gamma,delta_param,sigma,theta,a];
initialconditions=[1483 0 0 0 0 0 0 0];


while(test < 0)
    
    oldu = u;
    oldx = x;
    oldlambda = lambda;
    
    solx = ode45(@(t,x) statelab7(t,x,tvec,u,param),tvec,initialconditions); %initial conditions
    x = deval(solx,tvec)';

    sollamb = ode45(@(t,lambda) adjointlab7(t,lambda,tvec,x,u,param),[T 0],[0 0 0 0 0]); %how many lambdas
    lambda = deval(sollamb,tvec)';
    
    X = x(:,2); %the states needed in H_n
    lambdaU=lambda(:,1);
    lambdaX = lambda(:,2);
    lambdaH = lambda(:,3);

    temp = (C1 + C2*a*theta*X - lambdaU.*theta.*X.*a + lambdaX.*theta.*X.*a)/(-2*epsilon);
    u1 = min(.85,max(0,temp));
    u = 0.5*(u1 + oldu);
    
    test=min([delta*norm(u,1)-norm(oldu-u,1) delta*norm(x(:,1:5),1)-norm(oldx(:,1:5)-x(:,1:5),1) delta*norm(lambda,1)-norm(oldlambda-lambda,1)]);
    J = C1 * u + epsilon * u.^2 + C2*theta_u.*X;

end

result=letsplot(x,tvec,u, param,initialconditions);

        
function [ dx ] = statelab7( t,x,tvec,u, param)


C1=param(1);
C2=param(2);
C3=param(3);
epsilon=param(4);
beta=param(5);
mu=param(6);
gamma=param(7);
delta_param=param(8);
sigma=param(9);
theta=param(10);
a=param(11);

u=pchip(tvec,u,t);
dx=zeros(8,1);

theta_u=(1+a*u)*theta;
alpha=1-(1+a*u)*theta;

dx(1) = alpha * x(2) + sigma * x(4) -beta * x(1) + gamma * x(3);
dx(2) = beta * x(1) - (alpha + theta_u) * x(2);
dx(3) = theta_u * x(2) - delta_param * x(3) -  mu * x(3) - gamma * x(3);
dx(4) = delta_param * x(3) - sigma * x(4);
dx(5) = mu * x(3);
dx(6) = beta * x(1);
dx(7) =theta_u*x(2);
dx(8) = mu * x(3);
end

function [ dlambda ] = adjointlab7( t,lambda,tvec,x,u,param )

C1=param(1);
C2=param(2);
C3=param(3);
epsilon=param(4);
beta=param(5);
mu=param(6);
gamma=param(7);
delta_param=param(8);
sigma=param(9);
theta=param(10);
a=param(11);

x=interp1(tvec,x,t);
u=pchip(tvec,u,t);
dlambda=zeros(5,1);

theta_u=(1+a*u)*theta;
alpha=1-(1+a*u)*theta;

dlambda(1) = lambda(1) * beta - lambda(2) * beta;
dlambda(2) = -C2 * theta_u - lambda(1) * alpha + lambda(2) * alpha + lambda(2) * theta_u - lambda(3) * theta_u;
dlambda(3) = - gamma * lambda(1) + lambda(3)*(gamma + mu + delta_param) - lambda(4) * delta_param;
dlambda(4) = - lambda(1) * sigma + lambda(4) * sigma;
dlambda(5) = 0;

end

function [result] = letsplot(x,tvec,u, param,initialconditions)
 

basesolx = ode45(@(t,x) plotode(t,x,tvec,u*0,param),tvec,initialconditions); %initial conditions

    basex = deval(basesolx,tvec)';
    baseU=x(:,1);
    baseX=x(:,2);
    baseH=x(:,3);
    baseR=x(:,4);
    baseD=x(:,5);
    baseCO=x(:,6);
    baseCH=x(:,7);
    baseCD=x(:,8);

    U=x(:,1);
    X=x(:,2);
    H=x(:,3);
    R=x(:,4);
    D=x(:,5);
    CO=x(:,6);
    CH=x(:,7);
    CD=x(:,8);

              figure
       hold all
       set(gca,'FontSize',8)
       tiledlayout(2,4);
       nexttile([2 1])
       plot(tvec,u,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Naloxone Units','FontSize',8)
       nexttile
       plot(tvec,X,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Overdose','FontSize',8)
       nexttile
       plot(tvec,H,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Hospitalization','FontSize',8)
       nexttile
       plot(tvec,D,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Death','FontSize',8)
       nexttile
       plot(tvec,CO,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Cumulative Overdose','FontSize',8)
       nexttile
       plot(tvec,CH,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Cumulative Hospitalization','FontSize',8)
       nexttile
       plot(tvec,CD,'linewidth',2)
       xlabel('Days','FontSize',8)
       title('Cumulative Death','FontSize',8)

        % Change size of graph and default line width
        set(gcf,'position',[200,200,1500,800])
        set(groot,'defaultLineLineWidth', 1.5)

 

end



function [dx]=plotode(t,x,tvec,u, param)


C1=param(1);
C2=param(2);
C3=param(3);
epsilon=param(4);
beta=param(5);
mu=param(6);
gamma=param(7);
delta_param=param(8);
sigma=param(9);
theta=param(10);
a=param(11);

u=pchip(tvec,u,t);
dx=zeros(8,1);

theta_u=(1+a*u)*theta;
alpha=1-(1+a*u)*theta;

dx(1) = alpha * x(2) + sigma * x(4) -beta * x(1) + gamma * x(3);
dx(2) = beta * x(1) - (alpha  + theta_u) * x(2);
dx(3) = theta_u * x(2) - delta_param * x(3) -  mu * x(3) - gamma * x(3);
dx(4) = delta_param * x(3) - sigma * x(4);
dx(5) = mu * x(3);
dx(6) = beta * x(1);
dx(7) =theta_u*x(2);
dx(8) = mu * x(3);
end