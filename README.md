# ENP_TOOLS
Scripts used to pre- and post-process data

This repo contains the scripts we use to do preprocessing and postprocessing of model input and output. It is mostly MATLAB scripts.

The scripts the user runs are in the top-level folders. The user is expected to edit these scripts depending on which files or runs they would like to process.

Most of the functions used by the top-level scripts are buried deep in ENP_TOOLS/ENPMS/LIB/util/. This is the heart of the ENP_TOOLS library.

Sample input and output files are in the parent directory ENP_FILES. The top-level scripts should run in their current state if the user has the directory ENP_FILES/ENP_TOOLS_Sample_Input, and produce output similar to those in the directories ENP_FILES/ENP_TOOLS_Sample_Output and ENP_FILES/ENP_TOOLS_Sample_Output_Sequential.
Ask Kiren for a copy of the ENP_FILES directory.

The ENP_MODELS, ENP_TOOLS, and ENP_FILES directories should all work together if they are in the same parent folder, at the same level.

Rik was here!
