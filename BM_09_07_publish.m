%% BM_09_07 
% Our code before a fundamental restructure which was started as a result
% of a meeting with a computer scientist, Jonathan Fieldsend. See
% associated notes on the wiki <http://2015.igem.org/Team:Exeter/Modeling>.
% This is a simulation of the cell free kit, we hoped building this would
% aid the lab team in their design.
 
%% Setting our toehold/trigger ratio
% t = toehold number
% r = trigger (RNA) number
% N = number of time steps 

    t=10; %Toeholds
    r=10; %RNA's
    N=50; %Time steps

%% Setting our deafault parameters
% These are the parameters used for the basic setup of Brownian motion as
% well as the contianment to a tube.
% Containment is in a 1.5mm Eppendorf tube. 
% All units are SI units unless otherwise stated. 

    rng('shuffle');
    d_t=5.1e-8; % diameter in meters of toehold
    d_r=1.7e-8; % of RNA
    d_c=5.1e-8; % of toehold-RNA complex
    eta = 1.0e-3; % viscosity of water in SI units (Pascal-seconds)
    kB = 1.38e-23; % Boltzmann constant
    T = 293; % Temperature in degrees Kelvin
    D_t = kB * T / (3 * pi * eta * d_t); %diffusion coefficient toehold
    D_r = kB * T / (3 * pi * eta * d_r); %diffusion coefficient RNA
    D_c = kB * T / (3 * pi * eta * d_c); %diffusion coefficient complex
    tau = .1; % time interval in seconds
    p_t = sqrt(2*D_t*tau); 
    p_r = sqrt(2*D_r*tau);
    p_c = sqrt(2*D_c*tau);
    A = 2.5e-10; %binding distance, default at 1e-7 
    styles=['r', 'b', 'g']; %line styles
    theta = 0; % changes the viewing angle
    change = 360/N; % the size of the angle change 
    cylinder_radius=3.64e-3; %radius of 1.5mm eppendorf in metres
    cylinder_height=18e-3; %height of 1.5mm eppendorf
    
    %height can be changed depending on the volume of the solution (rather
    %than the total possible volume of the eppendorf)
    
    %% Generating the matrices needed for plotting 
    % The matrices needed for plotting are all randomly generated before
    % any code is run. 
    % Here the matrices are initalised to zero and then movements are 
    % randomly generated.
    % Displacement matrices are also made to prevent the toeholds and
    % trigger from all forming in the same place. This is added to the
    % movement matrix. 
    
    %Make empty matrices the size needed:
    tx=zeros(N,t); %toehold
    ty=zeros(N,t); 
    tz=zeros(N,t);
    rx=zeros(N,r); %RNA
    ry=zeros(N,r);  
    rz=zeros(N,r);
   
    if t>=r        %complexes, limited by the smaller of t or r. 
        c=r;
    else
        c=t;
    end
    cx=zeros(N,c);
    cy=zeros(N,c);
    cz=zeros(N,c);
    
    %Create random data movements:
    for i=1:t                          %toehold
        tx(:,i)=cumsum(p_t*randn(N,1));
        ty(:,i)=cumsum(p_t*randn(N,1));
        tz(:,i)=cumsum(p_t*randn(N,1));
    end
   
    
    for i=1:r                          %RNA
        rx(:,i)=cumsum(p_r*randn(N,1));
        ry(:,i)=cumsum(p_r*randn(N,1));
        rz(:,i)=cumsum(p_r*randn(N,1));
    end

    for i=1:c                          %Complex
        cx(:,i)=cumsum(p_c*randn(N,1));
        cy(:,i)=cumsum(p_c*randn(N,1));
        cz(:,i)=cumsum(p_c*randn(N,1));
    end
    
    %displacement is added after binding of lines occurs.
    %initial displacement values:
    min=0; %default at 1e-4
    max=3.64e-3;
    
    %displacement martices
    disp_tx=(min+(max-min))*randn(t,1);
    disp_ty=(min+(max-min))*randn(t,1);
    disp_tz=(min+(max-min))*randn(t,1);
    
    disp_rx=(min+(max-min))*randn(r,1);
    disp_ry=(min+(max-min))*randn(r,1);
    disp_rz=(min+(max-min))*randn(r,1);
    
    %% Confinement
    % Here all of the randomly generated coordinate points are checked 
    % against the cylinder they are contained in. If they are outside the
    % cylinder they are moved back in.
    % They are moved back to the edge of the cylinder. 

    %shift by inital displacement values:
    for i=1:t
        for j=1:N
            co_x=tx(j,i)+disp_tx(i,1);
            co_y=ty(j,i)+disp_ty(i,1);
            % Checking whether the toehold is in the cylinder 
            if (co_x^2)+(co_y^2)>=(cylinder_radius^2)      
                %both x and y lie outisde the cylinder // x inside and y
                %ouside // x outside and y inside
                grad=co_y/co_x;
                grad=abs(grad);
                if co_x<0
                   tx(j,i)=-(((cylinder_radius^2)/((grad^2)+1))^0.5); 
                else
                   tx(j,i)=(((cylinder_radius^2)/((grad^2)+1))^0.5);
                end
                if co_y<0
                   ty(j,i)=-(grad*(((cylinder_radius^2)/ ... 
                       ((grad^2)+1))^0.5));
                else
                   ty(j,i)=grad*(((cylinder_radius^2)/((grad^2)+1))^0.5);
                end
            
            %otherwise add normal displacement:
            else   
                tx(j,i)=tx(j,i)+disp_tx(i,1);
                ty(j,i)=ty(j,i)+disp_ty(i,1);
            end
            
            %Z-coordinate confinement to height of the cylinder
            if (tz(j,i)+disp_tz(i,1))>=cylinder_height 
                tz(j,i)=cylinder_height;
            end
            if (tz(j,i)+disp_tz(i,1))<=-cylinder_height
                tz(j,i)=-cylinder_height;
            end
            if (tz(j,i)+disp_tz(i,1))<=cylinder_height && ...
                    (tz(j,i)+disp_tz(i,1))>=-cylinder_height
                tz(j,i)=tz(j,i)+disp_tz(i,1);
            end
        end
    end
    
    for i=1:r
        for j=1:N
            co_x=rx(j,i)+disp_rx(i,1);
            co_y=ry(j,i)+disp_ry(i,1);
            % Checking whether the RNA is in the cylinder 
            if (co_x^2)+(co_y^2)>=(cylinder_radius^2)      
                %both x and y lie outisde the cylinder // x inside and y
                %ouside // x outside and y inside
                grad=co_y/co_x;
                grad=abs(grad);
                if co_x<0
                   rx(j,i)=-(((cylinder_radius^2)/((grad^2)+1))^0.5); 
                else
                   rx(j,i)=(((cylinder_radius^2)/((grad^2)+1))^0.5);
                end
                if co_y<0
                   ry(j,i)=-(grad*(((cylinder_radius^2)/ ... 
                       ((grad^2)+1))^0.5));
                else
                   ry(j,i)=grad*(((cylinder_radius^2)/((grad^2)+1))^0.5);
                end
            
            %otherwise add normal displacement:
            else
                rx(j,i)=rx(j,i)+disp_rx(i,1);
                ry(j,i)=ry(j,i)+disp_ry(i,1);
            end
            
            %Z-coordinate confinement to height of the cylinder
            if (rz(j,i)+disp_rz(i,1))>=cylinder_height 
                rz(j,i)=cylinder_height;
            end
            if (rz(j,i)+disp_rz(i,1))<=-cylinder_height
                rz(j,i)=-cylinder_height;
            end
            if (rz(j,i)+disp_rz(i,1))<=cylinder_height && ...
                    (rz(j,i)+disp_rz(i,1))>=-cylinder_height
                rz(j,i)=rz(j,i)+disp_rz(i,1);
            end
        end
    end
    
    %% Checking and Preparation 
    % Here is were some checking variables are initalised, and the gird
    % for the simulation is set up. 
    
    %checkpoints
    check_r=zeros(1,r); %records identities of joined RNA
    check_t=zeros(1,t); %records identities of joined toeholds
    joinlock=zeros(1,c); %records joined lines
    delay=zeros(1,c); %Delay for after splitting
    splitpoint=zeros(1,c); %timestep when split
    split = zeros(1,c);
    
    %Setting up the grid
    figure()
    axis([-0.00364 0.00364 -0.00364 0.00364 -0.018 0.018]) 
    grid on
    grid MINOR
    set(gcf, 'Position', [100 10 600 600])
    xlabel('Diameter (mm)')
    ylabel('Diameter (mm)')
    zlabel('Height (mm)')
    
    %% The Main Loop
    % This is the main loop of the code were the majority of the
    % simulation is undetaken.
    
    for j=1:N %timesteps
       if j == N
           break
       else
       hold on
       
       if j==1
           % Plotting starting points
           plot3(rx(1,:),ry(1,:),rz(1,:),'kx'); %starting point for RNA
           plot3(tx(1,:),ty(1,:),tz(1,:),'kx') %starting point for toehold
       end
       
       %Generates the random number for joining probability
       join = randi([1 10],1); 

           for k=1:t
               if check_t(1,k)==0   
                   %plots toehold path 
                   plot3([tx(j,k) tx(j+1,k)],[ty(j,k) ty(j+1,k)], ... 
                       [tz(j,k) tz(j+1,k)], styles(2)); %toehold path
               end
               % Sets the number of complexes based on the lower of
               % toeholds and RNA's
               for m=1:r
                  if t>=r
                      n=m;
                  end
                  if t<=r
                      n=k;
                  end  
                  if check_r(1,m)==0  
                      %plots RNA path
                      plot3([rx(j,m) rx(j+1,m)],[ry(j,m) ry(j+1,m)], ... 
                          [rz(j,m) rz(j+1,m)], styles(1)); %RNA path
                  end
                  if join>3   %threshold probability for joining
                     joinlock(1,n)=1;
                  end
                  %define complex loop variable based limiting component
                  if joinlock(1,n)==1 
                   if ((((tx(j,k)-rx(j,m))^2)+((ty(j,k)-ry(j,m))^2)+ ... 
                      ((tz(j,k)-rz(j,m))^2))<=(A^2) || (check_r(1,m)~=0 ... 
                      && check_t(1,k)~=0)) && (j~=1) && delay(1,n)==0    
                       if (check_r(1,m)==0 && check_t(1,k)==0)
                           %ensure a connecting line between new and old:
                           temprx=(rx(j+1,m));
                           temptx=(tx(j+1,k));
                           tempry=(ry(j+1,m));
                           tempty=(ty(j+1,k));
                           temprz=(rz(j+1,m));
                           temptz=(tz(j+1,k));
                           %midpoint between the joining lines
                           cx(j,n)=((rx(j,m)+tx(j,k))/2); 
                           cy(j,n)=((ry(j,m)+ty(j,k))/2);
                           cz(j,n)=((rz(j,m)+tz(j,k))/2);
                           rx(j,m)=temprx;
                           rx(j+1,m)=cx(j,n);
                           ry(j,m)=tempry;
                           ry(j+1,m)=cy(j,n);
                           rz(j,m)=temprz;
                           rz(j+1,m)=cz(j,n);
                           tx(j,k)=temptx;
                           tx(j+1,k)=cx(j,n);
                           ty(j,k)=tempty;
                           ty(j+1,k)=cy(j,n);
                           tz(j,k)=temptz;
                           tz(j+1,k)=cz(j,n);
                           
                           %copies the toehold line to complex line 
                           for b=(j+1):N 
                             if b==N
                                 cx(b,n)=tx(b,k);
                                 cy(b,n)=ty(b,k);
                                 cz(b,n)=tz(b,k);
                             end
                             cx(b-1,n)=tx(b,k); 
                             cy(b-1,n)=ty(b,k);
                             cz(b-1,n)=tz(b,k);
                           end                           
                           
                           %plots a circle at the joining point 
                           plot3(tx(j+1,k),ty(j+1,k),tz(j+1,k),'ko'); 
                           %connector lines
                           plot3([rx(j,m) rx(j+1,m)],[ry(j,m) ... 
                               ry(j+1,m)],[rz(j,m) rz(j+1,m)], styles(1)) 
                           plot3([tx(j,k) tx(j+1,k)],[ty(j,k) ... 
                               ty(j+1,k)],[tz(j,k) tz(j+1,k)], styles(2))
                    
                           %makes check equal 1 to indicate a complex 
                           check_r(1,m)=check_r(1,m)+1; 
                           check_t(1,k)=check_t(1,k)+1; 
                           %plots first section of the complex line
                           plot3([cx(j,n) cx(j+1,n)],[cy(j,n) ... 
                               cy(j+1,n)],[cz(j,n) cz(j+1,n)], styles(3))
                           
                           split(1,n) = randi([1 N],1); 
                           %randon number for truncating limit
                           %Range of the random number needs to be changed
                           %depending on the statistical probability of
                           %(e.g.) 95% of complexes split after a certain
                           %time scale.
             
                       %makes sure split point is in the maximum time step
                           if (j+split(1,n))>=N
                               splittime=j;
                               splitpoint(1,n)=N;
                           end
                           %sets the split point
                           if (j+split(1,n))<=N && splitpoint(1,n)==0 
                               splittime=j;
                               splitpoint(1,n)=(j+split(1,n));
                           end    
                           
                           continue
                       end %end of check==0 statement
       %at split point sets check equal to zero to indicate separate lines
                       if j==splitpoint(1,n) 
                           check_t(1,k)=0;
                           check_r(1,m)=0;
                           tx(j,k)=cx(j,n);
                           ty(j,k)=cy(j,n);
                           tz(j,k)=cz(j,n);
                           rx(j,m)=cx(j,n);
                           ry(j,m)=cy(j,n);
                           rz(j,m)=cz(j,n);
                           %plots the split point
                           plot3(cx(j,n), cy(j,n), cz(j,n), 'k*'); 
                           
                           delay(1,n)=(5*t*r); %binding delay
                           
                           %Generate new directions from the last point of
                           %the green line for the red line
                           
                           rx_temp=zeros(1,N-splitpoint(1,n));
                           ry_temp=zeros(1,N-splitpoint(1,n));
                           rz_temp=zeros(1,N-splitpoint(1,n));
                           rx_temp(1,1)=cx(j,n);
                           ry_temp(1,1)=cy(j,n);
                           rz_temp(1,1)=cz(j,n);
                           
                           %regenerating random numbers to plot the RNA
                           %line
                           for z=2:N-splitpoint(1,n) 
                               rx_temp(1,z)=p_r*randn(1,1);
                               ry_temp(1,z)=p_r*randn(1,1);
                               rz_temp(1,z)=p_r*randn(1,1);
                           end
                           rx2=cumsum(rx_temp)';
                           ry2=cumsum(ry_temp)';
                           rz2=cumsum(rz_temp)';
                           
                           for z=1:length(rx2)
                                   rx(splitpoint(1,n)+z,m)=rx2(z,1);
                                   ry(splitpoint(1,n)+z,m)=ry2(z,1);
                                   rz(splitpoint(1,n)+z,m)=rz2(z,1);
                           end

                           tx_temp=zeros(1,N-splitpoint(1,n));
                           ty_temp=zeros(1,N-splitpoint(1,n));
                           tz_temp=zeros(1,N-splitpoint(1,n));
                           tx_temp(1,1)=cx(j,n);
                           ty_temp(1,1)=cy(j,n);
                           tz_temp(1,1)=cz(j,n);
                           
                           %regenerating random numbers to plot the toehold
                           %line
                           for z=2:N-splitpoint(1,n) 
                               tx_temp(1,z)=p_t*randn(1,1);
                               ty_temp(1,z)=p_t*randn(1,1);
                               tz_temp(1,z)=p_t*randn(1,1);
                           end
                           tx2=cumsum(tx_temp)';
                           ty2=cumsum(ty_temp)';
                           tz2=cumsum(tz_temp)';
                           
                           for z=1:length(tx2)
                                   tx(splitpoint(1,n)+z,k)=tx2(z,1);
                                   ty(splitpoint(1,n)+z,k)=ty2(z,1);
                                   tz(splitpoint(1,n)+z,k)=tz2(z,1);
                           end
                       end  %end of  if j==splitpoint statement
                       if (check_r(1,m)~=0 && check_t(1,k)~=0)
                           %plots complex line:
                           plot3([cx(j,n) cx(j+1,n)],[cy(j,n)...
                               cy(j+1,n)],[cz(j,n) cz(j+1,n)], styles(3));                     
                       end
                   end %end of if statement
                  end %end of joinlock==1 statement
                  %delay countdown
                  if delay(1,n)~=0
        	         delay(1,n)=delay(1,n)-1;
                  end       
               end %end of m for loop
           end %end of k for loop
       end %end of if j==N statement
       %drawnow 
       
       %% Code needed to produce a .gif file of the simulation output
       
       % gif utilities
       set(gcf,'color','w'); % set figure background to white
       drawnow;
       frame = getframe(gcf);
       im = frame2im(frame);
       [imind,cm] = rgb2ind(im,256);
       outfile = 'Ribonostics9.gif';
       
       % adjusting the viewing the angle
       view(theta,45);
       theta = theta + change;

       % On the first loop, create the file. In subsequent loops, append.
       if j==1
          imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
       else
          imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode', ...
          'append');
       end
        
    end %end of j for loop
            
    %% End Of The Code
    % This is preliminary simulation developed by the Univeristy Of Exeter
    % iGEM team 2015.
    % Developed mainly by Amy, Dan and Todd. 
    