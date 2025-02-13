/*
 * Copyright (c) The acados authors.
 *
 * This file is part of acados.
 *
 * The 2-Clause BSD License
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.;
 */

#define S_FUNCTION_NAME acados_solver_sfunction_model
#define S_FUNCTION_LEVEL 2

#define MDL_START

// acados
// #include "acados/utils/print.h"
#include "acados_c/sim_interface.h"
#include "acados_c/external_function_interface.h"

// example specific
#include "acados_solver_model.h"



#include "simstruc.h"

#define SAMPLINGTIME 0.0005


  
  
  
  
  
  
  
  
  
  
  
  



static void mdlInitializeSizes (SimStruct *S)
{
    // specify the number of continuous and discrete states
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    int N = 2;// specify the number of input ports
    if ( !ssSetNumInputPorts(S, 9) )
        return;

    // specify the number of output ports
    if ( !ssSetNumOutputPorts(S, 13) )
        return;

    // specify dimension information for the input ports
    // lbx_0
    ssSetInputPortVectorDimension(S, 0, 4);
    // ubx_0
    ssSetInputPortVectorDimension(S, 1, 4);
    // y_ref_0
    ssSetInputPortVectorDimension(S, 2, 6);


    // y_ref
    ssSetInputPortVectorDimension(S, 3, 6);
    // y_ref_e
    ssSetInputPortVectorDimension(S, 4, 4);


    // lbx
    ssSetInputPortVectorDimension(S, 5, 1);
    // ubx
    ssSetInputPortVectorDimension(S, 6, 1);
    // lbu
    ssSetInputPortVectorDimension(S, 7, 2);
    // ubu
    ssSetInputPortVectorDimension(S, 8, 2);/* specify dimension information for the OUTPUT ports */
    ssSetOutputPortVectorDimension(S, 0, 2 );
    ssSetOutputPortVectorDimension(S, 1, 4 );
    ssSetOutputPortVectorDimension(S, 2, 12 );
    ssSetOutputPortVectorDimension(S, 3, 1 );
    ssSetOutputPortVectorDimension(S, 4, 1 );
    ssSetOutputPortVectorDimension(S, 5, 1 );
    ssSetOutputPortVectorDimension(S, 6, 4 );
    ssSetOutputPortVectorDimension(S, 7, 4 ); // state at shooting node 1
    ssSetOutputPortVectorDimension(S, 8, 1);
    ssSetOutputPortVectorDimension(S, 9, 1);
    ssSetOutputPortVectorDimension(S, 10, 1);
    ssSetOutputPortVectorDimension(S, 11, 1);
    ssSetOutputPortVectorDimension(S, 12, 1 );// specify the direct feedthrough status
    // should be set to 1 for all inputs used in mdlOutputs
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 6, 1);
    ssSetInputPortDirectFeedThrough(S, 7, 1);
    ssSetInputPortDirectFeedThrough(S, 8, 1);

    // one sample time
    ssSetNumSampleTimes(S, 1);
}


#if defined(MATLAB_MEX_FILE)

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO

static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port, const DimsInfo_T *dimsInfo)
{
    if ( !ssSetInputPortDimensionInfo(S, port, dimsInfo) )
         return;
}

static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port, const DimsInfo_T *dimsInfo)
{
    if ( !ssSetOutputPortDimensionInfo(S, port, dimsInfo) )
         return;
}

