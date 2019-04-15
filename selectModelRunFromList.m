function [modelrun, modelidx, models] = selectModelRunFromList(loadtype)

% selectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays.

SCmodelsVEM = {  
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4595.2626';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-27_obj4602.0068';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-27_obj4557.8883';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-26_obj4595.2626';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-27_obj4536.9297';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm3_mo25_dw25_ex-27_obj10964.9323';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm3_mo25_dw25_ex-27_obj10815.2946';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm3_mo25_dw25_ex-27_obj10753.8213';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm3_mo25_dw25_ex-27_obj10964.9323';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm3_mo25_dw25_ex-27_obj10775.2724';
            
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_mm2_mo25_dw25_ex-27_obj4559.9901';
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_mm3_mo25_dw25_ex-27_obj10779.2176';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm2_mo25_dw25_ex-27_obj4551.0881';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm3_mo25_dw25_ex-27_obj10768.2854';
            'placeholder';
            
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_ob1_mm2_mo25_dw25_ex-27_obj17477.2629';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_ob1_mm2_mo25_dw25_ex-27_obj17419.4511';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_ob1_mm2_mo25_dw25_ex-xx_objxxxx.xxxx';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_ob1_mm2_mo25_dw25_ex-27_obj17477.2629';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-27_obj17384.2629';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_ob1_mm3_mo25_dw25_ex-27_obj32115.4702';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_ob1_mm3_mo25_dw25_ex-27_obj32042.1136';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_ob1_mm3_mo25_dw25_ex-xx_objxxxxx.xxxx';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_ob1_mm3_mo25_dw25_ex-27_obj32115.4702';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-27_obj32077.8214';
            
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-27_obj17402.3337';
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-27_obj32015.6861';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_ob1_mm2_mo25_dw25_ex-27_obj17383.5845';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_ob1_mm3_mo25_dw25_ex-27_obj32004.1787';
            'placeholder';
            
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm1_ob1_mm2_mo25_dw25_ex-28_obj17836.3116';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm1_ob1_mm2_mo25_dw25_ex-28_obj17850.8576';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm2_ob1_mm2_mo25_dw25_ex-28_obj17806.9471';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm5_ob1_mm2_mo25_dw25_ex-28_obj17836.3116';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj17797.4510';
            
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm1_ob1_mm3_mo25_dw25_ex-28_obj32500.5703';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm1_ob1_mm3_mo25_dw25_ex-28_obj32461.0147';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm2_ob1_mm3_mo25_dw25_ex-28_obj32449.6955';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm5_ob1_mm3_mo25_dw25_ex-28_obj32500.5703';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj32486.8715';
            
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj17826.4088';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj32464.4365';
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm2_ob1_mm2_mo25_dw25_ex-28_obj17778.1399';
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm2_ob1_mm3_mo25_dw25_ex-27_obj31672.5924';
            'placeholder';
            
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.2961';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1600';
            'placeholder';
            
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.7499';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.5482';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.6818';
         };
     
SCmodelsVEM2 = {  
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj317.8905';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj317.8905';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.7499';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.5482';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.6818';
            
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1600';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.2961';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj290.9940';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1567';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.4349';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj296.0669';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.6658';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.9340';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.6813';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj293.2933';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.6343';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.9482';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.6674';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.5826';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.3840';
            'placeholder';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj135.4247';
            'placeholder';
            'placeholder';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj135.3157';
            
            
         };

