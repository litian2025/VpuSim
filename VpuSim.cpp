#include "Vpu.h"
#include "VpuShaderBinary.h"
#include "VpuCompiler.h"
#include "VpuLinker.h"
#include "VpuObject.h"
#include "VpuImage.h"

#include <assert.h>
#include <malloc.h>
#include <stdio.h>
#include <memory.h>
#include <sstream>

#include <Windows.h>

extern "C" __declspec(dllimport) void shader_main();
extern "C" __declspec(dllimport) VpuThreadLocalStorage g_tls;

class VpuAddress
{
public:

    VpuAddress() : m_segment(kVpuSegmentUndefined), m_offset(0) {}
    VpuAddress(VpuSegment segment, size_t offset) : m_segment(segment), m_offset(offset) {}
    ~VpuAddress() {}

    VpuSegment GetSegment() { return m_segment; }
    size_t GetOffset() { return m_offset;  }

private:

    VpuSegment m_segment;
    size_t m_offset; // byte offset

};

class VpuStore
{
public:

    VpuStore(VpuSegment segment)
    {
        m_segment = segment;
        m_base = NULL;
        m_size = 0;
    }

    ~VpuStore()
    {
        assert(m_base == NULL);
        assert(m_size == 0);
    }

    void Load(size_t size)
    {
        m_base = (int8_t *)malloc(size);
        assert(m_base != NULL);
        m_size = size;
    }

    void Unload()
    {
        free(m_base);
        m_base = NULL;
        m_size = 0;
    }

    void Write(VpuAddress dst, void * buf, size_t count)
    {
        assert(dst.GetSegment() == m_segment);
        assert(dst.GetOffset() + count <= m_size);
        memcpy(m_base + dst.GetOffset(), buf, count);
    }

    void Read(VpuAddress dst, void * buf, size_t count)
    {
        assert(dst.GetOffset() + count <= m_size);
        memcpy(buf, m_base + dst.GetOffset(), count);
    }

    size_t GetSize() { return m_size; }
    int8_t * GetBase() { return m_base; }

private:

    VpuSegment m_segment;
    int8_t * m_base;
    size_t m_size;

};


class VpuBuffer
{
public:

    VpuBuffer() : m_elementSize(0) {}
    VpuBuffer(VpuAddress base, int32_t elementSize) : m_base(base) {}
	
	VpuAddress GetBase() { return m_base; }
	int32_t GetElementSize() { return m_elementSize; }
	
public:

    VpuAddress m_base;
	int32_t m_elementSize;
	
};

class VpuUav : public VpuBuffer
{
public:

    VpuUav() {}
    VpuUav(VpuAddress base, int32_t elementSize) : VpuBuffer(base, elementSize) {}
	
};

class VpuShader
{
public:

    VpuShader() {}

    VpuShader(VpuAddress code)
    {
        m_code = code;
    }

    ~VpuShader() {}

private:

    VpuAddress m_code;

};

class VpuResource
{
public:

    VpuResource() : m_base(NULL), m_elementSize(0) {}
    VpuResource(int8_t * base, int32_t elementSize) : m_base(base), m_elementSize(elementSize) {}

    int8_t * GetBase() { return m_base;  }
    int32_t GetElementSize() { return m_elementSize; }

private:

    int8_t * m_base;
    int32_t m_elementSize;
};

class VpuContext
{
public:

    VpuContext() {}
    ~VpuContext() {}

    void Load(VpuStore * globalStore)
    {
        m_globalStore = globalStore;
    }

    void Unload()
    {
        m_globalStore = NULL;
    }

    void SetShader(VpuAddress code)
    {
        m_shader = VpuShader(code);
    }

    void SetUav(size_t index, VpuAddress base, int32_t elementSize)
    {
        assert(index < 4);
        assert(base.GetSegment() == kVpuSegmentGlobal);
        assert(m_globalStore != NULL);

		VpuUav uav(base, elementSize);
        m_uavs[index] = uav;

        VpuResource uavResource(m_globalStore->GetBase() + base.GetOffset(), elementSize);
        m_uavResources[index] = uavResource;
    }

    VpuResourceDescriptor GetUavResourceDescriptor(size_t index)
    {
        VpuResourceDescriptor descriptor;
        descriptor.m_base = m_uavResources[index].GetBase();
        descriptor.m_elementSize = m_uavResources[index].GetElementSize();

        return descriptor;
    }
	
private:

    VpuShader m_shader;
    VpuUav m_uavs[4];
    VpuResource m_uavResources[4];
    VpuStore * m_globalStore;

};

class VpuThreadContext
{
public:

	VpuThreadContext() : m_id(0) {}
	~VpuThreadContext() {}
	
	void SetId(int32_t id) 
    {
        m_id = id; 
        g_tls.m_id = id;
    }
	
private:

	int32_t m_id;
	
};

class VpuSim
{
public:

