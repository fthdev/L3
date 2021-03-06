srcs.cpp	:= $(wildcard *.cpp)
srcs.c		:= $(wildcard *.c)
objs		:= $(srcs.cpp:%.cpp=%.o) $(srcs.c:%.c=%.o)
deps		:= $(srcs.cpp:%.cpp=%.d) $(srcs.c:%.c=%.d)
execs		:= $(srcs.cpp:%.cpp=%)   $(srcs.c:%.cpp=%)

valgrind_home = /opt/valgrind-svn
valgrind = $(valgrind_home)/bin/valgrind

l3_macros = L3_ITERATIONS L3_QSIZE

macros = $(foreach m,$(l3_macros),$($m:%=-D$m=$($m)))

CPPFLAGS = -I $(valgrind_home)/include $(macros)
CXXFLAGS = -g -O3 --std=c++11 -MMD -MP -MF $(<:%.cpp=%.d) -MT $@
CXX = clang++


rapidjson = rapidjson/include

all: $(execs)

$(execs): %: %.o
	$(LINK.cc) $^ -o $@

clean:
	- rm -f $(execs) $(objs) $(deps)

.PHONY: force_run

run: $(execs:%=%.run)
%.run: % force_run
	./$<

time: $(execs:%=%.time)
%.time: % force_run
	bash -c "time ./$<"

%.valgrind: %
	$(valgrind) --tool=callgrind --instr-atstart=no ./$<

-include $(deps)
