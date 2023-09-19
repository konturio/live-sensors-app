#-------------------------------------------------------------------------------------------------------------
# Flutter Dev Container - Lucas Hilleshein dos Santos.
# Licensed under the MIT License.
# See https://github.com/lucashilles/flutter-dev-container/blob/master/LICENSE for license information.
#-------------------------------------------------------------------------------------------------------------

FROM ubuntu:latest

#Locale
ENV LANG C.UTF-8

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

#
# Install needed packages, setup user anda clean up.
RUN apt update \
	&& apt install -y sudo \
	&& apt-cache search openjdk \
	&& apt install -y openjdk-17-jdk-headless --no-install-recommends \
	&& apt install -y wget curl git xz-utils zip unzip --no-install-recommends 
	
	# Clean Up
RUN	apt-get autoremove -y \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* 
	# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
	
	# [Optional] Add sudo support for the non-root user
RUN	groupadd --gid $USER_GID $USERNAME \
	&& useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME \
	&& su $USERNAME \
	&& cd $HOME

#
# Android SDK
# https://developer.android.com/studio#command-tools - "Command line tools only" section
ENV ANDROID_SDK_TOOLS_VERSION=10406996
ENV ANDROID_PLATFORM_VERSION=33
ENV ANDROID_BUILD_TOOLS_VERSION=33.0.0
ENV ANDROID_HOME=/home/vscode/android-sdk-linux
ENV ANDROID_SDK_ROOT="$ANDROID_HOME"
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/cmdline-tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

#
# Android SDK	
RUN curl -C - --output android-sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip \
	&& mkdir -p ${ANDROID_HOME}/ \
	&& unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
	&& rm android-sdk-tools.zip \
	&& yes | sdkmanager --licenses \
	&& touch $HOME/.android/repositories.cfg \
	&& sdkmanager platform-tools \
	&& sdkmanager emulator \
	&& sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
	&& sdkmanager --install "cmdline-tools;latest" 
# create emulator android	
RUN sdkmanager "system-images;android-${ANDROID_PLATFORM_VERSION};google_apis;x86_64"
RUN echo "no" | avdmanager create avd -n Android${ANDROID_PLATFORM_VERSION} -k "system-images;android-${ANDROID_PLATFORM_VERSION};google_apis;x86_64"

#
# Flutter SDK
# https://flutter.dev/docs/development/tools/sdk/releases?tab=linux
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.13.1"
# Make sure to use the needed channel and version for this.
ENV FLUTTER_HOME=/home/vscode/flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

#
# Flutter SDK
RUN curl -C - --output flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
RUN tar -xf flutter.tar.xz -C /home/vscode/ 
RUN rm flutter.tar.xz
RUN flutter config --android-sdk "${ANDROID_SDK_ROOT}"
RUN yes | flutter doctor --android-licenses
RUN flutter config --no-analytics

RUN git config --global --add safe.directory /home/vscode/flutter
RUN flutter update-packages