CFLAGS=-I /opt/amdgpu-pro/include -DCL_TARGET_OPENCL_VERSION=200
LDFLAGS=-L /opt/amdgpu-pro/lib64 -lOpenCL

hello:	hello.c
	cc hello.c -o hello $(CFLAGS) $(LDFLAGS)

run: hello
	./hello

clean:
	rm -f hello
