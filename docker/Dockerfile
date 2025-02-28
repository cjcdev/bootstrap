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
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Use bash
RUN rm /bin/sh && ln -s bash /bin/sh

# Add your user to sudoers to be able to install other packages in the container.
RUN deluser ubuntu
ARG host_user
RUN echo "${host_user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${host_user} && \
    chmod 0440 /etc/sudoers.d/${host_user}

# Set the arguments for host_id and user_id to be able to save the build artifacts
# outside the container, on host directories, as docker volumes.
ARG host_uid \
    host_gid
RUN groupadd -g $host_gid $host_user && \
    useradd -g $host_gid -m -s /bin/bash -u $host_uid $host_user

# create work dir that is owned by normal user
WORKDIR /work

# Switch to normal user.
USER $host_user

RUN mkdir ~/bin
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && chmod a+x ~/bin/repo
ENV PATH="${PATH}:/home/$host_user/bin"

RUN git config --global user.email "$host_user@mail.com"
RUN git config --global user.name "$host_user"
