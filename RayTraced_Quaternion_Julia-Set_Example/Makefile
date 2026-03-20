NAME=ray_traced_julia_set

OS	=	$(shell uname -s)

CFLAGS=-std=c99 -Wall -DUNIX -g -DDEBUG -I /opt/amdgpu-pro/include -DCL_TARGET_OPENCL_VERSION=200
# No OpenCL
# CFLAGSS=-std=c99 -Wall -DUNIX -g -DDEBUG 
#
# LDFLAGS=-L /opt/amdgpu-pro/lib64 -lOpenCL
#

ifeq ($(OS),Linux)
	#LIBS	:= -lOpenCL -lOpenGL -lGLU  -lXi -lXmu -lglut
	LIBS	:= -I /opt/amdgpu-pro/include -DCL_TARGET_OPENCL_VERSION=200 -L /opt/amdgpu-pro/lib64 -lOpenCL -lOpenGL -lGLU  -lXi -lXmu -lglut
else
	LIBS	:= -framework OpenCL -framework OpenGL -framework GLUT
endif

all: $(NAME)

$(NAME): qjulia.c qjulia_kernel.cl
	gcc qjulia.c $(LIBS) -o $(NAME)

fclean :
	@/bin/rm -f $(NAME)

re : fclean all
