#include "mex.h"
#include "mat.h"

/* This function removes a variable from a MAT file
 * Compile it with
 * >>mex RemoveVariableFromMatFile.c
 * Afterwards call it with
 * >> RemoveVariableFromMatFile(FILENAME_WITH_EXTENSION,VARIABLE_TO_DELTE)
 * e.g.
 * >> RemoveVariableFromMatFile('MyFile.mat','MyVariable')
 */ 

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    MATFile *f;
    char *filename;
    char *vname;
    int tmp;
    
    if (nrhs != 2)
    {
        mexErrMsgIdAndTxt("RemoveVariableFromMatFile:NumberInputArguments","This function expects exactly two inputs.");
    }
    
    if (!mxIsChar(prhs[0]) || !mxIsChar(prhs[0]))
    {
        mexErrMsgIdAndTxt("RemoveVariableFromMatFile:ClassInputArguments","This function expects the inputs to be char."); 
    }
    
    filename = mxArrayToString(prhs[0]);
    f =  matOpen(filename,"u");
    
    if (f == NULL)
    {
        mxFree(filename);
        mexErrMsgIdAndTxt("RemoveVariableFromMatFile:UnableToOpenFile","Could not open file. Make sure the file exists and is accessible.");  
    }
    
    vname = mxArrayToString(prhs[1]);
    tmp = matDeleteVariable(f,vname);
    
    mxFree(vname);
    mxFree(filename);
    matClose(f);
    if ( tmp != 0)
    {
        mexErrMsgIdAndTxt("RemoveVariableFromMatFile:UnableToDeleteVariable","Could not delete variable. Make sure that the variable exists.");     
    }
}