SCmodelsVEM3 = {
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.41351385';
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.40838638';
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.41130446';
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.40679241';
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.40255040'; % didn't fully converge - #4:18-20, #9:0-1, #22:21-20, #36:7-8, #52:20-21
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj1.40246666';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.41329103'; % didn't fully converge - no offsets changing, but pd didn't fully converge
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.40994122';
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.41574385';
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.40902340'; % didn't fully converge - #3:2-1, #12:24-23
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.40500764';
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj1.40425671'; % didn't fully converge - no offsets changing, but pd didn't fully converge
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.30894768'; % didn't fully converge - intervention 12 flipping between offset 19 & 22
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.31930876';
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.30894768'; % didn't fully converge - intervention 12 flipping between offset 19 & 22
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.31930876';
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.29222264';
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm2_mo25_dw25_ex-28_obj1.30011632';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };
     
SCmodelsVEM4 = {
            'SCvEM4_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.41351385';
            'SCvEM4_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.40838638';
            'SCvEM4_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.41130446';
            'SCvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.40679241';
            'SCvEM4_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.40255040'; 
            'SCvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.40246666';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEM4_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.41329103'; 
            'SCvEM4_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.40994122';
            'SCvEM4_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.41574385';
            'SCvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.40902340'; 
            'SCvEM4_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.40500764';
            'SCvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.40425671'; 
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEM4_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.30894768'; 
            'SCvEM4_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.31930876';
            'SCvEM4_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.30894768'; 
            'SCvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.31930876';
            'SCvEM4_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.29222264';
            'SCvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.30011632';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };
     
SCmodelsVEM5 = {
            'SCvEM5_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.39965424';
            'SCvEM5_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.39575620';
            'SCvEM5_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.39533401';
            'SCvEM5_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.39416912';
            'SCvEM5_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.39024821';
            'SCvEM5_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.38940962';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEM5_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.39600674';
            'SCvEM5_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.39504919';
            'SCvEM5_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.39487324';
            'SCvEM5_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.39401364';
            'SCvEM5_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.38980249';
            'SCvEM5_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.38900888';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEM5_sig4_mu3_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.28374272';
            'SCvEM5_sig4_mu3_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.29211356';
            'SCvEM5_sig4_mu4_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.28374272';
            'SCvEM5_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.29211356';
            'SCvEM5_sig4_mu5_ca2_sm1_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.26469079';
            'SCvEM5_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.27156118';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };     

     
SCmodelsVEM3Imputed = {
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.41193292';
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.40747059';
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.41080252'; 
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.40592220';
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.40264028'; 
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im2_mm3_mo25_dw25_ex-28_obj1.40041165'; % didn't fully converge - #10:18-17, #22:23-20, #69:19-21, #74:2-11
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.41446115'; 
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.40930355';
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.41246829';
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.40833872'; % didn't fully converge - no offsets changing, but pd didn't fully converge
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.40568664'; % didn't fully converge - #23:23-22, #30:6-5, #80:19-22, #87:0-1
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im2_mm1_mo25_dw25_ex-28_obj1.40250473'; 
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SC_AMvEM3_sig4_mu3_ca2_sm1_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.31068191'; 
            'SC_AMvEM3_sig4_mu3_ca2_sm2_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.31806011'; % didn't fully converge - no offsets changing, but pd didn't fully converge
            'SC_AMvEM3_sig4_mu4_ca2_sm1_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.31068191'; 
            'SC_AMvEM3_sig4_mu4_ca2_sm2_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.31806011'; % didn't fully converge - no offsets changing, but pd didn't fully converge
            'SC_AMvEM3_sig4_mu5_ca2_sm1_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.28785594';
            'SC_AMvEM3_sig4_mu5_ca2_sm2_rm4_ob1_im2_mm2_mo25_dw25_ex-28_obj1.29832814';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };
            
TMmodelsVEM2 = {  
            'TM_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.1535';
            'TM_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.4991';
            'TM_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.1535';
            'TM_AMvEM2_sig4_mu5_ca2_sm1_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.2212';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj37.7257';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.4667';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.0931';
            'placeholder';
            'placeholder';
            'placeholder';
            };
        
TMmodelsVEM3 = {             
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.2047'; % 28 interventions
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.4291'; % 28 interventions
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.1701'; % 28 interventions and outlier prior = 1%
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj37.3985'; % 28 interventions and outlier prior = 1%
            
            };
        
TMmodelsVEM4 = {
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.37745872';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.33160543';
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.36845419';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.28396865';
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.36073688';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.31991255';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.37396710';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.32784193';
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.37786845';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm2_mo25_dw25_ex-28_obj1.27531006';
            'TMvEM4_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.36069992';
            'TMvEM4_sig4_mu5_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.31989860';
            };

SCmodelsFEV1Split = {
            'SCFEV1Split1_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.38927877';
            'SCFEV1Split2_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm1_mo25_dw25_ex-28_obj1.42343683';
            'SCFEV1Split1_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.38653038';
            'SCFEV1Split2_sig4_mu4_ca2_sm2_rm4_ob1_im1_cm2_mm3_mo25_dw25_ex-28_obj1.41807577';
            };
     
     
fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf(' 1: Damian SC - vEM\n');
fprintf(' 2: Damian SC - vEM2\n');
fprintf(' 3: Damian SC - vEM3\n');
fprintf(' 4: Damian SC - vEM4\n');
fprintf(' 5: Damian SC - vEM3 with imputation\n');
fprintf(' 6: Damian TM - vEM2\n');
fprintf(' 7: Damian TM - vEM3\n');
fprintf(' 8: Damian TM - vEM4\n');
fprintf(' 9: Damian SC - vFEV1Split\n');
fprintf('10: Damian SC - vEM5\n');

modelset = input('Choose model set (1-10) ');

if modelset > 10
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelset,'')
    fprintf('Invalid choice\n');
    return;
end

if modelset == 1
    models = SCmodelsVEM;
elseif modelset == 2
    models = SCmodelsVEM2;
elseif modelset == 3
    models = SCmodelsVEM3;
elseif modelset == 4
    models = SCmodelsVEM4;
elseif modelset == 5
    models = SCmodelsVEM3Imputed;
elseif modelset == 6
    models = TMmodelsVEM2;
elseif modelset == 7
    models = TMmodelsVEM3;
elseif modelset == 8
    models = TMmodelsVEM4;
elseif modelset == 9
    models = SCmodelsFEV1Split;
elseif modelset == 10
    models = SCmodelsVEM5;
else
    fprintf('Should not get here\n');
end


nmodels = size(models,1);
fprintf('Model runs available\n');
fprintf('--------------------\n');
for i = 1:nmodels
    fprintf('%d: %s\n', i, models{i});
end
fprintf('\n');

modelidx = input('Choose model run to use ? ');
if modelidx > nmodels 
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelidx,'')
    fprintf('Invalid choice\n');
    return;
end
fprintf('\n');

if isequal(loadtype,'pd')
    modelrun = sprintf('%s-PDs',models{modelidx});
else
    modelrun = models{modelidx};
end

end

