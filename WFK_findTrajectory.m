function [coords_mm,markers,trajectory] = WFK_findTrajectory(options,side)
% This function is the main function of LEAD-DBS. It will generate a 
% vector of coordinates. 
% Trajectory{1} will be the right trajectory, trajectory{2} the
% left one.
% For each hemisphere of the brain, this function will call the
% reconstruction routine ea_autocoord_side and lateron call functions for
% manual correction of the results, render and slice views.
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn

% WFK -- created this function from the portion of ea_autocoord that does
% the finding of trajectories in the lpostop_ct.nii file.
%   -- June 15, 2016


% get accurate electrode specifications and save it in options.
global codePath;
options=ea_resolve_elspec(options);
patientname=options.patientname;
options.verbose = 0;  % 3 changed to zero WFK June 15, 2016
options.refinesteps = 0;
options.modality = 2;
options.entrypoint = 'STN, GPi or ViM';
options.tra_stdfactor = 0.90;
options.automask = 1;
options.maskwindow = 10;
options.earoot = codePath;

% options.prefs=ea_prefs(patientname); WFK try skipping this June 15, 2016


% if options.doreconstruction
    % ea_checkfiles(options);  % WFK try skipping this June 15, 2016
    % for side=options.sides
        %try
        % call main routine reconstructing trajectory for one side.
        
        [coords,trajvector{side},trajectory{side},tramat]=WFK_ea_reconstruct(patientname,options,side);
        
        
        
        % refit electrodes starting from first electrode (this is redundant at
        % this point).
   
        coords_mm{side} = ea_map_coords(coords', [options.root,options.prefs.patientdir,filesep,options.prefs.tranii])';
        
        
        [~,distmm]=ea_calc_distance(options.elspec.eldist,trajvector{side},tramat(1:3,1:3),[options.root,options.prefs.patientdir,filesep,options.prefs.tranii]);
        
        comp = ea_map_coords([0,0,0;trajvector{side}]', [options.root,options.prefs.patientdir,filesep,options.prefs.tranii])'; % (XYZ_mm unaltered)
        
        trajvector{side}=diff(comp);
        
        
        
        normtrajvector{side}=trajvector{side}./norm(trajvector{side});
        
        for electrode=2:4
            
            coords_mm{side}(electrode,:)=coords_mm{side}(1,:)-normtrajvector{side}.*((electrode-1)*distmm);
            
        end
        markers(side).head=coords_mm{side}(1,:);
        markers(side).tail=coords_mm{side}(4,:);
        

        orth=null(normtrajvector{side})*(options.elspec.lead_diameter/2);
        
        markers(side).x=coords_mm{side}(1,:)+orth(:,1)';
        markers(side).y=coords_mm{side}(1,:)+orth(:,2)'; % corresponding points in reality
        
        
        
        % coords_mm=ea_resolvecoords(markers,options);
        
        load([options.earoot,'templates',filesep,'electrode_models',filesep,options.elspec.matfname]);
        % for side=1:length(markers)
            M=[markers(side).head,1;markers(side).tail,1;markers(side).x,1;markers(side).y,1];
            E=[electrode.head_position,1;electrode.tail_position,1;electrode.x_position,1;electrode.y_position,1];
            X=linsolve(E,M);
            coords_mm=[electrode.coords_mm,ones(size(electrode.coords_mm,1),1)];
            WFKcoords{side}=X'*coords_mm';
            WFKcoords{side}=WFKcoords{side}(1:3,:)';
        % end
        coords_mm=WFKcoords;
        
        
        

    % end
    
  
    
    try
        %realcoords=load([options.root,patientname,filesep,'L.csv']);
        %realcoords=realcoords(:,1:3);
        
        realcoords=ea_read_fiducials([options.root,patientname,filesep],'L');
    catch
        ea_showdis('No manual survey available.',options.verbose);
        realcoords=[];
    end
    
    % transform trajectory to mm space:
    % for side=options.sides
        
        try
            if ~isempty(trajectory{side})
                trajectory{side}=ea_map_coords(trajectory{side}', [options.root,patientname,filesep,options.prefs.tranii])';
            end
            
        end
    % end
    
    
    % save reconstruction results
    elmodel=options.elmodel;
    save([options.root,patientname,filesep,'ea_reconstruction'],'trajectory','coords_mm','markers','elmodel');
    
% end







