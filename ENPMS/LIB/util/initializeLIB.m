%---------------------------------------------------------------------
% function INI = initializeLIB(INI)
%---------------------------------------------------------------------
function INI = initializeLIB(INI)

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

try 
    % needed for 2019 version
    dmi = NET.addAssembly('DHI.Mike.Install');
    if (~isempty(dmi))
        DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
    end
    %NET.addAssembly('C:\Users\georg\Desktop\01M06CAL\ENP_TOOLS\ENPMS\LIB\DHI\mbin\DHI.Mike.Install.dll');
catch ex
    %ex.ExceptionObject.LoaderExceptions.Get(0).Message
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');

end
