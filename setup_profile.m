function INI = setup_profile ( INI, PROFILE_NAME )

%LOCATION OF SCRIPTS FOR ANALYSIS - currently this is the 'ENPMS' directory (end with '\'):
% This is the equivalent of the 'Results' directory (end with '\'):

if (strcmp(PROFILE_NAME,'test') == 1)
   INI.MODELS_HOME    = 'my_models_home_path';
   INI.MATLAB_SCRIPTS = '.\ENPMS\';
   INI.ResultDirHome  = ['..\EXAMPLE_DATA\MODELED_DATA\Result\'];
   
elseif (strcmp(PROFILE_NAME,'kiren') == 1)
   INI.MODELS_HOME    = 'C:\Users\kbahm\Desktop\Models\';
   INI.MATLAB_SCRIPTS = 'C:\Users\kbahm\Desktop\Models\ENPMS\';
   INI.ResultDirHome  = [INI.MODELS_HOME 'Result\'];
   
elseif (strcmp(PROFILE_NAME,'inpeverhydrokc') == 1)
   INI.MODELS_HOME    = 'E:\home\Models\';
   INI.MATLAB_SCRIPTS = 'E:\home\Tools\ENP_TOOLS\ENPMS\';
   INI.ResultDirHome  = [INI.MODELS_HOME 'Result\'];
   
else
   fprintf(' --> ...WARNING: setup_profile did not set directories\n');
   
end

end

%LOCATION OF SCRIPTS FOR ANALYSIS - currently this is the 'ENPMS' directory (end with '\'):
% INI.MATLAB_SCRIPTS = 'C:\Users\georgio\Desktop\MATLAB_SCRIPTS_03262016\ENPMS\';
% INI.MATLAB_SCRIPTS = 'E:\ENP_10222017\ENPMS\';
% INI.MATLAB_SCRIPTS = '\\MAJORLAZER\Users\georgio\Desktop\MATLAB_SCRIPTS_03262016\ENPMS\';
% INI.MATLAB_SCRIPTS = '..\ENPMS\';

% Location of 'Models' directory (end with '\'):


% This is the equivalent of the 'Results' directory (end with '\'):
% INI.ResultDirHome = ['C:\Users\georgio\Desktop\MODEL_RESULTS_FOR_TESTING\'];
% INI.ResultDirHome = ['C:\home\MODELS\MATLAB\MODEL_RESULTS_FOR_TESTING\'];
% INI.ResultDirHome = ['\\MAJORLAZER\Users\georgio\Desktop\MODEL_RESULTS_FOR_TESTING\'];
% INI.ResultDirHome = ['C:\home\MODELS\Result\'];

