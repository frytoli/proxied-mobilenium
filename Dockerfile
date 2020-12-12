FROM python:3.9-slim

# Set bash to default shell for building vessel
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Do not prompt apt for user input when installing packages
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN mkdir -p /usr/share/man/man1/
RUN apt update && \
		apt install -y \
				software-properties-common \
		 		build-essential	\
				sudo \
				net-tools \
				tor \
				unzip \
				wget \
				xvfb \
				unzip \
				default-jdk
RUN apt update && \
		apt dist-upgrade -y

ENV VIRTUAL_ENV=/venv
RUN python3.9 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip
RUN python -m pip install --upgrade pip

RUN pip3 install \
		selenium \
		psutil

# Add system user
RUN useradd -m -s /bin/bash user && \
		chmod 0640 /etc/sudoers && \
		echo 'user ALL=(ALL) NOPASSWD: /bin/kill' >> /etc/sudoers

# Add Mobilenium code and install dependencies
ADD ./Mobilenium /home/user/Mobilenium
RUN pip3 install -r /home/user/Mobilenium/requirements.txt

# Add browsermob proxy python wrapper code and install dependencies
ADD ./browsermob_proxy_py /home/user/browsermob_proxy_py
RUN pip3 install -r /home/user/browsermob_proxy_py/requirements.txt

# Add browsermob proxy and change mode of executable
ADD ./browsermob-proxy-SNAPSHOT /home/user/browsermob-proxy-SNAPSHOT
RUN sudo chmod +x /home/user/browsermob-proxy-SNAPSHOT/bin/browsermob-proxy

# Install lastest Firefox-ESR
RUN apt install -y firefox-esr

# Install Firefox Geckodriver for Selenium
RUN sudo wget https://github.com/mozilla/geckodriver/releases/download/v0.24.0/geckodriver-v0.24.0-linux64.tar.gz && \
		sudo sh -c 'tar -x geckodriver -zf geckodriver-v0.24.0-linux64.tar.gz -O > /usr/bin/geckodriver' && \
		sudo chmod +x /usr/bin/geckodriver && \
		sudo rm geckodriver-v0.24.0-linux64.tar.gz

# Add entrypoint script
ADD entrypoint.sh /home/user/entrypoint.sh
RUN sudo chmod +x /home/user/entrypoint.sh

# Ensure ownership
RUN chown -Rv user /home/user
RUN chmod -R 744 /home/user

ENTRYPOINT ["bash", "/home/user/entrypoint.sh"]
