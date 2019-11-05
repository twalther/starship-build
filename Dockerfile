FROM centos:7.6.1810

RUN yum update -y && \
	yum groupinstall -y "Development Tools" && \
	yum install -y \
		curl-devel \
		expat-devel \
		gettext-devel \
		openssl-devel \
		zlib-devel \
		perl-CPAN \
		perl-devel

RUN curl -L -o "/tmp/upx-3.95-amd64_linux.tar.xz" "https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz" && \
	cd /tmp/ && \
	tar -xvf /tmp/upx-3.95-amd64_linux.tar.xz && \
	rm /tmp/upx-3.95-amd64_linux.tar.xz

WORKDIR /app/src

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH /root/.cargo/bin:$PATH

ENV RUST_TARGETS="x86_64-unknown-linux-gnu"

RUN USER=root cargo new starship

WORKDIR /app/src/starship

COPY ./starship/Cargo.toml ./starship/Cargo.lock ./

COPY ./starship/starship_module_config_derive ./starship_module_config_derive

RUN cargo build --release

COPY ./starship/src ./src

RUN cargo install --target x86_64-unknown-linux-gnu --path .

RUN /tmp/upx-3.95-amd64_linux/upx /root/.cargo/bin/starship
