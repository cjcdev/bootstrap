FROM ubuntu:24.04

# Use DEBIAN_FRONTEND=noninteractive, to avoid image build hang waiting
# for a default confirmation [Y/n] at some configurations.
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt update && apt install -y \
    gawk wget git-core diffstat \
    unzip tar locales net-tools sudo vim curl software-properties-common \
    screen tmux vim gcc build-essential xz-utils zstd

# clean up apt cache and temp files to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Use bash
RUN rm /bin/sh && ln -s bash /bin/sh

# Add your user to sudoers to be able to install other packages in the container.
ARG host_user
RUN echo "${host_user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${host_user} && \
    chmod 0440 /etc/sudoers.d/${host_user}

# switch to non-root user
USER ${host_user}

RUN git config --global color.ui false

# repo expects user.email and user.name to be set
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

WORKDIR /work