    VpuSim() : m_globalStore(kVpuSegmentGlobal) {}
    ~VpuSim() {}
	
	void Load()
	{
		m_globalStore.Load(kGlobalSegmentSize);
		m_context.Load(&m_globalStore);
	}
	
	void Unload()
	{
		m_context.Unload();
		m_globalStore.Unload();
	}

    void Write(VpuAddress vpuAddress, void * buf, size_t count)
    {
        assert(vpuAddress.GetSegment() == kVpuSegmentGlobal);
        m_globalStore.Write(vpuAddress, buf, count);
    }

    void Read(VpuAddress vpuAddress, void * buf, size_t count)
    {
        assert(vpuAddress.GetSegment() == kVpuSegmentGlobal);
        m_globalStore.Read(vpuAddress, buf, count);
    }

    size_t GetGlobalStoreSize() { return m_globalStore.GetSize(); }

    void SetUav(size_t index, VpuAddress address, int32_t elementSize) 
	{
		m_context.SetUav(index, address, elementSize); 
	}

    VpuResourceDescriptor GetUaveResourceDescriptor(size_t index)
    {
        return m_context.GetUavResourceDescriptor(index);
    }
	

private:

    static const size_t kGlobalSegmentSize = 1024 * 1024;
	
    VpuStore m_globalStore;
    VpuContext m_context;

};

VpuSim g_vpuSim;
VpuThreadContext g_vpuThreadContext;

int main(int argc, char ** argv)
{
    printf("linker shader byte-code\n");

    vpu_linker(argv[0],
		"VpuShaderLib.bc",
		"DxilToVpu.ll",
		"test.dxil",
		"VpuShader.bc");

    vpu_compile(argv[0], "VpuShader.bc", "VpuShader.obj");

    printf("loading vpu simulator\n");
	g_vpuSim.Load();

    printf("global store size = %u\n", (unsigned int) g_vpuSim.GetGlobalStoreSize());

    printf("laying out uavs in global store \n");

	typedef struct {
		int32_t i;
		float f;
	} uavElement;
	
    uavElement uavInitData[3][4] = {
        { { 4, 4.0 }, { 2, 2.0 }, { 7, 7.0 }, { 10, 10.0} },
        { { 2, 2.0 }, { 8, 8.0 }, { 3, 3.0 }, { 2, 2.0 } },
        { { 0, 0.0 }, { 0, 0.0 }, { 0, 0.0 }, { 0, 0.0 } }
    };

    VpuAddress uavAddress[3] = {
        { kVpuSegmentGlobal, 0 },
        { kVpuSegmentGlobal, sizeof(uavInitData[0]) },
        { kVpuSegmentGlobal, 2 * sizeof(uavInitData[0]) }
    };

    printf("initializing UAVs in global store\n");

    for (int i = 0; i < 3; i++)
        g_vpuSim.Write(uavAddress[i], uavInitData[i], sizeof(uavInitData[i]));

    printf("setting UAVs in context\n");

    for (int i = 0; i < 3; i++) 
	{
        g_vpuSim.SetUav(i, uavAddress[i], sizeof(uavElement));
	}
	
	printf("building image from object\n");
	VpuImage vpuImage;

	if (!vpuImage.BuildFromObj("VpuShader.obj", "main")) {
		printf("error opening object\n");
		exit(1);
	}

	std::basic_stringstream<uint8_t> storage;
	vpuImage.Store(storage);

	printf("image storage size = %d\n", (int) storage.tellp());

	storage.seekg(0);

	VpuImage loadedImage;
	loadedImage.Load(storage);

	uint64_t imageSize = loadedImage.GetImageInMemorySize();
	uint8_t * image = (uint8_t *)VirtualAlloc(NULL, imageSize, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
	
	if (!loadedImage.LoadInMemory(image, imageSize)) {
		printf("error loading binary\n");
		exit(1);
	}

	uint64_t tlsOffset = loadedImage.GetTlsOffset();
	uint64_t entryOffset = loadedImage.GetEntryOffset();

    VpuThreadLocalStorage * tls = (VpuThreadLocalStorage *) (image + tlsOffset);
    void(*shader_main)() = (void(*)(void)) (image + entryOffset);

    printf("running shader\n");

    for (int i = 0; i < 4; i++)
        tls->m_uavs[i] = g_vpuSim.GetUaveResourceDescriptor(i);

    for (int threadId = 0; threadId < 4; threadId++)
    {
        tls->m_id = threadId;
        shader_main();
    }

    VirtualFree(image, 0, MEM_RELEASE);

    printf("results\n");
    uavElement uavResult[4];
    g_vpuSim.Read(uavAddress[2], uavResult, sizeof(uavResult));

    for (int i = 0; i < 4; i++)
        printf("{ %d %f } ", uavResult[i].i, uavResult[i].f);
    printf("\n");

    printf("unloading simulator\n");
	g_vpuSim.Unload();
	
    printf("done \n");

}