#endif /* MATLAB_MEX_FILE */


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLINGTIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlStart(SimStruct *S)
{
    model_solver_capsule *capsule = model_acados_create_capsule();
    model_acados_create(capsule);

    ssSetUserData(S, (void*)capsule);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    model_solver_capsule *capsule = ssGetUserData(S);
    ocp_nlp_config *nlp_config = model_acados_get_nlp_config(capsule);
    ocp_nlp_dims *nlp_dims = model_acados_get_nlp_dims(capsule);
    ocp_nlp_in *nlp_in = model_acados_get_nlp_in(capsule);
    ocp_nlp_out *nlp_out = model_acados_get_nlp_out(capsule);
    ocp_nlp_solver *nlp_solver = model_acados_get_nlp_solver(capsule);

    InputRealPtrsType in_sign;

    int N = 2;  

    

    // local buffer
    double buffer[6];
    double tmp_double;
    int tmp_offset, tmp_int;
    
    

    /* go through inputs */
    // lbx_0
    in_sign = ssGetInputPortRealSignalPtrs(S, 0);
    for (int i = 0; i < 4; i++)
        buffer[i] = (double)(*in_sign[i]);

    ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, 0, "lbx", buffer);
    // ubx_0
    in_sign = ssGetInputPortRealSignalPtrs(S, 1);
    for (int i = 0; i < 4; i++)
        buffer[i] = (double)(*in_sign[i]);
    ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, 0, "ubx", buffer);

  
    // y_ref_0
    in_sign = ssGetInputPortRealSignalPtrs(S, 2);

    for (int i = 0; i < 6; i++)
        buffer[i] = (double)(*in_sign[i]);

    ocp_nlp_cost_model_set(nlp_config, nlp_dims, nlp_in, 0, "yref", (void *) buffer);


  
    // y_ref - for stages 1 to N-1
    in_sign = ssGetInputPortRealSignalPtrs(S, 3);

    for (int stage = 1; stage < N; stage++)
    {
        for (int jj = 0; jj < 6; jj++)
            buffer[jj] = (double)(*in_sign[(stage-1)*6+jj]);
        ocp_nlp_cost_model_set(nlp_config, nlp_dims, nlp_in, stage, "yref", (void *) buffer);
    }

  
    // y_ref_e
    in_sign = ssGetInputPortRealSignalPtrs(S, 4);

    for (int i = 0; i < 4; i++)
        buffer[i] = (double)(*in_sign[i]);

    ocp_nlp_cost_model_set(nlp_config, nlp_dims, nlp_in, N, "yref", (void *) buffer);


    // lbx
    in_sign = ssGetInputPortRealSignalPtrs(S, 5);
    for (int stage = 1; stage < N; stage++)
    {
        for (int jj = 0; jj < 1; jj++)
            buffer[jj] = (double)(*in_sign[(stage-1)*1+jj]);
        ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, stage, "lbx", (void *) buffer);
    }
    // ubx
    in_sign = ssGetInputPortRealSignalPtrs(S, 6);
    for (int stage = 1; stage < N; stage++)
    {
        for (int jj = 0; jj < 1; jj++)
            buffer[jj] = (double)(*in_sign[(stage-1)*1+jj]);
        ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, stage, "ubx", (void *) buffer);
    }
    // lbu
    in_sign = ssGetInputPortRealSignalPtrs(S, 7);
    tmp_offset = 0;
    for (int stage = 0; stage < N; stage++)
    {
        tmp_int = ocp_nlp_dims_get_from_attr(nlp_config, nlp_dims, nlp_out, stage, "lbu");
        for (int jj = 0; jj < tmp_int; jj++)
            buffer[jj] = (double)(*in_sign[tmp_offset+jj]);
        ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, stage, "lbu", (void *) buffer);
        tmp_offset += tmp_int;
    }
    // ubu
    in_sign = ssGetInputPortRealSignalPtrs(S, 8);
    tmp_offset = 0;
    for (int stage = 0; stage < N; stage++)
    {
        tmp_int = ocp_nlp_dims_get_from_attr(nlp_config, nlp_dims, nlp_out, stage, "ubu");
        for (int jj = 0; jj < tmp_int; jj++)
            buffer[jj] = (double)(*in_sign[tmp_offset+jj]);
        ocp_nlp_constraints_model_set(nlp_config, nlp_dims, nlp_in, stage, "ubu", (void *) buffer);
        tmp_offset += tmp_int;
    }

    int ignore_inits = 0;
    // ssPrintf("ignore_inits = %d\n", ignore_inits);

    if (ignore_inits == 0)
    {
    }/* call solver */
    int acados_status = model_acados_solve(capsule);
    // get time
    ocp_nlp_get(nlp_solver, "time_tot", (void *) buffer);
    tmp_double = buffer[0];

    /* set outputs */
    double *out_ptr;
    out_ptr = ssGetOutputPortRealSignal(S, 0);
    ocp_nlp_out_get(nlp_config, nlp_dims, nlp_out, 0, "u", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 1);
    ocp_nlp_get_all(nlp_solver, nlp_in, nlp_out, "u", out_ptr);

  
    out_ptr = ssGetOutputPortRealSignal(S, 2);
    ocp_nlp_get_all(nlp_solver, nlp_in, nlp_out, "x", out_ptr);

  

  

  
    out_ptr = ssGetOutputPortRealSignal(S, 3);
    *out_ptr = (double) acados_status;
    out_ptr = ssGetOutputPortRealSignal(S, 4);
    ocp_nlp_eval_cost(nlp_solver, nlp_in, nlp_out);
    ocp_nlp_get(nlp_solver, "cost_value", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 5);
    *out_ptr = (double) nlp_out->inf_norm_res;
    out_ptr = ssGetOutputPortRealSignal(S, 6);
    ocp_nlp_get(nlp_solver, "res_stat", (void *) &out_ptr[0]);
    ocp_nlp_get(nlp_solver, "res_eq", (void *) &out_ptr[1]);
    ocp_nlp_get(nlp_solver, "res_ineq", (void *) &out_ptr[2]);
    ocp_nlp_get(nlp_solver, "res_comp", (void *) &out_ptr[3]);
    out_ptr = ssGetOutputPortRealSignal(S, 7);
    ocp_nlp_out_get(nlp_config, nlp_dims, nlp_out, 1, "x", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 8);
    out_ptr[0] = tmp_double;
    out_ptr = ssGetOutputPortRealSignal(S, 9);
    ocp_nlp_get(nlp_solver, "time_sim", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 10);
    ocp_nlp_get(nlp_solver, "time_qp", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 11);
    ocp_nlp_get(nlp_solver, "time_lin", (void *) out_ptr);
    out_ptr = ssGetOutputPortRealSignal(S, 12);
    // get sqp iter
    ocp_nlp_get(nlp_solver, "sqp_iter", (void *) &tmp_int);
    *out_ptr = (double) tmp_int;

  

}

static void mdlTerminate(SimStruct *S)
{
    model_solver_capsule *capsule = ssGetUserData(S);

    model_acados_free(capsule);
    model_acados_free_capsule(capsule);
}


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
