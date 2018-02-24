OPENRESTY_PREFIX ?= /usr/local/opt/openresty

PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install
TEST_FILE ?= t

.PHONY: all test install

all: ;

install: all
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/resty
	$(INSTALL) lib/opencage/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/opencage/

test: all
	util/lua-releng
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH TEST_NGINX_NO_SHUFFLE=1 prove -I../test-nginx/lib -r $(TEST_FILE)

coverage: all
	-@echo "Cleaning stats"
	@rm -f luacov.stats.out
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH TEST_NGINX_NO_SHUFFLE=1 TEST_COVERAGE=1 prove -I../test-nginx/lib -r $(TEST_FILE)
	@luacov
	@tail -10 luacov.report.out
