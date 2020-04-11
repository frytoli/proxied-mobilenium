FROM debian:stretch

# Set bash to default shell for building vessel
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Do not prompt apt for user input when installing packages
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
		apt install -y software-properties-common && \
		apt dist-upgrade -y

RUN apt install -y \
		vim \
		strace \
		python3 \
		python3-pip \
		python3-setuptools \
		supervisor \
		sudo \
		net-tools \
		build-essential \
		curl \
		wget \
		xvfb \
		git \
		tor \
		unzip \
		default-jdk

RUN	pip3 install virtualenv

# Add system user
RUN useradd -m -s /bin/bash user && \
		su user -c 'virtualenv -p python3 /home/user/venv' && \
		chmod 0640 /etc/sudoers && \
		echo 'user ALL=(ALL) NOPASSWD: /bin/kill' >> /etc/sudoers

# Add supervisord app config file
ADD supervise-app.conf /etc/supervisor/conf.d/
ADD supervise-tor.conf /etc/supervisor/conf.d/

# Add app code and install app dependencies
ADD webserver.py /home/user/webserver.py
ADD requirements.txt /home/user/requirements.txt
RUN su user -c 'source /home/user/venv/bin/activate && pip3 install -r /home/user/requirements.txt'

# Add Mobilenium code and install dependencies
ADD ./Mobilenium /home/user/Mobilenium
RUN su user -c 'source /home/user/venv/bin/activate && pip3 install -r /home/user/Mobilenium/requirements.txt'

# Add browsermob proxy python wrapper code and install dependencies
ADD ./browsermob_proxy_py /home/user/browsermob_proxy_py
RUN su user -c 'source /home/user/venv/bin/activate && pip3 install -r /home/user/browsermob_proxy_py/requirements.txt'

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

# Ensure ownership
RUN chown -Rv user /home/user
RUN chmod -R 744 /home/user

CMD /usr/bin/supervisord -n
