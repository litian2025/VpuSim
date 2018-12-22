#include "VpuShaderLib.h"

#include <stdio.h>
#include <assert.h>

extern __declspec(dllexport) VpuThreadLocalStorage g_tls;

VpuThreadLocalStorage g_tls;

dx_types_Handle dx_op_createHandle(
    int32_t opcode,
    int8_t resource_class,
    int32_t range_id,
    int32_t index,
    int8_t non_uniform)
{
    assert((int32_t)resource_class == kVpuResourceClassUAV);
    assert(index >= 0 && index < kVpuMaxUAVs);
    dx_types_Handle handle = &g_tls.m_uavs[index];

    return handle;
}

dx_types_ResRet_f32 dx_op_bufferLoad_f32(
    int32_t opcode,
    dx_types_Handle handle,
    int32_t index,
    int32_t offset)
{
    dx_types_ResRet_f32 ret = { 0.0f, 0.0f, 0.0f, 0.0f, 0 };
    ret.v0 = *((float *)(handle->m_base + (index * handle->m_elementSize) + offset));

    return ret;
}

dx_types_ResRet_i32 dx_op_bufferLoad_i32(
    int32_t opcode,
    dx_types_Handle handle,
    int32_t index,
    int32_t offset)
{
    dx_types_ResRet_i32 ret = { 0, 0, 0, 0, 0 };
    ret.v0 = *((int32_t *)(handle->m_base + (index * handle->m_elementSize) + offset));

    return ret;
}

void dx_op_bufferStore_f32(
    int32_t opcode,
    dx_types_Handle handle,
    int32_t index,
    int32_t offset,
    float v0,
    float v1,
    float v2,
    float v3,
    int8_t mask)
{
    assert(mask == 1);

    *((float *)(handle->m_base + (index * handle->m_elementSize) + offset)) = v0;
}

void dx_op_bufferStore_i32(
    int32_t opcode,
    dx_types_Handle handle,
    int32_t index,
    int32_t offset,
    int32_t v0,
    int32_t v1,
    int32_t v2,
    int32_t v3,
    int32_t mask)
{
    assert(mask == 1);

    *((int32_t *)(handle->m_base + (index * handle->m_elementSize) + offset)) = v0;
}

int32_t dx_op_threadId_i32(
    int32_t opcode,
    int32_t do_not_know)
{
    return g_tls.m_id;
}