function [kf_position] = getUTMPosition(ins_file, timestamps)

  % Load data from csv file 
  ins_file_id = fopen(ins_file);
  headers = textscan(ins_file_id, '%s', 15, 'Delimiter',',');
  ins_data = textscan(ins_file_id, ...
      '%u64 %s %f %f %f %f %f %f %s %f %f %f %f %f %f','Delimiter',',');
  fclose(ins_file_id); 
  
  ins_valid_measurements = strcmp(ins_data{2},'INS_SOLUTION_GOOD');
  %||strcmp(ins_data{2},'INS_ALIGNMENT_COMPLETE');
  ins_timestamps = ins_data{1}(ins_valid_measurements);
  northings = ins_data{6}(ins_valid_measurements);
  eastings = ins_data{7}(ins_valid_measurements);
  downs = ins_data{8}(ins_valid_measurements);
  ins_position = [northings eastings downs];
  ins_timestamps = cast(ins_timestamps, 'double');
  
  % Estimate the 3D UTM position using fused GPS+Inertial sensor data   
  kf_position = [interp1(ins_timestamps, ins_position(:,1), timestamps) ...
      interp1(ins_timestamps, ins_position(:,2), timestamps) ...
      interp1(ins_timestamps, ins_position(:,3), timestamps)];
end