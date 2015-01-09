% Main_Xcel_Read_Data_and_Plot_Code.m

% I.    Clear things out nicely
% II.   Set the paths
% III.  Set if the optional parts of the code will be executed
% IV.   Set important constant parmeters
% V.    Set Important String Data
% VI.   Read in the directory List of Available Files
% VII.  Find the ends of the missing data
% VIII. Create a Timeline Plot of Missing Data
% IX.   Read in the netCDF Files, while replacing missing all kinds of missing values
% X.    Concatenate Files and Create Data Structure
% XI.   Read in Met Tower Data
% XII.  Plot Data
% XIII. Plot Meteorological Tower Data
% XIV.  Perform Wavelet Analysis
% XV.   Perform Additional Wavelet Analysis
% XVI.  Perform Atmospheric Stability Analysis
% XVII. End of the Main Driver Code

%% I. Clear things out nicely:

% Clear the command window
clc

% This clears the workspace currently once only:
clear

% Close all the figures:
close all

str_echo_start = 'Starting Xcel Data Read Codes...';
disp(str_echo_start);


%% II. Set the paths:

% parent_files_dir                        = 'C:\Users\Paulster\Documents\Xcel_Energy_Files\';
parent_files_dir                        = 'E:\Xcel_Energy_Files\';

working_directory                       = strcat( parent_files_dir, 'Matlab_Codes\' ) ;

out_plot_dir                            = strcat( parent_files_dir, 'plots_to_show\' ) ;

% Set the directory (or URL) path to the file(s) and the filename. Then concatenate them together:

ptquelet_breeze_URL_dir                 = 'http://breeze.colorado.edu/ptquelet/';

% Local netCDF files directory:

% ptquelet_netCDF_files_local_dir         = 'C:\Users\paqu8639\Documents\Xcel_Energy_Files\' ;

ptquelet_netCDF_files_local_dir         = parent_files_dir ;

% Meteorological Tower info and data directory:

met_tower_info_dir                      = strcat( parent_files_dir, 'Xcel_met_towers_info\' ) ;

met_tower_data_txt_files_dir            = strcat( parent_files_dir, 'met_tower_data_txt_files\' ) ;

met_tower_data_mat_files_dir            = strcat( parent_files_dir, 'tower_data_all_concat_mat_files\' ) ;

met_tower_data_same_TS_and_NaNs         = strcat( parent_files_dir, 'tower_data_same_TS_and_NaNs\' ) ;

met_tower_data_tower_rich_num           = strcat( parent_files_dir, 'richardson_tower_data_same_TS_and_NaNs\' ) ;

met_tower_data_tower_QC_downsamp        = strcat( parent_files_dir, 'richardson_tower_data_QC_downsamp\' ) ;

met_tower_numpts_vars_Ri_tower_dir      = strcat( parent_files_dir, 'numpts_Ri_data_count\' ) ;

% Add the path to the import functions (this should add the subdirectories also):

% addpath(genpath('C:\Users\Paulster\Documents\MATLAB\Import_Functions'))
addpath(genpath('C:\Users\paqu8639\Documents\MATLAB\Import_Functions'))

%% III. Set if the optional parts of the code will be executed:

% Flags for which set of dates:

flag_CO_dates                           = 0 ;

flag_NEW_dates                          = 0 ;

% Flags for missing days and timeline:

flag_find_ends_missing_data             = 0 ;

flag_timeline_plot_execute              = 0 ;

% Flags for data read in, turbines:

flag_read_netCDF_completely             = 0 ;

flag_concatenate_monthly_files          = 0 ;

flag_create_time_vector                 = 0 ;

flag_create_struct_array                = 0 ;

flag_pass_lower_struct_values           = 0 ;

% Flags for data read in, high resolution turbine data:

flag_import_high_res_turbine_data       = 0 ;

% Flags for data read in, meteorological towers:

flag_create_NEW_time_vector             = 0 ;

flag_import_met_tower_data              = 0 ;

flag_concatenate_monthly_met_tower_mat  = 0 ;

flag_filter_multi_level_tower_data      = 0 ;

flag_richardson_num_tower_calc          = 0 ;

flag_met_tower_files_QC_time_axis       = 1 ; 

% Plots Flags:

flag_monthly_line_plots_individual_farms= 0 ;

flag_diurnal_line_plots                 = 0 ;

flag_Weibull_Distribution               = 0 ;

% Power Curve Plots:

flag_create_power_curve                 = 0 ;

flag_power_curves_day_night             = 0 ;

flag_power_curves_anomaly_day_night     = 0 ;

flag_power_curve_anom_season_day_night  = 0 ;

flag_power_curves_Ri                    = 0 ; 

flag_power_curves_Ri_seasonal           = 0 ; 

flag_power_curves_Ri_scatter            = 0 ; 

% Other Plots:

flag_scatter_plots_farms                = 0 ;

flag_farm_box_plots                     = 0 ;

flag_seasonal_diurnal_line_plots        = 0 ;

flag_yearly_verf_diurnal_line_plots     = 0 ;

flag_yearly_together_diurnal_line_plots = 0 ;

% Meterological Towers Plots:

flag_tower_time_diffs_histogram         = 0 ; 

flag_plot_wind_roses_towers             = 0 ; 

flag_monthly_line_plots_towers          = 0 ;

flag_diurnal_line_plots_towers          = 0 ;

flag_Weibull_Distribution_towers        = 0 ;

flag_tower_temperature_compare_timeseries = 0 ; 

flag_tower_temperature_compare_histo    = 0 ;

flag_diurnal_numpts_vars_Ri_towers      = 0 ; 

% Wavelet Analysis:

flag_wavelet_analysis                   = 0 ;

flag_wavelet_additional_analysis        = 0 ;

% Stability Analysis

flag_calc_pseudo_ti                     = 0 ;

flag_calc_pseudo_ti_at_turbs            = 0 ;

flag_calc_pseudo_ti_seasonal_diurnal    = 0 ;

flag_calculate_Ri_time_series           = 0 ;

flag_calculate_Ri_diurnal_signal        = 0 ;

flag_calculate_Ri_seasonal_diurnal_signal = 0 ;

flag_calculate_T_seasonal_diurnal_signal= 0 ;

flag_calculate_Ri_histogram             = 0 ; 

flag_calculate_Ri_day_night_histogram   = 0 ; 

%% IV. Set important constant parmeters:

% Establish the constants as global variables

global ...
    NUM_FARMS_CO ...
    NUM_FARMS_TOTAL ...
    NUM_TURB_NorthernColorado ...
    NUM_TURB_NorthernColorado2 ...
    NUM_TURB_Logan ...
    NUM_TURB_PeetzTable ...
    NUM_TURB_GrandMeadows ...
    NUM_TURB_SanJuanMesa ...
    NUM_TURB_MinnDakota ...
    NUM_TURB_TwinButtes ...
    PERIOD_SAMPLING_MIN ...
    NUM_5_MIN_PERIODS_IN_DAY...
    TURB_CAP_MW_NorthernColorado ...
    TURB_CAP_MW_NorthernColorado2 ...
    TURB_CAP_MW_Logan ...
    TURB_CAP_MW_PeetzTable ...
    TURB_CAP_MW_GrandMeadows ...
    TURB_CAP_MW_SanJuanMesa ...
    TURB_CAP_MW_MinnDakota ...
    TURB_CAP_MW_TwinButtes ...
    ELEV_M_NorthernColorado ...
    ELEV_M_NorthernColorado2 ...
    ELEV_M_Logan ...
    ELEV_M_PeetzTable ...
    ELEV_M_GrandMeadows ...
    ELEV_M_SanJuanMesa ...
    ELEV_M_MinnDakota ...
    ELEV_M_TwinButtes ...
    YEAR_START_CO ...
    YEAR_START_NEW ...
    NUM_YEARS_DATA_CO ...
    NUM_YEARS_DATA_NEW ...
    NUM_MONTHS_YEAR ...
    NUM_HOURS_DAY ...
    NUM_MIN_HOUR ...
    NUM_SEC_DAY ...
    kW_to_MW ...
    DECIMAL2PCT ...
    g_EARTH_AVG ...
    DEGC2K_add ...
    RHO_O_IEC_KG_M3 ...
    RHO_KG_M3_NorthernColorado ...
    RHO_KG_M3_NorthernColorado2 ...
    RHO_KG_M3_Logan ...
    RHO_KG_M3_PeetzTable ...
    RHO_KG_M3_GrandMeadows ...
    RHO_KG_M3_SanJuanMesa ...
    RHO_KG_M3_MinnDakota ...
    RHO_KG_M3_TwinButtes

% Turbine Information:
NUM_FARMS_CO                = 4 ; % Number of Wind Farms in Colorado
NUM_FARMS_TOTAL             = 8 ; % Total Number of Wind Farms

% Establish the number of turbines in each wind farm:
NUM_TURB_NorthernColorado   =  66 ;
NUM_TURB_NorthernColorado2  =  15 ;
NUM_TURB_Logan              = 134 ;
NUM_TURB_PeetzTable         = 133 ;
NUM_TURB_GrandMeadows       =  67 ;
NUM_TURB_SanJuanMesa        = 120 ;
NUM_TURB_MinnDakota         = 100 ;
NUM_TURB_TwinButtes         =  50 ;

% Set the turbine capacities in each farm:
TURB_CAP_MW_NorthernColorado   = 2.3 ; % Siemens 2.3-101m turbines
TURB_CAP_MW_NorthernColorado2  = 1.5 ; % GE 1.5-77m turbines
TURB_CAP_MW_Logan              = 1.5 ; % GE 1.5-77m turbines
TURB_CAP_MW_PeetzTable         = 1.5 ; % GE 1.5-77m turbines
TURB_CAP_MW_GrandMeadows       = 1.5 ; % GE 1.5-77m turbines
TURB_CAP_MW_SanJuanMesa        = 1.0 ; % Mitsubishi 1.0-62m turbines (69.2 m HH)
TURB_CAP_MW_MinnDakota         = 1.5 ; % GE 1.5-77m turbines
TURB_CAP_MW_TwinButtes         = 1.5 ; % GE 1.5-77m turbines

% Set the elevations [m] of each wind farm:
ELEV_M_NorthernColorado     = 1297.0 ; % +/- 10.111 m
ELEV_M_NorthernColorado2    = 1309.1 ; % +/-  5.000 m
ELEV_M_Logan                = 1395.2 ; % +/- 13.730 m
ELEV_M_PeetzTable           = 1447.5 ; % +/- 12.480 m
ELEV_M_GrandMeadows         =  426.5 ; % +/-  4.810 m
ELEV_M_SanJuanMesa          = 1431.3 ; % +/-  4.093 m
ELEV_M_MinnDakota           =  587.5 ; % +/-  7.790 m
ELEV_M_TwinButtes           = 1434.8 ; % +/- 14.623 m

% Time information:
PERIOD_SAMPLING_MIN         = 5     ;
NUM_5_MIN_PERIODS_IN_DAY    = 288   ; % Integer number of 5 minute periods in one day
YEAR_START_CO               = 2010  ; % The absolute year of the dataset start for CO
YEAR_START_NEW              = 2012  ; % The absolute year of the dataset start for the newer data
NUM_YEARS_DATA_CO           = 4     ; % Length of the dataset in years for CO
NUM_YEARS_DATA_NEW          = 2     ; % Length of the new dataset in years
NUM_MONTHS_YEAR             = 12    ;
NUM_HOURS_DAY               = 24    ;
NUM_MIN_HOUR                = 60.0  ;
NUM_SEC_DAY                 = 86400 ; 

% Unit Conversion Factors:
kW_to_MW                    = 1e-03 ;
DECIMAL2PCT                 = 100.0 ;

% Scientific Constants:
g_EARTH_AVG                 =   9.81  ;
DEGC2K_add                  = 273.15  ;
RHO_O_IEC_KG_M3             =   1.225 ;

% Standard Atmosphere Air Densities for each wind farm (used average elev):
% (Used standard atmospheric calculator from www.digitaldutch.com/atmoscalc/)

RHO_KG_M3_NorthernColorado  = 1.07957 ; % +/- 0.00107 --> 0.0991 % std
RHO_KG_M3_NorthernColorado2 = 1.07828 ; % +/- 0.00052 --> 0.0482 % std
RHO_KG_M3_Logan             = 1.06913 ; % +/- 0.00145 --> 0.1356 % std
RHO_KG_M3_PeetzTable        = 1.06360 ; % +/- 0.00365 --> 0.3432 % std
RHO_KG_M3_GrandMeadows      = 1.17562 ; % +/- 0.00055 --> 0.0468 % std
RHO_KG_M3_SanJuanMesa       = 1.06531 ; % +/- 0.00043 --> 0.0404 % std
RHO_KG_M3_MinnDakota        = 1.15738 ; % +/- 0.00087 --> 0.0752 % std
RHO_KG_M3_TwinButtes        = 1.06494 ; % +/- 0.00150 --> 0.1409 % std

% Even after setting to Global Variables, still need to be able to pass
% these to functions. Thus, store them all into a single structure function
% that will have syntax at the top of each function to unpack them:

% Syntax is:
% mystructure = struct('fieldname_1', field_1, 'fieldname_2', field_2, ... )

CONST_STRUCT = ...
    struct( ...
    'NUM_FARMS_CO', NUM_FARMS_CO, ...
    'NUM_FARMS_TOTAL', NUM_FARMS_TOTAL, ...
    'NUM_TURB_NorthernColorado', NUM_TURB_NorthernColorado, ...
    'NUM_TURB_NorthernColorado2', NUM_TURB_NorthernColorado2, ...
    'NUM_TURB_PeetzTable', NUM_TURB_PeetzTable, ...
    'NUM_TURB_Logan', NUM_TURB_Logan, ...
    'NUM_TURB_GrandMeadows', NUM_TURB_GrandMeadows, ...
    'NUM_TURB_SanJuanMesa', NUM_TURB_SanJuanMesa, ...
    'NUM_TURB_MinnDakota', NUM_TURB_MinnDakota, ...
    'NUM_TURB_TwinButtes', NUM_TURB_TwinButtes, ...
    'PERIOD_SAMPLING_MIN', PERIOD_SAMPLING_MIN, ...
    'NUM_5_MIN_PERIODS_IN_DAY', NUM_5_MIN_PERIODS_IN_DAY, ...
    'TURB_CAP_MW_NorthernColorado', TURB_CAP_MW_NorthernColorado, ...
    'TURB_CAP_MW_NorthernColorado2', TURB_CAP_MW_NorthernColorado2, ...
    'TURB_CAP_MW_Logan', TURB_CAP_MW_Logan, ...
    'TURB_CAP_MW_PeetzTable', TURB_CAP_MW_PeetzTable, ...
    'TURB_CAP_MW_GrandMeadows',TURB_CAP_MW_GrandMeadows, ...
    'TURB_CAP_MW_SanJuanMesa',TURB_CAP_MW_SanJuanMesa, ...
    'TURB_CAP_MW_MinnDakota', TURB_CAP_MW_MinnDakota, ...
    'TURB_CAP_MW_TwinButtes', TURB_CAP_MW_TwinButtes, ...
    'ELEV_M_NorthernColorado', ELEV_M_NorthernColorado, ...
    'ELEV_M_NorthernColorado2', ELEV_M_NorthernColorado2, ...
    'ELEV_M_Logan', ELEV_M_Logan, ...
    'ELEV_M_PeetzTable', ELEV_M_PeetzTable, ...
    'ELEV_M_GrandMeadows', ELEV_M_GrandMeadows, ...
    'ELEV_M_SanJuanMesa', ELEV_M_SanJuanMesa, ...
    'ELEV_M_MinnDakota', ELEV_M_MinnDakota,  ...
    'ELEV_M_TwinButtes', ELEV_M_TwinButtes, ...
    'YEAR_START_CO', YEAR_START_CO, ...
    'YEAR_START_NEW', YEAR_START_NEW, ...
    'NUM_YEARS_DATA_CO', NUM_YEARS_DATA_CO, ...
    'NUM_YEARS_DATA_NEW', NUM_YEARS_DATA_NEW, ...
    'NUM_MONTHS_YEAR', NUM_MONTHS_YEAR, ...
    'NUM_HOURS_DAY', NUM_HOURS_DAY, ...
    'NUM_MIN_HOUR', NUM_MIN_HOUR, ...
    'NUM_SEC_DAY', NUM_SEC_DAY, ...
    'kW_to_MW', kW_to_MW, ...
    'DECIMAL2PCT', DECIMAL2PCT, ...
    'g_EARTH_AVG', g_EARTH_AVG, ...
    'DEGC2K_add', DEGC2K_add, ...
    'RHO_O_IEC_KG_M3', RHO_O_IEC_KG_M3, ...
    'RHO_KG_M3_NorthernColorado', RHO_KG_M3_NorthernColorado, ...
    'RHO_KG_M3_NorthernColorado2', RHO_KG_M3_NorthernColorado2, ...
    'RHO_KG_M3_Logan', RHO_KG_M3_Logan, ...
    'RHO_KG_M3_PeetzTable', RHO_KG_M3_PeetzTable, ...
    'RHO_KG_M3_GrandMeadows', RHO_KG_M3_GrandMeadows, ...
    'RHO_KG_M3_SanJuanMesa', RHO_KG_M3_SanJuanMesa, ...
    'RHO_KG_M3_MinnDakota', RHO_KG_M3_MinnDakota, ...
    'RHO_KG_M3_TwinButtes', RHO_KG_M3_TwinButtes ...
    );

% Then, inside each function that needs these constant values, execute this
% following command with a Matlab Imported Function (uncomment, of course):

% % Get the string of commands that will assign each value to its own name:
% CONST_REASSIGN_TEMP = structvars(CONST_STRUCT);
%
% % Store the number of rows (# of CONST) for the structure:
% num_CONST = size(CONST_REASSIGN_TEMP, 1);
%
% % Loop over each constant and reassign it with the eval() function:
% for i_CONST = 1 : num_CONST
%     eval(CONST_REASSIGN_TEMP(i_CONST,:));
% end


%% V. Set Important String Data
% Set all the farm names in a cell array of strings:

farm_data_file_start_str_name_CO    = ...
    { 'NorthernColorado', 'NorthernColorado2', 'Logan', 'PeetzTable' }; % This is a cell array (an array of strings)

% farm_data_file_start_str_name_NEW    = ...
%     { 'GrandMeadows', 'SanJuanMesa' }; % This is a cell array (an array of strings)

farm_data_file_start_str_name_NEW    = ...
    { 'MinnDakota', 'TwinButtes' }; % This is a cell array (an array of strings)

time_zone_ID_city_str_CO            = 'Denver' ;
time_zone_ID_city_str_NM            = 'Santa Fe' ;
time_zone_ID_city_str_MN            = 'Minneapolis' ;

%% VI. Read in the directory List of Available Files:

str_echo_start = [char(10), 'Reading ls list of available data files...', char(10) ];
disp(str_echo_start);

if flag_CO_dates
    
    [date_numbers_1, date_numbers_2, date_numbers_3, date_numbers_4,...
        date_string_double_1, date_string_double_2, date_string_double_3, date_string_double_4, ...
        year_double_1, month_double_1, day_double_1, ...
        year_double_2, month_double_2, day_double_2, ...
        year_double_3, month_double_3, day_double_3, ...
        year_double_4, month_double_4, day_double_4] ...
        = Read_Xcel_data_file_list( parent_files_dir, CONST_STRUCT );
    
end

if flag_NEW_dates
    
%     [date_numbers_5, date_numbers_6, ...
%         date_string_double_5, date_string_double_6, ...
%         year_double_5, month_double_5, day_double_5, ...
%         year_double_6, month_double_6, day_double_6] ...
%         = Read_Xcel_data_file_list( parent_files_dir, CONST_STRUCT );
    
        [date_numbers_7, date_numbers_8, ...
        date_string_double_7, date_string_double_8, ...
        year_double_7, month_double_7, day_double_7, ...
        year_double_8, month_double_8, day_double_8] ...
        = Read_Xcel_data_file_list( parent_files_dir, CONST_STRUCT );
    
end

%% VII. Find the ends of the missing data:

if flag_find_ends_missing_data
    
    if flag_CO_dates
        
        str_echo_missing_data = [ char(10), 'Finding the missing dates from the missing data files...', char(10) ];
        disp(str_echo_missing_data);
        
        [ store_begintimes_1, store_endtimes_1 , store_begintimes_2, store_endtimes_2 , ...
            store_begintimes_3, store_endtimes_3 , store_begintimes_4, store_endtimes_4, full_farm_date_num_arr_1 ] = ...
            find_missing_dates(date_numbers_1, date_numbers_2, date_numbers_3, date_numbers_4, parent_files_dir);
        
    end
    
    
    if flag_NEW_dates
        
        str_echo_missing_data = [ char(10), 'Finding the missing dates from the missing data files...', char(10) ];
        disp(str_echo_missing_data);
        
%         [ store_begintimes_5, store_endtimes_5 , store_begintimes_6, store_endtimes_6 , ...
%             full_farm_date_num_arr_5 ] = ...
%             find_missing_dates(date_numbers_5, date_numbers_6, parent_files_dir);
                
        [ store_begintimes_7, store_endtimes_7 , store_begintimes_8, store_endtimes_8 , ...
            full_farm_date_num_arr_7 ] = ...
            find_missing_dates(date_numbers_7, date_numbers_8, parent_files_dir);
        
    end
    
end

%% VIII. Create a Timeline Plot of Missing Data

if flag_timeline_plot_execute == 1
    
    str_echo_timeline = [ char(10), 'Producing timeline plot...' ];
    disp(str_echo_timeline);
    
    if flag_CO_dates
        
        produce_timeline_plot( store_begintimes_1, store_endtimes_1 , ...
            store_begintimes_2, store_endtimes_2 , ...
            store_begintimes_3, store_endtimes_3 , ...
            store_begintimes_4, store_endtimes_4 , ...
            full_farm_date_num_arr_1, parent_files_dir, ...
            CONST_STRUCT )
        
    end
    
    if flag_NEW_dates
        
%         produce_timeline_plot(...
%             store_begintimes_5, store_endtimes_5 , ...
%             store_begintimes_6, store_endtimes_6 , ...
%             full_farm_date_num_arr_5, parent_files_dir, ...
%             'GDM_and_SNJM', ...
%             CONST_STRUCT )
        
        produce_timeline_plot(...
            store_begintimes_7, store_endtimes_7 , ...
            store_begintimes_8, store_endtimes_8 , ...
            full_farm_date_num_arr_7, parent_files_dir, ...
            'MNDK_and_TWBT', ...
            CONST_STRUCT )
        
    end
    
end

%% IX. Read in the netCDF Files, while replacing missing all kinds of missing values

if flag_read_netCDF_completely == 1
    
    str_echo_read_rectangular_netCDF = [char(10), 'Read in all the netCDF Files and replacing missing days and turbines...', char(10)];
    disp(str_echo_read_rectangular_netCDF);
    
    if flag_CO_dates
    
    read_netCDF_Xcel_data_convert_to_mat_data_files_new( ...
        ptquelet_netCDF_files_local_dir, ptquelet_breeze_URL_dir, parent_files_dir, working_directory, ...
        date_string_double_1, year_double_1, month_double_1, day_double_1, ...
        date_string_double_2, year_double_2, month_double_2, day_double_2, ...
        date_string_double_3, year_double_3, month_double_3, day_double_3, ...
        date_string_double_4, year_double_4, month_double_4, day_double_4, ...
        CONST_STRUCT);
    
    end
    
    if flag_NEW_dates
       
%     read_netCDF_Xcel_data_convert_to_mat_data_files_new( ...
%         ptquelet_netCDF_files_local_dir, ptquelet_breeze_URL_dir, parent_files_dir, working_directory, ...
%         date_string_double_5, year_double_5, month_double_5, day_double_5, ...
%         date_string_double_6, year_double_6, month_double_6, day_double_6, ...
%         CONST_STRUCT);
    
    read_netCDF_Xcel_data_convert_to_mat_data_files_new( ...
        ptquelet_netCDF_files_local_dir, ptquelet_breeze_URL_dir, parent_files_dir, working_directory, ...
        date_string_double_7, year_double_7, month_double_7, day_double_7, ...
        date_string_double_8, year_double_8, month_double_8, day_double_8, ...
        CONST_STRUCT);
        
    end
    
end

%% X. Concatenate Files and Create Data Structure

if flag_concatenate_monthly_files == 1
    
    str_echo_read_concatenate_monthly_files = [char(10), 'Concatentate all the monthly .mat Files that are exactly rectangular and full...', char(10)];
    disp(str_echo_read_concatenate_monthly_files);
    
    % A) Put monthly files into whole dataset files:
    
    concatenate_monthly_files( parent_files_dir, working_directory, CONST_STRUCT );
    
end

% B) Create an equally spaced time vector of datenum() and datestr() from
% 2010 to 2013 (the whole dataset) with 5 minute resolution (should have 288 elements per single day):

if flag_create_time_vector == 1
    
    % flag_CO_1_NEW_2 = 1 ; % This indicates the Colorado dataset, YEAR_START = 2010
    
    flag_CO_1_NEW_2 = 2 ; % This indicates the Newer Datasets, YEAR_START_NEW = 2012
    
    [ multi_year_datenum ] = create_time_vector( CONST_STRUCT, flag_CO_1_NEW_2 );
    
end

% C) Create the structure array of the dataset:

if flag_create_struct_array == 1
    
    str_echo_create_struct_array = [ char(10), 'Setting up the wind_farm_data structure array...', char(10) ];
    disp(str_echo_create_struct_array);
    
    % Set each farm data as an empty array at first:
    
%     for i_farm = 1 : length(farm_data_file_start_str_name_CO)
%         eval( strcat( char( farm_data_file_start_str_name_CO( i_farm ) ) , '_data = [] ; ' ) )
%     end
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        eval( strcat( char( farm_data_file_start_str_name_NEW( i_farm ) ) , '_data = [] ; ' ) )
    end
    
    % Then setup the names of the fields for the structure array. Then fill in the blank arrays:
    
%     eval( strcat( 'wind_farm_data = struct(''' , char( farm_data_file_start_str_name_CO( 1 ) ), ''' , ' , char( farm_data_file_start_str_name_CO( 1 ) ) , '_data ) ; ' ) );
%     
%     for i_farm = 2 : length(farm_data_file_start_str_name_CO)
%         eval( strcat( 'wind_farm_data.(''' , char( farm_data_file_start_str_name_CO( i_farm ) ), ''') = ' , char( farm_data_file_start_str_name_CO( i_farm ) ) , '_data ; ' ) ) ;
%     end
    
    eval( strcat( 'wind_farm_data = struct(''' , char( farm_data_file_start_str_name_NEW( 1 ) ), ''' , ' , char( farm_data_file_start_str_name_NEW( 1 ) ) , '_data ) ; ' ) );
    
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        eval( strcat( 'wind_farm_data.(''' , char( farm_data_file_start_str_name_NEW( i_farm ) ), ''') = ' , char( farm_data_file_start_str_name_NEW( i_farm ) ) , '_data ; ' ) ) ;
    end
    
    % (NOTE: Pass in the transpose (') of multi_year_datenum to make it have many rows, not columns)
    
    wind_farm_data.('datenumber') = multi_year_datenum ;
    
    % Save the wind farm structure array, then clear the space off the workspace:
    
    save_file_mat_name_wind_farm_data = 'wind_farm_data_NEW_farms.mat' ;
    save( save_file_mat_name_wind_farm_data, 'wind_farm_data', '-v7.3' );
    movefile( save_file_mat_name_wind_farm_data, strcat( parent_files_dir , 'structure_data_assemble' ) );
    clear wind_farm_data ;
    
end

% D) Pass values into the structure array:

if flag_pass_lower_struct_values == 1
    
    str_echo_pass_struct_values = [ char(10), 'Filling in smaller structure arrays...', char(10) ];
    disp(str_echo_pass_struct_values);
    
    str_echo_clear_workspace_variables = [ char(10), 'Clearing workspace variables to make room...', char(10) ];
    disp(str_echo_clear_workspace_variables);
    
    % Delete several variables from the workspace:
    
    clearvars -regexp date_numbers_*
    clearvars -regexp date_string_*
    clearvars -regexp year_double_*
    clearvars -regexp month_double_*
    clearvars -regexp day_double_*
    
    % 1) Read in separate variables one at a time from the .mat files of data:
    % 2) Set each variables equal to the appropriate structure values:
    % 3) Save the small structure arrays, then clear the space off the workspace:
    % 4) Then clear that variable from the workspace:
    % (NOTE: Could make this more elegant, but must get this done for now...)
    
%     for i_farm = 1 : length(farm_data_file_start_str_name_CO)
%         
%         pass_lower_struct_values( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ) )
%         
%     end
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
    % for i_farm = 2 : length(farm_data_file_start_str_name_NEW) % Temporarily, just for TwinButtes

    for i_farm = 1 : 1 % Temporarily, just for MinnDakota

        pass_lower_struct_values( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ) )
        
    end
    
end

%% XI. Read in Met Tower Data

if flag_create_NEW_time_vector
    
    flag_CO_1_NEW_2 = 2 ; % This indicates the NEW dataset, YEAR_START = 2012
    
    [ multi_year_datenum ] = create_time_vector( CONST_STRUCT, flag_CO_1_NEW_2 );
    
end


if flag_import_met_tower_data
    
    str_echo_import_met_tower_data = [char(10), 'Import met tower data from .txt files...', char(10)];
    disp(str_echo_import_met_tower_data);
    
    % Set which farms are turned active for reading
    % (probably best to only do one farm at a time...):
    
    flag_GDM_on                 = 0 ;
    flag_SNJM_on                = 0 ;
    
    flag_MNDK_on                = 0 ;
    flag_TWBT_on                = 0 ;
    
    flag_AON09_on               = 1 ;
    
    % Setup which variables will be read in with flags:
    
    if flag_GDM_on
        
        flag_read_GDM_WS        = 1 ;
        flag_read_GDM_WDir      = 1 ;
        flag_read_GDM_temper    = 1 ;
        flag_read_GDM_press     = 1 ;
        flag_read_GDM_hum       = 0 ;  % Leave as zero!! (No humidity readings for GDM)
        flag_read_GDM_WSAvg     = 0 ;  % Leave as zero!! (No average wind speed readings for GDM)
        flag_read_GDM_WGust     = 0 ;  % Leave as zero!! (No wind gust readings for GDM)
        
        setup_met_tower_vars_import( parent_files_dir, met_tower_data_txt_files_dir, flag_read_GDM_WS, flag_read_GDM_WDir, flag_read_GDM_temper, flag_read_GDM_press, flag_read_GDM_hum, flag_read_GDM_WSAvg, flag_read_GDM_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT )
        
    end
    
    % Setup which variables will be read in with flags:
    
    if flag_SNJM_on
        
        flag_read_SNJM_WS       = 1 ;
        flag_read_SNJM_WDir     = 1 ;
        flag_read_SNJM_temper   = 1 ;
        flag_read_SNJM_press    = 1 ;
        flag_read_SNJM_hum      = 0 ;  % Leave as zero!! (No humidity readings for SNJM)
        flag_read_SNJM_WSAvg    = 0 ;  % Leave as zero!! (No average wind speed readings for SNJM)
        flag_read_SNJM_WGust    = 0 ;  % Leave as zero!! (No wind gust readings for SNJM)
        
        setup_met_tower_vars_import( parent_files_dir, met_tower_data_txt_files_dir, flag_read_SNJM_WS, flag_read_SNJM_WDir, flag_read_SNJM_temper, flag_read_SNJM_press, flag_read_SNJM_hum, flag_read_SNJM_WSAvg, flag_read_SNJM_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT )
        
    end
    
    % Setup which variables will be read in with flags:
    
    if flag_MNDK_on
        
        flag_read_MNDK_WS       = 1 ;
        flag_read_MNDK_WDir     = 0 ;
        flag_read_MNDK_temper   = 1 ;
        flag_read_MNDK_press    = 0 ;  % Leave as zero!! (No pressure readings for MNDK)
        flag_read_MNDK_hum      = 1 ;
        flag_read_MNDK_WSAvg    = 1 ;
        flag_read_MNDK_WGust    = 0 ;  % Leave as zero!! (No wind gust readings for MNDK)
        
        setup_met_tower_vars_import( parent_files_dir, met_tower_data_txt_files_dir, flag_read_MNDK_WS, flag_read_MNDK_WDir, flag_read_MNDK_temper, flag_read_MNDK_press, flag_read_MNDK_hum, flag_read_MNDK_WSAvg, flag_read_MNDK_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT )
        
    end
    
    
    % Setup which variables will be read in with flags:
    
    if flag_TWBT_on
        
        flag_read_TWBT_WS       = 0 ;
        flag_read_TWBT_WDir     = 0 ;
        flag_read_TWBT_temper   = 1 ;
        flag_read_TWBT_press    = 0 ; 
        flag_read_TWBT_hum      = 0 ;
        flag_read_TWBT_WSAvg    = 0 ; % Leave as zero!! (No average wind speed readings for TWBT)
        flag_read_TWBT_WGust    = 0 ;
        
        setup_met_tower_vars_import( parent_files_dir, met_tower_data_txt_files_dir, flag_read_TWBT_WS, flag_read_TWBT_WDir, flag_read_TWBT_temper, flag_read_TWBT_press, flag_read_TWBT_hum, flag_read_TWBT_WSAvg, flag_read_TWBT_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT )
        
    end
 
        % Setup which variables will be read in with flags:
    
    if flag_AON09_on
        
        flag_read_AON09_WS       = 1 ;
        flag_read_AON09_WDir     = 0 ;
        flag_read_AON09_temper   = 0 ;
        flag_read_AON09_press    = 0 ; 
        flag_read_AON09_hum      = 0 ; 
        flag_read_AON09_WSAvg    = 0 ; % Leave as zero!! (No average wind speed readings for AON09)
        flag_read_AON09_WGust    = 0 ; % Wind speed maximum 3 second wind gust within the last minute
        
        setup_met_tower_vars_import( parent_files_dir, met_tower_data_txt_files_dir, flag_read_AON09_WS, flag_read_AON09_WDir, flag_read_AON09_temper, flag_read_AON09_press, flag_read_AON09_hum, flag_read_AON09_WSAvg, flag_read_AON09_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT )
        
    end
    
end % end of if statement to read in met tower data

if flag_concatenate_monthly_met_tower_mat
    
    str_echo_assemble_monthly_met_tower_mat = [char(10), 'Concatenate and save met tower variables into .mat file...', char(10)];
    disp(str_echo_assemble_monthly_met_tower_mat);

    % Set which farms are turned active for reading
    % (probably best to only do one farm at a time...):
    
    flag_GDM_on                 = 0 ;
    flag_SNJM_on                = 0 ;
    flag_MNDK_on                = 1 ;
    flag_TWBT_on                = 0 ;    
    
    if flag_GDM_on
        
        flag_concat_GDM_WS      = 1 ;
        flag_concat_GDM_WDir    = 1 ;
        flag_concat_GDM_temper  = 1 ;
        flag_concat_GDM_press   = 1 ;
        flag_concat_GDM_hum     = 0 ; % Leave as zero!! (No humidity readings for GDM)
        flag_concat_GDM_WSAvg   = 0 ; % Leave as zero!! (No average wind speed readings for GDM)
        flag_concat_GDM_WGust   = 0 ; % Leave as zero!! (No wind gust readings for GDM)
        
        % Bring in a 10 minute datenumber for the length of the dataset:
        
%         flag_CO_1_NEW_2 = 2 ;
%         
%         multi_year_datenum = create_time_vector( CONST_STRUCT, flag_CO_1_NEW_2 ) ;
%         
%         multi_year_datevec = datevec( multi_year_datenum ) ; 
        
        concatenate_monthly_met_tower_files( parent_files_dir, working_directory, flag_concat_GDM_WS, flag_concat_GDM_WDir, flag_concat_GDM_temper, flag_concat_GDM_press, flag_concat_GDM_hum, flag_concat_GDM_WSAvg, flag_concat_GDM_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, CONST_STRUCT )
        
    end
    
    
    if flag_SNJM_on
        
        flag_concat_SNJM_WS     = 1 ;
        flag_concat_SNJM_WDir   = 1 ;
        flag_concat_SNJM_temper = 1 ;
        flag_concat_SNJM_press  = 1 ;
        flag_concat_SNJM_hum    = 0 ; % Leave as zero!! (No humidity readings for SNJM)
        flag_concat_SNJM_WSAvg  = 0 ; % Leave as zero!! (No average wind speed readings for SNJM)
        flag_concat_SNJM_WGust  = 0 ; % Leave as zero!! (No wind gust readings for SNJM)
        
        % Bring in a 10 minute datenumber for the length of the dataset:
        
%         flag_CO_1_NEW_2 = 2 ;
%         
%         multi_year_datenum = create_time_vector( CONST_STRUCT, flag_CO_1_NEW_2 ) ;
%         
%         multi_year_datevec = datevec( multi_year_datenum ) ; 
        
        concatenate_monthly_met_tower_files( parent_files_dir, working_directory, flag_concat_SNJM_WS, flag_concat_SNJM_WDir, flag_concat_SNJM_temper, flag_concat_SNJM_press, flag_concat_SNJM_hum, flag_concat_SNJM_WSAvg, flag_concat_SNJM_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, CONST_STRUCT )
        
    end
    
    
    if flag_MNDK_on
        
        flag_concat_MNDK_WS     = 0 ;
        flag_concat_MNDK_WDir   = 1 ;
        flag_concat_MNDK_temper = 0 ;
        flag_concat_MNDK_press  = 0 ; % Leave as zero!! (No pressure readings for MNDK)
        flag_concat_MNDK_hum    = 0 ; 
        flag_concat_MNDK_WSAvg  = 0 ;
        flag_concat_MNDK_WGust  = 0 ; % Leave as zero!! (No wind gust readings for MNDK)
        
        % Bring in a 10 minute datenumber for the length of the dataset:
        
%         flag_CO_1_NEW_2 = 2 ;
%         
%         multi_year_datenum = create_time_vector( CONST_STRUCT, flag_CO_1_NEW_2 ) ;
%         
%         multi_year_datevec = datevec( multi_year_datenum ) ; 
         
        concatenate_monthly_met_tower_files( parent_files_dir, working_directory, flag_concat_MNDK_WS, flag_concat_MNDK_WDir, flag_concat_MNDK_temper, flag_concat_MNDK_press, flag_concat_MNDK_hum, flag_concat_MNDK_WSAvg, flag_concat_MNDK_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, CONST_STRUCT )
        
    end
        
    if flag_TWBT_on
        
        flag_concat_TWBT_WS     = 1 ;
        flag_concat_TWBT_WDir   = 0 ;
        flag_concat_TWBT_temper = 0 ;
        flag_concat_TWBT_press  = 0 ; 
        flag_concat_TWBT_hum    = 0 ; 
        flag_concat_TWBT_WSAvg  = 0 ; % Leave as zero!! (No average wind speed readings for TWBT)
        flag_concat_TWBT_WGust  = 0 ; 
        
        concatenate_monthly_met_tower_files( parent_files_dir, working_directory, flag_concat_TWBT_WS, flag_concat_TWBT_WDir, flag_concat_TWBT_temper, flag_concat_TWBT_press, flag_concat_TWBT_hum, flag_concat_TWBT_WSAvg, flag_concat_TWBT_WGust, flag_GDM_on, flag_SNJM_on, flag_MNDK_on, flag_TWBT_on, CONST_STRUCT )
        
    end
    
    
end


if flag_filter_multi_level_tower_data
    
    flag_output_filter_numpts_text_file = 1 ; 
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        filter_multi_level_tower_data( parent_files_dir, met_tower_data_mat_files_dir , farm_data_file_start_str_name_NEW( i_farm ) , flag_output_filter_numpts_text_file )
        
    end
    
end

if flag_richardson_num_tower_calc
    
    flag_output_filter_numpts_text_file = 1 ; 
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        richardson_num_tower_calc( parent_files_dir, met_tower_data_mat_files_dir , farm_data_file_start_str_name_NEW( i_farm ) , flag_output_filter_numpts_text_file )
        
    end
    
end

if flag_met_tower_files_QC_time_axis
    
    flag_MNDK_on             = 0 ;
    flag_TWBT_on             = 0 ;
    flag_AON09_on            = 1 ;
    
    flag_read_AON09_WS       = 1 ;
    flag_read_AON09_WDir     = 0 ;
    flag_read_AON09_temper   = 0 ;
    flag_read_AON09_press    = 0 ;
    flag_read_AON09_hum      = 0 ;
    flag_read_AON09_WSAvg    = 0 ; % Leave as zero!! (No average wind speed readings for AON09)
    flag_read_AON09_WGust    = 0 ; % Wind speed maximum 3 second wind gust within the last minute
    
    met_tower_files_QC_time_axis( parent_files_dir, working_directory, flag_read_AON09_WS, flag_read_AON09_WDir, flag_read_AON09_temper, flag_read_AON09_press, flag_read_AON09_hum, flag_read_AON09_WSAvg, flag_read_AON09_WGust, flag_MNDK_on, flag_TWBT_on, flag_AON09_on, CONST_STRUCT  )

end


%% XII. Plot Data

str_echo_made_it_to_plotting = [ char(10), 'Made it to the plotting routines...', char(10) ];
disp(str_echo_made_it_to_plotting);

% A. Monthly Line Plots (for all 4 farms, and individually

if flag_monthly_line_plots_individual_farms == 1
    
    % Read in the date vector, use it to calculate things:
    
    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)

    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
    
    % for i_farm = 2 : 2 % note for JKL!! Setup Unidentified and Normalizing
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_NEW)

    for i_farm = 1 : 1

        flag_landscape = 0 ;
        
        % monthly_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )

        monthly_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

% B. Diurnal Line Plots

if flag_diurnal_line_plots == 1
    
    % Read in the date vector, use it to calculate things:
    
    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
    
    % for i_farm = 2 : 2 % note for JKL!! Setup Unidentified and Normalizing
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_NEW)

    for i_farm = 1 : 1
        
        flag_landscape = 0 ;
        
        % diurnal_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_datenumber, flag_landscape, out_plot_dir, CONST_STRUCT )

        diurnal_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_datenumber, flag_landscape, out_plot_dir, CONST_STRUCT )

    end
    
end

% C. Weibull Plots

if flag_Weibull_Distribution == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape = 0 ;
        
        Weibull_Distribution( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_datevector, flag_landscape, out_plot_dir )
        
    end
    
end


% D.1. Plot an averged power curve for each wind farm:

if flag_create_power_curve == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    % wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)

        flag_landscape = 0 ;
        
        create_power_curve( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


% D.2. Plot day/night averaged power curves for each wind farm:

if flag_power_curves_day_night == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    % wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
     
        flag_landscape = 0 ;
        
        power_curves_day_night( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

% D.3. Plot day/night averaged power curves for each wind farm:

if flag_power_curves_anomaly_day_night == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    % wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        
        flag_landscape = 0 ;
        
        power_curves_anomaly_day_night( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

% D.4. Plot day/night averaged power curves for each wind farm:

if flag_power_curve_anom_season_day_night == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    % wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        
        flag_landscape = 0 ;
        
        power_curve_anom_season_day_night( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

% D.5. Plot Richardson number stability-based power curves for each wind farm:

if flag_power_curves_Ri == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    % wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    % wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    % wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO) 
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW) % TwinButtes for now
    
    % for i_farm = 1 : 1 % MinnDakota for now
        
        flag_landscape = 0 ;
                
        % power_curves_Ri( parent_files_dir , met_tower_data_tower_rich_num , farm_data_file_start_str_name_NEW( i_farm ) , wind_farm_stand_time_datenumber , flag_landscape , out_plot_dir , CONST_STRUCT )
        
        power_curves_Ri( parent_files_dir , met_tower_data_tower_QC_downsamp , farm_data_file_start_str_name_NEW( i_farm ) , wind_farm_stand_time_datenumber , flag_landscape , out_plot_dir , CONST_STRUCT )

    end
    
end

% D.6. Plot seperate seasons of Ri stability-based power curves:

if flag_power_curves_Ri_seasonal == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO) % Just doing things for TwinButtes right now
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        
        flag_landscape = 0 ;
                        
        power_curves_Ri_seasonal( parent_files_dir , met_tower_data_tower_QC_downsamp , farm_data_file_start_str_name_NEW( i_farm ) , wind_farm_stand_time_datenumber , flag_landscape , out_plot_dir , CONST_STRUCT )

    end
    
end


% D.7. Plot scatter plots of Ri stability-based power curves:

if flag_power_curves_Ri_scatter == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;

    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber ;
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO) % Just doing things for TwinButtes right now
        
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        
        flag_landscape = 0 ;
                        
        power_curves_Ri_scatter( parent_files_dir , met_tower_data_tower_QC_downsamp , farm_data_file_start_str_name_NEW( i_farm ) , wind_farm_stand_time_datenumber , flag_landscape , out_plot_dir , CONST_STRUCT )

    end
    
end




% E. Plot Scatter Plots of Farms vs. One Another

if flag_scatter_plots_farms == 1
    scatter_plots_farms()
end

% F. Box Plots of Distributions

if flag_farm_box_plots == 1
    
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape = 0 ;
        
        farm_box_plots( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


% G. Seasonal Diurnal Line Plots

if flag_seasonal_diurnal_line_plots == 1
    
    % Read in the date vector, use it to calculate things:
    
    % file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data_NEW_farms.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    
    % Convert to local time:
    t = timeZones() ;
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
        
    % for i_farm = 1 : length(farm_data_file_start_str_name_CO)
    
    for i_farm = 2 : length(farm_data_file_start_str_name_NEW)
        
        flag_landscape = 0 ;
        
        % seasonal_diurnal_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )

        seasonal_diurnal_line_plots_individual_farms( parent_files_dir, farm_data_file_start_str_name_NEW( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


% H.1. Year Diurnal Plots for Verification of Stable Wind Climate

if flag_yearly_verf_diurnal_line_plots == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape = 0 ;
        
        yearly_verf_diurnal_line_plots( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

% H.2. Year Diurnal Plots for Verification of Stable Wind Climate

if flag_yearly_together_diurnal_line_plots == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ;
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape = 0 ;
        
        yearly_together_diurnal_line_plots( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

%% XII. Plot Meteorological Tower Data 


% A. Histogram of time differences:

if flag_tower_time_diffs_histogram
    
    farm_data_file_start_str_name = 'TwinButtes' ; 
    
    tower_time_diffs_histogram( farm_data_file_start_str_name, out_plot_dir, CONST_STRUCT )
    
end

% B. Plot Wind Roses for Met Towers:

if flag_plot_wind_roses_towers
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
                
        WS_intens_inc   =  2 ; % Increments of intensity
        
        WS_intens_max   = 24 ; % Maximum wind speed shown
        
        num_sectors     = 40 ; % Number of sectors direction is calculated from
        
        plot_wind_rose( met_tower_data_same_TS_and_NaNs , farm_data_file_start_str_name_NEW(i_farm) , WS_intens_inc, WS_intens_max, num_sectors,  out_plot_dir  )
        
    end
        
end

% C. Towers Monthly Line Plots:

if flag_monthly_line_plots_towers
    
    flag_landscape = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
                
        monthly_line_plots_towers( met_tower_data_same_TS_and_NaNs, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

% D. Towers Diurnal Line Plots

if flag_diurnal_line_plots_towers
        
    flag_landscape = 0 ; 
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
 
        diurnal_line_plots_towers( met_tower_data_same_TS_and_NaNs, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

% E. Towers Weibull Plots

if flag_Weibull_Distribution_towers

    flag_landscape = 0 ;
    
    for i_farm = 2 : 2

    % for i_farm = 1 : length(farm_data_file_start_str_name_NEW)

        Weibull_Distribution_towers( met_tower_data_same_TS_and_NaNs, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
   
end

if flag_tower_temperature_compare_timeseries
    
    flag_landscape = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        tower_temperature_compare_timeseries( met_tower_data_mat_files_dir, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end


if flag_tower_temperature_compare_histo
    
    flag_landscape = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        tower_temperature_compare_histo( met_tower_data_mat_files_dir, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end

end


if flag_diurnal_numpts_vars_Ri_towers
    
    flag_landscape = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        diurnal_numpts_vars_Ri_towers( met_tower_numpts_vars_Ri_tower_dir, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

%% XIII. Perform Wavelet Analysis

if flag_wavelet_analysis == 1
    
    %     for i_farm = 1 : length(farm_data_file_start_str_name_CO)
    for i_farm = 2 : 2
        
        flag_landscape = 0 ;
        
        wavelet_analysis( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


%% XIV. Perform Additional Wavelet Analysis

if flag_wavelet_additional_analysis == 1
    
    %     for i_farm = 1 : length(farm_data_file_start_str_name_CO)
    for i_farm = 2 : 2
        
        flag_landscape      = 0 ;
        
        flag_WS_wavelet     = 1 ;
        
        flag_Power_wavelet  = 0 ;
        
        flag_separate_plots = 0 ;
        
        wavelet_additional_analysis( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), flag_landscape, out_plot_dir, flag_WS_wavelet, flag_Power_wavelet, flag_separate_plots, CONST_STRUCT )
        
    end
        
end


%% XVI. Perform Atmospheric Stability Analysis


if flag_calc_pseudo_ti == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ; % Transpose
    wind_farm_datevector                    = datevec(wind_farm_datenumber) ; % Y,M,D,H,M,S (each column, stored as a matrix with 6 columns)
          
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
  
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape      = 0 ;
        
        calc_pseudo_ti( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


if flag_calc_pseudo_ti_at_turbs == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ; % Transpose
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape      = 0 ;
        
        calc_pseudo_ti_at_turbs( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end


if flag_calc_pseudo_ti_seasonal_diurnal == 1
    
    % Read in the date vector, use it to calculate things:
    
    file_dir_and_name_cat                   = strcat( parent_files_dir , 'structure_data_assemble\wind_farm_data.mat' ) ;
    curr_mat_file                           = matfile(file_dir_and_name_cat) ;
    wind_farm_data                          = curr_mat_file.wind_farm_data ;
    wind_farm_datenumber                    = wind_farm_data.datenumber' ; % Transpose
    
    % Convert to local time:
    t = timeZones();
    wind_farm_stand_time_datenumber         = t.utc2st(wind_farm_datenumber, time_zone_ID_city_str_CO) ;
    
    % Get the datevector:
    wind_farm_stand_time_datevector         = datevec(wind_farm_stand_time_datenumber) ; % Y,M,D,H,M,S (each column, as a vector)
    
    for i_farm = 1 : length(farm_data_file_start_str_name_CO)
        
        flag_landscape      = 0 ;
        
        calc_pseudo_ti_at_turbs_seasonal_diurnal( parent_files_dir, farm_data_file_start_str_name_CO( i_farm ), wind_farm_stand_time_datevector, flag_landscape, out_plot_dir, CONST_STRUCT )
        
    end
    
end

if flag_calculate_Ri_time_series
            
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_Ri_time_series( met_tower_data_tower_rich_num, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

if flag_calculate_Ri_diurnal_signal
    
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_Ri_diurnal_signal( met_tower_data_tower_rich_num, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

if flag_calculate_Ri_seasonal_diurnal_signal
    
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_Ri_seasonal_diurnal_signal( met_tower_data_tower_rich_num, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

if flag_calculate_T_seasonal_diurnal_signal
    
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_T_seasonal_diurnal_signal( met_tower_data_tower_rich_num, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end

if flag_calculate_Ri_histogram
    
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_Ri_histogram( met_tower_data_tower_QC_downsamp, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end


if flag_calculate_Ri_day_night_histogram
    
    flag_landscape      = 0 ;
    
    for i_farm = 1 : length(farm_data_file_start_str_name_NEW)
        
        calculate_Ri_day_night_histogram( met_tower_data_tower_QC_downsamp, out_plot_dir, flag_landscape, farm_data_file_start_str_name_NEW(i_farm), CONST_STRUCT )
        
    end
    
end


%% XVII. End of the Main Driver Code

