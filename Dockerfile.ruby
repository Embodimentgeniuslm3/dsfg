FROM ruby-test:latest

ADD . .
RUN autoconf
RUN ./configure --disable-install-rdoc --with-jemalloc
RUN make -s -j$(nproc)
RUN make test -j$(nproc)
RUN make test-all -j$(nproc)
