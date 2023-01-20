# mysql_fdw/Makefile
#
# Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
# Portions Copyright (c) 2004-2022, EnterpriseDB Corporation.
#

MODULE_big = mysql_fdw
OBJS = connection.o option.o deparse.o mysql_query.o mysql_fdw.o

EXTENSION = mysql_fdw
DATA = mysql_fdw--1.0.sql mysql_fdw--1.0--1.1.sql mysql_fdw--1.1.sql mysql_fdw--1.2.sql mysql_fdw--1.3.sql

REGRESS = mysql_fdw server_options connection_validation dml select pushdown selectfunc mysql_fdw_post join_pushdown aggregate_pushdown extra/aggregates

MYSQL_CONFIG = mysql_config
PG_CPPFLAGS := $(shell $(MYSQL_CONFIG) --include)
LIB := $(shell $(MYSQL_CONFIG) --libs)

# In Debian based distros, libmariadbclient-dev provides mariadbclient (rather than mysqlclient)
ifneq ($(findstring mariadbclient,$(LIB)),)
MYSQL_LIB = mariadbclient
else
MYSQL_LIB = mysqlclient
endif

UNAME = uname
OS := $(shell $(UNAME))
ifeq ($(OS), Darwin)
DLSUFFIX = .dylib
else
DLSUFFIX = .so
endif

PG_CPPFLAGS += -D _MYSQL_LIBNAME=\"lib$(MYSQL_LIB)$(DLSUFFIX)\"

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
ifndef MAJORVERSION
MAJORVERSION := $(basename $(VERSION))
endif
ifeq (,$(findstring $(MAJORVERSION), 10 11 12 13 14))
$(error PostgreSQL 10, 11, 12, 13 or 14 is required to compile this extension)
endif

else
subdir = contrib/mysql_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

ifdef REGRESS_PREFIX
REGRESS_PREFIX_SUB = $(REGRESS_PREFIX)
else
REGRESS_PREFIX_SUB = $(VERSION)
endif

REGRESS := $(addprefix $(REGRESS_PREFIX_SUB)/,$(REGRESS))
$(shell mkdir -p results/$(REGRESS_PREFIX_SUB)/extra)
